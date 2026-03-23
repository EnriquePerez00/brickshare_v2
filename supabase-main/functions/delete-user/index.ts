import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Create Supabase client with the user's JWT for authentication
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Get the authenticated user
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized - User not authenticated' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    const userId = user.id;
    const userEmail = user.email;

    // Create admin client for privileged operations
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    // 1. Fetch user profile to get subscription info and Stripe customer ID
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('users')
      .select('full_name, subscription_type, subscription_status, stripe_customer_id')
      .eq('user_id', userId)
      .maybeSingle();

    if (profileError) {
      console.error('Error fetching profile:', profileError);
    }

    const subscriptionType = profile?.subscription_type || 'none';
    const stripeCustomerId = profile?.stripe_customer_id;
    const fullName = profile?.full_name || userEmail || 'Usuario';
    const cancellationDate = new Date().toISOString();

    // 2. Cancel Stripe subscription if active
    let stripeCancelled = false;
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');

    if (stripeCustomerId && stripeSecretKey && subscriptionType && subscriptionType !== 'none') {
      try {
        // List active subscriptions for this customer
        const subsResponse = await fetch(
          `https://api.stripe.com/v1/customers/${stripeCustomerId}/subscriptions?status=active&limit=10`,
          {
            headers: {
              'Authorization': `Bearer ${stripeSecretKey}`,
            },
          }
        );

        if (subsResponse.ok) {
          const subsData = await subsResponse.json();

          // Cancel each active subscription
          for (const sub of subsData.data || []) {
            const cancelResponse = await fetch(
              `https://api.stripe.com/v1/subscriptions/${sub.id}`,
              {
                method: 'DELETE',
                headers: {
                  'Authorization': `Bearer ${stripeSecretKey}`,
                },
              }
            );

            if (cancelResponse.ok) {
              stripeCancelled = true;
              console.log(`Cancelled Stripe subscription ${sub.id} for customer ${stripeCustomerId}`);
            } else {
              console.error(`Failed to cancel subscription ${sub.id}:`, await cancelResponse.text());
            }
          }
        } else {
          console.error('Failed to list subscriptions:', await subsResponse.text());
        }
      } catch (stripeErr) {
        console.error('Stripe cancellation error:', stripeErr);
      }
    }

    // 3. Update user_status to 'inactive' (soft-delete — NO data is removed)
    const { error: updateError } = await supabaseAdmin
      .from('users')
      .update({
        user_status: 'inactive',
        subscription_status: 'cancelled',
        updated_at: cancellationDate,
      })
      .eq('user_id', userId);

    if (updateError) {
      console.error('Error updating user status:', updateError);
      return new Response(
        JSON.stringify({ error: 'Failed to deactivate account' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // 4. Log the operation in backoffice_operations
    await supabaseAdmin
      .from('backoffice_operations')
      .insert({
        user_id: userId,
        operation_type: 'recepcion paquete', // Using existing enum; ideally add 'account_deactivation'
        metadata: {
          action: 'account_deactivation',
          subscription_type: subscriptionType,
          stripe_cancelled: stripeCancelled,
          cancellation_date: cancellationDate,
          initiated_by: 'user',
        },
      });

    // 5. Send confirmation email via Resend
    const resendApiKey = Deno.env.get('RESEND_API_KEY');

    if (resendApiKey && userEmail) {
      try {
        const formattedDate = new Date(cancellationDate).toLocaleDateString('es-ES', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
        });

        const subscriptionLabel = subscriptionType !== 'none' ? subscriptionType : 'Sin suscripción activa';

        const emailHtml = `
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <style>
              body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #6366f1, #8b5cf6); padding: 30px; border-radius: 12px 12px 0 0; text-align: center; }
              .header h1 { color: white; margin: 0; font-size: 24px; }
              .content { background: #f9fafb; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px; }
              .info-box { background: white; border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; margin: 20px 0; }
              .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f3f4f6; }
              .info-row:last-child { border-bottom: none; }
              .label { color: #6b7280; font-size: 14px; }
              .value { font-weight: 600; color: #111827; font-size: 14px; }
              .footer { text-align: center; margin-top: 20px; color: #9ca3af; font-size: 12px; }
              .warning { background: #fef3c7; border: 1px solid #fcd34d; border-radius: 8px; padding: 16px; margin: 16px 0; }
              .warning p { margin: 0; color: #92400e; font-size: 14px; }
            </style>
          </head>
          <body>
            <div class="header">
              <h1>🧱 Brickshare</h1>
            </div>
            <div class="content">
              <p>Hola <strong>${fullName}</strong>,</p>
              <p>Te confirmamos que tu cuenta en Brickshare ha sido dada de baja correctamente.</p>
              
              <div class="info-box">
                <div class="info-row">
                  <span class="label">Suscripción cancelada</span>
                  <span class="value" style="text-transform: capitalize;">${subscriptionLabel}</span>
                </div>
                <div class="info-row">
                  <span class="label">Fecha de cancelación</span>
                  <span class="value">${formattedDate}</span>
                </div>
                ${stripeCancelled ? `
                <div class="info-row">
                  <span class="label">Pagos recurrentes</span>
                  <span class="value" style="color: #059669;">✓ Cancelados</span>
                </div>
                ` : ''}
              </div>

              <div class="warning">
                <p>⚠️ Tus datos se mantendrán en nuestro sistema durante un período de 30 días. Si deseas reactivar tu cuenta, contacta con nuestro equipo de soporte en <strong>soporte@brickshare.es</strong>.</p>
              </div>

              <p>Sentimos verte marchar. Si cambias de opinión, estaremos encantados de tenerte de vuelta.</p>
              
              <p>Un saludo,<br><strong>El equipo de Brickshare</strong></p>
            </div>
            <div class="footer">
              <p>© ${new Date().getFullYear()} Brickshare. Todos los derechos reservados.</p>
            </div>
          </body>
          </html>
        `;

        const emailResponse = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${resendApiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'Brickshare <no-reply@brickshare.es>',
            to: [userEmail],
            subject: 'Confirmación de baja de tu cuenta Brickshare',
            html: emailHtml,
          }),
        });

        if (!emailResponse.ok) {
          console.error('Failed to send confirmation email:', await emailResponse.text());
        } else {
          console.log('Confirmation email sent to:', userEmail);
        }
      } catch (emailErr) {
        console.error('Email sending error:', emailErr);
        // Don't fail the operation if email fails
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Account deactivated successfully',
        subscription_cancelled: subscriptionType,
        stripe_cancelled: stripeCancelled,
        cancellation_date: cancellationDate,
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});