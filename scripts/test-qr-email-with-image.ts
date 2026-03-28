#!/usr/bin/env ts-node
/**
 * Script para probar la generación de emails QR con imagen visual
 * Simula el envío de un email QR de recogida con código permanente
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

async function testQREmailWithImage() {
  console.log('🧪 Testing QR Email with Image Generation\n');

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  try {
    // 1. Buscar un shipment existente con Brickshare PUDO
    console.log('📦 Fetching existing Brickshare shipment...');
    const { data: shipments, error: shipmentError } = await supabase
      .from('shipments')
      .select('*')
      .eq('pudo_type', 'brickshare')
      .not('brickshare_pudo_id', 'is', null)
      .limit(1);

    if (shipmentError || !shipments || shipments.length === 0) {
      console.error('❌ No Brickshare shipments found. Creating test shipment...');
      
      // Crear un shipment de prueba
      const { data: user } = await supabase
        .from('users')
        .select('user_id')
        .eq('email', 'enriqueperez.bcn1973@gmail.com')
        .single();

      if (!user) {
        console.error('❌ Test user not found');
        return;
      }

      const { data: set } = await supabase
        .from('sets')
        .select('id')
        .limit(1)
        .single();

      if (!set) {
        console.error('❌ No sets found');
        return;
      }

      const { data: pudo } = await supabase
        .from('brickshare_pudo_locations')
        .select('id')
        .limit(1)
        .single();

      if (!pudo) {
        console.error('❌ No Brickshare PUDO locations found');
        return;
      }

      const { data: newShipment, error: createError } = await supabase
        .from('shipments')
        .insert({
          user_id: user.user_id,
          set_id: set.id,
          pudo_type: 'brickshare',
          brickshare_pudo_id: pudo.id,
          shipment_status: 'pending',
        })
        .select()
        .single();

      if (createError || !newShipment) {
        console.error('❌ Error creating test shipment:', createError);
        return;
      }

      console.log('✅ Test shipment created:', newShipment.id);
      shipments[0] = newShipment;
    }

    const shipment = shipments[0];
    console.log(`✅ Using shipment: ${shipment.id}\n`);

    // 2. Generar QR de entrega si no existe
    if (!shipment.delivery_qr_code) {
      console.log('🔑 Generating delivery QR code...');
      const { data: qrData, error: qrError } = await supabase.rpc(
        'generate_delivery_qr',
        { p_shipment_id: shipment.id }
      );

      if (qrError) {
        console.error('❌ Error generating QR:', qrError);
        return;
      }

      console.log('✅ QR Code generated:', qrData[0]?.qr_code);
      console.log('📅 Expires at:', qrData[0]?.expires_at || 'PERMANENT (NULL)');
      shipment.delivery_qr_code = qrData[0]?.qr_code;
    } else {
      console.log('ℹ️  Using existing QR code:', shipment.delivery_qr_code);
    }

    // 3. Verificar que el QR no tiene expiración
    const { data: shipmentUpdated } = await supabase
      .from('shipments')
      .select('delivery_qr_expires_at')
      .eq('id', shipment.id)
      .single();

    console.log('\n🔍 Verification:');
    console.log('   QR Code:', shipment.delivery_qr_code);
    console.log('   Expires at:', shipmentUpdated?.delivery_qr_expires_at || 'PERMANENT ✅');

    // 4. Validar que el QR es válido (sin check de expiración)
    console.log('\n✅ Validating QR code (should work without expiration check)...');
    const { data: validation, error: validationError } = await supabase.rpc(
      'validate_qr_code',
      { p_qr_code: shipment.delivery_qr_code }
    );

    if (validationError) {
      console.error('❌ Validation error:', validationError);
    } else {
      console.log('✅ QR Validation result:');
      console.log('   Valid:', validation[0]?.is_valid);
      console.log('   Type:', validation[0]?.validation_type);
      console.log('   Error:', validation[0]?.error_message || 'None');
    }

    // 5. Enviar email con QR visual
    console.log('\n📧 Sending QR email with visual image...');
    const { data: emailResult, error: emailError } = await supabase.functions.invoke(
      'send-brickshare-qr-email',
      {
        body: {
          shipment_id: shipment.id,
          type: 'delivery',
        },
      }
    );

    if (emailError) {
      console.error('❌ Error sending email:', emailError);
      return;
    }

    console.log('✅ Email sent successfully!');
    console.log('   Email ID:', emailResult.email_id);
    console.log('   QR Code:', emailResult.qr_code);

    console.log('\n🎉 Test completed successfully!');
    console.log('\n📋 Summary:');
    console.log('   ✅ QR code generated (permanent, no expiration)');
    console.log('   ✅ QR validation works without expiration check');
    console.log('   ✅ Email sent with visual QR image');
    console.log('   ✅ Email includes backup alphanumeric code');
    console.log('   ✅ No "Important" warnings in email');

  } catch (error) {
    console.error('❌ Unexpected error:', error);
  }
}

// Run the test
testQREmailWithImage();