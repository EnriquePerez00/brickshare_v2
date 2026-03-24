#!/usr/bin/env tsx
/**
 * Test Assignment Flow with QR Code Generation
 * 
 * This script:
 * 1. Verifies user enriquepeto@yahoo.es exists and has active subscription
 * 2. Checks wishlist and inventory availability
 * 3. Previews assignment
 * 4. Confirms assignment (creates shipment with status='pending')
 * 5. Generates logistics package and QR code
 * 6. Sends real email with QR to enriquepeto@yahoo.es
 * 7. Displays QR data for testing with PUDO app
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
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

const TARGET_EMAIL = 'enriquepeto@yahoo.es';

async function main() {
  console.log('🚀 Starting Assignment Flow Test for', TARGET_EMAIL);
  console.log('═'.repeat(70));

  // Step 1: Verify user exists and has active subscription
  console.log('\n📋 Step 1: Verifying user...');
  const { data: user, error: userError } = await supabase
    .from('users')
    .select('*')
    .eq('email', TARGET_EMAIL)
    .single();

  if (userError || !user) {
    console.error('❌ User not found:', userError?.message);
    process.exit(1);
  }

  console.log('✅ User found:');
  console.log('   - Name:', user.full_name);
  console.log('   - ID:', user.user_id);
  console.log('   - Status:', user.user_status);
  console.log('   - Subscription:', user.subscription_status);
  console.log('   - Address:', user.address || 'NOT SET');
  console.log('   - City:', user.city || 'NOT SET');
  console.log('   - Postal Code:', user.postal_code || 'NOT SET');

  // Step 2: Check wishlist
  console.log('\n📋 Step 2: Checking wishlist...');
  const { data: wishlistItems, error: wishlistError } = await supabase
    .from('wishlist')
    .select(`
      set_id,
      sets (
        id,
        set_name,
        set_ref,
        set_price
      )
    `)
    .eq('user_id', user.user_id);

  if (wishlistError || !wishlistItems || wishlistItems.length === 0) {
    console.error('❌ No items in wishlist:', wishlistError?.message);
    process.exit(1);
  }

  console.log(`✅ Wishlist has ${wishlistItems.length} items:`);
  wishlistItems.forEach((item: any, idx) => {
    console.log(`   ${idx + 1}. ${item.sets.set_name} (${item.sets.set_ref}) - €${item.sets.set_price}`);
  });

  // Step 3: Check inventory availability
  console.log('\n📋 Step 3: Checking inventory...');
  const setIds = wishlistItems.map((item: any) => item.set_id);
  const { data: inventory, error: inventoryError } = await supabase
    .from('inventory_sets')
    .select('*')
    .in('set_id', setIds)
    .gt('inventory_set_available_qty', 0);

  if (inventoryError || !inventory || inventory.length === 0) {
    console.error('❌ No available inventory for wishlist items:', inventoryError?.message);
    process.exit(1);
  }

  console.log(`✅ ${inventory.length} sets available in inventory`);

  // Step 4: Preview assignment
  console.log('\n📋 Step 4: Previewing assignment...');
  const { data: preview, error: previewError } = await supabase
    .rpc('preview_assign_sets_to_users');

  if (previewError) {
    console.error('❌ Preview error:', previewError.message);
    process.exit(1);
  }

  const userPreview = preview?.find((p: any) => p.user_id === user.user_id);
  
  if (!userPreview) {
    console.log('⚠️  No assignment proposal for this user');
    console.log('   This could mean:');
    console.log('   - User status is not eligible (must be "sin set")');
    console.log('   - No stock available for wishlist items');
    process.exit(1);
  }

  console.log('✅ Assignment preview:');
  console.log('   - User:', userPreview.user_name);
  console.log('   - Set:', userPreview.set_name);
  console.log('   - Ref:', userPreview.set_ref);
  console.log('   - Price: €' + userPreview.set_price);
  console.log('   - Current Stock:', userPreview.current_stock);

  // Step 5: Confirm assignment (creates shipment)
  console.log('\n📋 Step 5: Confirming assignment (creating shipment)...');
  const { data: confirmed, error: confirmError } = await supabase
    .rpc('confirm_assign_sets_to_users', {
      p_user_ids: [user.user_id]
    });

  if (confirmError) {
    console.error('❌ Confirmation error:', confirmError.message);
    process.exit(1);
  }

  if (!confirmed || confirmed.length === 0) {
    console.error('❌ No shipment was created');
    process.exit(1);
  }

  const shipment = confirmed[0];
  console.log('✅ Shipment created:');
  console.log('   - Shipment ID:', shipment.shipment_id);
  console.log('   - User:', shipment.user_name);
  console.log('   - Set:', shipment.set_name, '(' + shipment.set_ref + ')');
  console.log('   - Price: €' + shipment.set_price);
  console.log('   - Created:', new Date(shipment.created_at).toLocaleString());

  // Verify shipment was created with correct status
  const { data: shipmentData, error: shipmentError } = await supabase
    .from('shipments')
    .select('*')
    .eq('id', shipment.shipment_id)
    .single();

  if (shipmentError || !shipmentData) {
    console.error('❌ Could not fetch shipment data:', shipmentError?.message);
    process.exit(1);
  }

  console.log('✅ Shipment status:', shipmentData.shipment_status);
  
  if (shipmentData.shipment_status !== 'pending') {
    console.error('❌ Unexpected shipment status:', shipmentData.shipment_status);
    process.exit(1);
  }

  // Step 6: Generate logistics package and QR code
  console.log('\n📋 Step 6: Generating QR code...');
  
  const qrCode = `BS-${shipment.shipment_id.substring(0, 8).toUpperCase()}`;
  const qrExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  
  const { error: updateError } = await supabase
    .from('shipments')
    .update({
      delivery_qr_code: qrCode,
      delivery_qr_expires_at: qrExpiresAt.toISOString(),
      pickup_type: 'brickshare',
      updated_at: new Date().toISOString()
    })
    .eq('id', shipment.shipment_id);

  if (updateError) {
    console.error('❌ Error updating shipment with QR:', updateError.message);
    process.exit(1);
  }

  console.log('✅ QR Code generated:');
  console.log('   - Code:', qrCode);
  console.log('   - Expires:', qrExpiresAt.toLocaleString());

  // Step 7: Send email with QR code
  console.log('\n📋 Step 7: Sending email with QR code...');
  
  try {
    const { data: emailResult, error: emailError } = await supabase.functions.invoke(
      'send-brickshare-qr-email',
      {
        body: {
          shipment_id: shipment.shipment_id,
          type: 'delivery'
        }
      }
    );

    if (emailError) {
      console.error('❌ Email error:', emailError.message);
    } else if (emailResult?.success) {
      console.log('✅ Email sent successfully!');
      console.log('   - Email ID:', emailResult.email_id);
      console.log('   - QR Code in email:', emailResult.qr_code);
    } else {
      console.error('❌ Email failed:', emailResult?.error);
    }
  } catch (error: any) {
    console.error('❌ Email exception:', error.message);
  }

  // Final summary
  console.log('\n' + '═'.repeat(70));
  console.log('🎉 ASSIGNMENT FLOW COMPLETED');
  console.log('═'.repeat(70));
  console.log('\n📧 CHECK YOUR EMAIL:', TARGET_EMAIL);
  console.log('\n🔍 QR CODE FOR TESTING:');
  console.log('   Code:', qrCode);
  console.log('   Shipment ID:', shipment.shipment_id);
  console.log('   Set:', shipment.set_name, '(' + shipment.set_ref + ')');
  console.log('\n📱 Use this QR code in your PUDO simulation app to validate the pickup process');
  console.log('\n✅ All steps completed successfully!');
}

main().catch((error) => {
  console.error('\n❌ Script failed:', error);
  process.exit(1);
});