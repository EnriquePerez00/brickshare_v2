import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@11.1.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2022-11-15",
  httpClient: Stripe.createFetchHttpClient(),
});

const cryptoProvider = Stripe.createSubtleCryptoProvider();

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// ─── Helper: send transactional email via the send-email edge function ────────
async function sendEmail(type: string, to: string, data: Record<string, string | number | undefined>) {
  try {
    await fetch(`${SUPABASE_URL}/functions/v1/send-email`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ type, to, data }),
    });
  } catch (e) {
    console.error("send-email error:", e);
  }
}

// ─── Helper: process referral credit when subscription goes active ────────────
async function processReferralCredit(
  supabase: ReturnType<typeof createClient>,
  userId: string
) {
  // Find pending referral where this user is the referee
  const { data: referral, error } = await supabase
    .from("referrals")
    .select("id, referrer_id, reward_credits")
    .eq("referee_id", userId)
    .eq("status", "pending")
    .maybeSingle();

  if (error || !referral) return;

  // Credit the referrer
  const { data: referrer } = await supabase
    .from("users")
    .select("id, full_name, email:id")
    .eq("id", referral.referrer_id)
    .maybeSingle();

  // Increment referral_credits on referrer profile
  await supabase.rpc("increment_referral_credits", {
    p_user_id: referral.referrer_id,
    p_amount: referral.reward_credits ?? 1,
  });

  // Also give referee 1 credit (first month free)
  await supabase.rpc("increment_referral_credits", {
    p_user_id: userId,
    p_amount: 1,
  });

  // Mark referral as credited
  await supabase
    .from("referrals")
    .update({ status: "credited", credited_at: new Date().toISOString() })
    .eq("id", referral.id);

  console.log(`Referral ${referral.id} credited — referrer ${referral.referrer_id}`);

  // Notify referrer by email
  if (referrer) {
    const { data: referrerProfile } = await supabase
      .from("users")
      .select("full_name")
      .eq("id", referral.referrer_id)
      .maybeSingle();

    const { data: refereeProfile } = await supabase
      .from("users")
      .select("full_name")
      .eq("id", userId)
      .maybeSingle();

    // Get referrer email from auth.users via service role
    const { data: referrerAuth } = await supabase.auth.admin.getUserById(referral.referrer_id);
    if (referrerAuth?.user?.email) {
      await sendEmail("referral_credited", referrerAuth.user.email, {
        name: referrerProfile?.full_name ?? "",
        referee_name: refereeProfile?.full_name ?? "un amigo",
      });
    }
  }
}

// ─── Main webhook handler ─────────────────────────────────────────────────────
serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("No signature", { status: 400 });

  try {
    const body = await req.text();
    const endpointSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
    if (!endpointSecret) {
      console.error("STRIPE_WEBHOOK_SECRET is not configured");
      return new Response("Webhook secret not configured", { status: 500 });
    }

    const event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      endpointSecret,
      undefined,
      cryptoProvider
    );

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    console.log(`Stripe event: ${event.type}`);

    switch (event.type) {
      // ── Subscription payment confirmed ─────────────────────────────────────
      case "invoice.paid": {
        const invoice = event.data.object as any;
        const subscriptionId = invoice.subscription;
        const customerId = invoice.customer;

        const subscription = await stripe.subscriptions.retrieve(subscriptionId);
        const plan = subscription.metadata?.plan;
        const userId = subscription.metadata?.user_id;
        const isFirstInvoice = invoice.billing_reason === "subscription_create";

        console.log(`Invoice paid — customer ${customerId}, user ${userId}, plan ${plan}`);

        if (customerId) {
          const updateData: Record<string, string> = {
            subscription_status: "active",
            subscription_id: subscriptionId,
          };
          if (plan) updateData.subscription_type = plan;

          // Update users (not legacy "users" table)
          const { error } = await supabase
            .from("users")
            .update(updateData)
            .eq("stripe_customer_id", customerId);

          if (error) {
            console.error("DB update error:", error);
            throw error;
          }
        }

        // Process referral credits only on the very first invoice
        if (userId && isFirstInvoice) {
          await processReferralCredit(supabase, userId);

          // Send subscription_activated email
          const { data: authUser } = await supabase.auth.admin.getUserById(userId);
          const { data: profile } = await supabase
            .from("users")
            .select("full_name, correos_name")
            .eq("id", userId)
            .maybeSingle();

          if (authUser?.user?.email) {
            await sendEmail("subscription_activated", authUser.user.email, {
              name: profile?.full_name ?? "",
              plan: plan ?? "Estándar",
              pudo_name: profile?.correos_name ?? undefined,
            });
          }
        }
        break;
      }

      // ── One-off payment (logistics fee = 10 EUR) ───────────────────────────
      case "payment_intent.succeeded": {
        const pi = event.data.object as any;
        const userId = pi.metadata?.user_id;
        const orderType = pi.metadata?.order_type;
        const assignmentId = pi.metadata?.assignment_id;
        console.log(`PaymentIntent succeeded — user ${userId}, type ${orderType}, assignment ${assignmentId}`);

        // Trigger Swikly deposit request after logistics fee is paid
        if (
          (orderType === "logistics_fee" || pi.metadata?.type === "logistics_fee") &&
          assignmentId
        ) {
          console.log(`Triggering Swikly wish for assignment ${assignmentId}`);
          try {
            const swiklyRes = await fetch(
              `${SUPABASE_URL}/functions/v1/create-swikly-wish`,
              {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
                },
                body: JSON.stringify({ assignment_id: assignmentId }),
              }
            );
            const swiklyData = await swiklyRes.json();
            if (!swiklyRes.ok) {
              console.error("create-swikly-wish failed:", swiklyData);
            } else {
              console.log("Swikly wish created:", swiklyData.wish_id);
            }
          } catch (e) {
            console.error("Error calling create-swikly-wish:", e);
          }

          // Mark assignment payment as paid
          await supabase
            .from("assignments")
            .update({ payment_status: "paid" })
            .eq("id", assignmentId);

          // Notify user of payment confirmation
          if (userId) {
            const { data: authUser } = await supabase.auth.admin.getUserById(userId);
            const { data: profile } = await supabase
              .from("users")
              .select("full_name")
              .eq("id", userId)
              .maybeSingle();

            const { data: assignment } = await supabase
              .from("assignments")
              .select("sets (name, lego_ref)")
              .eq("id", assignmentId)
              .maybeSingle();

            if (authUser?.user?.email) {
              await sendEmail("payment_confirmed", authUser.user.email, {
                name: profile?.full_name ?? "",
                set_name: (assignment?.sets as any)?.name ?? "",
                set_ref: (assignment?.sets as any)?.lego_ref ?? "",
              });
            }
          }
        }
        break;
      }

      // ── Subscription cancelled ─────────────────────────────────────────────
      case "customer.subscription.deleted": {
        const sub = event.data.object as any;
        const customerId = sub.customer;
        console.log(`Subscription deleted — customer ${customerId}`);

        if (customerId) {
          const { error } = await supabase
            .from("users")
            .update({ subscription_status: "canceled", subscription_type: "none" })
            .eq("stripe_customer_id", customerId);

          if (error) throw error;
        }
        break;
      }

      // ── Subscription updated (plan change) ────────────────────────────────
      case "customer.subscription.updated": {
        const sub = event.data.object as any;
        const customerId = sub.customer;
        const plan = sub.metadata?.plan;
        console.log(`Subscription updated — customer ${customerId}, plan ${plan}`);

        if (customerId) {
          const updateData: Record<string, string> = { subscription_status: sub.status };
          if (plan) updateData.subscription_type = plan;

          await supabase
            .from("users")
            .update(updateData)
            .eq("stripe_customer_id", customerId);
        }
        break;
      }

      default:
        console.log(`Unhandled event: ${event.type}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err: any) {
    console.error(`Webhook Error: ${err.message}`);
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }
});