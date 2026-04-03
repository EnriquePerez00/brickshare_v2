#!/usr/bin/env node

/**
 * Test Resend Email - Direct Edge Function Invocation
 * 
 * Llamada directa a la Edge Function con RESEND_API_KEY correctamente configurada
 * Para diagnosticar si el email se envía realmente a Resend
 */

import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "http://127.0.0.1:54331";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";

const supabase = createClient(supabaseUrl, supabaseKey);

async function testResendDirect() {
  console.log("\n╔════════════════════════════════════════════════════════════╗");
  console.log("║       TEST RESEND EMAIL - DIRECT EDGE FUNCTION             ║");
  console.log("╚════════════════════════════════════════════════════════════╝\n");

  // Step 1: Find any Brickshare shipment (regardless of status)
  console.log("🔍 STEP 1: Finding a Brickshare shipment\n");

  const { data: shipments, error: shipmentError } = await supabase
    .from("shipments")
    .select(`
      id,
      user_id,
      set_ref,
      delivery_qr_code,
      shipment_status,
      swikly_status,
      pudo_type,
      users:user_id(email, full_name),
      sets:set_ref(set_name)
    `)
    .eq("pudo_type", "brickshare")
    .limit(3)
    .order("updated_at", { ascending: false });

  if (shipmentError || !shipments || shipments.length === 0) {
    console.log("   ❌ No Brickshare shipments found at all");
    console.log("   Available statuses to check:");
    
    // Show what shipments exist
    const { data: allShipments } = await supabase
      .from("shipments")
      .select("shipment_status, swikly_status, pudo_type")
      .limit(10);
    
    if (allShipments) {
      const statuses = new Set();
      allShipments.forEach(s => {
        statuses.add(`pudo_type=${s.pudo_type}, status=${s.shipment_status}, swikly=${s.swikly_status}`);
      });
      console.log("   " + Array.from(statuses).join("\n   "));
    }
    return;
  }

  console.log(`   ✅ Found ${shipments.length} Brickshare shipment(s)\n`);

  // Loop through shipments and try to send
  for (const shipment of shipments) {
    const s = shipment as any;
    console.log(`📧 Testing with Shipment: ${s.id}`);
    console.log(`   User: ${s.users?.full_name} (${s.users?.email})`);
    console.log(`   Status: ${s.shipment_status} / Swikly: ${s.swikly_status}`);
    console.log(`   QR Code: ${s.delivery_qr_code ? "✅ EXISTS" : "❌ MISSING"}\n`);

    // If QR code is missing, we can't test properly
    if (!s.delivery_qr_code) {
      console.log("   ⚠️ Skipping - QR code is missing (needed for email)\n");
      continue;
    }

    // Step 2: Call Edge Function
    console.log("   🔄 Calling send-brickshare-qr-email Edge Function...\n");

    const { data: emailData, error: emailError } = await supabase.functions.invoke(
      "send-brickshare-qr-email",
      {
        body: {
          shipment_id: s.id,
          type: "delivery",
        },
      }
    );

    if (emailError) {
      console.log("   ❌ ERROR from Edge Function:");
      console.log(`      Status: ${emailError.context?.status || "UNKNOWN"}`);
      console.log(`      Message: ${emailError.message}`);
      if (emailError.context?.error) {
        try {
          const errorData = JSON.parse(emailError.context.error);
          console.log(`      Details: ${JSON.stringify(errorData, null, 6)}`);
        } catch {
          console.log(`      Details: ${emailError.context.error}`);
        }
      }
      console.log();
      continue;
    }

    if (!emailData?.success) {
      console.log("   ⚠️ Edge Function returned non-success response:");
      console.log(`      ${JSON.stringify(emailData, null, 6)}`);
      console.log();
      continue;
    }

    console.log("   ✅ SUCCESS - Email sent via Edge Function!");
    console.log(`      Email ID: ${emailData.email_id}`);
    console.log(`      QR Code: ${emailData.qr_code}`);
    console.log();

    // Success! Tell user to check Resend
    console.log("╔════════════════════════════════════════════════════════════╗");
    console.log("║                    ✅ TEST SUCCESSFUL                       ║");
    console.log("╚════════════════════════════════════════════════════════════╝\n");

    console.log("📋 Next Steps:");
    console.log(`   1. Email sent to: ${s.users?.email}`);
    console.log("   2. Check https://resend.com/emails");
    console.log("   3. Look for subject: 'Tu código QR para recoger'");
    console.log("   4. Status should be 'Delivered' or 'Sent'\n");

    return;
  }

  // If we got here, all shipments had issues
  console.log("❌ Could not test with any shipment (all were missing QR codes or had errors)");
}

testResendDirect().catch((error) => {
  console.error("❌ Test failed:", error);
  process.exit(1);
});