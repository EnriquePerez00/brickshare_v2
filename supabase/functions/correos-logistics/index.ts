import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CorreosConfig {
    clientId: string;
    clientSecret: string;
    contractId: string;
    baseUrl: string;
    authUrl: string;
    scope: string;
}

const OFFICE_ADDRESS = {
    nombre: "Brickshare Oficinas",
    direccion: "Avinguda josep Tarradellas 97",
    cp: "08029",
    poblacion: "Barcelona",
    provincia: "Barcelona",
    pais: "España"
};

function parseDimensions(dimStr: string | null) {
    // Default dimensions if null or malformed
    const defaults = { alto: 10, ancho: 20, largo: 30 };
    if (!dimStr) return defaults;

    try {
        // Expected format: "48 x 37.8 x 7 cm"
        const parts = dimStr.toLowerCase().replace('cm', '').split('x').map(p => parseFloat(p.trim()));
        if (parts.length >= 3 && !parts.some(isNaN)) {
            return {
                alto: parts[0],
                ancho: parts[1],
                largo: parts[2]
            };
        }
    } catch (e) {
        console.warn("Failed to parse dimensions:", dimStr);
    }
    return defaults;
}

// Simple in-memory cache for the token
let cachedToken: string | null = null;
let tokenExpiration: number | null = null;

const getCorreosToken = async (config: CorreosConfig): Promise<string> => {
    if (cachedToken && tokenExpiration && Date.now() < tokenExpiration - 60000) {
        return cachedToken;
    }

    console.log("Acquiring new Correos token...");

    const params = new URLSearchParams();
    params.append('grant_type', 'client_credentials');
    params.append('client_id', config.clientId);
    params.append('client_secret', config.clientSecret);
    params.append('scope', config.scope);

    const response = await fetch(config.authUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
        },
        body: params,
    });

    if (!response.ok) {
        const text = await response.text();
        throw new Error(`Failed to get OAuth token: ${response.status} ${response.statusText} - ${text}`);
    }

    const data = await response.json();

    if (!data.access_token) {
        throw new Error(`Token response missing access_token: ${JSON.stringify(data)}`);
    }

    cachedToken = data.access_token;
    const expiresInMinutes = data.expiresIn ? parseInt(data.expiresIn) : 30;
    tokenExpiration = Date.now() + (expiresInMinutes * 60 * 1000);

    return data.access_token;
};

const fetchWithAuth = async (url: string, options: RequestInit, config: CorreosConfig): Promise<Response> => {
    let token = await getCorreosToken(config);

    let response = await fetch(url, {
        ...options,
        headers: {
            ...options.headers,
            'Authorization': `Bearer ${token}`
        }
    });

    if (response.status === 401 || response.status === 403) {
        console.warn(`Received ${response.status}, refreshing token and retrying...`);
        cachedToken = null;
        tokenExpiration = null;
        token = await getCorreosToken(config);

        response = await fetch(url, {
            ...options,
            headers: {
                ...options.headers,
                'Authorization': `Bearer ${token}`
            }
        });
    }

    return response;
};

const sendReturnEmail = async (supabaseUrl: string, supabaseKey: string, emailData: any) => {
    try {
        const response = await fetch(`${supabaseUrl}/functions/v1/send-email`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${supabaseKey}`
            },
            body: JSON.stringify(emailData)
        });
        return response.ok;
    } catch (e) {
        console.error("Failed to send return email:", e);
        return false;
    }
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
        const supabaseClient = createClient(supabaseUrl, supabaseKey)

        const config: CorreosConfig = {
            clientId: Deno.env.get('CORREOS_CLIENT_ID') ?? '',
            clientSecret: Deno.env.get('CORREOS_CLIENT_SECRET') ?? '',
            contractId: Deno.env.get('CORREOS_CONTRACT_ID') ?? '',
            baseUrl: Deno.env.get('CORREOS_BASE_URL') ?? Deno.env.get('CORREOS_BASE_PRE_PROD_URL') ?? 'https://api1.correos.es',
            authUrl: Deno.env.get('CORREOS_AUTH_URL') ?? 'https://apioauthcid.correos.es/Api/Authorize/Token',
            scope: Deno.env.get('CORREOS_SCOPE') ?? 'oauthtest'
        }

        const { action, p_envios_id, p_shipment_id } = await req.json()

        // Support both old and new parameter names during transition
        const shipmentId = p_shipment_id || p_envios_id;

        // 1. JWT Verification and Authorization
        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: 'Missing Authorization header' }),
                { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        const supabaseUserClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY') ?? '', {
            global: { headers: { Authorization: authHeader } }
        })

        const { data: { user }, error: userError } = await supabaseUserClient.auth.getUser()
        if (userError || !user) {
            return new Response(
                JSON.stringify({ error: 'Unauthorized' }),
                { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // 2. Role check (Only admins and operadores)
        const { data: roles, error: rolesError } = await supabaseClient
            .from('user_roles')
            .select('role')
            .eq('user_id', user.id)

        if (rolesError) throw rolesError

        const userRoles = roles.map(r => r.role)
        const isAuthorized = userRoles.includes('admin') || userRoles.includes('operador')

        if (!isAuthorized) {
            return new Response(
                JSON.stringify({ error: 'Forbidden - Insufficient permissions' }),
                { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        if (!action || !shipmentId) {
            return new Response(
                JSON.stringify({ error: 'Missing action or p_shipment_id' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        switch (action) {
            case 'preregister': {
                const { data: shipment, error: shipmentError } = await supabaseClient
                    .from('shipments')
                    .select(`
                        id, 
                        shipping_address, 
                        shipping_city, 
                        shipping_postal_code, 
                        user_id,
                        set_id,
                        sets:set_id (
                            set_name,
                            set_ref,
                            set_weight,
                            set_dim
                        ),
                        users:user_id (
                            full_name,
                            email,
                            phone
                        )
                    `)
                    .eq('id', shipmentId)
                    .single();

                if (shipmentError || !shipment) {
                    throw new Error(`Shipment not found: ${shipmentError?.message}`);
                }

                const preregisterPayload = {
                    solicitante: config.contractId,
                    fecha: new Date().toISOString().split('T')[0],
                    envio: {
                        codEtiquetado: "",
                        referencia: shipment.id,
                        remitente: {
                            nombre: "Brickshare Almacén",
                            direccion: OFFICE_ADDRESS.direccion,
                            cp: OFFICE_ADDRESS.cp,
                            poblacion: OFFICE_ADDRESS.poblacion,
                            provincia: OFFICE_ADDRESS.provincia,
                        },
                        destinatario: {
                            nombre: shipment.users?.full_name || "Cliente Brickshare",
                            direccion: shipment.shipping_address,
                            cp: shipment.shipping_postal_code,
                            poblacion: shipment.shipping_city,
                            provincia: shipment.shipping_city,
                            email: shipment.users?.email,
                            telefono: shipment.users?.phone,
                        },
                        bultos: [{
                            peso: shipment.sets?.set_weight || 1,
                            ...parseDimensions(shipment.sets?.set_dim)
                        }],
                        añadidos: [
                            {
                                tipAñadido: "E" // Entrega en Oficina/Citypaq
                            }
                        ]
                    }
                };

                const preregisterResponse = await fetchWithAuth(`${config.baseUrl}/preregister`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(preregisterPayload),
                }, config);

                if (!preregisterResponse.ok) {
                    const errorData = await preregisterResponse.json();
                    throw new Error(`Correos Preregister Error: ${JSON.stringify(errorData)}`);
                }

                const preregisterData = await preregisterResponse.json();
                const correosShipmentId = preregisterData.codEtiquetado;

                await supabaseClient
                    .from('shipments')
                    .update({
                        correos_shipment_id: correosShipmentId,
                        shipment_status: 'prepared',
                        updated_at: new Date().toISOString()
                    })
                    .eq('id', shipmentId);

                return new Response(
                    JSON.stringify({ message: 'Preregistration successful', correos_shipment_id: correosShipmentId }),
                    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            case 'return_preregister': {
                // 1. Fetch shipment, user and set data
                const { data: shipment, error: shipmentError } = await supabaseClient
                    .from('shipments')
                    .select(`
                        id, 
                        shipping_address, 
                        shipping_city, 
                        shipping_postal_code, 
                        user_id,
                        set_id,
                        sets:set_id (
                            set_name,
                            set_ref,
                            set_weight,
                            set_dim
                        ),
                        users:user_id (
                            full_name,
                            email,
                            phone
                        )
                    `)
                    .eq('id', shipmentId)
                    .single();

                if (shipmentError || !shipment) {
                    throw new Error(`Shipment info not found: ${shipmentError?.message}`);
                }

                // 2. Fetch PUDO info for this user
                const { data: pudoData, error: pudoError } = await supabaseClient
                    .from('users_correos_dropping')
                    .select('*')
                    .eq('user_id', shipment.user_id)
                    .single();

                if (pudoError) {
                    console.warn(`PUDO info not found for user ${shipment.user_id}: ${pudoError.message}`);
                }

                const pudo = pudoData;

                const returnPayload = {
                    solicitante: config.contractId,
                    fecha: new Date().toISOString().split('T')[0],
                    envio: {
                        referencia: `RET-${shipment.id.substring(0, 8)}`,
                        remitente: {
                            nombre: shipment.users?.full_name || "Cliente Brickshare",
                            direccion: pudo?.correos_full_address || shipment.shipping_address,
                            cp: pudo?.correos_zip_code || shipment.shipping_postal_code,
                            poblacion: pudo?.correos_city || shipment.shipping_city,
                            provincia: pudo?.correos_province || shipment.shipping_city,
                            email: shipment.users?.email,
                            telefono: shipment.users?.phone,
                        },
                        destinatario: {
                            nombre: OFFICE_ADDRESS.nombre,
                            direccion: OFFICE_ADDRESS.direccion,
                            cp: OFFICE_ADDRESS.cp,
                            poblacion: OFFICE_ADDRESS.poblacion,
                            provincia: OFFICE_ADDRESS.provincia,
                        },
                        bultos: [{
                            peso: shipment.sets?.set_weight || 1,
                            ...parseDimensions(shipment.sets?.set_dim)
                        }],
                        caracteristicas: {
                            etiqueta_sin_etiqueta: "S"
                        }
                    }
                };

                const returnResponse = await fetchWithAuth(`${config.baseUrl}/preregister`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(returnPayload),
                }, config);

                if (!returnResponse.ok) {
                    const errorData = await returnResponse.json();
                    throw new Error(`Correos Return Preregister Error: ${JSON.stringify(errorData)}`);
                }

                const returnData = await returnResponse.json();
                const returnCode = returnData.codEtiquetado || (returnData.qrCode ? "QR_CODE_PENDING" : "UNKNOWN");
                const qrCodeSvg = returnData.qrCode; // Base64 SVG from Correos

                await supabaseClient
                    .from('shipments')
                    .update({
                        tracking_number: returnCode,
                        shipment_status: 'in_return_pudo',
                        return_request_date: new Date().toISOString(),
                        pickup_provider: 'Correos (Sin Etiqueta)',
                        updated_at: new Date().toISOString()
                    })
                    .eq('id', shipmentId);

                await sendReturnEmail(supabaseUrl, supabaseKey, {
                    to: shipment.users?.email,
                    subject: "Tu código de devolución Brickshare",
                    html: `
                        <div style="font-family: sans-serif; max-width: 600px; margin: auto; color: #333;">
                            <h2 style="color: #1a1a1a;">¡Hola ${shipment.users?.full_name}!</h2>
                            <p>Has solicitado la devolución de tu set de LEGO <strong>${shipment.sets?.set_name}</strong>. Hemos activado el servicio <strong>"Etiqueta sin Etiqueta"</strong> para tu comodidad.</p>
                            
                            <div style="background: #fdf6b2; padding: 30px; border-radius: 12px; border: 1px solid #facc15; text-align: center; margin: 24px 0;">
                                <p style="margin: 0 0 10px 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; color: #854d0e; font-weight: bold;">CÓDIGO DE DEVOLUCIÓN</p>
                                <h1 style="margin: 0; font-size: 42px; letter-spacing: 4px; color: #000;">${returnCode !== "QR_CODE_PENDING" ? returnCode : "MOSTRAR QR"}</h1>
                                
                                ${qrCodeSvg ? `
                                <div style="margin-top: 20px; background: white; padding: 15px; display: inline-block; border-radius: 8px;">
                                    <img src="data:image/svg+xml;base64,${qrCodeSvg}" alt="Código QR de Correos" style="width: 200px; height: 200px;" />
                                </div>
                                ` : ''}
                            </div>

                            <div style="background: #f3f4f6; padding: 20px; border-radius: 12px; margin-bottom: 24px;">
                                <p style="margin: 0 0 10px 0; font-weight: bold; color: #4b5563;">PUNTO DE ENTREGA SELECCIONADO:</p>
                                <p style="margin: 0; font-size: 16px;">
                                    <strong>${pudo?.correos_name || 'Oficina de Correos'}</strong><br/>
                                    ${pudo?.correos_full_address || shipment.shipping_address}
                                </p>
                            </div>

                            <p style="font-weight: bold; font-size: 18px; margin-bottom: 15px;">Pasos a seguir:</p>
                            <ol style="padding-left: 20px; line-height: 1.6;">
                                <li style="margin-bottom: 10px;">Prepara el paquete de forma segura, preferiblemente en su embalaje original.</li>
                                <li style="margin-bottom: 10px;">Llévalo al punto de Correos indicado arriba.</li>
                                <li style="margin-bottom: 10px;">Muestra el <strong>código QR</strong> o el código alfanumérico al personal. <strong>No necesitas imprimir nada.</strong></li>
                            </ol>
                            
                            <div style="margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; font-size: 14px; color: #666; text-align: center;">
                                <p>Gracias por jugar con Brickshare. ¡Esperamos verte pronto!</p>
                            </div>
                        </div>
                    `
                });

                return new Response(
                    JSON.stringify({ message: 'Return requested successfully', return_code: returnCode }),
                    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            case 'get_label': {
                const { data: shipment, error: shipmentError } = await supabaseClient
                    .from('shipments')
                    .select('correos_shipment_id')
                    .eq('id', shipmentId)
                    .single();

                if (shipmentError || !shipment?.correos_shipment_id) {
                    throw new Error(`Shipment or Correos ID not found: ${shipmentError?.message}`);
                }

                const labelResponse = await fetchWithAuth(`${config.baseUrl}/labels`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        shipmentId: shipment.correos_shipment_id,
                        format: 'PDF',
                    }),
                }, config);

                if (!labelResponse.ok) throw new Error(`Correos Label Error: ${labelResponse.statusText}`);

                const labelBlob = await labelResponse.blob();
                const fileName = `label_${shipment.correos_shipment_id}.pdf`;
                const filePath = `${shipmentId}/${fileName}`;

                await supabaseClient.storage.from('shipping-labels').upload(filePath, labelBlob, {
                    contentType: 'application/pdf',
                    upsert: true
                });

                const { data: { publicUrl } } = supabaseClient.storage.from('shipping-labels').getPublicUrl(filePath);

                await supabaseClient.from('shipments').update({
                    label_url: publicUrl,
                    updated_at: new Date().toISOString()
                }).eq('id', shipmentId);

                return new Response(
                    JSON.stringify({ message: 'Label generated successfully', label_url: publicUrl }),
                    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            case 'request_pickup': {
                const { data: shipment, error: shipmentError } = await supabaseClient
                    .from('shipments')
                    .select('*, users:user_id(full_name, email, phone)')
                    .eq('id', shipmentId)
                    .single();

                if (shipmentError || !shipment) throw new Error(`Shipment not found: ${shipmentError?.message}`);

                const pickupPayload = [{
                    codContract: config.contractId,
                    codSpecificContract: config.contractId,
                    codAnnex: '091',
                    modalityType: 'S',
                    estimatedShipments: 1,
                    estimatedVolume: 20,
                    address: shipment.shipping_address.split(',')[0].trim(),
                    number: '1',
                    locality: shipment.shipping_city,
                    province: shipment.shipping_city,
                    postalCode: shipment.shipping_postal_code,
                    contactName: shipment.users?.full_name || "Cliente Brickshare",
                    contactEmail: shipment.users?.email || "info@brickshare.es",
                    phoneNumberContact: shipment.users?.phone || "000000000",
                    originSystem: 'CEX'
                }];

                const pickupResponse = await fetchWithAuth(`${config.baseUrl}/digital-delivery/v1/pickups`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(pickupPayload),
                }, config);

                if (!pickupResponse.ok) {
                    const errorData = await pickupResponse.json();
                    throw new Error(`Correos Pickup Error: ${JSON.stringify(errorData)}`);
                }

                const pickupData = await pickupResponse.json();
                const pickupId = pickupData[0]?.codRequests;

                await supabaseClient.from('shipments').update({
                    pickup_id: pickupId,
                    updated_at: new Date().toISOString()
                }).eq('id', shipmentId);

                return new Response(
                    JSON.stringify({ message: 'Pickup requested successfully', pickup_id: pickupId }),
                    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            case 'track': {
                const { data: shipment, error: shipmentError } = await supabaseClient
                    .from('shipments')
                    .select('correos_shipment_id')
                    .eq('id', shipmentId)
                    .single();

                if (shipmentError || !shipment?.correos_shipment_id) {
                    throw new Error(`Shipment or Correos ID not found: ${shipmentError?.message}`);
                }

                const trackResponse = await fetchWithAuth(`${config.baseUrl}/logistics/trackpub/api/v2/search/${shipment.correos_shipment_id}`, {
                    method: 'GET',
                    headers: {
                        'client_id': config.clientId,
                        'client_secret': config.clientSecret,
                    },
                }, config);

                if (!trackResponse.ok) throw new Error(`Correos Tracking Error: ${trackResponse.statusText}`);

                const trackData = await trackResponse.json();

                await supabaseClient.from('shipments').update({
                    last_tracking_update: new Date().toISOString(),
                    updated_at: new Date().toISOString()
                }).eq('id', shipmentId);

                return new Response(
                    JSON.stringify({ message: 'Tracking info retrieved', data: trackData }),
                    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            default:
                return new Response(
                    JSON.stringify({ error: 'Invalid action' }),
                    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                )
        }
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})