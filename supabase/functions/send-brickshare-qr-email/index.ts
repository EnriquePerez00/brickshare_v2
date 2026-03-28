// Send Brickshare QR Code emails for delivery and return
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

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
    // Return a placeholder if QR generation fails
    return '';
  }
}

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

    // Fetch shipment details - first get basic shipment info
    const { data: shipment, error: shipmentError } = await supabaseClient
      .from('shipments')
      .select('*')
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

    // Validate shipment has required fields
    if (!shipment.user_id || !shipment.set_ref) {
      console.error('Shipment missing required fields:', { user_id: shipment.user_id, set_ref: shipment.set_ref });
      return new Response(
        JSON.stringify({ error: 'Shipment missing user_id or set_ref' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Fetch user with pudo_id and pudo_type
    const { data: user, error: userError } = await supabaseClient
      .from('users')
      .select('email, full_name, pudo_id, pudo_type')
      .eq('user_id', shipment.user_id)
      .single();

    if (userError || !user) {
      console.error('Error fetching user:', userError);
      return new Response(
        JSON.stringify({ error: 'User not found for shipment' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Validate set_ref exists in shipment
    if (!shipment.set_ref) {
      console.error('Shipment missing set_ref:', { shipment_id });
      return new Response(
        JSON.stringify({ error: 'Shipment missing set_ref (LEGO reference)' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Fetch set using set_ref
    const { data: set, error: setError } = await supabaseClient
      .from('sets')
      .select('set_name, set_ref, set_theme')
      .eq('set_ref', String(shipment.set_ref))
      .single();

    if (setError || !set) {
      console.error('Set not found for shipment:', {
        shipment_id,
        set_ref: shipment.set_ref,
        error: setError?.message
      });
      return new Response(
        JSON.stringify({ 
          error: `Set not found for ref: ${shipment.set_ref}. Please verify the set exists in the database.`
        }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Fetch PUDO info based on pudo_type
    let pudo = null;
    let pudoError = null;

    if (shipment.pudo_type === 'brickshare') {
      // Fetch from brickshare_pudo_locations
      const pudoIdToUse = shipment.brickshare_pudo_id || user.pudo_id;
      
      if (pudoIdToUse) {
        const { data: pudoLocation, error: pudoLocationError } = await supabaseClient
          .from('brickshare_pudo_locations')
          .select('id, name, address, city, postal_code, contact_phone, opening_hours')
          .eq('id', pudoIdToUse)
          .single();

        if (pudoLocationError) {
          console.warn('Error fetching Brickshare PUDO location:', pudoLocationError, 'pudo_id:', pudoIdToUse);
          pudoError = pudoLocationError;
        } else if (pudoLocation) {
          pudo = {
            type: 'brickshare',
            location_name: pudoLocation.name,
            address: pudoLocation.address,
            city: pudoLocation.city,
            postal_code: pudoLocation.postal_code,
            contact_phone: pudoLocation.contact_phone,
            opening_hours: pudoLocation.opening_hours
          };
        }
      }
    } else if (shipment.pudo_type === 'correos') {
      // Fetch from users_correos_dropping
      const { data: correosPudo, error: correosError } = await supabaseClient
        .from('users_correos_dropping')
        .select('correos_name, correos_full_address, correos_city, correos_zip_code, correos_phone, correos_point_type')
        .eq('user_id', shipment.user_id)
        .single();

      if (correosError) {
        console.warn('Error fetching Correos PUDO location:', correosError, 'user_id:', shipment.user_id);
        pudoError = correosError;
      } else if (correosPudo) {
        pudo = {
          type: 'correos',
          location_name: correosPudo.correos_name,
          address: correosPudo.correos_full_address,
          city: correosPudo.correos_city,
          postal_code: correosPudo.correos_zip_code,
          contact_phone: correosPudo.correos_phone,
          point_type: correosPudo.correos_point_type
        };
      }
    }

    // Validate PUDO configuration for Brickshare shipments
    if (shipment.pudo_type === 'brickshare') {
      if (!user.pudo_id || user.pudo_type !== 'brickshare') {
        console.error('User PUDO not properly configured for Brickshare:', {
          user_id: shipment.user_id,
          user_pudo_id: user.pudo_id,
          user_pudo_type: user.pudo_type,
          shipment_pudo_type: shipment.pudo_type
        });
        return new Response(
          JSON.stringify({ 
            error: 'User PUDO not properly configured for Brickshare delivery' 
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }

      if (!pudo) {
        console.error('Brickshare PUDO location not found:', { 
          user_id: shipment.user_id,
          error: pudoError
        });
        return new Response(
          JSON.stringify({ 
            error: 'Brickshare PUDO location not found for user' 
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }
    }

    const userEmail = user.email;
    const userName = user.full_name || 'Cliente';
    const productName = set.set_name;
    const setNumber = set.set_ref;
    const pudoName = pudo?.location_name || 'Punto de Recogida';
    const pudoAddress = pudo?.address || '';
    const pudoCity = pudo?.city || '';
    const pudoPostalCode = pudo?.postal_code || '';
    const pudoPhone = pudo?.contact_phone || '';

    let qrCode: string;
    let subject: string;
    let htmlContent: string;

    if (type === 'delivery') {
      qrCode = shipment.delivery_qr_code;
      
      // Validate QR code exists
      if (!qrCode) {
        return new Response(
          JSON.stringify({ error: 'Delivery QR code not found for this shipment' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }
      
      subject = `Tu código QR para recoger: ${productName}`;
      
      // Generate QR code image
      const qrImageDataURL = await generateQRCodeDataURL(qrCode);
      
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
            .qr-image { max-width: 300px; height: auto; margin: 20px auto; display: block; }
            .qr-code-text { font-size: 20px; font-weight: bold; color: #667eea; letter-spacing: 2px; font-family: 'Courier New', monospace; margin-top: 15px; }
            .info-box { background: white; padding: 20px; margin: 20px 0; border-left: 4px solid #667eea; border-radius: 5px; }
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
              
              <p>Tu set <strong>${productName}</strong> está listo para ser recogido en nuestro punto Brickshare.</p>
              
              <div class="qr-box">
                <h2>Tu Código QR para Recoger: ${productName} (${setNumber})</h2>
                ${qrImageDataURL ? `<img src="${qrImageDataURL}" alt="QR Code" class="qr-image" />` : ''}
                <div class="qr-code-text">${qrCode}</div>
                <p style="margin-top: 15px; color: #666; font-size: 14px;">Presenta este código en el punto de recogida</p>
              </div>

              <div class="info-box">
                <h3>📍 Punto de Recogida</h3>
                <p><strong>${pudoName}</strong></p>
                ${pudoAddress ? `<p>${pudoAddress}</p>` : ''}
                ${pudoPostalCode || pudoCity ? `<p>${pudoPostalCode} ${pudoCity}</p>` : ''}
                ${pudoPhone ? `<p>📞 ${pudoPhone}</p>` : ''}
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
      
      // Validate QR code exists
      if (!qrCode) {
        return new Response(
          JSON.stringify({ error: 'Return QR code not found for this shipment' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
      }
      
      subject = `Tu código QR para devolver: ${productName}`;
      
      // Generate QR code image
      const qrImageDataURL = await generateQRCodeDataURL(qrCode);
      
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
            .qr-image { max-width: 300px; height: auto; margin: 20px auto; display: block; }
            .qr-code-text { font-size: 20px; font-weight: bold; color: #f5576c; letter-spacing: 2px; font-family: 'Courier New', monospace; margin-top: 15px; }
            .info-box { background: white; padding: 20px; margin: 20px 0; border-left: 4px solid #f5576c; border-radius: 5px; }
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
              
              <p>Has solicitado la devolución del set <strong>${productName}</strong>.</p>
              
              <div class="qr-box">
                <h2>Tu Código QR de Devolución: ${productName} (${setNumber})</h2>
                ${qrImageDataURL ? `<img src="${qrImageDataURL}" alt="QR Code" class="qr-image" />` : ''}
                <div class="qr-code-text">${qrCode}</div>
                <p style="margin-top: 15px; color: #666; font-size: 14px;">Presenta este código al entregar el set</p>
              </div>

              <div class="info-box">
                <h3>📍 Punto de Devolución</h3>
                <p><strong>${pudoName}</strong></p>
                ${pudoAddress ? `<p>${pudoAddress}</p>` : ''}
                ${pudoPostalCode || pudoCity ? `<p>${pudoPostalCode} ${pudoCity}</p>` : ''}
                ${pudoPhone ? `<p>📞 ${pudoPhone}</p>` : ''}
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
    if (!RESEND_API_KEY || RESEND_API_KEY.startsWith('re_test')) {
      console.warn('⚠️ Resend API key not configured for production. Using test key.');
      // In development/test, still return success but log a warning
      console.log('📧 Email would be sent to:', userEmail);
      console.log('📧 Subject:', subject);
    }

    let emailResult = { id: `test-${Date.now()}` };
    
    if (RESEND_API_KEY && !RESEND_API_KEY.startsWith('re_test')) {
      // Only attempt actual email send if we have a real API key
      const emailResponse = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: 'Brickshare <onboarding@resend.dev>',
          to: [userEmail],
          subject: subject,
          html: htmlContent,
        }),
      });

      if (!emailResponse.ok) {
        const errorData = await emailResponse.text();
        console.error('Error sending email via Resend:', {
          status: emailResponse.status,
          statusText: emailResponse.statusText,
          error: errorData
        });
        throw new Error(`Resend API error (${emailResponse.status}): Failed to send email`);
      }

      emailResult = await emailResponse.json();
    }

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