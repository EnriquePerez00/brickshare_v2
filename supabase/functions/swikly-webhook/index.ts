import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const SWIKLY_WEBHOOK_SECRET = Deno.env.get("SWIKLY_WEBHOOK_SECRET") ?? "";

console.log("[Swikly Webhook] Initialized (API V2)");

// ✅ FASE 2: Verificar firma V2 de Swikly
// Formato: t=<timestamp>,sha256=<hash>
// Payload: <timestamp>.<raw_body>
async function verifySwiklySignatureV2(
  signatureHeader: string,
  rawBody: string
): Promise<boolean> {
  try {
    // Parse: "t=1739352941,sha256=7244dc6a957d9583516a170ff07242499e58e74da34afd732a60f900e8e162e1"
    const parts = signatureHeader.split(",");
    const tPart = parts.find((p) => p.startsWith("t="));
    const sha256Part = parts.find((p) => p.startsWith("sha256="));

    if (!tPart || !sha256Part) {
      console.error("[Swikly Webhook] Invalid signature format");
      return false;
    }

    const timestamp = tPart.replace("t=", "");
    const providedHash = sha256Part.replace("sha256=", "");

    // Construct payload: timestamp.body
    const payload = `${timestamp}.${rawBody}`;

    // Compute HMAC-SHA256 using Web Crypto API
    const encoder = new TextEncoder();
    const keyData = encoder.encode(SWIKLY_WEBHOOK_SECRET);
    const messageData = encoder.encode(payload);

    const key = await crypto.subtle.importKey(
      "raw",
      keyData,
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const signature = await crypto.subtle.sign("HMAC", key, messageData);

    const computedHash = Array.from(new Uint8Array(signature))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");

    const isValid = computedHash === providedHash;
    console.log(
      `[Swikly Webhook] Signature verification: ${isValid ? "✅ Valid" : "❌ Invalid"}`
    );
    if (!isValid) {
      console.log(`  Expected: ${providedHash}`);
      console.log(`  Computed: ${computedHash}`);
    }
    return isValid;
  } catch (err) {
    console.error("[Swikly Webhook] Error verifying signature:", err);
    return false;
  }
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
    console.error("[Swikly Webhook] send-email error:", e);
  }
}

serve(async (req) => {
  // Swikly sends POST callbacks
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const rawBody = await req.text();

  try {
    // ✅ FASE 2: Verificar firma V2 de Swikly
    const signatureHeader = req.headers.get("Swikly-Signature") || "";

    console.log(
      `[Swikly Webhook] Received webhook, signature: ${signatureHeader.substring(0, 30)}...`
    );

    if (!signatureHeader) {
      console.error("[Swikly Webhook] No Swikly-Signature header found");
      return new Response(JSON.stringify({ error: "No signature provided" }), {
        status: 401,
      });
    }

    // Verify signature
    const isValid = await verifySwiklySignatureV2(signatureHeader, rawBody);
    if (!isValid) {
      console.error("[Swikly Webhook] Invalid signature, rejecting");
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 401,
      });
    }

    let payload: any;
    try {
      payload = JSON.parse(rawBody);
    } catch {
      return new Response("Invalid JSON", { status: 400 });
    }

    console.log("[Swikly Webhook] ✅ Signature verified, processing payload");
    console.log("[Swikly Webhook] Payload:", JSON.stringify(payload, null, 2));

    // ── Parse Swikly V2 event ────────────────────────────────────────────────
    // API V2 sends request object with nested deposit status
    const requestId: string = payload.id;
    const requestStatus: string = payload.status; // "Pending", "Secured", "Canceled", "Expired"
    const depositStatus: string = payload.deposit?.status; // "Pending", "Secured", "Released", "Canceled"

    if (!requestId) {
      console.error("[Swikly Webhook] No request ID in webhook payload");
      return new Response("Missing request ID", { status: 400 });
    }

    console.log(
      `[Swikly Webhook] Request ID: ${requestId}, Request Status: ${requestStatus}, Deposit Status: ${depositStatus}`
    );

    // ── Map Swikly V2 status to our internal swikly_status ──────────────────
    let newStatus: string | null = null;

    if (requestStatus === "Secured" && depositStatus === "Secured") {
      newStatus = "accepted";
      console.log("[Swikly Webhook] Deposit secured by user → 'accepted'");
    } else if (requestStatus === "Canceled") {
      newStatus = "cancelled";
      console.log("[Swikly Webhook] Request cancelled → 'cancelled'");
    } else if (requestStatus === "Expired") {
      newStatus = "expired";
      console.log("[Swikly Webhook] Request expired → 'expired'");
    } else if (depositStatus === "Released") {
      newStatus = "released";
      console.log("[Swikly Webhook] Deposit released → 'released'");
    } else {
      console.log(
        `[Swikly Webhook] Unhandled status combination: ${requestStatus} / ${depositStatus}`
      );
      return new Response(JSON.stringify({ received: true }), { status: 200 });
    }

    if (!newStatus) {
      console.log("[Swikly Webhook] No status mapping found");
      return new Response(JSON.stringify({ received: true }), { status: 200 });
    }

    // ── Find the shipment by swikly_wish_id ──────────────────────────────────
    console.log(
      `[Swikly Webhook] Looking for shipment with wish_id: ${requestId}`
    );
    const { data: shipment, error: findErr } = await supabase
      .from("shipments")
      .select("id, user_id, set_ref, swikly_status, swikly_deposit_amount")
      .eq("swikly_wish_id", requestId)
      .single();

    if (findErr || !shipment) {
      console.error(
        "[Swikly Webhook] Shipment not found for request_id:",
        requestId,
        findErr?.message
      );
      return new Response("Shipment not found", { status: 404 });
    }

    console.log(
      `[Swikly Webhook] Found shipment ${shipment.id} (current status: ${shipment.swikly_status})`
    );

    // Skip if status unchanged
    if (newStatus === shipment.swikly_status) {
      console.log(`[Swikly Webhook] Status unchanged (${newStatus}), skipping update`);
      return new Response(
        JSON.stringify({ received: true, updated: false }),
        { status: 200 }
      );
    }

    // ── Update swikly_status in shipments ────────────────────────────────────
    console.log(
      `[Swikly Webhook] Updating shipment ${shipment.id}: ${shipment.swikly_status} → ${newStatus}`
    );
    const { error: updErr } = await supabase
      .from("shipments")
      .update({ swikly_status: newStatus })
      .eq("id", shipment.id);

    if (updErr) {
      console.error(
        `[Swikly Webhook] Failed to update shipment ${shipment.id}:`,
        updErr.message
      );
      return new Response("DB update failed", { status: 500 });
    }

    console.log(`[Swikly Webhook] ✅ Updated shipment ${shipment.id} to '${newStatus}'`);

    // ── Resolve user email and name ──────────────────────────────────────────
    const { data: userProfile } = await supabase
      .from("users")
      .select("full_name, email")
      .eq("id", shipment.user_id)
      .maybeSingle();

    let userEmail: string = userProfile?.email ?? "";
    if (!userEmail) {
      const { data: authUser } = await supabase.auth.admin.getUserById(
        shipment.user_id
      );
      userEmail = authUser?.user?.email ?? "";
    }

    const userName: string = userProfile?.full_name ?? "Cliente";

    // ── Get set info for email context ───────────────────────────────────────
    const { data: setData } = await supabase
      .from("sets")
      .select("set_name, set_ref")
      .eq("set_ref", shipment.set_ref)
      .maybeSingle();

    const setName = setData?.set_name ?? shipment.set_ref ?? "";
    const setRef = setData?.set_ref ?? shipment.set_ref ?? "";
    const depositEur = ((shipment.swikly_deposit_amount ?? 0) / 100).toFixed(2);

    // ── Send email based on new status ───────────────────────────────────────
    if (newStatus === "accepted" && userEmail) {
      console.log(
        `[Swikly Webhook] Sending 'deposit accepted' email to ${userEmail}`
      );
      await sendEmail("swikly_deposit_confirmed", userEmail, {
        name: userName,
        set_name: setName,
        set_ref: setRef,
        deposit_amount: depositEur,
      });
    }

    if (newStatus === "released" && userEmail) {
      console.log(
        `[Swikly Webhook] Sending 'deposit released' email to ${userEmail}`
      );
      await sendEmail("swikly_deposit_released", userEmail, {
        name: userName,
        set_name: setName,
        set_ref: setRef,
        deposit_amount: depositEur,
      });
    }

    if (newStatus === "cancelled" && userEmail) {
      console.log(
        `[Swikly Webhook] Sending 'deposit cancelled' email to ${userEmail}`
      );
      await sendEmail("swikly_deposit_cancelled", userEmail, {
        name: userName,
        set_name: setName,
        set_ref: setRef,
        deposit_amount: depositEur,
      });
    }

    return new Response(
      JSON.stringify({ received: true, new_status: newStatus, updated: true }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("[Swikly Webhook] ❌ Error:", err.message);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});