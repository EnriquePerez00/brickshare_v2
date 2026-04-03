/**
 * Script de prueba: ¿Funciona el API Key de V1 en la API V2 de Swikly?
 * 
 * Este script prueba si el token del sandbox de V1 puede autenticarse en V2
 */

const SWIKLY_API_TOKEN_SANDBOX = "api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3";
const SWIKLY_API = "https://api.v2.sandbox.swikly.com/v1";

async function testSwiklyV2Auth() {
  console.log("\n🧪 TEST: ¿Funciona el API Key V1 en API V2?\n");
  console.log(`API Token (primeros 30 chars): ${SWIKLY_API_TOKEN_SANDBOX.slice(0, 30)}...`);
  console.log(`Endpoint: ${SWIKLY_API}\n`);

  try {
    // ── Intento 1: Hacer un request simple con Bearer token ────────────────
    console.log("📌 Intento 1: Llamar con Bearer token...\n");

    // Primero, intentamos obtener información de la cuenta con una llamada al endpoint principal
    // Este es un endpoint que no requiere account_id
    const testPayload = {
      description: "Test Brickshare",
      firstName: "Test",
      lastName: "User",
      email: "test@example.com",
      callbacks: {
        requestSecured: "https://example.com/webhook",
      },
      deposit: {
        startDate: new Date().toISOString().slice(0, 10),
        endDate: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10),
        amount: 7999,
      },
      language: "es",
    };

    // Intentamos diferentes endpoints que podrían funcionar sin account_id:
    const endpoints = [
      `${SWIKLY_API}/requests`,                    // Posible endpoint sin account_id
      `${SWIKLY_API}/accounts`,                    // Para listar cuentas
      `${SWIKLY_API}/health`,                      // Health check
    ];

    for (const endpoint of endpoints) {
      console.log(`   ▶ Probando: ${endpoint}`);
      try {
        const res = await fetch(endpoint, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${SWIKLY_API_TOKEN_SANDBOX}`,
          },
        });

        console.log(`     └─ Status: ${res.status}`);
        const data = await res.json();
        console.log(`     └─ Response: ${JSON.stringify(data, null, 2).slice(0, 200)}...\n`);

        if (res.ok) {
          console.log(`✅ ÉXITO: Endpoint ${endpoint} funcionó con Bearer token V1!\n`);
          return { success: true, endpoint, data };
        }
      } catch (e) {
        console.log(`     └─ Error: ${(e as Error).message}\n`);
      }
    }

    // ── Intento 2: Probar con X-Api-Key (por si V2 sigue aceptando esto) ──────
    console.log("📌 Intento 2: Intentar con X-Api-Key header (compatibilidad)...\n");

    const res2 = await fetch(`${SWIKLY_API}/accounts`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-Api-Key": SWIKLY_API_TOKEN_SANDBOX,
      },
    });

    console.log(`   Status: ${res2.status}`);
    const data2 = await res2.json();
    console.log(`   Response: ${JSON.stringify(data2, null, 2).slice(0, 300)}\n`);

    if (res2.ok) {
      console.log(`✅ ÉXITO: X-Api-Key funcionó!\n`);
      return { success: true, method: "X-Api-Key", data: data2 };
    }

    // ── Intento 3: Probar como secret en HMAC (por si es necesario) ─────────
    console.log("📌 Intento 3: Verificar formato del token...\n");
    console.log(`Token format: ${SWIKLY_API_TOKEN_SANDBOX.startsWith("api-") ? "✓ Parece ser un token de API (prefijo 'api-')" : "✗ Formato desconocido"}`);
    console.log(`Token length: ${SWIKLY_API_TOKEN_SANDBOX.length} caracteres\n`);

    return {
      success: false,
      message: "No se pudo autenticar, pero el token parece válido",
    };
  } catch (err: any) {
    console.error("❌ ERROR:", err.message);
    return { success: false, error: err.message };
  }
}

async function testSwiklyAccountInfo() {
  console.log("\n🔍 Obtener información de la cuenta de Swikly...\n");

  try {
    // Intentar obtener info de cuenta con diferentes métodos
    const methods = [
      {
        name: "GET /accounts (Bearer token)",
        url: `${SWIKLY_API}/accounts`,
        method: "GET",
        headers: { "Authorization": `Bearer ${SWIKLY_API_TOKEN_SANDBOX}` },
      },
      {
        name: "POST /accounts (Bearer token)",
        url: `${SWIKLY_API}/accounts`,
        method: "POST",
        headers: { "Authorization": `Bearer ${SWIKLY_API_TOKEN_SANDBOX}` },
        body: JSON.stringify({}),
      },
    ];

    for (const method of methods) {
      console.log(`📌 ${method.name}:`);
      try {
        const res = await fetch(method.url, {
          method: method.method as any,
          headers: {
            "Content-Type": "application/json",
            ...method.headers,
          },
          body: method.body,
        });

        const data = await res.json();
        console.log(`   Status: ${res.status}`);
        console.log(`   Response: ${JSON.stringify(data, null, 2)}\n`);

        if (res.ok && data.id) {
          console.log(`✅ CUENTA ENCONTRADA: ${data.id}\n`);
          return data;
        }
      } catch (e) {
        console.log(`   Error: ${(e as Error).message}\n`);
      }
    }

    return null;
  } catch (err: any) {
    console.error("Error:", err.message);
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
async function main() {
  console.log("═══════════════════════════════════════════════════════════════");
  console.log("TEST: Compatibilidad API Key V1 → API V2");
  console.log("═══════════════════════════════════════════════════════════════");

  const result = await testSwiklyV2Auth();

  console.log("\n📊 RESULTADO:");
  console.log(JSON.stringify(result, null, 2));

  if (result.success) {
    console.log("\n✅ ÉXITO: El API Key de V1 funciona en V2!");
    console.log("   Próximo paso: Obtener ACCOUNT_ID\n");

    const accountInfo = await testSwiklyAccountInfo();
    if (accountInfo) {
      console.log(`✅ ACCOUNT_ID encontrado: ${accountInfo.id}`);
      console.log("   Usa este valor en SWIKLY_ACCOUNT_ID\n");
    }
  } else {
    console.log("\n❌ El API Key de V1 NO funciona directamente en V2");
    console.log("   Necesitarías:");
    console.log("   1. Un nuevo API Token (Bearer token) para V2");
    console.log("   2. O validar si Swikly ha deprecated el token de V1\n");
  }
}

main();