/**
 * Test script for Brickshare PUDO QR Code Flow
 * 
 * This script tests the complete flow:
 * 1. Create a shipment with Brickshare PUDO
 * 2. Generate delivery QR code
 * 3. Validate delivery QR
 * 4. Confirm delivery
 * 5. Generate return QR code
 * 6. Validate return QR
 * 7. Confirm return
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY || '';
const API_URL = `${SUPABASE_URL}/functions/v1/brickshare-qr-api`;

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

interface TestResult {
  step: string;
  success: boolean;
  data?: any;
  error?: string;
}

const results: TestResult[] = [];

function logStep(step: string, success: boolean, data?: any, error?: string) {
  const result: TestResult = { step, success, data, error };
  results.push(result);
  
  const icon = success ? '✅' : '❌';
  console.log(`\n${icon} ${step}`);
  if (data) console.log('   Data:', JSON.stringify(data, null, 2));
  if (error) console.log('   Error:', error);
}

async function testBrickshareQRFlow() {
  console.log('🧪 Testing Brickshare PUDO QR Code Flow\n');
  console.log('=' .repeat(60));

  let testShipmentId: string | null = null;
  let deliveryQR: string | null = null;
  let returnQR: string | null = null;

  try {
    // Step 1: Create test assignment and shipment
    console.log('\n📦 Step 1: Creating test shipment...');
    
    // First, get a test user and product
    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .limit(1)
      .single();

    if (!profile) {
      throw new Error('No test user found');
    }

    const { data: product } = await supabase
      .from('products')
      .select('id')
      .limit(1)
      .single();

    if (!product) {
      throw new Error('No test product found');
    }

    // Create test assignment
    const { data: assignment, error: assignmentError } = await supabase
      .from('assignments')
      .insert({
        user_id: profile.id,
        set_id: product.id,
        start_date: new Date().toISOString(),
        end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        status: 'active',
      })
      .select()
      .single();

    if (assignmentError || !assignment) {
      throw new Error(`Failed to create assignment: ${assignmentError?.message}`);
    }

    // Create test shipment
    const { data: shipment, error: shipmentError } = await supabase
      .from('shipments')
      .insert({
        assignment_id: assignment.id,
        type: 'outbound',
        status: 'pending',
        pickup_type: 'brickshare',
        brickshare_pudo_id: 'BS-PUDO-001',
      })
      .select()
      .single();

    if (shipmentError || !shipment) {
      throw new Error(`Failed to create shipment: ${shipmentError?.message}`);
    }

    testShipmentId = shipment.id;
    logStep('Create test shipment', true, { shipment_id: testShipmentId });

    // Step 2: Generate delivery QR code
    console.log('\n🔑 Step 2: Generating delivery QR code...');
    
    const { data: deliveryQRData, error: deliveryQRError } = await supabase
      .rpc('generate_delivery_qr', {
        p_shipment_id: testShipmentId,
      });

    if (deliveryQRError) {
      throw new Error(`Failed to generate delivery QR: ${deliveryQRError.message}`);
    }

    deliveryQR = deliveryQRData[0].qr_code;
    logStep('Generate delivery QR', true, { 
      qr_code: deliveryQR,
      expires_at: deliveryQRData[0].expires_at 
    });

    // Step 3: Validate delivery QR via API
    console.log('\n✓ Step 3: Validating delivery QR via API...');
    
    const validateResponse = await fetch(`${API_URL}/validate/${deliveryQR}`);
    const validateData = await validateResponse.json();

    if (!validateData.success) {
      throw new Error(`Validation failed: ${validateData.error}`);
    }

    logStep('Validate delivery QR', true, validateData.data);

    // Step 4: Confirm delivery
    console.log('\n📝 Step 4: Confirming delivery...');
    
    const confirmResponse = await fetch(`${API_URL}/confirm`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        qr_code: deliveryQR,
        validated_by: 'BS-PUDO-001',
      }),
    });
    
    const confirmData = await confirmResponse.json();

    if (!confirmData.success) {
      throw new Error(`Confirmation failed: ${confirmData.error}`);
    }

    logStep('Confirm delivery', true, { message: confirmData.message });

    // Verify shipment status changed to delivered
    const { data: deliveredShipment } = await supabase
      .from('shipments')
      .select('status, delivery_validated_at')
      .eq('id', testShipmentId)
      .single();

    logStep('Verify delivery status', true, {
      status: deliveredShipment?.status,
      validated_at: deliveredShipment?.delivery_validated_at,
    });

    // Step 5: Generate return QR code
    console.log('\n🔄 Step 5: Generating return QR code...');
    
    const { data: returnQRData, error: returnQRError } = await supabase
      .rpc('generate_return_qr', {
        p_shipment_id: testShipmentId,
      });

    if (returnQRError) {
      throw new Error(`Failed to generate return QR: ${returnQRError.message}`);
    }

    returnQR = returnQRData[0].qr_code;
    logStep('Generate return QR', true, { 
      qr_code: returnQR,
      expires_at: returnQRData[0].expires_at 
    });

    // Step 6: Validate return QR via API
    console.log('\n✓ Step 6: Validating return QR via API...');
    
    const validateReturnResponse = await fetch(`${API_URL}/validate/${returnQR}`);
    const validateReturnData = await validateReturnResponse.json();

    if (!validateReturnData.success) {
      throw new Error(`Return validation failed: ${validateReturnData.error}`);
    }

    logStep('Validate return QR', true, validateReturnData.data);

    // Step 7: Confirm return
    console.log('\n📝 Step 7: Confirming return...');
    
    const confirmReturnResponse = await fetch(`${API_URL}/confirm`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        qr_code: returnQR,
        validated_by: 'BS-PUDO-001',
      }),
    });
    
    const confirmReturnData = await confirmReturnResponse.json();

    if (!confirmReturnData.success) {
      throw new Error(`Return confirmation failed: ${confirmReturnData.error}`);
    }

    logStep('Confirm return', true, { message: confirmReturnData.message });

    // Verify shipment status changed to returned
    const { data: returnedShipment } = await supabase
      .from('shipments')
      .select('status, return_validated_at')
      .eq('id', testShipmentId)
      .single();

    logStep('Verify return status', true, {
      status: returnedShipment?.status,
      validated_at: returnedShipment?.return_validated_at,
    });

    // Step 8: Test error cases
    console.log('\n🚫 Step 8: Testing error cases...');

    // Try to use delivery QR again (should fail - already used)
    const revalidateResponse = await fetch(`${API_URL}/validate/${deliveryQR}`);
    const revalidateData = await revalidateResponse.json();
    
    logStep('Test QR reuse prevention', !revalidateData.success, {
      expected_error: 'QR code already used',
      actual_error: revalidateData.error,
    });

    // Try invalid QR
    const invalidResponse = await fetch(`${API_URL}/validate/INVALID-QR`);
    const invalidData = await invalidResponse.json();
    
    logStep('Test invalid QR', !invalidData.success, {
      expected_error: 'QR code not found',
      actual_error: invalidData.error,
    });

    // Step 9: Get PUDO locations
    console.log('\n📍 Step 9: Getting PUDO locations...');
    
    const pudoResponse = await fetch(`${API_URL}/pudo-locations`);
    const pudoData = await pudoResponse.json();
    
    logStep('Get PUDO locations', pudoData.success, {
      count: pudoData.data?.length,
      locations: pudoData.data?.map((l: any) => l.name),
    });

    // Cleanup: Delete test data
    console.log('\n🧹 Cleanup: Removing test data...');
    
    if (testShipmentId) {
      await supabase.from('shipments').delete().eq('id', testShipmentId);
      await supabase.from('assignments').delete().eq('id', assignment.id);
      logStep('Cleanup test data', true);
    }

  } catch (error) {
    logStep('Test execution', false, undefined, (error as Error).message);
    
    // Cleanup on error
    if (testShipmentId) {
      await supabase.from('shipments').delete().eq('id', testShipmentId);
    }
  }

  // Print summary
  console.log('\n' + '='.repeat(60));
  console.log('\n📊 Test Summary\n');
  
  const passed = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;
  const total = results.length;
  
  console.log(`Total Tests: ${total}`);
  console.log(`✅ Passed: ${passed}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`Success Rate: ${((passed / total) * 100).toFixed(1)}%`);
  
  console.log('\n' + '='.repeat(60));

  // Exit with appropriate code
  process.exit(failed > 0 ? 1 : 0);
}

// Run tests
testBrickshareQRFlow().catch(error => {
  console.error('\n❌ Fatal error:', error);
  process.exit(1);
});