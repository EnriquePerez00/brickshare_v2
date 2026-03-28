// ============================================================
// create-logistics-package — Supabase Edge Function
//
// Crea un package en Brickshare_logistics cuando un shipment
// utiliza un punto PUDO de Brickshare.
//
// Se llama automáticamente cuando:
// - Se crea un shipment con pickup_type='brickshare'
// - Se solicita una devolución en un punto Brickshare
//
// POST /functions/v1/create-logistics-package
// Headers: Authorization: Bearer <USER_JWT> o <SERVICE_ROLE_KEY>
// Body: {
//   "shipment_id": "uuid",
//   "type": "delivery" | "return"
// }
// ============================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Configuración de Brickshare_logistics
// Configuración de Brickshare_logistics (LOCAL ONLY)
const LOGISTICS_URL = Deno.env.get('BRICKSHARE_LOGISTICS_URL') || 'http://127.0.0.1:54331'
const LOGISTICS_SECRET = Deno.env.get('BRICKSHARE_LOGISTICS_SECRET') || 'change-me-in-production'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Crear cliente Supabase con service role
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // 2. Parsear body
    const body = await req.json()
    const { shipment_id, type } = body

    if (!shipment_id || !type) {
      return errorResponse(400, 'shipment_id and type are required')
    }

    if (type !== 'delivery' && type !== 'return') {
      return errorResponse(400, 'type must be "delivery" or "return"')
    }

    // 3. Obtener información del shipment
    const { data: shipment, error: shipmentError } = await supabase
      .from('shipments')
      .select(`
        id,
        assignment_id,
        direction,
        status,
        pickup_type,
        brickshare_pudo_id,
        brickshare_package_id,
        tracking_number,
        assignments (
          user_id,
          product_id
        )
      `)
      .eq('id', shipment_id)
      .single()

    if (shipmentError || !shipment) {
      console.error('Shipment not found:', shipmentError)
      return errorResponse(404, 'Shipment not found')
    }

    // 4. Validar que usa Brickshare PUDO
    if (shipment.pickup_type !== 'brickshare' || !shipment.brickshare_pudo_id) {
      return errorResponse(400, 'Shipment does not use Brickshare PUDO')
    }

    // 5. Si ya tiene un package_id, retornarlo
    if (shipment.brickshare_package_id) {
      console.log('Shipment already has a package:', shipment.brickshare_package_id)
      return new Response(
        JSON.stringify({
          success: true,
          already_exists: true,
          package_id: shipment.brickshare_package_id,
          shipment_id: shipment.id
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    // 6. Generar tracking code único si no existe
    const trackingCode = shipment.tracking_number || `BS-${shipment_id.substring(0, 8).toUpperCase()}`

    // 7. Preparar datos para crear package en Logistics
    const packageData = {
      tracking_code: trackingCode,
      type: type,
      location_id: shipment.brickshare_pudo_id,
      customer_id: shipment.assignments?.user_id || null,
      external_shipment_id: shipment.id,
      source_system: 'brickshare'
    }

    console.log('Creating package in Brickshare_logistics:', packageData)

    // 8. Llamar a la API de Brickshare_logistics para crear el package
    const logisticsResponse = await fetch(`${LOGISTICS_URL}/api/packages/create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Integration-Secret': LOGISTICS_SECRET
      },
      body: JSON.stringify(packageData)
    })

    if (!logisticsResponse.ok) {
      const errorData = await logisticsResponse.json()
      console.error('Error from Brickshare_logistics:', errorData)
      return errorResponse(
        logisticsResponse.status,
        `Failed to create package in logistics: ${errorData.error || 'Unknown error'}`
      )
    }

    const logisticsData = await logisticsResponse.json()
    console.log('Package created successfully:', logisticsData)

    // 9. Actualizar el shipment con el package_id
    const { error: updateError } = await supabase
      .from('shipments')
      .update({
        brickshare_package_id: logisticsData.package.id,
        tracking_number: trackingCode
      })
      .eq('id', shipment_id)

    if (updateError) {
      console.error('Error updating shipment:', updateError)
      // No fallar la operación completa, el package ya fue creado
      // TODO: Implementar cola de reintentos si es crítico
    }

    // 10. Respuesta exitosa
    return new Response(
      JSON.stringify({
        success: true,
        package_id: logisticsData.package.id,
        tracking_code: trackingCode,
        shipment_id: shipment.id,
        type: type,
        location_id: shipment.brickshare_pudo_id,
        location_name: logisticsData.package.location_name
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 201
      }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return errorResponse(500, 'Internal server error')
  }
})

function errorResponse(status: number, message: string): Response {
  return new Response(
    JSON.stringify({ error: message }),
    {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status
    }
  )
}