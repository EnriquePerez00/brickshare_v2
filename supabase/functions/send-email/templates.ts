/**
 * Brickshare — Email HTML Templates
 * Shared across all transactional emails.
 * Usage: import { renderTemplate, templates } from "./templates.ts"
 */

const BRAND_COLOR = "#F97316"; // orange-500
const BRAND_DARK = "#1E1B4B"; // indigo-950
const BRAND_LIGHT = "#FFF7ED"; // orange-50
const LOGO_URL = "https://brickshare.es/favicon.ico";
const BASE_URL = "https://brickshare.es";

// ─── Base layout ────────────────────────────────────────────────────────────

function baseLayout(content: string, preheader = ""): string {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Brickshare</title>
  <!--[if mso]><noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript><![endif]-->
</head>
<body style="margin:0;padding:0;background-color:#f3f4f6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <!-- Preheader (hidden) -->
  <div style="display:none;max-height:0;overflow:hidden;mso-hide:all;">${preheader}&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;</div>

  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f3f4f6;">
    <tr>
      <td align="center" style="padding:32px 16px;">
        <table width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.07);">
          
          <!-- Header -->
          <tr>
            <td style="background:${BRAND_DARK};padding:28px 40px;text-align:center;">
              <a href="${BASE_URL}" style="text-decoration:none;">
                <span style="color:#ffffff;font-size:26px;font-weight:800;letter-spacing:-0.5px;">
                  🧱 Brickshare
                </span>
              </a>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:40px 40px 32px;">
              ${content}
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#f9fafb;padding:24px 40px;border-top:1px solid #e5e7eb;text-align:center;">
              <p style="margin:0 0 8px;color:#6b7280;font-size:13px;">
                © ${new Date().getFullYear()} Brickshare · <a href="${BASE_URL}/privacidad" style="color:#6b7280;">Privacidad</a> · <a href="${BASE_URL}/terminos" style="color:#6b7280;">Términos</a>
              </p>
              <p style="margin:0;color:#9ca3af;font-size:12px;">
                Brickshare S.L. · España · <a href="${BASE_URL}/contacto" style="color:#9ca3af;">Contactar</a>
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

// ─── Button helper ───────────────────────────────────────────────────────────

function ctaButton(label: string, url: string): string {
  return `<div style="text-align:center;margin:28px 0;">
    <a href="${url}" style="display:inline-block;background:${BRAND_COLOR};color:#ffffff;font-size:15px;font-weight:700;padding:14px 32px;border-radius:10px;text-decoration:none;letter-spacing:0.2px;">
      ${label}
    </a>
  </div>`;
}

// ─── Divider helper ──────────────────────────────────────────────────────────

function divider(): string {
  return `<hr style="border:none;border-top:1px solid #e5e7eb;margin:24px 0;" />`;
}

// ─── Set info card helper ────────────────────────────────────────────────────

function setCard(setName: string, setTheme: string, pieceCount: number, imageUrl?: string): string {
  const img = imageUrl
    ? `<img src="${imageUrl}" width="80" height="80" alt="${setName}" style="border-radius:8px;object-fit:cover;margin-right:16px;" />`
    : `<div style="width:80px;height:80px;background:${BRAND_LIGHT};border-radius:8px;margin-right:16px;display:flex;align-items:center;justify-content:center;font-size:32px;">🧱</div>`;

  return `<div style="background:${BRAND_LIGHT};border-radius:12px;padding:16px;display:flex;align-items:center;margin:20px 0;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
      <td width="96" valign="middle">${img}</td>
      <td valign="middle">
        <p style="margin:0 0 4px;font-weight:700;font-size:15px;color:${BRAND_DARK};">${setName}</p>
        <p style="margin:0;color:#6b7280;font-size:13px;">${setTheme} · ${pieceCount.toLocaleString("es-ES")} piezas</p>
      </td>
    </tr></table>
  </div>`;
}

// ─── Templates ───────────────────────────────────────────────────────────────

export interface WelcomeParams {
  userName: string;
}

export interface ShipmentSentParams {
  userName: string;
  setName: string;
  setTheme: string;
  pieceCount: number;
  setImageUrl?: string;
  trackingCode?: string;
  estimatedDays?: number;
}

export interface ReturnConfirmedParams {
  userName: string;
  setName: string;
  setTheme: string;
  pieceCount: number;
  returnCode?: string;
}

export interface SubscriptionChangedParams {
  userName: string;
  plan: string;
  price: string;
  nextBillingDate: string;
}

export interface SubscriptionCancelledParams {
  userName: string;
  endDate: string;
}

export interface WishlistMatchParams {
  userName: string;
  setName: string;
  setTheme: string;
  pieceCount: number;
  setImageUrl?: string;
}

export interface ReviewRequestParams {
  userName: string;
  setName: string;
  setTheme: string;
  pieceCount: number;
  setImageUrl?: string;
  reviewUrl: string;
}

export const templates = {
  // ── Bienvenida tras registro ─────────────────────────────────────────────
  welcome({ userName }: WelcomeParams) {
    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        ¡Bienvenido/a a Brickshare, ${userName}! 🎉
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Estamos encantados de tenerte a bordo. Con Brickshare puedes disfrutar de los mejores sets de LEGO® sin preocuparte por el almacenamiento ni el precio de compra.
      </p>
      <div style="background:${BRAND_LIGHT};border-radius:12px;padding:20px;margin:20px 0;">
        <p style="margin:0 0 12px;font-weight:700;font-size:14px;color:${BRAND_DARK};">¿Qué puedes hacer ahora?</p>
        <ul style="margin:0;padding-left:20px;color:#374151;font-size:14px;line-height:2;">
          <li>Explora nuestro <strong>catálogo</strong> de más de 50 sets</li>
          <li>Añade tus favoritos a la <strong>wishlist</strong></li>
          <li>Elige tu <strong>plan de suscripción</strong></li>
          <li>Recibe tu primer set en casa</li>
        </ul>
      </div>
      ${ctaButton("Explorar el catálogo", `${BASE_URL}/catalogo`)}
      ${divider()}
      <p style="margin:0;color:#6b7280;font-size:13px;text-align:center;">
        ¿Tienes alguna duda? Escríbenos a <a href="mailto:info@brickclinic.eu" style="color:${BRAND_COLOR};">info@brickclinic.eu</a>
      </p>
    `;
    return {
      subject: `¡Bienvenido/a a Brickshare, ${userName}! 🧱`,
      html: baseLayout(content, `Bienvenido/a a Brickshare. Empieza a explorar el catálogo.`),
    };
  },

  // ── Envío preparado / en camino ──────────────────────────────────────────
  shipmentSent({
    userName,
    setName,
    setTheme,
    pieceCount,
    setImageUrl,
    trackingCode,
    estimatedDays = 2,
  }: ShipmentSentParams) {
    const trackingSection = trackingCode
      ? `<div style="background:#f0f9ff;border:1px solid #bae6fd;border-radius:10px;padding:16px;margin:20px 0;text-align:center;">
          <p style="margin:0 0 4px;font-size:12px;color:#0369a1;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;">Código de seguimiento</p>
          <p style="margin:0;font-size:22px;font-weight:800;color:#0c4a6e;letter-spacing:2px;">${trackingCode}</p>
         </div>`
      : "";

    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        ¡Tu set está en camino! 📦
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Hola <strong>${userName}</strong>, hemos enviado tu pedido. Lo recibirás en aproximadamente <strong>${estimatedDays} días laborables</strong>.
      </p>
      ${setCard(setName, setTheme, pieceCount, setImageUrl)}
      ${trackingSection}
      ${ctaButton("Ver mi pedido", `${BASE_URL}/dashboard`)}
      ${divider()}
      <p style="margin:0;color:#6b7280;font-size:13px;line-height:1.6;">
        Recuerda que tienes <strong>30 días</strong> para disfrutar del set antes de devolverlo o renovarlo. 
        Cuando quieras iniciar la devolución, hazlo desde tu <a href="${BASE_URL}/dashboard" style="color:${BRAND_COLOR};">panel de usuario</a>.
      </p>
    `;
    return {
      subject: `Tu set "${setName}" está en camino 🚚`,
      html: baseLayout(content, `Tu pedido de ${setName} ha sido enviado.`),
    };
  },

  // ── Devolución confirmada ────────────────────────────────────────────────
  returnConfirmed({
    userName,
    setName,
    setTheme,
    pieceCount,
    returnCode,
  }: ReturnConfirmedParams) {
    const codeSection = returnCode
      ? `<div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:16px;margin:20px 0;text-align:center;">
          <p style="margin:0 0 4px;font-size:12px;color:#15803d;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;">Código de devolución Correos</p>
          <p style="margin:0;font-size:22px;font-weight:800;color:#14532d;letter-spacing:2px;">${returnCode}</p>
          <p style="margin:8px 0 0;font-size:12px;color:#15803d;">Muestra este código en cualquier oficina de Correos</p>
         </div>`
      : "";

    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        Devolución registrada ✅
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Hola <strong>${userName}</strong>, hemos registrado la devolución de tu set. 
        Lleva el paquete a tu oficina de Correos más cercana.
      </p>
      ${setCard(setName, setTheme, pieceCount)}
      ${codeSection}
      <div style="background:${BRAND_LIGHT};border-radius:12px;padding:16px;margin:20px 0;">
        <p style="margin:0 0 8px;font-weight:700;font-size:14px;color:${BRAND_DARK};">Instrucciones de embalaje:</p>
        <ol style="margin:0;padding-left:20px;color:#374151;font-size:14px;line-height:2;">
          <li>Incluye <strong>todas las piezas</strong> en la bolsa original</li>
          <li>Introduce en la caja original con el embalaje</li>
          <li>Cierra bien la caja y llévala a Correos</li>
          <li>Muestra el código en el mostrador</li>
        </ol>
      </div>
      ${ctaButton("Ver mi historial", `${BASE_URL}/dashboard`)}
    `;
    return {
      subject: `Devolución de "${setName}" registrada ✅`,
      html: baseLayout(content, `Devolución de ${setName} registrada correctamente.`),
    };
  },

  // ── Suscripción cambiada ─────────────────────────────────────────────────
  subscriptionChanged({
    userName,
    plan,
    price,
    nextBillingDate,
  }: SubscriptionChangedParams) {
    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        Tu suscripción ha sido actualizada 🔄
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Hola <strong>${userName}</strong>, los cambios en tu suscripción están activos.
      </p>
      <div style="background:${BRAND_LIGHT};border-radius:12px;padding:20px;margin:20px 0;">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td style="color:#6b7280;font-size:14px;padding:6px 0;">Plan:</td>
            <td style="color:${BRAND_DARK};font-size:14px;font-weight:700;text-align:right;">${plan}</td>
          </tr>
          <tr>
            <td style="color:#6b7280;font-size:14px;padding:6px 0;">Precio mensual:</td>
            <td style="color:${BRAND_DARK};font-size:14px;font-weight:700;text-align:right;">${price}</td>
          </tr>
          <tr>
            <td style="color:#6b7280;font-size:14px;padding:6px 0;">Próxima facturación:</td>
            <td style="color:${BRAND_DARK};font-size:14px;font-weight:700;text-align:right;">${nextBillingDate}</td>
          </tr>
        </table>
      </div>
      ${ctaButton("Gestionar suscripción", `${BASE_URL}/dashboard`)}
      ${divider()}
      <p style="margin:0;color:#6b7280;font-size:13px;">
        Si no reconoces este cambio, contacta con nosotros en <a href="mailto:info@brickclinic.eu" style="color:${BRAND_COLOR};">info@brickclinic.eu</a>
      </p>
    `;
    return {
      subject: `Tu suscripción Brickshare ha sido actualizada`,
      html: baseLayout(content, `Plan actualizado: ${plan} · ${price}/mes`),
    };
  },

  // ── Suscripción cancelada ────────────────────────────────────────────────
  subscriptionCancelled({ userName, endDate }: SubscriptionCancelledParams) {
    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        Tu suscripción ha sido cancelada
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Hola <strong>${userName}</strong>, hemos procesado la cancelación de tu suscripción. 
        Tendrás acceso completo hasta el <strong>${endDate}</strong>.
      </p>
      <div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:16px;margin:20px 0;">
        <p style="margin:0;font-size:14px;color:#991b1b;">
          ⚠️ Recuerda devolver los sets activos antes de que finalice tu suscripción para evitar cargos adicionales.
        </p>
      </div>
      ${ctaButton("Reactivar suscripción", `${BASE_URL}/como-funciona`)}
      ${divider()}
      <p style="margin:0;color:#6b7280;font-size:13px;line-height:1.6;">
        ¿Cancelaste por error o tienes algún problema? Escríbenos y lo solucionamos: 
        <a href="mailto:info@brickclinic.eu" style="color:${BRAND_COLOR};">info@brickclinic.eu</a>
      </p>
    `;
    return {
      subject: `Tu suscripción Brickshare ha sido cancelada`,
      html: baseLayout(content, `Acceso activo hasta ${endDate}.`),
    };
  },

  // ── Set disponible en wishlist ───────────────────────────────────────────
  wishlistMatch({
    userName,
    setName,
    setTheme,
    pieceCount,
    setImageUrl,
  }: WishlistMatchParams) {
    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        ¡Un set de tu wishlist está disponible! ⭐
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Hola <strong>${userName}</strong>, buenas noticias: un set que tenías en tu wishlist acaba de estar disponible.
      </p>
      ${setCard(setName, setTheme, pieceCount, setImageUrl)}
      <p style="color:#374151;font-size:14px;line-height:1.6;">
        Date prisa — los sets populares se asignan rápidamente. 🏃
      </p>
      ${ctaButton("Ver mi wishlist", `${BASE_URL}/dashboard`)}
    `;
    return {
      subject: `"${setName}" de tu wishlist está disponible 🧱`,
      html: baseLayout(content, `${setName} está disponible en Brickshare.`),
    };
  },

  // ── Solicitud de valoración tras devolución ──────────────────────────────
  reviewRequest({
    userName,
    setName,
    setTheme,
    pieceCount,
    setImageUrl,
    reviewUrl,
  }: ReviewRequestParams) {
    const content = `
      <h1 style="margin:0 0 8px;font-size:24px;font-weight:800;color:${BRAND_DARK};">
        ¿Qué te pareció "${setName}"? ⭐
      </h1>
      <p style="margin:0 0 20px;color:#374151;font-size:15px;line-height:1.6;">
        Hola <strong>${userName}</strong>, hemos recibido la devolución de tu set. 
        ¿Te tomás 2 minutos para dejarnos una valoración? Tu opinión ayuda a otros usuarios.
      </p>
      ${setCard(setName, setTheme, pieceCount, setImageUrl)}
      ${ctaButton("Valorar este set", reviewUrl)}
      ${divider()}
      <p style="margin:0;color:#9ca3af;font-size:12px;text-align:center;">
        Puedes ignorar este email si no deseas dejar una valoración.
      </p>
    `;
    return {
      subject: `¿Qué te pareció "${setName}"? Déjanos tu valoración`,
      html: baseLayout(content, `Valora tu experiencia con ${setName}.`),
    };
  },
};

export type TemplateName = keyof typeof templates;