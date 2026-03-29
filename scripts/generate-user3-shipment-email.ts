import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL || "http://127.0.0.1:54331";
const SUPABASE_ANON_KEY =
  process.env.SUPABASE_ANON_KEY ||
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";
const SERVICE_ROLE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

interface EmailData {
  user_name: string;
  user_email: string;
  set_name: string;
  set_ref: string;
  delivery_qr_code: string;
  delivery_date: string;
  pudo_location: string;
  shipment_id: string;
}

async function generateQREmail(data: EmailData): Promise<string> {
  // Generar HTML del email con QR
  const qrImageUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(data.delivery_qr_code)}`;

  const htmlEmail = `
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tu Shipment de LEGO - Brickshare</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; color: #1f2937; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; text-align: center; }
        .header h1 { font-size: 24px; margin-bottom: 10px; }
        .header p { font-size: 14px; opacity: 0.9; }
        .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; border: 1px solid #e5e7eb; border-top: none; }
        .section { margin-bottom: 30px; }
        .section h2 { font-size: 18px; color: #1f2937; margin-bottom: 15px; border-bottom: 2px solid #667eea; padding-bottom: 10px; }
        .set-info { background: white; padding: 20px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #667eea; }
        .set-info h3 { font-size: 16px; font-weight: 600; margin-bottom: 8px; }
        .set-info p { font-size: 14px; color: #6b7280; margin: 5px 0; }
        .qr-container { text-align: center; background: white; padding: 30px; border-radius: 6px; border: 1px solid #e5e7eb; }
        .qr-container img { max-width: 300px; height: auto; }
        .qr-code-text { font-size: 12px; color: #6b7280; margin-top: 15px; font-family: monospace; letter-spacing: 2px; }
        .timeline { background: white; padding: 20px; border-radius: 6px; border-left: 4px solid #667eea; }
        .timeline-item { display: flex; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 1px solid #e5e7eb; }
        .timeline-item:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
        .timeline-icon { width: 40px; height: 40px; background: #667eea; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; margin-right: 15px; flex-shrink: 0; }
        .timeline-content h4 { font-size: 14px; font-weight: 600; margin-bottom: 4px; }
        .timeline-content p { font-size: 13px; color: #6b7280; }
        .button { display: inline-block; background: #667eea; color: white; padding: 12px 24px; border-radius: 6px; text-decoration: none; font-weight: 600; font-size: 14px; margin-top: 15px; }
        .footer { background: #f3f4f6; padding: 20px; border-radius: 6px; margin-top: 30px; text-align: center; font-size: 12px; color: #6b7280; }
        .badge { display: inline-block; background: #dbeafe; color: #0c4a6e; padding: 6px 12px; border-radius: 4px; font-size: 12px; font-weight: 600; margin: 5px 5px 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧱 Tu Envío está en Camino</h1>
            <p>Brickshare - Alquiler Circular de LEGO</p>
        </div>

        <div class="content">
            <!-- Set Information -->
            <div class="section">
                <h2>📦 Detalles de tu Set LEGO</h2>
                <div class="set-info">
                    <h3>${data.set_name}</h3>
                    <p><strong>Código del Set:</strong> <code>${data.set_ref}</code></p>
                    <p><strong>Shipment ID:</strong> <code>${data.shipment_id.substring(0, 8).toUpperCase()}</code></p>
                    <div style="margin-top: 15px;">
                        <span class="badge">📦 En Envío</span>
                        <span class="badge">🎯 PUDO</span>
                    </div>
                </div>
            </div>

            <!-- QR Code -->
            <div class="section">
                <h2>📍 Código QR de Recogida</h2>
                <div class="qr-container">
                    <img src="${qrImageUrl}" alt="QR de Recogida">
                    <div class="qr-code-text">Código: ${data.delivery_qr_code}</div>
                    <p style="font-size: 12px; color: #6b7280; margin-top: 20px;">
                        Presente este código QR al recoger en tu PUDO
                    </p>
                </div>
            </div>

            <!-- Timeline -->
            <div class="section">
                <h2>📅 Tu Cronograma</h2>
                <div class="timeline">
                    <div class="timeline-item">
                        <div class="timeline-icon">1</div>
                        <div class="timeline-content">
                            <h4>Envío Confirmado</h4>
                            <p>Tu set ha sido enviado a tu PUDO</p>
                        </div>
                    </div>
                    <div class="timeline-item">
                        <div class="timeline-icon">2</div>
                        <div class="timeline-content">
                            <h4>Llegada en PUDO</h4>
                            <p>Esperado para ${data.delivery_date}</p>
                        </div>
                    </div>
                    <div class="timeline-item">
                        <div class="timeline-icon">3</div>
                        <div class="timeline-content">
                            <h4>Recogida</h4>
                            <p>Recoge tu set mostrando el código QR</p>
                        </div>
                    </div>
                    <div class="timeline-item">
                        <div class="timeline-icon">4</div>
                        <div class="timeline-content">
                            <h4>¡A Disfrutar!</h4>
                            <p>Tienes 30 días para disfrutar de tu set</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Location Info -->
            <div class="section">
                <h2>📍 Punto de Recogida</h2>
                <div class="set-info">
                    <p><strong>Ubicación PUDO:</strong></p>
                    <p>${data.pudo_location}</p>
                    <p style="font-size: 12px; color: #6b7280; margin-top: 15px;">
                        Abre tu aplicación de Brickshare para ver la ubicación exacta y los horarios
                    </p>
                </div>
            </div>

            <!-- Support -->
            <div class="section">
                <h2>❓ ¿Necesitas Ayuda?</h2>
                <p>Si tienes alguna pregunta o problema con tu envío, no dudes en contactarnos:</p>
                <p style="margin-top: 15px;">
                    📧 support@brickshare.es<br>
                    📱 +34 XXX XXX XXX<br>
                    🌐 www.brickshare.es/help
                </p>
            </div>
        </div>

        <div class="footer">
            <p>© 2026 Brickshare. Todos los derechos reservados.</p>
            <p style="margin-top: 10px;">
                <a href="https://brickshare.es" style="color: #667eea; text-decoration: none;">Ver en el navegador</a> | 
                <a href="https://brickshare.es/preferences" style="color: #667eea; text-decoration: none;">Preferencias</a>
            </p>
        </div>
    </div>
</body>
</html>
`;

  return htmlEmail;
}

async function main() {
  console.log("🔍 Buscando a user3 y sus datos...\n");

  // 1. Buscar user3
  const { data: user3Data, error: userError } = await supabase
    .from("users")
    .select("id, full_name, email, pudo_id, pudo_type")
    .eq("full_name", "user3")
    .single();

  if (userError || !user3Data) {
    console.error("❌ Error: No se encontró user3", userError);
    process.exit(1);
  }

  console.log("✅ Usuario encontrado:");
  console.log(`   Nombre: ${user3Data.full_name}`);
  console.log(`   Email: ${user3Data.email}`);
  console.log(`   PUDO ID: ${user3Data.pudo_id}`);
  console.log(`   PUDO Type: ${user3Data.pudo_type}\n`);

  // 2. Buscar la wishlist de user3
  console.log("🔍 Buscando sets en la wishlist de user3...\n");

  const { data: wishlistData, error: wishlistError } = await supabase
    .from("wishlist")
    .select(
      `
      id,
      set_ref,
      sets (
        set_ref,
        set_name,
        set_pvp_release
      )
    `
    )
    .eq("user_id", user3Data.id)
    .limit(1)
    .single();

  if (wishlistError || !wishlistData) {
    console.error("❌ Error: No se encontraron sets en la wishlist", wishlistError);
    process.exit(1);
  }

  const set = wishlistData.sets as any;
  console.log("✅ Set encontrado en wishlist:");
  console.log(`   Nombre: ${set.set_name}`);
  console.log(`   Referencia: ${set.set_ref}`);
  console.log(`   PVP: €${set.set_pvp_release}\n`);

  // 3. Crear shipment
  console.log("🚀 Creando shipment...\n");

  const shipmentId = `ship-${Date.now()}-${Math.random().toString(36).substring(7)}`;
  const deliveryQrCode = `BS-DEL-${shipmentId.substring(0, 12).toUpperCase()}`;
  const deliveryDate = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000)
    .toLocaleDateString("es-ES", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });

  const { error: shipmentError } = await supabaseAdmin
    .from("shipments")
    .insert({
      id: shipmentId,
      user_id: user3Data.id,
      set_ref: set.set_ref,
      pudo_type: user3Data.pudo_type,
      pudo_id: user3Data.pudo_id,
      shipment_status: "assigned",
      delivery_qr_code: deliveryQrCode,
      swikly_wish_id: `MOCK-${shipmentId.substring(0, 8).toUpperCase()}`,
      swikly_status: "wish_created",
      swikly_deposit_amount: Math.round(set.set_pvp_release * 100),
      created_at: new Date().toISOString(),
    });

  if (shipmentError) {
    console.error("❌ Error creando shipment:", shipmentError);
    process.exit(1);
  }

  console.log("✅ Shipment creado exitosamente:");
  console.log(`   ID: ${shipmentId}`);
  console.log(`   QR Code: ${deliveryQrCode}\n`);

  // 4. Generar email
  console.log("📧 Generando email...\n");

  const emailData: EmailData = {
    user_name: user3Data.full_name,
    user_email: user3Data.email,
    set_name: set.set_name,
    set_ref: set.set_ref,
    delivery_qr_code: deliveryQrCode,
    delivery_date: deliveryDate,
    pudo_location: user3Data.pudo_id ? `Punto PUDO: ${user3Data.pudo_id}` : "Tu PUDO seleccionado",
    shipment_id: shipmentId,
  };

  const emailHtml = await generateQREmail(emailData);

  // 5. Guardar email HTML
  const fs = await import("fs").then((m) => m.promises);
  const outputPath = `email-preview-user3-shipment-${Date.now()}.html`;

  await fs.writeFile(outputPath, emailHtml);

  console.log("✅ Email generado exitosamente");
  console.log(`   Guardado en: ${outputPath}\n`);

  // 6. Mostrar resumen
  console.log("═".repeat(70));
  console.log("📋 RESUMEN DEL SHIPMENT");
  console.log("═".repeat(70));
  console.log(`Usuario: ${user3Data.full_name} <${user3Data.email}>`);
  console.log(`Set: ${set.set_name} (${set.set_ref})`);
  console.log(`Shipment ID: ${shipmentId}`);
  console.log(`QR Code: ${deliveryQrCode}`);
  console.log(`Fianza: €${(set.set_pvp_release).toFixed(2)}`);
  console.log(`Fecha Entrega Estimada: ${deliveryDate}`);
  console.log(`\n📂 Archivo HTML: ${outputPath}`);
  console.log(`\n🌐 Para ver el email en el navegador, ejecuta:`);
  console.log(`   open ${outputPath}`);
  console.log("═".repeat(70));
}

main().catch(console.error);