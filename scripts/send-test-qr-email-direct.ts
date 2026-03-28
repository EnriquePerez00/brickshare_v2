#!/usr/bin/env node
/**
 * Send a test QR email directly to verify the fix
 * This bypasses database lookups and sends directly via Resend
 */

import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../.env.local') });

const RESEND_API_KEY = process.env.RESEND_API_KEY;

if (!RESEND_API_KEY) {
  console.error('❌ RESEND_API_KEY not found in .env.local');
  process.exit(1);
}

// Function to generate QR code as Data URL using QR Server API
async function generateQRCodeDataURL(text: string): Promise<string> {
  const size = 300;
  const qrApiUrl = `https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=${encodeURIComponent(text)}`;
  
  try {
    const response = await fetch(qrApiUrl);
    const blob = await response.arrayBuffer();
    const base64 = btoa(String.fromCharCode(...new Uint8Array(blob)));
    return `data:image/png;base64,${base64}`;
  } catch (error) {
    console.error('Error generating QR code:', error);
    return '';
  }
}

async function sendTestEmail() {
  console.log('\n📧 Sending test QR email...\n');
  console.log('=' .repeat(60));

  try {
    // Test data
    const testEmail = 'enriqueperezbcn1973@gmail.com';
    const userName = 'Enrique';
    const productName = 'Millennium Falcon';
    const setNumber = '75192';
    const qrCode = `BRICKSHARE-TEST-${Date.now()}`;
    const pudoName = 'Brickshare Depot - Barcelona Centro';
    const pudoAddress = 'Calle de Balmes, 123';
    const pudoCity = 'Barcelona';
    const pudoPostalCode = '08008';

    console.log(`📦 Set: ${productName} (${setNumber})`);
    console.log(`🔑 QR Code: ${qrCode}`);
    console.log(`📧 Sending to: ${testEmail}\n`);

    // Generate QR code image
    console.log('🎨 Generating QR code image...');
    const qrImageDataURL = await generateQRCodeDataURL(qrCode);
    console.log('✅ QR code image generated\n');

    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .qr-box { background: white; padding: 30px; text-align: center; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .qr-image { max-width: 300px; height: auto; margin: 20px auto; display: block; }
          .qr-code-text { font-size: 20px; font-weight: bold; color: #667eea; letter-spacing: 2px; font-family: 'Courier New', monospace; margin-top: 15px; }
          .info-box { background: white; padding: 20px; margin: 20px 0; border-left: 4px solid #667eea; border-radius: 5px; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
          .test-badge { background: #fbbf24; color: #92400e; padding: 5px 15px; border-radius: 20px; display: inline-block; margin-top: 10px; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>¡Tu pedido está listo para recoger! 🎉</h1>
            <div class="test-badge">EMAIL DE PRUEBA - FIX QR VERIFICADO</div>
          </div>
          <div class="content">
            <p>Hola ${userName},</p>
            
            <p>Tu set <strong>${productName}</strong> está listo para ser recogido en nuestro punto Brickshare.</p>
            
            <div class="qr-box">
              <h2>Tu Código QR para Recoger: ${productName}${setNumber ? ` (${setNumber})` : ''}</h2>
              ${qrImageDataURL ? `<img src="${qrImageDataURL}" alt="QR Code" class="qr-image" />` : ''}
              <div class="qr-code-text">${qrCode}</div>
              <p style="margin-top: 15px; color: #666; font-size: 14px;">Presenta este código en el punto de recogida</p>
            </div>

            <div class="info-box">
              <h3>📍 Punto de Recogida</h3>
              <p><strong>${pudoName}</strong></p>
              <p>${pudoAddress}</p>
              <p>${pudoPostalCode} ${pudoCity}</p>
              <p>📞 +34 900 123 456</p>
            </div>

            <h3>¿Cómo funciona?</h3>
            <ol>
              <li>Dirígete al punto Brickshare en el horario de apertura</li>
              <li>Muestra tu código QR al personal</li>
              <li>Ellos escanearán el código para validar la entrega</li>
              <li>¡Recoge tu set y disfruta! 🧱</li>
            </ol>

            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>
            
            <p>¡Que disfrutes construyendo!</p>
            <p><strong>El equipo de Brickshare</strong></p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Brickshare. Todos los derechos reservados.</p>
            <p>Este es un correo de prueba para verificar el fix del QR display.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    console.log('📨 Sending email via Resend...');
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Brickshare <onboarding@resend.dev>',
        to: [testEmail],
        subject: `[TEST] Tu código QR para recoger: ${productName} (${setNumber})`,
        html: htmlContent,
      }),
    });

    if (!emailResponse.ok) {
      const errorData = await emailResponse.text();
      console.error('❌ Error sending email:', errorData);
      throw new Error('Failed to send email');
    }

    const emailResult = await emailResponse.json();

    console.log('\n' + '='.repeat(60));
    console.log('✅ EMAIL ENVIADO CORRECTAMENTE');
    console.log('='.repeat(60));
    console.log(`\n📧 Email ID: ${emailResult.id}`);
    console.log(`📬 Enviado a: ${testEmail}`);
    console.log(`📦 Set: ${productName} (${setNumber})`);
    console.log(`🔑 QR Code: ${qrCode}`);
    console.log('\n📝 Verifica en tu bandeja de entrada:');
    console.log('   ✅ El título debe mostrar: "Millennium Falcon (75192)"');
    console.log('   ✅ La imagen QR debe ser visible');
    console.log('   ✅ El código QR debe aparecer como texto debajo de la imagen');
    console.log('\n');

  } catch (error) {
    console.error('\n❌ ERROR:', error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

// Run the test
sendTestEmail();