import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@11.1.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
    apiVersion: "2022-11-15",
    httpClient: Stripe.createFetchHttpClient(),
});

// Helper function to get default payment method
async function getDefaultPaymentMethod(customerId: string): Promise<string | null> {
    try {
        const customer = await stripe.customers.retrieve(customerId, {
            expand: ['invoice_settings.default_payment_method']
        });

        if (customer.deleted) return null;

        const defaultPM = customer.invoice_settings?.default_payment_method;

        if (typeof defaultPM === 'string') {
            return defaultPM;
        } else if (defaultPM && typeof defaultPM === 'object') {
            return defaultPM.id;
        }

        // Fallback: buscar el payment method más reciente
        const paymentMethods = await stripe.paymentMethods.list({
            customer: customerId,
            type: 'card',
            limit: 1
        });

        return paymentMethods.data[0]?.id || null;
    } catch (error) {
        console.error("Error retrieving payment method:", error);
        return null;
    }
}

// Helper function to cancel a payment intent authorization
async function cancelPaymentIntent(paymentIntentId: string): Promise<void> {
    try {
        await stripe.paymentIntents.cancel(paymentIntentId);
        console.log(`Cancelled PaymentIntent: ${paymentIntentId}`);
    } catch (error) {
        console.error(`Failed to cancel PaymentIntent ${paymentIntentId}:`, error);
    }
}

serve(async (req) => {
    const origin = req.headers.get("origin") || "";
    const corsHeaders = {
        "Access-Control-Allow-Origin": origin,
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Credentials": "true",
    };

    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const { userId, setRef, pudoType } = await req.json();

        // JWT Verification
        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            return new Response(JSON.stringify({ error: "Unauthorized - Missing header" }), {
                status: 401,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const supabaseUser = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: authHeader } } }
        );

        const { data: { user }, error: userError } = await supabaseUser.auth.getUser();
        if (userError || !user) {
            return new Response(JSON.stringify({ error: "Unauthorized - Invalid token" }), {
                status: 401,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Check if user is admin or processing their own payment
        const supabaseAdmin = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
        );

        const { data: roles } = await supabaseAdmin
            .from("user_roles")
            .select("role")
            .eq("user_id", user.id);

        const isAdmin = roles?.some(r => r.role === "admin");
        const isOwnPayment = user.id === userId;

        if (!isAdmin && !isOwnPayment) {
            return new Response(JSON.stringify({ error: "Unauthorized - Only admins can process payments for other users" }), {
                status: 403,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        if (!userId || !setRef) {
            return new Response(JSON.stringify({
                success: false,
                error: "userId y setRef son requeridos",
                errorCode: "invalid_parameters"
            }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const sbUrl = Deno.env.get("SUPABASE_URL");
        const sbKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

        if (!sbUrl || !sbKey) {
            throw new Error("Missing Supabase environment variables");
        }

        const supabase = createClient(sbUrl, sbKey);

        // 1. Get user profile and stripe_customer_id
        const { data: userProfile, error: profileError } = await supabase
            .from("users")
            .select("stripe_customer_id, email, full_name")
            .eq("id", userId)
            .maybeSingle();

        if (profileError) {
            throw profileError;
        }

        if (!userProfile?.stripe_customer_id) {
            return new Response(JSON.stringify({
                success: false,
                error: "Usuario no tiene Customer ID de Stripe configurado",
                errorCode: "no_stripe_customer",
                failedOperation: "customer_validation",
                userEmail: userProfile?.email
            }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const stripeCustomerId = userProfile.stripe_customer_id;

        // 2. Validate user has PUDO configured
        if (!pudoType) {
            return new Response(JSON.stringify({
                success: false,
                error: "Usuario no tiene punto PUDO configurado. Debe seleccionar un punto de recogida antes de recibir asignaciones.",
                errorCode: "no_pudo_configured",
                failedOperation: "pudo_validation",
                userEmail: userProfile.email
            }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 3. Check if user has Correos PUDO - only charge if Correos
        if (pudoType !== 'correos') {
            console.log(`No charge needed for user ${userId} with pudo_type: ${pudoType || 'not set'}`);
            return new Response(JSON.stringify({
                success: true,
                message: "No charge required for Brickshare PUDO",
                depositPaymentIntentId: null,
                transportPaymentIntentId: null,
                depositAmount: 0,
                transportAmount: 0
            }), {
                status: 200,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 4. Get default payment method (only for Correos users)
        const paymentMethod = await getDefaultPaymentMethod(stripeCustomerId);

        if (!paymentMethod) {
            return new Response(JSON.stringify({
                success: false,
                error: "Usuario no tiene método de pago configurado",
                errorCode: "no_payment_method",
                failedOperation: "customer_validation",
                userEmail: userProfile.email
            }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 5. Create PaymentIntent for Transport Fee (Correos only) - Immediate charge
        let transportPaymentIntent;
        const shippingCost = parseInt(Deno.env.get("COSTE_ENVIO_DEVOLUCION") ?? "8");

        try {
            transportPaymentIntent = await stripe.paymentIntents.create({
                amount: shippingCost * 100,
                currency: "eur",
                customer: stripeCustomerId,
                payment_method: paymentMethod,
                off_session: true,
                confirm: true,
                capture_method: "automatic",
                description: `Gastos de transporte Correos - Set ${setRef}`,
                metadata: {
                    user_id: userId,
                    set_ref: setRef,
                    type: "transport",
                    pudo_type: "correos"
                }
            });

            console.log(`Transport fee charged: ${transportPaymentIntent.id}, status: ${transportPaymentIntent.status}, amount: ${shippingCost} EUR`);

            // Check if charge was successful
            if (transportPaymentIntent.status !== "succeeded") {
                throw new Error(`Transport charge failed with status: ${transportPaymentIntent.status}`);
            }

        } catch (error: any) {
            console.error("Transport charge failed:", error);

            let errorCode = "stripe_error";
            if (error.code === "insufficient_funds" || error.decline_code === "insufficient_funds") {
                errorCode = "insufficient_funds";
            } else if (error.code === "card_declined" || error.type === "card_error") {
                errorCode = "card_declined";
            }

            return new Response(JSON.stringify({
                success: false,
                error: error.message || "Error al procesar cobro de transporte",
                errorCode: errorCode,
                failedOperation: "transport",
                userEmail: userProfile.email
            }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // 6. Success: Transport fee charged
        return new Response(JSON.stringify({
            success: true,
            transportPaymentIntentId: transportPaymentIntent.id,
            transportAmount: shippingCost
        }), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (error: any) {
        console.error("Error processing assignment payment:", error);
        return new Response(JSON.stringify({
            success: false,
            error: error.message || "Error inesperado al procesar el pago",
            errorCode: "stripe_error",
            failedOperation: "unknown"
        }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
