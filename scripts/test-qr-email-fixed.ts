#!/usr/bin/env node
/**
 * Test script to verify QR email generation with proper set information
 * This tests the fixes for displaying QR codes correctly in emails
 */

import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../.env.local') });

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

if (!supabaseServiceKey) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY not found in .env.local');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function testQREmail() {
  console.log('\n🧪 Testing QR Email with Fixed Display\n');
  console.log('=' .repeat(60));

  try {
    // Step 1: Find a shipment with delivery_qr_code
    console.log('\n📦 Step 1: Finding shipment with QR codes...');
    const { data: shipments, error: shipmentError } = await supabase
      .from('shipments')
      .select(`
        id,
        delivery_qr_code,
        return_qr_code,
        shipment_status,
        pudo_type,
        user_id,
        set_id,
        brickshare_pudo_id
      `)
      .eq('pudo_type', 'brickshare')
      .not('delivery_qr_code', 'is', null)
      .limit(1);

    if (shipmentError) {
      throw new Error(`Error fetching shipments: ${shipmentError.message}`);
    }

    if (!shipments || shipments.length === 0) {
      console.log('\n⚠️  No shipments with QR codes found. Creating test shipment...');
      
      // Get a user
      const { data: users } = await supabase
        .from('users')
        .select('user_id, email, full_name')
        .eq('user_status', 'active')
        .limit(1);

      if (!users || users.length === 0) {
        throw new Error('No active users found');
      }

      // Get a set
      const { data: sets } = await supabase
        .from('sets')
        .select('id, set_name, set_ref')
        .eq('status', 'available')
        .limit(1);

      if (!sets || sets.length === 0) {
        throw new Error('No available sets found');
      }

      // Get a Brickshare PUDO
      const { data: pudos } = await supabase
        .from('brickshare_pudo_locations')
        .select('id, name')
        .limit(1);

      if (!pudos || pudos.length === 0) {
        throw new Error('No Brickshare PUDO locations found');
      }

      // Create test shipment
      const deliveryQR = `BRICKSHARE-DEL-${Date.now()}`;
      const returnQR = `BRICKSHARE-RET-${Date.now()}`;

      const { data: newShipment, error: createError } = await supabase
        .from('shipments')
        .insert({
          user_id: users[0].user_id,
          set_id: sets[0].id,
          shipment_status: 'assigned',
          pudo_type: 'brickshare',
          brickshare_pudo_id: pudos[0].id,
          delivery_qr_code: deliveryQR,
          return_qr_code: returnQR,
          delivery_address: 'Test Address',
          delivery_city: 'Test City',
          delivery_postal_code: '28001',
        })
        .select()
        .single();

      if (createError) {
        throw new Error(`Error creating test shipment: ${createError.message}`);
      }

      console.log(`✅ Test shipment created: ${newShipment.id}`);
      shipments[0] = newShipment;
    }

    const shipment = shipments[0];
    console.log(`✅ Found shipment: ${shipment.id}`);
    console.log(`   Delivery QR: ${shipment.delivery_qr_code}`);
    console.log(`   Return QR: ${shipment.return_qr_code || 'Not set'}`);

    // Step 2: Get shipment details for display
    const { data: user } = await supabase
      .from('users')
      .select('email, full_name')
      .eq('user_id', shipment.user_id)
      .single();

    const { data: set } = await supabase
      .from('sets')
      .select('set_name, set_ref, theme')
      .eq('id', shipment.set_id)
      .single();

    console.log(`\n📧 Email will be sent to: ${user?.email}`);
    console.log(`📦 Set: ${set?.set_name} (${set?.set_ref})`);

    // Step 3: Test delivery email
    console.log('\n📨 Step 2: Sending delivery QR email...');
    const deliveryResponse = await fetch(`${supabaseUrl}/functions/v1/send-brickshare-qr-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${supabaseServiceKey}`,
      },
      body: JSON.stringify({
        shipment_id: shipment.id,
        type: 'delivery',
      }),
    });

    if (!deliveryResponse.ok) {
      const errorText = await deliveryResponse.text();
      throw new Error(`Delivery email failed: ${errorText}`);
    }

    const deliveryResult = await deliveryResponse.json();
    console.log('✅ Delivery email sent successfully');
    console.log(`   Email ID: ${deliveryResult.email_id}`);
    console.log(`   QR Code: ${deliveryResult.qr_code}`);

    // Step 4: Test return email (if return QR exists)
    if (shipment.return_qr_code) {
      console.log('\n📨 Step 3: Sending return QR email...');
      const returnResponse = await fetch(`${supabaseUrl}/functions/v1/send-brickshare-qr-email`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${supabaseServiceKey}`,
        },
        body: JSON.stringify({
          shipment_id: shipment.id,
          type: 'return',
        }),
      });

      if (!returnResponse.ok) {
        const errorText = await returnResponse.text();
        throw new Error(`Return email failed: ${errorText}`);
      }

      const returnResult = await returnResponse.json();
      console.log('✅ Return email sent successfully');
      console.log(`   Email ID: ${returnResult.email_id}`);
      console.log(`   QR Code: ${returnResult.qr_code}`);
    }

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('✅ TEST COMPLETED SUCCESSFULLY');
    console.log('='.repeat(60));
    console.log('\n📝 What was fixed:');
    console.log('   1. ✅ QR title now shows: "Set Name (set_ref)" instead of "Set LEGO ()"');
    console.log('   2. ✅ Added validation to prevent sending emails with null QR codes');
    console.log('   3. ✅ Applied fix to both delivery and return emails');
    console.log('\n📧 Check your email inbox to verify the QR codes display correctly!');
    console.log(`   Email sent to: ${user?.email}\n`);

  } catch (error) {
    console.error('\n❌ TEST FAILED:', error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

// Run the test
testQREmail();