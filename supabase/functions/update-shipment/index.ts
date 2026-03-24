// Edge Function: update-shipment
// Purpose: Allow external logistics operators to update shipment status and timestamps
// Authentication: API Key in X-API-Key header
// Documentation: See docs/EXTERNAL_LOGISTICS_API.md

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-api-key',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Valid shipping status values
const VALID_SHIPPING_STATUSES = [
  'assigned',
  'in_transit_pudo',
  'delivered',
  'picked_up',
  'in_transit_return',
  'returned'
] as const;

// Fields that can be updated via this API
const ALLOWED_FIELDS = [
  'shipping_status',
  'delivered_at',
  'picked_up_at',
  'returned_at',
  'tracking_update'
] as const;

type AllowedField = typeof ALLOWED_FIELDS[number];
type ShippingStatus = typeof VALID_SHIPPING_STATUSES[number];

interface UpdateRequest {
  shipment_id: string;
  updates: Partial<Record<AllowedField, string>>;
}

interface UpdateResponse {
  success: boolean;
  shipment_id?: string;
  updated_fields?: string[];
  message?: string;
  error?: string;
}

function isValidUUID(uuid: string): boolean {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
}

function isValidISO8601(dateString: string): boolean {
  const date = new Date(dateString);
  return date instanceof Date && !isNaN(date.getTime()) && date.toISOString() === dateString;
}

function validateUpdates(updates: Partial<Record<string, string>>): { valid: boolean; error?: string } {
  // Check for invalid fields
  const invalidFields = Object.keys(updates).filter(
    field => !ALLOWED_FIELDS.includes(field as AllowedField)
  );
  
  if (invalidFields.length > 0) {
    return {
      valid: false,
      error: `Invalid fields: ${invalidFields.join(', ')}. Allowed fields: ${ALLOWED_FIELDS.join(', ')}`
    };
  }

  // Validate shipping_status value
  if (updates.shipping_status && !VALID_SHIPPING_STATUSES.includes(updates.shipping_status as ShippingStatus)) {
    return {
      valid: false,
      error: `Invalid shipping_status value. Must be one of: ${VALID_SHIPPING_STATUSES.join(', ')}`
    };
  }

  // Validate timestamp fields
  const timestampFields: AllowedField[] = ['delivered_at', 'picked_up_at', 'returned_at'];
  for (const field of timestampFields) {
    if (updates[field] && !isValidISO8601(updates[field] as string)) {
      return {
        valid: false,
        error: `Invalid ${field} format. Must be ISO 8601 format (e.g., 2025-03-24T14:30:00Z)`
      };
    }
  }

  return { valid: true };
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: 'Method not allowed. Only POST is supported.' 
      }),
      { 
        status: 405, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }

  try {
    // Authentication: Check API Key
    const apiKey = req.headers.get('X-API-Key');
    const expectedApiKey = Deno.env.get('LOGISTICS_API_KEY');

    if (!apiKey || apiKey !== expectedApiKey) {
      console.error('Invalid or missing API key');
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Unauthorized. Invalid or missing API key.' 
        }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Parse request body
    const body: UpdateRequest = await req.json();
    const { shipment_id, updates } = body;

    // Validate shipment_id
    if (!shipment_id) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'shipment_id is required' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (!isValidUUID(shipment_id)) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Invalid shipment_id format. Must be a valid UUID.' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate updates object
    if (!updates || typeof updates !== 'object' || Object.keys(updates).length === 0) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'updates object is required and must contain at least one field' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate update fields and values
    const validation = validateUpdates(updates);
    if (!validation.valid) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: validation.error 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Create Supabase client with service role key
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    // Check if shipment exists and get current values
    const { data: currentShipment, error: fetchError } = await supabaseClient
      .from('shipments')
      .select('id, shipping_status, delivered_at, picked_up_at, returned_at, tracking_update')
      .eq('id', shipment_id)
      .single();

    if (fetchError || !currentShipment) {
      console.error('Shipment not found:', fetchError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Shipment not found with ID: ${shipment_id}` 
        }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Prepare old values for audit log
    const oldValues: Record<string, unknown> = {};
    const updatedFields = Object.keys(updates);
    
    for (const field of updatedFields) {
      oldValues[field] = currentShipment[field as keyof typeof currentShipment];
    }

    // Update shipment
    const { error: updateError } = await supabaseClient
      .from('shipments')
      .update(updates)
      .eq('id', shipment_id);

    if (updateError) {
      console.error('Error updating shipment:', updateError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Failed to update shipment: ${updateError.message}` 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Log the update in audit table
    const sourceIp = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip') || 'unknown';
    const userAgent = req.headers.get('user-agent') || 'unknown';

    const { error: logError } = await supabaseClient
      .from('shipment_update_logs')
      .insert({
        shipment_id,
        updated_by: 'logistics_api',
        updated_fields: updatedFields,
        old_values: oldValues,
        new_values: updates,
        source_ip: sourceIp,
        user_agent: userAgent,
      });

    if (logError) {
      console.error('Error creating audit log:', logError);
      // Don't fail the request if logging fails, but log the error
    }

    // Success response
    const response: UpdateResponse = {
      success: true,
      shipment_id,
      updated_fields: updatedFields,
      message: 'Shipment updated successfully'
    };

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
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