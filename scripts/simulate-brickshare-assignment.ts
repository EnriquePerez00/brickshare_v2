#!/usr/bin/env tsx
/**
 * Simulate Brickshare Assignment - Email Sending
 * 
 * This script:
 * 1. Finds the last created shipment for enriquepeto@yahoo.es
 * 2. Invokes the send-brickshare-qr-email Edge Function
 * 3. Displays QR code and validation info
 * 4. Provides testing instructions
 */

import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import { resolve } from 'path';

// Load environment variables
dotenv.config({ path: resolve(__dirname, '../.env.local') });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54331';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SHIPMENT_ID = 'abd0f0ad-b28a-47b0-a4b3-05f759cdb213'; // Direct shipment ID

if (!SUPABASE_SERVICE_KEY) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY not found in environment');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function main() {
  console.log('════════════════════════════════════════════════════════════');
  console.log('📧 BRICKSHARE ASSIGNMENT - EMAIL SENDING');
  console.log('════════════════════════════════════════════════════════════');
  console.log('');

  // Step 1: Get the shipment directly by ID
  console.log('📦 Step 1: Retrieving shipment details...');
  
  const { data: shipment, error: shipmentError } = await supabase
    .from('shipments')
    .select(`
      id,
      user_id,
      shipment_status,
      pudo_type,
      set_ref,
      delivery_qr_code,
      delivery_qr_expires_at,
      brickshare_pudo_id,
      shipping_address,
      shipping_city,
      shipping_zip_code,
      shipping_province,
      assigned_date,
      set_id
    `)
    .eq('id', SHIPMENT_ID)
    .single();

  if (shipmentError || !shipment) {
    console.error('❌ Shipment not found:', shipmentError?.message);
    process.exit(1);
  }

  // Get user info
  const { data: user, error: userError } = await supabase
    .from('users')
    .select('user_id, email, full_name')
    .eq('user_id', shipment.user_id)
    .single();

  if (userError || !user) {
    console.error('❌ User not found:', userError?.message);
    process.exit(1);
  }

  console.log(`✅ User found: ${user.full_name} (${user.email})`);

  // Get set info
  const { data: setInfo, error: setError } = await supabase
    .from('sets')
    .select('id, set_name, set_ref, set_price')
    .eq('id', shipment.set_id)
    .single();

  // Get PUDO info
  let pudoInfo = null;
  if (shipment.brickshare_pudo_id) {
    const { data: pudo } = await supabase
      .from('brickshare_pudo_locations')
      .select('id, name, address, city, postal_code, contact_phone')
      .eq('id', shipment.brickshare_pudo_id)
      .single();
    pudoInfo = pudo;
  }

  console.log('');
  console.log('✅ Shipment found:');
  console.log(`   - ID: ${shipment.id}`);
  console.log(`   - Status: ${shipment.shipment_status}`);
  console.log(`   - Set: ${setInfo?.set_name || 'N/A'} (${shipment.set_ref})`);
  console.log(`   - QR Code: ${shipment.delivery_qr_code}`);
  console.log(`   - PUDO: ${pudoInfo?.name || 'N/A'}`);
  console.log('');

  if (!shipment.delivery_qr_code) {
    console.error('❌ No QR code found in shipment');
    console.log('');
    console.log('💡 The SQL script should have generated the QR code.');
    console.log('   Please check the shipment record.');
    process.exit(1);
  }

  // Step 2: Send email with QR code
  console.log('📧 Step 2: Sending QR code email...');
  console.log('');

  try {
    const { data: emailResult, error: emailError } = await supabase.functions.invoke(
      'send-brickshare-qr-email',
      {
        body: {
          shipment_id: shipment.id,
          type: 'delivery'
        }
      }
    );

    if (emailError) {
      console.error('❌ Email sending failed:', emailError.message);
      console.log('');
      console.log('💡 Possible issues:');
      console.log('   1. Edge function not deployed');
      console.log('   2. RESEND_API_KEY not configured');
      console.log('   3. Shipment data incomplete');
      process.exit(1);
    }

    if (emailResult?.success) {
      console.log('✅ Email sent successfully!');
      console.log(`   - Email ID: ${emailResult.email_id}`);
      console.log(`   - QR Code: ${emailResult.qr_code}`);
      console.log(`   - Recipient: ${user.email}`);
    } else {
      console.error('❌ Email failed:', emailResult?.error);
      process.exit(1);
    }
  } catch (error: any) {
    console.error('❌ Exception sending email:', error.message);
    process.exit(1);
  }

  // Step 3: Display testing information
  console.log('');
  console.log('════════════════════════════════════════════════════════════');
  console.log('🎉 SIMULATION COMPLETED SUCCESSFULLY');
  console.log('════════════════════════════════════════════════════════════');
  console.log('');
  console.log('📋 SUMMARY:');
  console.log('─────────────────────────────────────────────────────────────');
  console.log(`User:          ${user.full_name}`);
  console.log(`Email:         ${user.email}`);
  console.log(`Set:           ${setInfo?.set_name || 'N/A'}`);
  console.log(`Set Ref:       ${shipment.set_ref}`);
  console.log(`QR Code:       ${shipment.delivery_qr_code}`);
  console.log(`Expires:       ${new Date(shipment.delivery_qr_expires_at).toLocaleString()}`);
  console.log(`PUDO:          ${pudoInfo?.name || 'N/A'}`);
  console.log(`Address:       ${shipment.shipping_address}`);
  console.log(`City:          ${shipment.shipping_zip_code} ${shipment.shipping_city}`);
  console.log(`Province:      ${shipment.shipping_province}`);
  console.log(`Shipment ID:   ${shipment.id}`);
  console.log('─────────────────────────────────────────────────────────────');
  console.log('');
  console.log('📧 CHECK YOUR EMAIL:');
  console.log(`   Open ${user.email} inbox to see the QR code email`);
  console.log('');
  console.log('🔍 TEST QR CODE VALIDATION:');
  console.log('');
  console.log('   1. Via API (GET):');
  console.log(`      curl ${SUPABASE_URL}/functions/v1/brickshare-qr-api/validate/${shipment.delivery_qr_code}`);
  console.log('');
  console.log('   2. Via API (Confirm):');
  console.log(`      curl -X POST ${SUPABASE_URL}/functions/v1/brickshare-qr-api/confirm \\`);
  console.log('           -H "Content-Type: application/json" \\');
  console.log(`           -d '{"qr_code":"${shipment.delivery_qr_code}","validated_by":"BS-PUDO-001"}'`);
  console.log('');
  console.log('   3. Via Database:');
  console.log(`      SELECT * FROM validate_qr_code('${shipment.delivery_qr_code}');`);
  console.log('');
  console.log('📱 MOBILE APP TESTING:');
  console.log('   Use the QR scanner app to scan this code and validate the delivery');
  console.log('');
  console.log('✅ All steps completed successfully!');
  console.log('');
}

main().catch((error) => {
  console.error('');
  console.error('❌ Script failed:', error);
  console.error('');
  process.exit(1);
});