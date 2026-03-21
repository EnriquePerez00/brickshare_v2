import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CorreosConfig {
  clientId: string;
  clientSecret: string;
  baseUrl: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { lat, lng, radius = 5000 } = await req.json()

    // JWT Verification
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized - Missing header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { createClient } = await import("https://esm.sh/@supabase/supabase-js@2");
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const config: CorreosConfig = {
      clientId: Deno.env.get('CORREOS_CLIENT_ID') ?? '',
      clientSecret: Deno.env.get('CORREOS_CLIENT_SECRET') ?? '',
      baseUrl: Deno.env.get('CORREOS_BASE_URL') ?? 'https://api1.correos.es',
    }

    if (!config.clientId || !config.clientSecret) {
      throw new Error('Missing Correos credentials')
    }

    try {
      const url = new URL(`${config.baseUrl}/logistics/terminals/api/v1/homepaqs`)
      url.searchParams.append('latitude', lat.toString())
      url.searchParams.append('longitude', lng.toString())
      url.searchParams.append('distance', radius.toString())

      let response;
      let retries = 1;

      while (retries >= 0) {
        response = await fetch(url.toString(), {
          method: 'GET',
          headers: {
            'Accept': 'application/json',
            'client_id': config.clientId,
            'client_secret': config.clientSecret
          }
        });

        if (response.ok) break;

        // If 5xx error, retry once
        if (response.status >= 500 && retries > 0) {
          console.log(`Correos API 5xx error (${response.status}), retrying...`);
          await new Promise(resolve => setTimeout(resolve, 1000));
          retries--;
          continue;
        }

        const errText = await response.text();
        console.error(`Correos API Final Error: ${response.status}`, errText);
        throw new Error(`Error de Correos (${response.status})`);
      }

      if (!response || !response.ok) {
        throw new Error("No se pudo obtener respuesta de Correos");
      }

      const data = await response.json()
      // Ensure we have an array to map over
      const content = Array.isArray(data) ? data : (data.content && Array.isArray(data.content) ? data.content : []);

      if (content.length === 0 && data.error) {
        throw new Error(data.error);
      }

      const results = content.map((term: any) => {
        const parseCoord = (val: any) => {
          if (typeof val === 'number') return val;
          if (typeof val === 'string') return parseFloat(val.replace(',', '.'));
          return 0;
        };

        return {
          id_correos_pudo: term.terminalId || term.codHomepaq || term.id || `unknown-${Math.random()}`,
          nombre: term.alias || term.channelDescription || term.name || (term.terminalType === "P" || term.terminalType === "PUBLICO" ? "Citypaq" : "Oficina de Correos"),
          direccion: term.address || term.direccion || "Dirección no disponible",
          cp: term.postalCode || term.cp || "00000",
          ciudad: term.municipality || term.poblacion || term.location || "Localidad no disponible",
          lat: parseCoord(term.latitudeWGS84 || term.latitudeETRS89 || term.latitude || term.lat),
          lng: parseCoord(term.longitudeWGS84 || term.longitudeETRS89 || term.longitude || term.lng),
          horario: term.openingDescription || term.openingHours || term.fullSchedule || "Consultar en ubicación",
          tipo_punto: (() => {
            const name = (term.alias || term.channelDescription || term.name || "").toUpperCase();
            const type = (term.terminalType || "").toUpperCase();

            // Name overrides
            if (name.includes("CITYPAQ")) return "Citypaq";
            if (name.includes("SUC") || name.includes("OFICINA") || name.includes("DIRECCION")) return "Oficina";

            // Type-based classification
            if (type === "P" || type === "PUBLICO" || type === "D" || type === "DOMICILIARIO") return "Citypaq";

            return "Oficina";
          })()
        };
      })

      return new Response(
        JSON.stringify(results),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    } catch (apiError: any) {
      console.error('PUDO Function error:', apiError)
      throw apiError
    }
  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
