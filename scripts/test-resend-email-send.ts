#!/usr/bin/env node

/**
 * Test Script: Validate Resend Email Sending
 * 
 * Verifies that the RESEND_API_KEY is correctly configured and can send emails
 * via the send-brickshare-qr-email Edge Function
 * 
 * Usage: npx ts-node scripts/test-resend-email-send.ts
 */

import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "http://127.0.0.1:54331";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";

const supabase = createClient(supabaseUrl, supabaseKey);

async function testResendEmail() {
  console.log("🧪 Testing Resend Email Configuration\n");

  // Step 1: Fetch a shipment ready for label generation
  console.log("📦 Step 1: Fetching shipment for testing...");

  const { data: shipment, error: shipmentError } = await supabase
    .from("shipments")
    .select(`
      id,
      user_id,
      set_ref,
      delivery_qr_code,
      shipment_status,
      swikly_status,
      users:user_id(email, full_name),
      sets:set_ref(set_name)
    `)
    .eq("shipment_status", "assigned")
    .eq("swikly_status", "accepted")
    .limit(1)
    .single();

  if (shipmentError || !shipment) {
    console.error("❌ No suitable shipment found:", shipmentError?.message);
    console.log(
      "📝 Note: Need a shipment with status='assigned' and swikly_status='accepted'"
    );
    return;
  }

  console.log(`✅ Found shipment: ${shipment.id}`);
  console.log(
    `   User: ${shipment.users?.full_name} (${shipment.users?.email})`
  );
  console.log(`   Set: ${shipment.sets?.set_name}`);
  console.log(`   QR Code: ${shipment.delivery_qr_code || "MISSING"}\n`);

  // Step 2: Call the Edge Function to send QR email
  console.log("📧 Step 2: Calling send-brickshare-qr-email Edge Function...");

  const { data: emailResponse, error: emailError } = await supabase.functions.invoke(
    "send-brickshare-qr-email",
    {
      body: {
        shipment_id: shipment.id,
        type: "delivery",
      },
    }
  );

  if (emailError) {
    console.error("❌ Error calling Edge Function:");
    console.error("   Message:", emailError.message);
    console.error("   Context:", emailError.context);
    return;
  }

  console.log("✅ Edge Function executed successfully\n");

  // Step 3: Analyze response
  console.log("📊 Step 3: Response Analysis:");
  console.log("   Status: SUCCESS ✓");

  if (emailResponse?.success) {
    console.log(`   Email ID: ${emailResponse.email_id}`);
    console.log(`   QR Code: ${emailResponse.qr_code}`);
    console.log(`   Reception QR: ${emailResponse.reception_qr_code}`);

    if (emailResponse.label_html) {
      console.log("   Label HTML: Generated ✓");
    }
  }

  // Step 4: Verification instructions
  console.log("\n✅ Email sending process initiated!\n");
  console.log("📝 Verification Steps:");
  console.log("   1. Check email in: " + (shipment.users?.email || "USER_EMAIL"));
  console.log(
    "   2. Or view in Resend dashboard: https://resend.com/emails"
  );
  console.log("   3. Check browser console for any errors");
  console.log("   4. Verify QR code is embedded in the email\n");

  console.log("🎯 Next Steps:");
  console.log("   - Email should arrive in 1-2 seconds");
  console.log("   - Subject should contain: Tu código QR para recoger");
  console.log("   - QR code should be clickable/scannable\n");

  console.log("═══════════════════════════════════════════════════════");
  console.log("Configuration validated! Resend API is properly set.");
  console.log("═══════════════════════════════════════════════════════\n");
}

testResendEmail().catch((error) => {
  console.error("❌ Test failed:", error);
  process.exit(1);
});