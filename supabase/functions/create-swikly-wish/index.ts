import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const SWIKLY_ACCOUNT_ID = Deno.env.get("SWIKLY_ACCOUNT_ID") ?? "";
const SWIKLY_SECRET_KEY = Deno.env.get("SWIKLY_SECRET_KEY") ?? "";
const APP_URL = Deno.env.get("APP_URL") ?? "https://brickshare.es";

// Swikly base URL
const SWIKLY_API = "https://api.v2.swikly.com/v1";

// Build HMAC-SHA256 signature from the request body string
function buildSwiklySignature(body: string): string {
  return hmac("sha256", SWIKLY_SECRET_KEY, body, "utf8", "hex") as string;
}

// Helper: call the send-email function
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
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const { assignment_id, force } = await req.json();
    if (!assignment_id) throw new Error("assignment_id is required");

    // ── 1. Fetch assignment with set and profile data ─────────────────────────
    const { data: assignment, error: aErr } = await supabase
      .from("assignments")
      .select(
        `
        id, set_id, user_id, swikly_status, swikly_wish_url, swikly_deposit_amount,
        sets (name, lego_ref, retail_price),
        profiles (full_name, email)
      `
      )
      .eq("id", assignment_id)
      .single();

    if (aErr || !assignment) throw new Error("Assignment not found");

    // Avoid creating duplicates unless force=true (re-send)
    if (assignment.swikly_status !== "pending" && !force) {
      console.log(
        `Swikly wish already created for assignment ${assignment_id} (status: ${assignment.swikly_status})`
      );
      // If wish_url exists, re-send preparatory email without creating a new wish
      if (assignment.swikly_status === "wish_created") {
        const wishUrl = (assignment as any).swikly_wish_url ?? "";
        let userEmail: string = (assignment.profiles as any)?.email ?? "";
        if (!userEmail) {
          const { data: authUser } = await supabase.auth.admin.getUserById(assignment.user_id);
          userEmail = authUser?.user?.email ?? "";
        }
        if (userEmail) {
          await sendEmail("swikly_wish_created", userEmail, {
            name: (assignment.profiles as any)?.full_name ?? "Cliente",
            set_name: (assignment.sets as any)?.name ?? "",
            set_ref: (assignment.sets as any)?.lego_ref ?? "",
            deposit_amount: (((assignment as any).swikly_deposit_amount ?? 0) / 100).toFixed(2),
            wish_url: wishUrl,
          });
        }
      }
      return new Response(
        JSON.stringify({ success: true, skipped: true }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 2. Resolve user email (profiles may not store email directly) ─────────
    let userEmail: string = (assignment.profiles as any)?.email ?? "";
    if (!userEmail) {
      const { data: authUser } = await supabase.auth.admin.getUserById(
        assignment.user_id
      );
      userEmail = authUser?.user?.email ?? "";
    }
    if (!userEmail) throw new Error("Could not resolve user email");

    const userName: string =
      (assignment.profiles as any)?.full_name ?? "Cliente";
    const set = assignment.sets as any;
    const setName: string = set?.name ?? "Set LEGO";
    const retailPriceCents: number = Math.round((set?.retail_price ?? 0) * 100);

    if (retailPriceCents <= 0) {
      throw new Error(
        `Invalid retail price for set ${set?.lego_ref}: €${set?.retail_price}`
      );
    }

    // ── 3. Build Swikly wish payload ──────────────────────────────────────────
    // Rental period: starts today, ends 90 days from now (adjustable)
    const today = new Date();
    const endDate = new Date(today);
    endDate.setDate(endDate.getDate() + 90);
    const fmt = (d: Date) => d.toISOString().slice(0, 10); // YYYY-MM-DD

    const callbackUrl = `${SUPABASE_URL}/functions/v1/swikly-webhook`;

    const wishPayload = {
      amount: retailPriceCents,
      currency: "EUR",
      description: `Fianza LEGO ${set?.lego_ref ?? ""} - ${setName} · Brickshare`,
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

    // ── 4. Call Swikly API ────────────────────────────────────────────────────
    console.log(`Creating Swikly wish for assignment ${assignment_id} — €${retailPriceCents / 100}`);

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

    const wishId: string = swiklyData.id ?? swiklyData.wish_id ?? swiklyData.data?.id;
    const wishUrl: string =
      swiklyData.url ??
      swiklyData.wish_url ??
      swiklyData.data?.url ??
      swiklyData.link ??
      "";

    if (!wishId) throw new Error("Swikly did not return a wish ID");

    // ── 5. Persist wish info to assignment ────────────────────────────────────
    const { error: updErr } = await supabase
      .from("assignments")
      .update({
        swikly_wish_id: wishId,
        swikly_wish_url: wishUrl,
        swikly_status: "wish_created",
        swikly_deposit_amount: retailPriceCents,
      })
      .eq("id", assignment_id);

    if (updErr) throw new Error(`DB update failed: ${updErr.message}`);

    // ── 6. Send preparatory email to user ─────────────────────────────────────
    await sendEmail("swikly_wish_created", userEmail, {
      name: userName,
      set_name: setName,
      set_ref: set?.lego_ref ?? "",
      deposit_amount: (retailPriceCents / 100).toFixed(2),
      wish_url: wishUrl,
    });

    console.log(`Swikly wish ${wishId} created and email sent to ${userEmail}`);

    return new Response(
      JSON.stringify({ success: true, wish_id: wishId, wish_url: wishUrl }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("create-swikly-wish error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});