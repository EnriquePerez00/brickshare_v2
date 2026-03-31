/**
 * Test: Asignar set a user3 y verificar creación de depósito Swikly
 * 
 * Este script simula la asignación de un set a user3 y verifica que
 * la Edge Function create-swikly-wish-shipment funciona correctamente
 * con el ACCOUNT_ID configurado.
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Load from environment variables (use hardcoded values for local testing)
// NOTE: Do not commit real secrets. Use environment variables when running in production.
const SUPABASE_URL = "http://127.0.0.1:54331";
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

if (!SUPABASE_KEY) {
  console.warn("⚠️ SUPABASE_SERVICE_ROLE_KEY is not set. Set it via: export SUPABASE_SERVICE_ROLE_KEY=<key>");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testUser3Assignment() {
  console.log("\n═══════════════════════════════════════════════════════════════");
  console.log("TEST: Asignar set a user3 y crear depósito Swikly");
  console.log("═══════════════════════════════════════════════════════════════\n");

  try {
    // ── 1. Buscar usuario regular (no admin) ──────────────────────────────
    console.log("📌 Paso 1: Buscar usuario regular...\n");
    const { data: users, error: usersErr } = await supabase
      .from("users")
      .select("id, full_name, email, phone")
      .not("email", "like", "%admin%")
      .not("email", "like", "%test-%")
      .limit(1);

    if (usersErr || !users || users.length === 0) {
      throw new Error(`No hay usuarios disponibles: ${usersErr?.message}`);
    }

    const user3 = users[0];
    console.log(`✅ Usuario encontrado:`);
    console.log(`   ID: ${user3.id}`);
    console.log(`   Nombre: ${user3.full_name || "Sin nombre"}`);
    console.log(`   Email: ${user3.email}\n`);

    // ── 2. Obtener un set del catálogo ───────────────────────────────────
    console.log("📌 Paso 2: Obtener un set del catálogo...\n");
    const { data: sets, error: setsErr } = await supabase
      .from("sets")
      .select("id, set_ref, set_name, set_pvp_release")
      .gt("set_pvp_release", 0)
      .limit(1);

    if (setsErr || !sets || sets.length === 0) {
      throw new Error(`No hay sets disponibles: ${setsErr?.message}`);
    }

    const set = sets[0];
    console.log(`✅ Set seleccionado:`);
    console.log(`   Set Ref: ${set.set_ref}`);
    console.log(`   Nombre: ${set.set_name}`);
    console.log(`   Depósito (€): ${set.set_pvp_release}\n`);

    // ── 3. Crear un shipment (simulando asignación) ───────────────────────
    console.log("📌 Paso 3: Crear shipment para user3...\n");

    const { data: shipment, error: shipErr } = await supabase
      .from("shipments")
      .insert({
        user_id: user3.id,
        set_ref: set.set_ref,
        pudo_type: "brickshare",
        shipment_status: "pending",
        shipping_address: "C/ Test 123",
        shipping_city: "Madrid",
        shipping_zip_code: "28001",
      })
      .select("id")
      .single();

    if (shipErr || !shipment) {
      throw new Error(`Error creando shipment: ${shipErr?.message}`);
    }

    console.log(`✅ Shipment creado:`);
    console.log(`   ID: ${shipment.id}\n`);

    // ── 4. Llamar Edge Function para crear depósito Swikly ────────────────
    console.log("📌 Paso 4: Llamar Edge Function create-swikly-wish-shipment...\n");

    const functionRes = await supabase.functions.invoke(
      "create-swikly-wish-shipment",
      {
        body: { shipment_id: shipment.id },
      }
    );

    console.log(`Response Status: ${functionRes.status}`);
    console.log(`Response Data:`);
    console.log(JSON.stringify(functionRes.data, null, 2));

    if (functionRes.error) {
      throw new Error(`Error en Edge Function: ${JSON.stringify(functionRes.error)}`);
    }

    if (!functionRes.data.success) {
      throw new Error(`Edge Function retornó error: ${functionRes.data.error}`);
    }

    // ── 5. Verificar que el shipment fue actualizado ──────────────────────
    console.log("\n📌 Paso 5: Verificar estado del shipment...\n");

    const { data: updatedShipment, error: checkErr } = await supabase
      .from("shipments")
      .select("id, swikly_wish_id, swikly_status, swikly_deposit_amount")
      .eq("id", shipment.id)
      .single();

    if (checkErr || !updatedShipment) {
      throw new Error(`Error verificando shipment: ${checkErr?.message}`);
    }

    console.log(`✅ Shipment actualizado:`);
    console.log(`   Wish ID: ${updatedShipment.swikly_wish_id}`);
    console.log(`   Status: ${updatedShipment.swikly_status}`);
    console.log(`   Depósito (centavos): ${updatedShipment.swikly_deposit_amount}\n`);

    // ── 6. Resumen final ─────────────────────────────────────────────────
    console.log("═══════════════════════════════════════════════════════════════");
    console.log("✅ TEST EXITOSO");
    console.log("═══════════════════════════════════════════════════════════════");
    console.log(`
    Resumen:
    - Usuario: ${user3.full_name} (${user3.email})
    - Set: ${set.set_name} (${set.set_ref}) — €${set.set_pvp_release}
    - Shipment: ${shipment.id}
    - Wish ID Swikly: ${updatedShipment.swikly_wish_id}
    - Status: ${updatedShipment.swikly_status}
    
    Próximos pasos:
    1. Ir a Admin → Operations → Label Generation
    2. Buscar a ${user3.full_name}
    3. Verificar que aparece el set asignado
    4. Imprimir etiquetas
    `);

    return {
      success: true,
      user3,
      set,
      shipment,
      swikly: updatedShipment,
    };
  } catch (err: any) {
    console.error("\n❌ ERROR:", err.message);
    console.error("\nDetalles:", err);
    return { success: false, error: err.message };
  }
}

await testUser3Assignment();