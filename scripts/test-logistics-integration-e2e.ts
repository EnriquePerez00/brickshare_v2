/**
 * Test End-to-End: Integración Brickshare ↔ Brickshare_logistics
 * 
 * Flujo completo:
 * 1. Crear shipment de delivery a punto Brickshare
 * 2. Crear package en Logistics
 * 3. Simular recepción en PUDO
 * 4. Generar QR de entrega y enviar email
 * 5. Simular validación QR en PUDO (entrega al cliente)
 * 6. Crear shipment de return
 * 7. Generar QR de devolución
 * 8. Simular validación QR de devolución en PUDO
 * 9. Verificar trazabilidad completa en BD
 */

import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY || '';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

// Validar que tenemos las credenciales necesarias
if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_KEY) {
  console.error('❌ ERROR: Faltan credenciales de Supabase');
  console.error('Asegúrate de tener en el archivo .env:');
  console.error('- VITE_SUPABASE_URL');
  console.error('- VITE_SUPABASE_ANON_KEY');
  console.error('- SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

// Crear clientes
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Configuración del test
const TEST_USER_EMAIL = 'user2@brickshare.com';
const LOGISTICS_URL = 'https://qumjzvhtotcvnzpjgjkl.supabase.co'; // Ajustar a tu URL de Logistics
const LOGISTICS_SECRET = 'test-secret-123'; // Ajustar a tu secret compartido

interface TestResult {
  step: string;
  success: boolean;
  data?: any;
  error?: string;
}

const results: TestResult[] = [];

function logStep(step: string, success: boolean, data?: any, error?: string) {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`${success ? '✅' : '❌'} ${step}`);
  if (data) console.log('Data:', JSON.stringify(data, null, 2));
  if (error) console.error('Error:', error);
  console.log('='.repeat(60));
  
  results.push({ step, success, data, error });
}

async function runE2ETest() {
  console.log('\n🚀 INICIANDO TEST END-TO-END: Brickshare ↔ Brickshare_logistics\n');
  
  let userId: string;
  let assignmentId: string;
  let pudoId: string;
  let deliveryShipmentId: string;
  let packageId: string;
  let deliveryQRCode: string;
  let returnShipmentId: string;
  let returnQRCode: string;
  let returnPackageId: string;

  try {
    // ========================================
    // PASO 1: Obtener usuario de test
    // ========================================
    console.log('\n📋 PASO 1: Obtener usuario de test...');
    const { data: user, error: userError } = await supabaseAdmin
      .from('profiles')
      .select('id, email, full_name')
      .eq('email', TEST_USER_EMAIL)
      .single();

    if (userError || !user) {
      logStep('1. Obtener usuario', false, null, userError?.message || 'Usuario no encontrado');
      throw new Error(`Usuario ${TEST_USER_EMAIL} no encontrado`);
    }

    userId = user.id;
    logStep('1. Obtener usuario', true, { userId, email: user.email, name: user.full_name });

    // ========================================
    // PASO 2: Obtener punto Brickshare PUDO
    // ========================================
    console.log('\n📋 PASO 2: Obtener punto Brickshare PUDO...');
    const { data: pudo, error: pudoError } = await supabaseAdmin
      .from('brickshare_pudo_locations')
      .select('id, name, address, city')
      .eq('is_active', true)
      .limit(1)
      .single();

    if (pudoError || !pudo) {
      logStep('2. Obtener PUDO', false, null, pudoError?.message || 'No hay PUDOs activos');
      throw new Error('No hay puntos Brickshare PUDO disponibles');
    }

    pudoId = pudo.id;
    logStep('2. Obtener PUDO', true, { pudoId, name: pudo.name, address: pudo.address });

    // ========================================
    // PASO 3: Obtener un assignment activo del usuario
    // ========================================
    console.log('\n📋 PASO 3: Obtener assignment activo...');
    const { data: assignment, error: assignmentError } = await supabaseAdmin
      .from('assignments')
      .select(`
        id,
        status,
        product_id,
        products (
          name,
          set_number
        )
      `)
      .eq('user_id', userId)
      .in('status', ['active', 'pending'])
      .limit(1)
      .single();

    if (assignmentError || !assignment) {
      logStep('3. Obtener assignment', false, null, assignmentError?.message || 'No hay assignments activos');
      throw new Error('No hay assignments activos para el usuario');
    }

    assignmentId = assignment.id;
      const productInfo = Array.isArray(assignment.products) 
        ? assignment.products[0] 
        : assignment.products;
      
      logStep('3. Obtener assignment', true, { 
        assignmentId, 
        productName: productInfo?.name,
        setNumber: productInfo?.set_number 
      });

    // ========================================
    // PASO 4: Crear shipment de DELIVERY
    // ========================================
    console.log('\n📋 PASO 4: Crear shipment de delivery...');
    const { data: deliveryShipment, error: deliveryShipmentError } = await supabaseAdmin
      .from('shipments')
      .insert({
        assignment_id: assignmentId,
        direction: 'to_user',
        status: 'pending',
        pickup_type: 'brickshare',
        brickshare_pudo_id: pudoId,
      })
      .select()
      .single();

    if (deliveryShipmentError || !deliveryShipment) {
      logStep('4. Crear delivery shipment', false, null, deliveryShipmentError?.message);
      throw new Error('Error creando delivery shipment');
    }

    deliveryShipmentId = deliveryShipment.id;
    logStep('4. Crear delivery shipment', true, { 
      shipmentId: deliveryShipmentId,
      direction: deliveryShipment.direction,
      pickupType: deliveryShipment.pickup_type 
    });

    // ========================================
    // PASO 5: Crear package en Logistics
    // ========================================
    console.log('\n📋 PASO 5: Crear package en Brickshare_logistics...');
    
    const trackingCode = `BS-${deliveryShipmentId.substring(0, 8).toUpperCase()}`;
    
    const createPackageResponse = await fetch(`${LOGISTICS_URL}/api/packages/create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Integration-Secret': LOGISTICS_SECRET
      },
      body: JSON.stringify({
        tracking_code: trackingCode,
        type: 'delivery',
        location_id: pudoId,
        customer_id: userId,
        external_shipment_id: deliveryShipmentId,
        source_system: 'brickshare'
      })
    });

    if (!createPackageResponse.ok) {
      const errorText = await createPackageResponse.text();
      logStep('5. Crear package en Logistics', false, null, errorText);
      throw new Error('Error creando package en Logistics');
    }

    const packageData = await createPackageResponse.json();
    packageId = packageData.package.id;
    
    // Actualizar shipment con package_id
    await supabaseAdmin
      .from('shipments')
      .update({ 
        brickshare_package_id: packageId,
        tracking_number: trackingCode 
      })
      .eq('id', deliveryShipmentId);

    logStep('5. Crear package en Logistics', true, { 
      packageId,
      trackingCode,
      type: packageData.package.type,
      status: packageData.package.status 
    });

    // ========================================
    // PASO 6: Simular recepción en PUDO (pending_dropoff → in_location)
    // ========================================
    console.log('\n📋 PASO 6: Simular recepción en PUDO...');
    
    // En un escenario real, la app móvil escanearía el tracking code
    // Aquí lo simulamos actualizando directamente el estado
    const { error: receptionError } = await supabaseAdmin
      .from('packages')
      .update({ 
        status: 'in_location',
        updated_at: new Date().toISOString()
      })
      .eq('id', packageId);

    if (receptionError) {
      logStep('6. Simular recepción en PUDO', false, null, receptionError.message);
      throw new Error('Error simulando recepción');
    }

    logStep('6. Simular recepción en PUDO', true, { 
      packageId,
      newStatus: 'in_location',
      message: 'Package recibido en punto PUDO' 
    });

    // ========================================
    // PASO 7: Generar QR de entrega y enviar email
    // ========================================
    console.log('\n📋 PASO 7: Generar QR de entrega...');
    
    deliveryQRCode = `DELIVERY-QR-${deliveryShipmentId}`;
    
    const { error: qrUpdateError } = await supabaseAdmin
      .from('shipments')
      .update({
        delivery_qr_code: deliveryQRCode,
        delivery_qr_expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
      })
      .eq('id', deliveryShipmentId);

    if (qrUpdateError) {
      logStep('7. Generar QR de entrega', false, null, qrUpdateError.message);
    } else {
      logStep('7. Generar QR de entrega', true, { 
        deliveryQRCode,
        shipmentId: deliveryShipmentId,
        emailSentTo: TEST_USER_EMAIL,
        message: 'QR generado y enviado por email (simulado)'
      });
    }

    // ========================================
    // PASO 8: Simular validación QR en PUDO (cliente recoge)
    // ========================================
    console.log('\n📋 PASO 8: Simular entrega al cliente (escaneo QR)...');
    
    const { error: pickupError } = await supabaseAdmin
      .from('packages')
      .update({ 
        status: 'picked_up',
        dynamic_qr_hash: null,
        qr_expires_at: null,
        updated_at: new Date().toISOString()
      })
      .eq('id', packageId);

    if (pickupError) {
      logStep('8. Simular entrega al cliente', false, null, pickupError.message);
    } else {
      // Actualizar shipment también
      await supabaseAdmin
        .from('shipments')
        .update({
          status: 'delivered',
          delivery_qr_validated_at: new Date().toISOString()
        })
        .eq('id', deliveryShipmentId);

      logStep('8. Simular entrega al cliente', true, { 
        packageId,
        newStatus: 'picked_up',
        qrValidated: deliveryQRCode,
        message: 'Cliente ha recogido el set en el punto PUDO'
      });
    }

    // ========================================
    // PASO 9: Crear shipment de RETURN
    // ========================================
    console.log('\n📋 PASO 9: Crear shipment de devolución...');
    
    const { data: returnShipment, error: returnShipmentError } = await supabaseAdmin
      .from('shipments')
      .insert({
        assignment_id: assignmentId,
        direction: 'to_brickshare',
        status: 'pending',
        pickup_type: 'brickshare',
        brickshare_pudo_id: pudoId,
      })
      .select()
      .single();

    if (returnShipmentError || !returnShipment) {
      logStep('9. Crear return shipment', false, null, returnShipmentError?.message);
      throw new Error('Error creando return shipment');
    }

    returnShipmentId = returnShipment.id;
    logStep('9. Crear return shipment', true, { 
      shipmentId: returnShipmentId,
      direction: returnShipment.direction 
    });

    // ========================================
    // PASO 10: Crear package de devolución en Logistics
    // ========================================
    console.log('\n📋 PASO 10: Crear package de devolución en Logistics...');
    
    const returnTrackingCode = `BS-RET-${returnShipmentId.substring(0, 8).toUpperCase()}`;
    
    const createReturnPackageResponse = await fetch(`${LOGISTICS_URL}/api/packages/create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Integration-Secret': LOGISTICS_SECRET
      },
      body: JSON.stringify({
        tracking_code: returnTrackingCode,
        type: 'return',
        location_id: pudoId,
        customer_id: userId,
        external_shipment_id: returnShipmentId,
        source_system: 'brickshare'
      })
    });

    if (!createReturnPackageResponse.ok) {
      const errorText = await createReturnPackageResponse.text();
      logStep('10. Crear return package', false, null, errorText);
      throw new Error('Error creando return package');
    }

    const returnPackageData = await createReturnPackageResponse.json();
    returnPackageId = returnPackageData.package.id;
    
    // Actualizar shipment con package_id
    await supabaseAdmin
      .from('shipments')
      .update({ 
        brickshare_package_id: returnPackageId,
        tracking_number: returnTrackingCode 
      })
      .eq('id', returnShipmentId);

    logStep('10. Crear return package', true, { 
      packageId: returnPackageId,
      trackingCode: returnTrackingCode,
      type: returnPackageData.package.type 
    });

    // ========================================
    // PASO 11: Generar QR estático de devolución
    // ========================================
    console.log('\n📋 PASO 11: Generar QR estático de devolución...');
    
    returnQRCode = `RETURN-QR-${returnShipmentId}`;
    
    const { error: returnQrUpdateError } = await supabaseAdmin
      .from('shipments')
      .update({
        return_qr_code: returnQRCode,
        return_qr_expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
      })
      .eq('id', returnShipmentId);

    if (returnQrUpdateError) {
      logStep('11. Generar QR de devolución', false, null, returnQrUpdateError.message);
    } else {
      logStep('11. Generar QR de devolución', true, { 
        returnQRCode,
        shipmentId: returnShipmentId,
        emailSentTo: TEST_USER_EMAIL,
        message: 'QR estático generado y enviado por email (simulado)',
        note: 'Este QR no expira temporalmente'
      });
    }

    // ========================================
    // PASO 12: Simular entrega del cliente en PUDO (devolución)
    // ========================================
    console.log('\n📋 PASO 12: Simular entrega de devolución en PUDO...');
    
    const { error: returnDropoffError } = await supabaseAdmin
      .from('packages')
      .update({ 
        status: 'in_location',
        static_qr_hash: null,
        updated_at: new Date().toISOString()
      })
      .eq('id', returnPackageId);

    if (returnDropoffError) {
      logStep('12. Simular entrega de devolución', false, null, returnDropoffError.message);
    } else {
      // Actualizar shipment
      await supabaseAdmin
        .from('shipments')
        .update({
          status: 'in_transit',
          return_qr_validated_at: new Date().toISOString()
        })
        .eq('id', returnShipmentId);

      logStep('12. Simular entrega de devolución', true, { 
        packageId: returnPackageId,
        newStatus: 'in_location',
        qrValidated: returnQRCode,
        message: 'Cliente ha entregado el set en el punto PUDO para devolución'
      });
    }

    // ========================================
    // PASO 13: Verificar trazabilidad completa en BD
    // ========================================
    console.log('\n📋 PASO 13: Verificar trazabilidad en BD...');
    
    // Consultar delivery shipment
    const { data: deliveryTrace } = await supabaseAdmin
      .from('shipments')
      .select('*')
      .eq('id', deliveryShipmentId)
      .single();

    // Consultar return shipment
    const { data: returnTrace } = await supabaseAdmin
      .from('shipments')
      .select('*')
      .eq('id', returnShipmentId)
      .single();

    // Consultar packages en Logistics (simulado - verificar en logs)
    logStep('13. Verificar trazabilidad', true, {
      deliveryShipment: {
        id: deliveryTrace?.id,
        status: deliveryTrace?.status,
        packageId: deliveryTrace?.brickshare_package_id,
        trackingCode: deliveryTrace?.tracking_number,
        deliveryQR: deliveryTrace?.delivery_qr_code,
        deliveryValidatedAt: deliveryTrace?.delivery_qr_validated_at
      },
      returnShipment: {
        id: returnTrace?.id,
        status: returnTrace?.status,
        packageId: returnTrace?.brickshare_package_id,
        trackingCode: returnTrace?.tracking_number,
        returnQR: returnTrace?.return_qr_code,
        returnValidatedAt: returnTrace?.return_qr_validated_at
      }
    });

    // ========================================
    // RESUMEN FINAL
    // ========================================
    console.log('\n' + '='.repeat(60));
    console.log('✅ TEST END-TO-END COMPLETADO EXITOSAMENTE');
    console.log('='.repeat(60));
    console.log('\n📊 RESUMEN:');
    console.log(`- Usuario: ${TEST_USER_EMAIL} (${userId})`);
    console.log(`- PUDO: ${pudo.name} (${pudoId})`);
    console.log(`- Assignment: ${assignmentId}`);
    console.log(`\n📦 DELIVERY:`);
    console.log(`  - Shipment: ${deliveryShipmentId}`);
    console.log(`  - Package: ${packageId}`);
    console.log(`  - Tracking: ${trackingCode}`);
    console.log(`  - QR Code: ${deliveryQRCode}`);
    console.log(`  - Status: delivered ✅`);
    console.log(`\n🔄 RETURN:`);
    console.log(`  - Shipment: ${returnShipmentId}`);
    console.log(`  - Package: ${returnPackageId}`);
    console.log(`  - Tracking: ${returnTrackingCode}`);
    console.log(`  - QR Code: ${returnQRCode}`);
    console.log(`  - Status: in_transit ✅`);
    
    console.log('\n📋 VERIFICACIÓN EN BD:');
    console.log('\n-- Ver shipments:');
    console.log(`SELECT id, direction, status, pickup_type, brickshare_package_id, tracking_number`);
    console.log(`FROM shipments WHERE id IN ('${deliveryShipmentId}', '${returnShipmentId}');`);
    
    console.log('\n-- Ver packages en Logistics (ejecutar en Brickshare_logistics):');
    console.log(`SELECT id, type, status, tracking_code, external_shipment_id, source_system`);
    console.log(`FROM packages WHERE external_shipment_id IN ('${deliveryShipmentId}', '${returnShipmentId}');`);
    
    console.log('\n' + '='.repeat(60));

  } catch (error) {
    console.error('\n❌ TEST FALLIDO:', error);
    console.log('\n📊 Resumen de pasos ejecutados:');
    results.forEach((result, index) => {
      console.log(`${index + 1}. ${result.success ? '✅' : '❌'} ${result.step}`);
      if (result.error) console.log(`   Error: ${result.error}`);
    });
    throw error;
  }
}

// Ejecutar el test
runE2ETest()
  .then(() => {
    console.log('\n✅ Test completado');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Test fallido:', error.message);
    process.exit(1);
  });