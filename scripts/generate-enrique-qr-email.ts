#!/usr/bin/env node
/**
 * Script para generar y enviar QR code + email para Enrique Perez
 * Simula que acabamos de imprimir la etiqueta y el usuario debe ir a recogerlo al PUDO
 */

const SUPABASE_URL = 'http://127.0.0.1:54331';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const SHIPMENT_ID = '4bcd6eb3-c99c-4456-8a7a-57901f5a3a69';
const USER_NAME = 'Enrique Perez';
const USER_EMAIL = 'enriqueperezbcn1973@gmail.com';

async function generateQRAndEmail() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('🧱 BRICKSHARE - Generación de QR y Email');
  console.log('═══════════════════════════════════════════════════════════\n');
  
  console.log('📋 Información del envío:');
  console.log(`   Usuario: ${USER_NAME}`);
  console.log(`   Email: ${USER_EMAIL}`);
  console.log(`   Shipment ID: ${SHIPMENT_ID}`);
  console.log(`   Tipo: delivery (entrega)\n`);

  try {
    console.log('🚀 Invocando Edge Function send-brickshare-qr-email...\n');

    const response = await fetch(
      `${SUPABASE_URL}/functions/v1/send-brickshare-qr-email`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
        body: JSON.stringify({
          shipment_id: SHIPMENT_ID,
          type: 'delivery'
        })
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('❌ Error en la respuesta:', response.status, response.statusText);
      console.error('   Detalle:', errorText);
      process.exit(1);
    }

    const result = await response.json();
    
    console.log('✅ Email enviado exitosamente!\n');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('📊 RESULTADO:');
    console.log('═══════════════════════════════════════════════════════════\n');
    console.log(`✓ Email ID: ${result.email_id}`);
    console.log(`✓ QR Code Usuario: ${result.qr_code}`);
    console.log(`✓ QR Code Recepción: ${result.reception_qr_code}\n`);

    // Guardar el HTML del email para visualización
    if (result.label_html) {
      const fs = require('fs');
      const labelPath = 'label-enrique-delivery.html';
      fs.writeFileSync(labelPath, result.label_html);
      console.log(`📄 Etiqueta PUDO guardada en: ${labelPath}\n`);
    }

    console.log('═══════════════════════════════════════════════════════════');
    console.log('📧 EMAIL ENVIADO A:');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`   ${USER_EMAIL}`);
    console.log('   (En desarrollo, va a sandbox: enriqueperezbcn1973@gmail.com)\n');

    console.log('═══════════════════════════════════════════════════════════');
    console.log('📱 CÓDIGO QR PARA EL USUARIO:');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`\n   ${result.qr_code}\n`);
    console.log('   El usuario debe presentar este QR en el PUDO Brickshare');
    console.log('   para recoger su set LEGO 21004\n');

    console.log('═══════════════════════════════════════════════════════════');
    console.log('✅ PROCESO COMPLETADO');
    console.log('═══════════════════════════════════════════════════════════\n');
    console.log('Próximos pasos:');
    console.log('1. El usuario recibió el email con el QR');
    console.log('2. Debe ir al PUDO Brickshare (brickshare-001)');
    console.log('3. Presentar el QR al personal');
    console.log('4. Personal escanea y entrega el set\n');

    console.log('💡 Puedes ver el email en Mailpit: http://127.0.0.1:54334\n');

  } catch (error) {
    console.error('❌ Error al generar QR y email:', error);
    process.exit(1);
  }
}

// Ejecutar
generateQRAndEmail();