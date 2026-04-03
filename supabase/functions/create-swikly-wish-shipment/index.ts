import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// ✅ Soporte para ambas variables (V1 y V2)
const SWIKLY_API_TOKEN = Deno.env.get("SWIKLY_API_TOKEN") ?? Deno.env.get("SWIKLY_API_TOKEN_SANDBOX") ?? "";
const SWIKLY_ACCOUNT_ID = Deno.env.get("SWIKLY_ACCOUNT_ID") ?? "";
const APP_URL = Deno.env.get("APP_URL") ?? "https://brickshare.es";
const SWIKLY_ENV = Deno.env.get("SWIKLY_ENV") ?? "sandbox";
// 🔧 Development bypass flag - skips real Swikly API calls in local environment
const SWIKLY_BYPASS_DEV = (Deno.env.get("SWIKLY_BYPASS_DEV") ?? "false").toLowerCase() === "true";

// Determine API endpoint based on environment (API V2)
const SWIKLY_API =
  SWIKLY_ENV === "production"
    ? "https://api.v2.swikly.com/v1"
    : "https://api.v2.sandbox.swikly.com/v1";

console.log(`[Swikly] Using ${SWIKLY_ENV} environment: ${SWIKLY_API}`);
console.log(`[Swikly] Account ID: ${SWIKLY_ACCOUNT_ID || "⚠️ NOT CONFIGURED"}`);
console.log(`[Swikly] API Token: ${SWIKLY_API_TOKEN ? "✓ Configured" : "❌ MISSING"}`);
if (SWIKLY_BYPASS_DEV) {
  console.log(`[Swikly] 🔧 BYPASS MODE ENABLED - Using mock deposits for development`);
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
        `[Swikly] Wish already exists for shipment ${shipment_id} (status: ${shipment.swikly_status})`
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
    console.log(`[Swikly] Fetching set data for set_ref: ${shipment.set_ref}`);
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
    console.log(`[Swikly] Set found: ${setData.set_name} (${setData.set_ref}), deposit: €${depositEur}`);

    // ── 4. Resolve user email, name, and phone ──────────────────────────────
    console.log(`[Swikly] Fetching user data for user_id: ${shipment.user_id}`);
    const { data: userProfile, error: uErr } = await supabase
      .from("users")
      .select("full_name, email, phone")
      .eq("id", shipment.user_id)
      .maybeSingle();

    let userEmail = userProfile?.email ?? "";
    if (!userEmail) {
      const { data: authUser } = await supabase.auth.admin.getUserById(shipment.user_id);
      userEmail = authUser?.user?.email ?? "";
    }
    if (!userEmail) throw new Error("Could not resolve user email");

    const userName = userProfile?.full_name ?? "Cliente";
    const userPhone = userProfile?.phone ?? undefined;
    
    console.log(`[Swikly] User resolved: ${userName} (${userEmail}), phone: ${userPhone || "N/A"}`);

    // ── 5. Build Swikly Request payload (API V2) ─────────────────────────────
    const today = new Date();
    const endDate = new Date(today);
    endDate.setDate(endDate.getDate() + 90);
    const fmt = (d: Date) => d.toISOString().slice(0, 10);

    const callbackUrl = `${SUPABASE_URL}/functions/v1/swikly-webhook`;

    // Parse user name properly (Fase 1: Split from full_name)
    const nameParts = userName.trim().split(/\s+/);
    const firstName = nameParts[0] || "Cliente";
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(" ") : firstName;

    const requestPayload = {
      description: `Fianza LEGO ${setData.set_ref} - ${setData.set_name} · Brickshare`,
      language: "es",
      firstName,
      lastName,
      email: userEmail,
      phoneNumber: userPhone, // ✅ FASE 1: Añadir teléfono si está disponible
      callbacks: {
        requestSecured: callbackUrl,
      },
      deposit: {
        startDate: fmt(today),
        endDate: fmt(endDate),
        amount: depositCents,
      },
      redirectUrl: `${APP_URL}/dashboard?deposit=confirmed`,
      returnUrl: `${APP_URL}/dashboard?deposit=return`,
    };

    // Remove undefined values
    if (!requestPayload.phoneNumber) delete requestPayload.phoneNumber;

    const bodyString = JSON.stringify(requestPayload);
    console.log(`[Swikly] Sending request to API V2: ${SWIKLY_API}/accounts/${SWIKLY_ACCOUNT_ID}/requests`);
    console.log(`[Swikly] Payload: firstName=${firstName}, lastName=${lastName}, email=${userEmail}, phone=${userPhone || "N/A"}, language=es, deposit=€${depositEur}`);

    // ── 6. Call Swikly API V2 ────────────────────────────────────────────────
    console.log(`[Swikly] Creating deposit request for shipment ${shipment_id} — set ${setData.set_ref} — €${depositEur}`);

    let wishId: string;
    let wishUrl: string;

    if (SWIKLY_BYPASS_DEV) {
      // 🔧 DEVELOPMENT BYPASS: Generate mock deposit without calling real API
      console.log(`[Swikly] 🔧 BYPASS MODE: Creating mock deposit for development`);
      wishId = `mock-${crypto.getRandomValues(new Uint8Array(8)).reduce((a, b) => a + b.toString(16), "")}`;
      wishUrl = `${APP_URL}/dashboard?deposit=mock&wish=${wishId}`;
      
      console.log(`[Swikly] Mock Request created: ${wishId}`);
      console.log(`[Swikly] Mock URL: ${wishUrl}`);
    } else {
      // ✅ PRODUCTION: Real Swikly API call
      // Validate configuration before making API call
      if (!SWIKLY_API_TOKEN) {
        throw new Error(
          "SWIKLY_API_TOKEN not configured. Set SWIKLY_API_TOKEN or SWIKLY_API_TOKEN_SANDBOX in environment"
        );
      }
      if (!SWIKLY_ACCOUNT_ID || SWIKLY_ACCOUNT_ID.includes("your_")) {
        throw new Error(
          `SWIKLY_ACCOUNT_ID not configured properly. Current value: "${SWIKLY_ACCOUNT_ID}". Please set a valid UUID in environment variables.`
        );
      }

      const swiklyRes = await fetch(`${SWIKLY_API}/accounts/${SWIKLY_ACCOUNT_ID}/requests`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${SWIKLY_API_TOKEN}`,
        },
        body: bodyString,
      });

      const swiklyData = await swiklyRes.json();
      console.log(`[Swikly] API Response (${swiklyRes.status}):`, JSON.stringify(swiklyData, null, 2));

      if (!swiklyRes.ok) {
        throw new Error(
          `Swikly API error ${swiklyRes.status}: ${JSON.stringify(swiklyData)}`
        );
      }

      // ── 7. Parse API V2 response ──────────────────────────────────────────────
      wishId = swiklyData.id;
      wishUrl = swiklyData.shortLink?.shortLink ?? swiklyData.shortLink;

      if (!wishId) throw new Error("Swikly did not return a request ID (id)");
      if (!wishUrl) {
        console.warn("[Swikly] Warning: shortLink not found in response, will be set later");
      }
    }

    // ── 8. Persist request info to shipment ───────────────────────────────────
    console.log(`[Swikly] Updating shipment ${shipment_id} with request ID: ${wishId}`);
    
    // In bypass mode, auto-accept the deposit to enable label generation immediately
    const swiklyStatus = SWIKLY_BYPASS_DEV ? "accepted" : "wish_created";
    
    const { error: updErr } = await supabase
      .from("shipments")
      .update({
        swikly_wish_id: wishId,
        swikly_wish_url: wishUrl || "",
        swikly_status: swiklyStatus,
        swikly_deposit_amount: depositCents,
      })
      .eq("id", shipment_id);

    if (updErr) throw new Error(`DB update failed: ${updErr.message}`);

    // ── 9. Send notification email to user ────────────────────────────────────
    console.log(`[Swikly] Sending notification email to ${userEmail}`);
    await sendEmail("swikly_wish_created", userEmail, {
      name: userName,
      set_name: setData.set_name,
      set_ref: setData.set_ref,
      deposit_amount: (depositCents / 100).toFixed(2),
      wish_url: wishUrl || "",
    });

    console.log(`[Swikly] ✅ Request ${wishId} created for shipment ${shipment_id}`);

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
    console.error("[Swikly] ❌ Error:", err.message);
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
