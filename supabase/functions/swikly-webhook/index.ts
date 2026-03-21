import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const SWIKLY_SECRET_KEY = Deno.env.get("SWIKLY_SECRET_KEY") ?? "";

function verifySwiklySignature(body: string, receivedSig: string): boolean {
  const expected = hmac("sha256", SWIKLY_SECRET_KEY, body, "utf8", "hex") as string;
  return expected === receivedSig;
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
  // Swikly sends POST callbacks; respond 200 quickly
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const rawBody = await req.text();

  // ── Verify Swikly signature (X-Api-Sig header) ────────────────────────────
  const receivedSig = req.headers.get("X-Api-Sig") ?? req.headers.get("x-api-sig") ?? "";
  if (SWIKLY_SECRET_KEY && receivedSig) {
    if (!verifySwiklySignature(rawBody, receivedSig)) {
      console.error("Invalid Swikly webhook signature");
      return new Response("Invalid signature", { status: 401 });
    }
  } else {
    console.warn("Swikly signature not verified — missing secret or header");
  }

  let payload: any;
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  console.log("Swikly webhook payload:", JSON.stringify(payload));

  // ── Parse Swikly event ────────────────────────────────────────────────────
  // Swikly sends: { wish_id, status, amount, currency, ... }
  const wishId: string = payload.wish_id ?? payload.id ?? payload.data?.wish_id;
  const swiklyEvent: string = payload.status ?? payload.event ?? payload.data?.status ?? "";

  if (!wishId) {
    console.error("No wish_id in Swikly callback");
    return new Response("Missing wish_id", { status: 400 });
  }

  // ── Map Swikly status to our internal swikly_status ───────────────────────
  // Swikly possible statuses: accepted, declined, cancelled, expired, released, captured
  const statusMap: Record<string, string> = {
    accepted: "accepted",
    confirmed: "accepted",   // some API versions use 'confirmed'
    declined: "cancelled",
    cancelled: "cancelled",
    canceled: "cancelled",
    expired: "expired",
    released: "released",
    release: "released",
    captured: "captured",
    capture: "captured",
  };

  const newStatus = statusMap[swiklyEvent.toLowerCase()] ?? null;

  if (!newStatus) {
    console.log(`Unhandled Swikly event status: ${swiklyEvent} — ignoring`);
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // ── Find the assignment by wish_id ────────────────────────────────────────
  const { data: assignment, error: findErr } = await supabase
    .from("assignments")
    .select(
      `id, user_id, swikly_status, swikly_deposit_amount,
       sets (name, lego_ref),
       profiles (full_name, email)`
    )
    .eq("swikly_wish_id", wishId)
    .single();

  if (findErr || !assignment) {
    console.error("Assignment not found for wish_id:", wishId);
    return new Response("Assignment not found", { status: 404 });
  }

  // ── Update swikly_status in DB ────────────────────────────────────────────
  await supabase
    .from("assignments")
    .update({ swikly_status: newStatus })
    .eq("id", assignment.id);

  console.log(
    `Assignment ${assignment.id} swikly_status updated: ${assignment.swikly_status} → ${newStatus}`
  );

  // ── Resolve user email ────────────────────────────────────────────────────
  let userEmail: string = (assignment.profiles as any)?.email ?? "";
  if (!userEmail) {
    const { data: authUser } = await supabase.auth.admin.getUserById(
      assignment.user_id
    );
    userEmail = authUser?.user?.email ?? "";
  }

  const userName: string = (assignment.profiles as any)?.full_name ?? "Cliente";
  const set = assignment.sets as any;
  const depositEur = ((assignment.swikly_deposit_amount ?? 0) / 100).toFixed(2);

  // ── Send email based on new status ───────────────────────────────────────
  if (newStatus === "accepted" && userEmail) {
    await sendEmail("swikly_deposit_confirmed", userEmail, {
      name: userName,
      set_name: set?.name ?? "",
      set_ref: set?.lego_ref ?? "",
      deposit_amount: depositEur,
    });
  }

  if (newStatus === "released" && userEmail) {
    await sendEmail("swikly_deposit_released", userEmail, {
      name: userName,
      set_name: set?.name ?? "",
      deposit_amount: depositEur,
    });
  }

  if (newStatus === "captured" && userEmail) {
    await sendEmail("swikly_deposit_captured", userEmail, {
      name: userName,
      set_name: set?.name ?? "",
      deposit_amount: depositEur,
    });
  }

  return new Response(JSON.stringify({ received: true, new_status: newStatus }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});