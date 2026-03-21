import { serve } from "https://deno.land/std@0.190.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const FROM = "Brickshare <noreply@brickshare.es>";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// ─── Email templates ──────────────────────────────────────────────────────────
type EmailType =
  | "welcome"
  | "subscription_activated"
  | "shipment_update"
  | "review_request"
  | "referral_credited"
  | "generic";

interface EmailPayload {
  type: EmailType;
  to: string;
  data?: Record<string, string | number | undefined>;
}

function buildEmail(payload: EmailPayload): { subject: string; html: string } {
  const d = payload.data ?? {};

  switch (payload.type) {
    case "welcome":
      return {
        subject: "¡Bienvenido/a a Brickshare! 🧱",
        html: `
          <h1>¡Hola${d.name ? ", " + d.name : ""}!</h1>
          <p>Bienvenido/a a <strong>Brickshare</strong>, la plataforma de alquiler de sets LEGO® con impacto social.</p>
          <p>Explora nuestro catálogo, añade sets a tu wishlist y activa tu suscripción para recibir tu primer set.</p>
          <a href="https://brickshare.es/catalogo" style="display:inline-block;padding:12px 24px;background:#e63946;color:#fff;border-radius:8px;text-decoration:none;font-weight:bold;">
            Ver catálogo
          </a>
          <p style="margin-top:32px;color:#666;font-size:13px;">
            Tu código de referido es: <strong>${d.referral_code ?? ""}</strong> — compártelo y consigue 1 mes gratis.
          </p>
        `,
      };

    case "subscription_activated":
      return {
        subject: "¡Tu suscripción Brickshare está activa! ✅",
        html: `
          <h1>¡Todo listo, ${d.name ?? "amigo/a"}!</h1>
          <p>Tu suscripción <strong>${d.plan ?? "Estándar"}</strong> está activa. En breve recibirás tu primer set de LEGO® en tu punto de entrega.</p>
          <p>📦 <strong>Punto de recogida:</strong> ${d.pudo_name ?? "pendiente de configurar"}</p>
          <a href="https://brickshare.es/dashboard" style="display:inline-block;padding:12px 24px;background:#e63946;color:#fff;border-radius:8px;text-decoration:none;font-weight:bold;">
            Ver mi panel
          </a>
        `,
      };

    case "shipment_update":
      return {
        subject: `Actualización de tu envío Brickshare — ${d.status_label ?? ""}`,
        html: `
          <h1>Novedad en tu envío 📦</h1>
          <p>El set <strong>${d.set_name ?? ""}</strong> ha cambiado de estado:</p>
          <p style="font-size:18px;font-weight:bold;color:#e63946;">${d.status_label ?? ""}</p>
          ${d.status === "entregado" ? `<p>¡Ya puedes recoger tu set en <strong>${d.pudo_name ?? "tu punto de entrega"}</strong>!</p>` : ""}
          ${d.status === "ruta_devolucion" ? `<p>Por favor, lleva el set a <strong>${d.pudo_name ?? "tu punto PUDO"}</strong> para completar la devolución.</p>` : ""}
          <a href="https://brickshare.es/dashboard?tab=envios" style="display:inline-block;padding:12px 24px;background:#e63946;color:#fff;border-radius:8px;text-decoration:none;font-weight:bold;">
            Ver mis envíos
          </a>
        `,
      };

    case "review_request":
      return {
        subject: `¿Qué te pareció ${d.set_name ?? "tu último set"}? ⭐`,
        html: `
          <h1>¡Cuéntanos tu experiencia!</h1>
          <p>Has devuelto <strong>${d.set_name ?? "tu set"}</strong>. Tu opinión nos ayuda a mejorar el catálogo y a otros usuarios a elegir mejor.</p>
          <a href="https://brickshare.es/dashboard?tab=envios&review=${d.set_id ?? ""}" style="display:inline-block;padding:12px 24px;background:#e63946;color:#fff;border-radius:8px;text-decoration:none;font-weight:bold;">
            Dejar mi reseña
          </a>
        `,
      };

    case "referral_credited":
      return {
        subject: "¡Has ganado 1 mes gratis en Brickshare! 🎉",
        html: `
          <h1>¡Enhorabuena, ${d.name ?? ""}!</h1>
          <p>Tu referido <strong>${d.referee_name ?? "un amigo"}</strong> ha activado su suscripción gracias a tu código.</p>
          <p>Hemos añadido <strong>1 mes gratis</strong> a tu cuenta. Se aplicará automáticamente en tu próxima renovación.</p>
          <a href="https://brickshare.es/dashboard?tab=referidos" style="display:inline-block;padding:12px 24px;background:#e63946;color:#fff;border-radius:8px;text-decoration:none;font-weight:bold;">
            Ver mis referidos
          </a>
        `,
      };

    default:
      return {
        subject: (d.subject as string) ?? "Mensaje de Brickshare",
        html: (d.html as string) ?? "<p>Sin contenido</p>",
      };
  }
}

// ─── Handler ─────────────────────────────────────────────────────────────────
serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  try {
    const payload: EmailPayload = await req.json();
    const { subject, html } = buildEmail(payload);

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: FROM, to: [payload.to], subject, html }),
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Resend error: ${err}`);
    }

    const data = await res.json();
    return new Response(JSON.stringify({ success: true, id: data.id }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});