#!/usr/bin/env node
/**
 * Script para obtener y visualizar el email enviado a Enrique Perez desde Resend API
 */

const EMAIL_ID = '62a41477-45a7-4173-89c3-6565aa83d5cf';

async function getEmailFromResend() {
  const RESEND_API_KEY = process.env.RESEND_API_KEY || 're_Wh2cTfZZ_3HjFJz6EhC3e65xpzxG3SCSB';

  console.log('═══════════════════════════════════════════════════════════');
  console.log('📧 OBTENIENDO EMAIL DESDE RESEND API');
  console.log('═══════════════════════════════════════════════════════════\n');
  console.log(`Email ID: ${EMAIL_ID}\n`);

  try {
    const response = await fetch(`https://api.resend.com/emails/${EMAIL_ID}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('❌ Error al obtener email:', response.status, response.statusText);
      console.error('   Detalle:', errorText);
      process.exit(1);
    }

    const emailData = await response.json();
    
    console.log('✅ Email obtenido exitosamente!\n');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('📊 DETALLES DEL EMAIL:');
    console.log('═══════════════════════════════════════════════════════════\n');
    console.log(`De: ${emailData.from}`);
    console.log(`Para: ${emailData.to}`);
    console.log(`Asunto: ${emailData.subject}`);
    console.log(`Estado: ${emailData.last_event || 'pending'}`);
    console.log(`Creado: ${emailData.created_at}\n`);

    // Guardar el HTML del email
    if (emailData.html) {
      const fs = require('fs');
      const emailPath = 'email-enrique-delivery-qr.html';
      fs.writeFileSync(emailPath, emailData.html);
      console.log(`📄 Contenido HTML guardado en: ${emailPath}\n`);
    }

    console.log('═══════════════════════════════════════════════════════════');
    console.log('📱 CONTENIDO DEL EMAIL (PREVIEW):');
    console.log('═══════════════════════════════════════════════════════════\n');
    
    // Mostrar preview del contenido
    if (emailData.html) {
      const htmlPreview = emailData.html
        .replace(/<[^>]*>/g, ' ')  // Remove HTML tags
        .replace(/\s+/g, ' ')       // Normalize whitespace
        .trim()
        .substring(0, 500);
      console.log(htmlPreview + '...\n');
    }

    console.log('═══════════════════════════════════════════════════════════');
    console.log('✅ PROCESO COMPLETADO');
    console.log('═══════════════════════════════════════════════════════════\n');
    console.log('Para visualizar el email completo:');
    console.log('1. Abre: email-enrique-delivery-qr.html en tu navegador');
    console.log('2. O visita Mailpit: http://127.0.0.1:54334\n');

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

// Ejecutar
getEmailFromResend();