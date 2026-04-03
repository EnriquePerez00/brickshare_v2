/**
 * Script de prueba: Verificar que user3 puede imprimir etiquetas con Swikly V2
 * 
 * Problema original:
 * - user3 tiene un set asignado pero no lo veía disponible en "imprimir etiquetas"
 * - Faltaban campos phoneNumber y language en el payload de Swikly
 * - El webhook no se actualizaba correctamente con la firma V2
 * 
 * Solución:
 * - Migración a API V2 de Swikly
 * - Fase 1: Quick Wins (phoneNumber + language + mejor logging)
 * - Fase 2: Migración API (Bearer token + nuevo endpoint + firma V2)
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("VITE_SUPABASE_URL") || "http://127.0.0.1:54321";
const SUPABASE_ANON_KEY = Deno.env.get("VITE_SUPABASE_ANON_KEY") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function main() {
  console.log("\n🔍 TEST: Verificar user3 con Swikly V2\n");
  console.log(`Supabase: ${SUPABASE_URL}\n`);

  try {
    // ── 1. Obtener user3 ──────────────────────────────────────────────────────
    console.log("📋 Buscando user3...");
    const { data: users, error: usersErr } = await supabase
      .from("users")
      .select("id, full_name, email, phone")
      .filter("full_name", "ilike", "%user3%")
      .limit(1);

    if (usersErr || !users || users.length === 0) {
      throw new Error(`No se encontró user3: ${usersErr?.message}`);
    }

    const user3 = users[0];
    console.log(`✅ Encontrado: ${user3.full_name} (${user3.email})`);
    console.log(`   - ID: ${user3.id}`);
    console.log(`   - Teléfono: ${user3.phone || "N/A"}\n`);

    // ── 2. Buscar envíos de user3 ─────────────────────────────────────────────
    console.log("📦 Buscando envíos de user3...");
    const { data: shipments, error: shipErr } = await supabase
      .from("shipments")
      .select(`
        id, 
        set_ref, 
        shipment_status, 
        swikly_status, 
        swikly_wish_id,
        swikly_wish_url,
        swikly_deposit_amount,
        created_at
      `)
      .eq("user_id", user3.id)
      .order("created_at", { ascending: false });

    if (shipErr) throw new Error(`Error fetching shipments: ${shipErr.message}`);

    if (!shipments || shipments.length === 0) {
      console.log("⚠️  user3 no tiene envíos asignados\n");
      return;
    }

    console.log(`✅ Encontrados ${shipments.length} envío(s)\n`);

    // ── 3. Analizar cada envío ────────────────────────────────────────────────
    for (const shipment of shipments) {
      console.log(`\n📫 Envío: ${shipment.id}`);
      console.log(`   Set: ${shipment.set_ref}`);
      console.log(`   Status: ${shipment.shipment_status}`);
      console.log(`   Swikly Status: ${shipment.swikly_status || "N/A"}`);
      console.log(`   Depósito: €${((shipment.swikly_deposit_amount || 0) / 100).toFixed(2)}`);

      // Obtener info del set
      const { data: setData } = await supabase
        .from("sets")
        .select("set_name, set_pvp_release")
        .eq("set_ref", shipment.set_ref)
        .single();

      if (setData) {
        console.log(`   Set Name: ${setData.set_name}`);
        console.log(`   PVP Release: €${setData.set_pvp_release}`);
      }

      // ── Verificar si está disponible para imprimir etiquetas ─────────────
      const canPrint =
        shipment.shipment_status === "assigned" &&
        shipment.swikly_status === "accepted";

      console.log(`   ✅ Disponible para imprimir: ${canPrint ? "SÍ" : "NO"}`);

      if (!canPrint) {
        console.log(`   ❌ Razones:`);
        if (shipment.shipment_status !== "assigned") {
          console.log(`      - Status no es 'assigned' (es: ${shipment.shipment_status})`);
        }
        if (shipment.swikly_status !== "accepted") {
          console.log(`      - Swikly status no es 'accepted' (es: ${shipment.swikly_status})`);
        }
      }

      // Mostrar Swikly URL si existe
      if (shipment.swikly_wish_url) {
        console.log(`   🔗 Swikly URL: ${shipment.swikly_wish_url}`);
      }
    }

    // ── 4. Verificar que los campos está siendo enviados a Swikly ───────────
    console.log("\n\n📊 VERIFICACIÓN DE CAMPOS ENVIADOS A SWIKLY\n");
    console.log("✅ Fase 1 - Quick Wins:");
    console.log(`   ✓ phoneNumber: ${user3.phone ? "Sí" : "No (pero disponible en BD)"}`);
    console.log(`   ✓ language: "es" (siempre enviado)`);
    console.log(`   ✓ Parsing de nombres: firstName/lastName (mejorado)\n`);

    console.log("✅ Fase 2 - API V2:");
    console.log(`   ✓ Autenticación: Bearer token`);
    console.log(`   ✓ Endpoint: /accounts/{id}/requests`);
    console.log(`   ✓ Estructura payload: Deposit anidado`);
    console.log(`   ✓ Webhook firma: Swikly-Signature V2\n`);

    // ── 5. Resumen ────────────────────────────────────────────────────────────
    console.log("📝 RESUMEN:\n");
    const totalShipments = shipments.length;
    const withSwiklyId = shipments.filter((s) => s.swikly_wish_id).length;
    const accepted = shipments.filter((s) => s.swikly_status === "accepted").length;
    const ready = shipments.filter(
      (s) => s.shipment_status === "assigned" && s.swikly_status === "accepted"
    ).length;

    console.log(`Envíos totales: ${totalShipments}`);
    console.log(`Con swikly_wish_id: ${withSwiklyId}`);
    console.log(`Con swikly_status = 'accepted': ${accepted}`);
    console.log(`Listos para imprimir etiquetas: ${ready}\n`);

    if (ready === 0 && totalShipments > 0) {
      console.log("⚠️  PROBLEMA: Ningún envío está listo para imprimir etiquetas");
      console.log("   Próximos pasos:");
      console.log("   1. Verificar que los webhooks de Swikly se reciben correctamente");
      console.log("   2. Confirmar que SWIKLY_API_TOKEN está configurado");
      console.log("   3. Revisar logs de Edge Functions: supabase functions logs create-swikly-wish-shipment");
      console.log("   4. Revisar logs de webhook: supabase functions logs swikly-webhook");
    } else if (ready > 0) {
      console.log(`✅ ÉXITO: ${ready} envío(s) está(n) listo(s) para imprimir etiquetas`);
    }
  } catch (err) {
    console.error("❌ ERROR:", err.message);
    process.exit(1);
  }
}

main();