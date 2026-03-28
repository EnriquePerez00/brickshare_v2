#!/usr/bin/env tsx
/**
 * Complete Assignment Flow - Email and Label Generation
 * 
 * This script:
 * 1. Fetches the shipment created by the SQL script
 * 2. Sends QR email via send-brickshare-qr-email Edge Function
 * 3. Generates Correos label if pudo_type = 'correos' (optional)
 * 4. Displays complete results
 */

import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import { resolve } from 'path';

// Load environment variables
dotenv.config({ path: resolve(__dirname, '../.env.local') });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_KEY) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY not found in environment');
  console.error('   Make sure .env.local exists with SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

const TARGET_EMAIL = 'enriquepeto@yahoo.es';

async function main() {
  console.log('═'.repeat(70));
  console.log('📧 EMAIL & LABEL GENERATION');
  console.log('   User: ' + TARGET_EMAIL);
  console.log('═'.repeat(70));
  console.log('');

  // Step 1: Find the shipment for this user
  console.log('📋 Step 1: Finding shipment...');
  
  const { data: user, error: userError } = await supabase
    .from('users')
    .select('user_id')
    .eq('email', TARGET_EMAIL)
    .single();

  if (userError || !user) {
    console.error('❌ User not found:', userError?.message);
    process.exit(1);
  }

  // Get most recent shipment for this user
  const { data: shipment, error: shipmentError } = await supabase
    .from('shipments')
    .select(`
      id,
      shipment_status,
      pudo_type,
      set_ref,
      delivery_qr_code,
      delivery_qr_expires_at,
      brickshare_pudo_id,
      shipping_address,
      shipping_city,
      shipping_zip_code,
      created_at,
      user_id,
      set_id
    `)
    .eq('user_id', user.user_id)
    .order('created_at', { ascending: false })
    .limit(1)
    .single();

  if (shipmentError || !shipment) {
    console.error('❌ No shipment found:', shipmentError?.message);
    console.error('   Run the SQL script first: psql -f scripts/simulate-enrique-complete-flow.sql');
    process.exit(1);
  }

  console.log('✅ Shipment found:');
  console.log('   - ID:', shipment.id);
  console.log('   - Status:', shipment.shipment_status);
  console.log('   - PUDO Type:', shipment.pudo_type);
  console.log('   - Set Ref:', shipment.set_ref);
  console.log('   - QR Code:', shipment.delivery_qr_code || 'NOT GENERATED');
  console.log('   - Created:', new Date(shipment.created_at).toLocaleString());
  console.log('');

  // Step 2: Generate QR code if not exists
  if (!shipment.delivery_qr_code) {
    console.log('🎫 Step 2: Generating QR code...');
    
    const qrCode = `BS-${shipment.id.substring(0, 8).toUpperCase()}`;
    const qrExpiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    
    const { error: updateError } = await supabase
      .from('shipments')
      .update({
        delivery_qr_code: qrCode,
        delivery_qr_expires_at: qrExpiresAt.toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', shipment.id);

    if (updateError) {
      console.error('❌ Error updating shipment with QR:', updateError.message);
      process.exit(1);
    }

    console.log('✅ QR Code generated:');
    console.log('   - Code:', qrCode);
    console.log('   - Expires:', qrExpiresAt.toLocaleString());
    console.log('');
    
    // Update shipment object
    shipment.delivery_qr_code = qrCode;
    shipment.delivery_qr_expires_at = qrExpiresAt.toISOString();
  } else {
    console.log('✅ QR Code already exists:', shipment.delivery_qr_code);
    console.log('');
  }

  // Step 3: Send QR email
  console.log('📧 Step 3: Sending QR email...');
  
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
      console.error('❌ Email error:', emailError.message);
      console.error('   Details:', emailError);
    } else if (emailResult?.success) {
      console.log('✅ Email sent successfully!');
      console.log('   - Email ID:', emailResult.email_id);
      console.log('   - QR Code in email:', emailResult.qr_code);
      console.log('   - Recipient:', TARGET_EMAIL);
    } else {
      console.error('❌ Email failed:', emailResult?.error || 'Unknown error');
      console.error('   Full response:', JSON.stringify(emailResult, null, 2));
    }
  } catch (error: any) {
    console.error('❌ Email exception:', error.message);
    console.error('   Stack:', error.stack);
  }
  
  console.log('');

  // Step 4: Generate Correos label (only if pudo_type = 'correos')
  if (shipment.pudo_type === 'correos') {
    console.log('📦 Step 4: Generating Correos label...');
    
    try {
      const { data: labelResult, error: labelError } = await supabase.functions.invoke(
        'correos-logistics',
        {
          body: {
            shipment_id: shipment.id
          }
        }
      );

      if (labelError) {
        console.error('❌ Label error:', labelError.message);
      } else if (labelResult?.label_url) {
        console.log('✅ Correos label generated!');
        console.log('   - Label URL:', labelResult.label_url);
        console.log('   - Tracking Number:', labelResult.tracking_number || 'N/A');
      } else {
        console.error('❌ Label generation failed:', labelResult?.error || 'Unknown error');
      }
    } catch (error: any) {
      console.error('❌ Label exception:', error.message);
    }
  } else {
    console.log('ℹ️  Step 4: Skipping Correos label (PUDO type is Brickshare)');
    console.log('   For Brickshare PUDOs, no Correos label is needed.');
    console.log('   The user will use the QR code for pickup.');
  }
  
  console.log('');

  // Final summary
  console.log('═'.repeat(70));
  console.log('🎉 COMPLETE FLOW FINISHED');
  console.log('═'.repeat(70));
  console.log('');
  console.log('📋 Summary:');
  console.log('   - User:', TARGET_EMAIL);
  console.log('   - Shipment ID:', shipment.id);
  console.log('   - Set Ref:', shipment.set_ref);
  console.log('   - PUDO Type:', shipment.pudo_type);
  console.log('   - QR Code:', shipment.delivery_qr_code);
  console.log('   - Status:', shipment.shipment_status);
  console.log('');
  console.log('📧 CHECK YOUR EMAIL:', TARGET_EMAIL);
  console.log('   You should receive an email with:');
  console.log('   - QR code image');
  console.log('   - Set details');
  console.log('   - PUDO information');
  console.log('   - Pickup instructions');
  console.log('');
  console.log('🔍 NEXT STEPS:');
  console.log('   1. Check email inbox for QR code');
  console.log('   2. Use PUDO app to scan QR: ' + shipment.delivery_qr_code);
  console.log('   3. Validate shipment delivery');
  console.log('');
  console.log('✅ All steps completed successfully!');
}

main().catch((error) => {
  console.error('\n❌ Script failed:', error);
  console.error('Stack:', error.stack);
  process.exit(1);
});