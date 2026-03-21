/**
 * test-deposit-locations.ts
 *
 * Script de exploración: conecta a la API de Depósitos Brickshare
 * y muestra las ubicaciones que se mapean en verde en el selector PUDO.
 *
 * Uso:
 *   npx tsx scripts/test-deposit-locations.ts
 *
 * Requiere que el servidor local esté corriendo en http://localhost:3000
 */

const API_URL = "http://localhost:3000/api/locations";

interface DepositPoint {
  id: string;
  code: string;
  name: string;           // Nombre interno / propietario
  location_name: string;  // Nombre público del establecimiento
  address: string;
  postal_code: string;
  city: string;
  is_active: boolean;
}

async function testDepositLocations() {
  console.log("=".repeat(60));
  console.log("  TEST: Depósitos Brickshare (marcadores VERDES en el mapa)");
  console.log("=".repeat(60));
  console.log(`\nConectando a: ${API_URL}\n`);

  let data: DepositPoint[];

  try {
    const response = await fetch(API_URL);

    if (!response.ok) {
      console.error(`❌ Error HTTP ${response.status}: ${response.statusText}`);
      const body = await response.text().catch(() => "(sin cuerpo)");
      console.error("Respuesta:", body);
      process.exit(1);
    }

    data = await response.json();
  } catch (err: any) {
    if (
      err?.cause?.code === "ECONNREFUSED" ||
      err?.message?.includes("ECONNREFUSED") ||
      err?.message?.includes("fetch failed")
    ) {
      console.error("❌ No se puede conectar a http://localhost:3000");
      console.error("   Asegúrate de que el servidor de Depósitos está corriendo.");
    } else {
      console.error("❌ Error inesperado:", err?.message ?? err);
    }
    process.exit(1);
  }

  if (!Array.isArray(data)) {
    console.error("❌ La API no devolvió un array. Respuesta recibida:");
    console.error(JSON.stringify(data, null, 2));
    process.exit(1);
  }

  const active = data.filter((p) => p.is_active);
  const inactive = data.filter((p) => !p.is_active);

  console.log(`Total de ubicaciones: ${data.length}`);
  console.log(`  ✅ Activas   (verdes en el mapa): ${active.length}`);
  console.log(`  ⏸️  Inactivas (no se muestran):   ${inactive.length}`);

  // --- ACTIVAS (verdes) ---
  if (active.length > 0) {
    console.log("\n" + "─".repeat(60));
    console.log("  📍 UBICACIONES ACTIVAS (marcadores verdes)");
    console.log("─".repeat(60));
    active.forEach((p, i) => {
      console.log(`\n[${i + 1}] ${p.location_name}  (${p.name})`);
      console.log(`    Código   : ${p.code}`);
      console.log(`    Dirección: ${p.address}, ${p.postal_code} ${p.city}`);
      console.log(`    ID       : ${p.id}`);
    });
  } else {
    console.log("\n⚠️  No hay ninguna ubicación activa. El mapa no mostrará marcadores verdes.");
  }

  // --- INACTIVAS ---
  if (inactive.length > 0) {
    console.log("\n" + "─".repeat(60));
    console.log("  ⏸️  UBICACIONES INACTIVAS (no aparecen en el mapa)");
    console.log("─".repeat(60));
    inactive.forEach((p, i) => {
      console.log(`\n[${i + 1}] ${p.location_name}  (${p.name})`);
      console.log(`    Código   : ${p.code}`);
      console.log(`    Dirección: ${p.address}, ${p.postal_code} ${p.city}`);
      console.log(`    ID       : ${p.id}`);
    });
  }

  // --- RESUMEN JSON ---
  console.log("\n" + "─".repeat(60));
  console.log("  JSON RAW (todas las ubicaciones)");
  console.log("─".repeat(60));
  console.log(JSON.stringify(data, null, 2));

  console.log("\n" + "=".repeat(60));
  console.log("  Fin del test.");
  console.log("=".repeat(60) + "\n");
}

testDepositLocations();