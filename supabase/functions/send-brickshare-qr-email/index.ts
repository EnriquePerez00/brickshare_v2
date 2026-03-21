// Send Brickshare QR Code emails for delivery and return
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface EmailRequest {
  shipment_id: string;
  type: 'delivery' | 'return';
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    const { shipment_id, type }: EmailRequest = await req.json();

    if (!shipment_id || !type) {
      return new Response(
        JSON.stringify({ error: 'shipment_id and type are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Fetch shipment details
    const { data: shipment, error: shipmentError } = await supabaseClient
      .from('shipments')
      .select(`
        id,
        status,
        pickup_type,
        delivery_qr_code,
        delivery_qr_expires_at,
        return_qr_code,
        return_qr_expires_at,
        brickshare_pudo_id,
        assignment:assignments!inner(
          id,
          user_id,
          set_id,
          user:profiles!inner(
            email,
            full_name
          ),
          product:products(
            name,
            set_number,
            theme
          )
        ),
        pudo:brickshare_pudo_locations(
          name,
          address,
          city,
          postal_code,
          contact_phone,
          opening_hours
        )
      `)
      .eq('id', shipment_id)
      .single();

    if (shipmentError || !shipment) {
      console.error('Error fetching shipment:', shipmentError);
      return new Response(
        JSON.stringify({ error: 'Shipment not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (shipment.pickup_type !== 'brickshare') {
      return new Response(
        JSON.stringify({ error: 'Shipment is not configured for Brickshare PUDO' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const userEmail = shipment.assignment.user.email;
    const userName = shipment.assignment.user.full_name || 'Cliente';
    const productName = shipment.assignment.product?.name || 'Set LEGO';
    const setNumber = shipment.assignment.product?.set_number || '';
    const pudoName = shipment.pudo?.name || 'Punto Brickshare';
    const pudoAddress = shipment.pudo?.address || '';
    const pudoCity = shipment.pudo?.city || '';
    const pudoPostalCode = shipment.pudo?.postal_code || '';

    let qrCode: string;
    let expiresAt: string;
    let subject: string;
    let htmlContent: string;

    if (type === 'delivery') {
      qrCode = shipment.delivery_qr_code;
      expiresAt = shipment.delivery_qr_expires_at;
      subject = `Tu código QR para recoger: ${productName}`;
      
      htmlContent = `
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
            .qr-code { font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 2px; font-family: 'Courier New', monospace; padding: 20px; background: #f0f0f0; border-radius: 5px; }
            .info-box { background: white; padding: 20px; margin: 20px 0; border-left: 4px solid #667eea; border-radius: 5px; }
            .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
            .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>¡Tu pedido está listo para recoger! 🎉</h1>
            </div>
            <div class="content">
              <p>Hola ${userName},</p>
              
              <p>Tu set <strong>${productName} (${setNumber})</strong> está listo para ser recogido en nuestro punto Brickshare.</p>
              
              <div class="qr-box">
                <h2>Tu Código QR de Recogida</h2>
                <div class="qr-code">${qrCode}</div>
                <p style="margin-top: 20px; color: #666;">Presenta este código en el punto de recogida</p>
              </div>

              <div class="info-box">
                <h3>📍 Punto de Recogida</h3>
                <p><strong>${pudoName}</strong></p>
                <p>${pudoAddress}</p>
                <p>${pudoPostalCode} ${pudoCity}</p>
                ${shipment.pudo?.contact_phone ? `<p>📞 ${shipment.pudo.contact_phone}</p>` : ''}
              </div>

              <div class="warning">
                <strong>⏰ Importante:</strong>
                <ul>
                  <li>Este código QR expira el ${new Date(expiresAt).toLocaleDateString('es-ES')}</li>
                  <li>Solo puede ser usado una vez</li>
                  <li>Debes presentarlo en el punto Brickshare para validar la entrega</li>
                </ul>
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
              <p>Este es un correo automático, por favor no respondas a este mensaje.</p>
            </div>
          </div>
        </body>
        </html>
      `;
    } else {
      // Return email
      qrCode = shipment.return_qr_code;
      expiresAt = shipment.return_qr_expires_at;
      subject = `Tu código QR para devolver: ${productName}`;
      
      htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .qr-box { background: white; padding: 30px; text-align: center; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .qr-code { font-size: 32px; font-weight: bold; color: #f5576c; letter-spacing: 2px; font-family: 'Courier New', monospace; padding: 20px; background: #f0f0f0; border-radius: 5px; }
            .info-box { background: white; padding: 20px; margin: 20px 0; border-left: 4px solid #f5576c; border-radius: 5px; }
            .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Código QR para Devolución 📦</h1>
            </div>
            <div class="content">
              <p>Hola ${userName},</p>
              
              <p>Has solicitado la devolución del set <strong>${productName} (${setNumber})</strong>.</p>
              
              <div class="qr-box">
                <h2>Tu Código QR de Devolución</h2>
                <div class="qr-code">${qrCode}</div>
                <p style="margin-top: 20px; color: #666;">Presenta este código al entregar el set</p>
              </div>

              <div class="info-box">
                <h3>📍 Punto de Devolución</h3>
                <p><strong>${pudoName}</strong></p>
                <p>${pudoAddress}</p>
                <p>${pudoPostalCode} ${pudoCity}</p>
                ${shipment.pudo?.contact_phone ? `<p>📞 ${shipment.pudo.contact_phone}</p>` : ''}
              </div>

              <div class="warning">
                <strong>⏰ Importante:</strong>
                <ul>
                  <li>Este código QR expira el ${new Date(expiresAt).toLocaleDateString('es-ES')}</li>
                  <li>Solo puede ser usado una vez</li>
                  <li>Asegúrate de que el set esté completo y en buen estado</li>
                </ul>
              </div>

              <h3>Instrucciones de Devolución:</h3>
              <ol>
                <li>Verifica que el set esté completo (todas las piezas y manual incluidos)</li>
                <li>Empaqueta el set de forma segura</li>
                <li>Dirígete al punto Brickshare en el horario de apertura</li>
                <li>Muestra tu código QR al personal</li>
                <li>Entrega el set para su validación</li>
              </ol>

              <p><strong>Nota:</strong> Una vez validada la devolución, procesaremos la finalización de tu alquiler.</p>
              
              <p>Gracias por usar Brickshare. ¡Esperamos verte pronto!</p>
              <p><strong>El equipo de Brickshare</strong></p>
            </div>
            <div class="footer">
              <p>© ${new Date().getFullYear()} Brickshare. Todos los derechos reservados.</p>
              <p>Este es un correo automático, por favor no respondas a este mensaje.</p>
            </div>
          </div>
        </body>
        </html>
      `;
    }

    // Send email via Resend
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Brickshare <noreply@brickshare.es>',
        to: [userEmail],
        subject: subject,
        html: htmlContent,
      }),
    });

    if (!emailResponse.ok) {
      const errorData = await emailResponse.text();
      console.error('Error sending email:', errorData);
      throw new Error('Failed to send email');
    }

    const emailResult = await emailResponse.json();

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'QR code email sent successfully',
        email_id: emailResult.id,
        qr_code: qrCode
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Error in send-brickshare-qr-email function:', error);
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'An unexpected error occurred' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  }
});