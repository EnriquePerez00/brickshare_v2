import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const SWIKLY_ACCOUNT_ID = Deno.env.get("SWIKLY_ACCOUNT_ID") ?? "";
const SWIKLY_SECRET_KEY = Deno.env.get("SWIKLY_SECRET_KEY") ?? "";
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
    const { assignment_id, action } = await req.json();

    if (!assignment_id) throw new Error("assignment_id is required");
    if (!["release", "capture"].includes(action)) {
      throw new Error("action must be 'release' or 'capture'");
    }

    // ── Fetch assignment ────────────────────────────────────────────────────
    const { data: assignment, error: aErr } = await supabase
      .from("assignments")
      .select(
        `id, user_id, swikly_wish_id, swikly_status, swikly_deposit_amount,
         sets (name, lego_ref),
         profiles (full_name, email)`
      )
      .eq("id", assignment_id)
      .single();

    if (aErr || !assignment) throw new Error("Assignment not found");

    const wishId = assignment.swikly_wish_id;
    if (!wishId) throw new Error("No Swikly wish_id for this assignment");

    if (assignment.swikly_status !== "accepted") {
      throw new Error(
        `Cannot ${action} a wish in status '${assignment.swikly_status}'`
      );
    }

    // ── Call Swikly API ─────────────────────────────────────────────────────
    // POST /wishes/{wish_id}/release  or  POST /wishes/{wish_id}/capture
    const bodyString = JSON.stringify({});
    const signature = buildSwiklySignature(bodyString);

    const swiklyRes = await fetch(
      `${SWIKLY_API}/wishes/${wishId}/${action}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Api-Key": SWIKLY_ACCOUNT_ID,
          "X-Api-Sig": signature,
        },
        body: bodyString,
      }
    );

    const swiklyData = await swiklyRes.json();
    console.log(`Swikly ${action} response:`, JSON.stringify(swiklyData));

    if (!swiklyRes.ok) {
      throw new Error(
        `Swikly API error ${swiklyRes.status}: ${JSON.stringify(swiklyData)}`
      );
    }

    // ── Update DB ───────────────────────────────────────────────────────────
    const newStatus = action === "release" ? "released" : "captured";
    await supabase
      .from("assignments")
      .update({ swikly_status: newStatus })
      .eq("id", assignment_id);

    // ── Send email notification to user ─────────────────────────────────────
    let userEmail: string = (assignment.profiles as any)?.email ?? "";
    if (!userEmail) {
      const { data: authUser } = await supabase.auth.admin.getUserById(
        assignment.user_id
      );
      userEmail = authUser?.user?.email ?? "";
    }

    const set = assignment.sets as any;
    const depositEur = ((assignment.swikly_deposit_amount ?? 0) / 100).toFixed(2);

    if (userEmail) {
      const emailType =
        action === "release" ? "swikly_deposit_released" : "swikly_deposit_captured";
      await sendEmail(emailType, userEmail, {
        name: (assignment.profiles as any)?.full_name ?? "Cliente",
        set_name: set?.name ?? "",
        deposit_amount: depositEur,
      });
    }

    return new Response(
      JSON.stringify({ success: true, new_status: newStatus }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("swikly-manage-wish error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});