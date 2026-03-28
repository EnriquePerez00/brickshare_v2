import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const SWIKLY_ACCOUNT_ID = Deno.env.get("SWIKLY_ACCOUNT_ID") ?? "";
const SWIKLY_SECRET_KEY = Deno.env.get("SWIKLY_SECRET_KEY") ?? "";
const APP_URL = Deno.env.get("APP_URL") ?? "https://brickshare.es";

const SWIKLY_API = "https://api.v2.swikly.com/v1";

function buildSwiklySignature(body: string): string {
  return hmac("sha256", SWIKLY_SECRET_KEY, body, "utf8", "hex") as string;
}

async function sendEmail(
  type: string,
  to: string,
  data: Record<string, string | number | undefined>
) {
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

serve(async (req) => {
  const origin = req.headers.get("origin") || "";
  const corsHeaders = {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Credentials": "true",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const { shipment_id } = await req.json();
    if (!shipment_id) throw new Error("shipment_id is required");

    // ── 1. Fetch shipment with user data ──────────────────────────────────────
    const { data: shipment, error: sErr } = await supabase
      .from("shipments")
      .select(`
        id, user_id, set_ref, pudo_type,
        swikly_wish_id, swikly_status, swikly_deposit_amount
      `)
      .eq("id", shipment_id)
      .single();

    if (sErr || !shipment) throw new Error("Shipment not found");

    // ── 2. Skip if already created (idempotent) ──────────────────────────────
    if (shipment.swikly_wish_id && shipment.swikly_status !== "pending") {
      console.log(
        `Swikly wish already exists for shipment ${shipment_id} (status: ${shipment.swikly_status})`
      );
      return new Response(
        JSON.stringify({
          success: true,
          skipped: true,
          wish_id: shipment.swikly_wish_id,
          swikly_status: shipment.swikly_status,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 3. Get set_pvp_release from sets table using set_ref ─────────────────
    const { data: setData, error: setErr } = await supabase
      .from("sets")
      .select("set_name, set_ref, set_pvp_release")
      .eq("set_ref", shipment.set_ref)
      .maybeSingle();

    if (setErr) throw new Error(`Error fetching set: ${setErr.message}`);
    if (!setData) throw new Error(`Set not found for set_ref: ${shipment.set_ref}`);

    const depositEur = setData.set_pvp_release;
    if (!depositEur || depositEur <= 0) {
      throw new Error(
        `set_pvp_release is missing or invalid for set ${setData.set_ref}: €${depositEur}`
      );
    }

    const depositCents = Math.round(depositEur * 100);

    // ── 4. Resolve user email and name ────────────────────────────────────────
    const { data: userProfile, error: uErr } = await supabase
      .from("users")
      .select("full_name, email")
      .eq("id", shipment.user_id)
      .maybeSingle();

    let userEmail = userProfile?.email ?? "";
    if (!userEmail) {
      const { data: authUser } = await supabase.auth.admin.getUserById(shipment.user_id);
      userEmail = authUser?.user?.email ?? "";
    }
    if (!userEmail) throw new Error("Could not resolve user email");

    const userName = userProfile?.full_name ?? "Cliente";

    // ── 5. Build Swikly wish payload ──────────────────────────────────────────
    const today = new Date();
    const endDate = new Date(today);
    endDate.setDate(endDate.getDate() + 90);
    const fmt = (d: Date) => d.toISOString().slice(0, 10);

    const callbackUrl = `${SUPABASE_URL}/functions/v1/swikly-webhook`;

    const wishPayload = {
      amount: depositCents,
      currency: "EUR",
      description: `Fianza LEGO ${setData.set_ref} - ${setData.set_name} · Brickshare`,
      wishee_email: userEmail,
      wishee_firstname: userName.split(" ")[0],
      wishee_lastname: userName.split(" ").slice(1).join(" ") || userName,
      start_date: fmt(today),
      end_date: fmt(endDate),
      callback_url: callbackUrl,
      success_url: `${APP_URL}/dashboard?deposit=confirmed`,
      cancel_url: `${APP_URL}/dashboard?deposit=cancelled`,
    };

    const bodyString = JSON.stringify(wishPayload);
    const signature = buildSwiklySignature(bodyString);

    // ── 6. Call Swikly API ────────────────────────────────────────────────────
    console.log(
      `Creating Swikly wish for shipment ${shipment_id} — set ${setData.set_ref} — €${depositEur}`
    );

    const swiklyRes = await fetch(`${SWIKLY_API}/wishes`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Api-Key": SWIKLY_ACCOUNT_ID,
        "X-Api-Sig": signature,
      },
      body: bodyString,
    });

    const swiklyData = await swiklyRes.json();
    console.log("Swikly response:", JSON.stringify(swiklyData));

    if (!swiklyRes.ok) {
      throw new Error(
        `Swikly API error ${swiklyRes.status}: ${JSON.stringify(swiklyData)}`
      );
    }

    const wishId: string =
      swiklyData.id ?? swiklyData.wish_id ?? swiklyData.data?.id;
    const wishUrl: string =
      swiklyData.url ??
      swiklyData.wish_url ??
      swiklyData.data?.url ??
      swiklyData.link ??
      "";

    if (!wishId) throw new Error("Swikly did not return a wish ID");

    // ── 7. Persist wish info to shipment ──────────────────────────────────────
    const { error: updErr } = await supabase
      .from("shipments")
      .update({
        swikly_wish_id: wishId,
        swikly_wish_url: wishUrl,
        swikly_status: "wish_created",
        swikly_deposit_amount: depositCents,
      })
      .eq("id", shipment_id);

    if (updErr) throw new Error(`DB update failed: ${updErr.message}`);

    // ── 8. Send notification email to user ────────────────────────────────────
    await sendEmail("swikly_wish_created", userEmail, {
      name: userName,
      set_name: setData.set_name,
      set_ref: setData.set_ref,
      deposit_amount: (depositCents / 100).toFixed(2),
      wish_url: wishUrl,
    });

    console.log(`Swikly wish ${wishId} created for shipment ${shipment_id} and email sent to ${userEmail}`);

    return new Response(
      JSON.stringify({
        success: true,
        wish_id: wishId,
        wish_url: wishUrl,
        deposit_amount: depositCents,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("create-swikly-wish-shipment error:", err);
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});