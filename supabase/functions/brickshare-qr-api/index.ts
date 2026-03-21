// Brickshare PUDO QR Code Validation API
// Provides mobile access to shipment information based on QR codes
// No personal data is exposed through this API

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ValidationResponse {
  success: boolean;
  data?: {
    shipment_id: string;
    validation_type: 'delivery' | 'return';
    shipment_info: {
      assignment_id: string;
      set_id: string;
      set_name: string;
      set_number: string;
      theme: string;
      status: string;
      brickshare_pudo_id: string;
      validation_type: string;
    };
  };
  error?: string;
}

interface ConfirmationResponse {
  success: boolean;
  message?: string;
  shipment_id?: string;
  error?: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    const url = new URL(req.url);
    const path = url.pathname;

    // Route: GET /validate/:qr_code - Validate QR and get shipment info
    if (req.method === 'GET' && path.includes('/validate/')) {
      const qrCode = path.split('/validate/')[1];
      
      if (!qrCode) {
        return new Response(
          JSON.stringify({ success: false, error: 'QR code is required' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      // Call validation function
      const { data, error } = await supabaseClient.rpc('validate_qr_code', {
        p_qr_code: qrCode
      });

      if (error) {
        console.error('Validation error:', error);
        return new Response(
          JSON.stringify({ success: false, error: error.message }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      if (!data || data.length === 0) {
        return new Response(
          JSON.stringify({ success: false, error: 'QR code not found' }),
          { 
            status: 404, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      const validationResult = data[0];

      if (!validationResult.is_valid) {
        return new Response(
          JSON.stringify({ 
            success: false, 
            error: validationResult.error_message 
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      const response: ValidationResponse = {
        success: true,
        data: {
          shipment_id: validationResult.shipment_id,
          validation_type: validationResult.validation_type,
          shipment_info: validationResult.shipment_info
        }
      };

      return new Response(
        JSON.stringify(response),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Route: POST /confirm - Confirm QR validation
    if (req.method === 'POST' && path.includes('/confirm')) {
      const body = await req.json();
      const { qr_code, validated_by } = body;

      if (!qr_code) {
        return new Response(
          JSON.stringify({ success: false, error: 'QR code is required' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      // Call confirmation function
      const { data, error } = await supabaseClient.rpc('confirm_qr_validation', {
        p_qr_code: qr_code,
        p_validated_by: validated_by || null
      });

      if (error) {
        console.error('Confirmation error:', error);
        return new Response(
          JSON.stringify({ success: false, error: error.message }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      if (!data || data.length === 0) {
        return new Response(
          JSON.stringify({ success: false, error: 'Validation failed' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      const confirmationResult = data[0];

      if (!confirmationResult.success) {
        return new Response(
          JSON.stringify({ 
            success: false, 
            error: confirmationResult.message 
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      const response: ConfirmationResponse = {
        success: true,
        message: confirmationResult.message,
        shipment_id: confirmationResult.shipment_id
      };

      return new Response(
        JSON.stringify(response),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Route: GET /pudo-locations - Get active Brickshare PUDO locations
    if (req.method === 'GET' && path.includes('/pudo-locations')) {
      const { data, error } = await supabaseClient
        .from('brickshare_pudo_locations')
        .select('*')
        .eq('is_active', true)
        .order('name');

      if (error) {
        console.error('Error fetching PUDO locations:', error);
        return new Response(
          JSON.stringify({ success: false, error: error.message }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      return new Response(
        JSON.stringify({ success: true, data }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Route: GET /shipment/:id - Get shipment details (requires authentication)
    if (req.method === 'GET' && path.includes('/shipment/')) {
      const shipmentId = path.split('/shipment/')[1];
      
      if (!shipmentId) {
        return new Response(
          JSON.stringify({ success: false, error: 'Shipment ID is required' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      // Get auth token from header
      const authHeader = req.headers.get('Authorization');
      if (!authHeader) {
        return new Response(
          JSON.stringify({ success: false, error: 'Authentication required' }),
          { 
            status: 401, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      const token = authHeader.replace('Bearer ', '');
      const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token);

      if (authError || !user) {
        return new Response(
          JSON.stringify({ success: false, error: 'Invalid authentication' }),
          { 
            status: 401, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      // Fetch shipment with limited info
      const { data, error } = await supabaseClient
        .from('shipments')
        .select(`
          id,
          status,
          pickup_type,
          delivery_qr_code,
          delivery_qr_expires_at,
          delivery_validated_at,
          return_qr_code,
          return_qr_expires_at,
          return_validated_at,
          brickshare_pudo_id,
          assignment:assignments!inner(
            id,
            set_id,
            user_id,
            product:products(
              name,
              set_number,
              theme
            )
          )
        `)
        .eq('id', shipmentId)
        .eq('assignment.user_id', user.id)
        .single();

      if (error) {
        console.error('Error fetching shipment:', error);
        return new Response(
          JSON.stringify({ success: false, error: 'Shipment not found' }),
          { 
            status: 404, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      return new Response(
        JSON.stringify({ success: true, data }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Default 404 response
    return new Response(
      JSON.stringify({ success: false, error: 'Endpoint not found' }),
      { 
        status: 404, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error instanceof Error ? error.message : 'An unexpected error occurred' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});