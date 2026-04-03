import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const authHeader = req.headers.get("Authorization")!;

    const supabaseClient = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // Verify user authentication
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { shipmentId } = await req.json();

    if (!shipmentId) {
      return new Response(
        JSON.stringify({ error: "shipmentId is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Fetch shipment with user verification
    const { data: shipment, error: shipmentError } = await supabaseClient
      .from("shipments")
      .select(`
        *,
        users:user_id(id, email, full_name, phone),
        sets:set_ref(set_name, set_weight, set_dim)
      `)
      .eq("id", shipmentId)
      .single();

    if (shipmentError || !shipment) {
      return new Response(
        JSON.stringify({ error: "Shipment not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verify user owns this shipment
    if (shipment.user_id !== user.id) {
      return new Response(
        JSON.stringify({ error: "Unauthorized - shipment does not belong to user" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verify shipment status allows return
    const validStatusForReturn = ["delivered", "in_use", "pending_pickup"];
    if (!validStatusForReturn.includes(shipment.shipment_status)) {
      return new Response(
        JSON.stringify({ 
          error: `Cannot request return for shipment with status: ${shipment.shipment_status}. Valid statuses: ${validStatusForReturn.join(", ")}` 
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check pudo_type to route correctly
    const pudoType = shipment.pudo_type;

    if (pudoType === "brickshare") {
      // ===== BRICKSHARE PUDO RETURN =====
      console.log(`Processing Brickshare PUDO return for shipment ${shipmentId}`);

      // Update shipment status to in_return_pudo
      const { error: updateError } = await supabaseClient
        .from("shipments")
        .update({
          shipment_status: "in_return_pudo",
          return_request_date: new Date().toISOString(),
          pickup_provider: "Brickshare PUDO",
          updated_at: new Date().toISOString(),
        })
        .eq("id", shipmentId);

      if (updateError) {
        throw new Error(`Failed to update shipment: ${updateError.message}`);
      }

      // Generate return QR code and send email
      const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
      const serviceClient = createClient(supabaseUrl, serviceRoleKey);

      const { data: emailData, error: emailError } = await serviceClient.functions.invoke(
        "send-brickshare-qr-email",
        {
          body: {
            shipmentId: shipmentId,
            emailType: "return",
          },
        }
      );

      if (emailError) {
        console.error("Failed to send return QR email:", emailError);
        // Don't fail the entire operation, just log the error
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: "Return initiated successfully with Brickshare PUDO",
          pudo_type: "brickshare",
          return_code: `BR-${shipmentId.substring(0, 8).toUpperCase()}`,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );

    } else if (pudoType === "correos") {
      // ===== CORREOS PUDO RETURN =====
      console.log(`Processing Correos PUDO return for shipment ${shipmentId}`);

      // Update shipment status first
      const { error: updateError } = await supabaseClient
        .from("shipments")
        .update({
          shipment_status: "in_return_pudo",
          return_request_date: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq("id", shipmentId);

      if (updateError) {
        throw new Error(`Failed to update shipment: ${updateError.message}`);
      }

      // Call correos-logistics with service role for return preregistration
      const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
      const serviceClient = createClient(supabaseUrl, serviceRoleKey);

      const { data: correosData, error: correosError } = await serviceClient.functions.invoke(
        "correos-logistics",
        {
          body: {
            action: "return_preregister",
            p_shipment_id: shipmentId,
          },
        }
      );

      if (correosError) {
        console.error("Correos logistics error:", correosError);
        throw new Error(`Error registering return with Correos: ${correosError.message}`);
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: "Return initiated successfully with Correos",
          pudo_type: "correos",
          return_code: correosData?.return_code || "PENDING",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );

    } else {
      // Unknown or missing pudo_type
      return new Response(
        JSON.stringify({ 
          error: `Invalid or missing pudo_type: ${pudoType}. Expected 'brickshare' or 'correos'` 
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

  } catch (error) {
    console.error("Error in request-return:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});