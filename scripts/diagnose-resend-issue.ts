#!/usr/bin/env node

/**
 * RESEND Email Diagnostic Script
 * 
 * Diagnoses why emails are not being sent to Resend
 * Checks:
 * 1. RESEND_API_KEY configuration
 * 2. Edge Function logs
 * 3. Attempts to send a test email
 * 4. Shows what's actually happening
 */

import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "http://127.0.0.1:54331";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";

const supabase = createClient(supabaseUrl, supabaseKey);

async function diagnoseResendIssue() {
  console.log("\n╔════════════════════════════════════════════════════════════╗");
  console.log("║          RESEND EMAIL DIAGNOSTIC                            ║");
  console.log("╚════════════════════════════════════════════════════════════╝\n");

  // Step 1: Check RESEND_API_KEY
  console.log("🔍 STEP 1: Checking RESEND_API_KEY Configuration\n");

  const env = process.env;
  const resendKey = env.RESEND_API_KEY || "NOT SET";
  
  console.log(`   Environment Variable: ${resendKey === "NOT SET" ? "❌ NOT SET" : "✅ SET"}`);
  if (resendKey !== "NOT SET") {
    console.log(`   Value (first 20 chars): ${resendKey.substring(0, 20)}...`);
    console.log(`   Total length: ${resendKey.length} chars`);
    console.log(`   Starts with 're_': ${resendKey.startsWith("re_") ? "✅ YES" : "❌ NO"}`);
    console.log(`   Starts with 're_test': ${resendKey.startsWith("re_test") ? "⚠️ TEST KEY" : "✅ PRODUCTION KEY"}`);
  }

  // Step 2: Find a Brickshare shipment to test
  console.log("\n🔍 STEP 2: Finding a Test Shipment\n");

  const { data: shipments, error: shipmentError } = await supabase
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
    .eq("pudo_type", "brickshare")
    .limit(1);

  if (shipmentError || !shipments || shipments.length === 0) {
    console.log("   ❌ No suitable shipment found");
    console.log("   Need: shipment_status='assigned' AND swikly_status='accepted' AND pudo_type='brickshare'");
    return;
  }

  const shipment = shipments[0] as any;
  console.log(`   ✅ Found shipment: ${shipment.id}`);
  console.log(`      User: ${shipment.users?.full_name} (${shipment.users?.email})`);
  console.log(`      Set: ${shipment.sets?.set_name}`);

  // Step 3: Attempt to send email via Edge Function
  console.log("\n🔍 STEP 3: Calling send-brickshare-qr-email Edge Function\n");

  const { data: emailData, error: emailError } = await supabase.functions.invoke(
    "send-brickshare-qr-email",
    {
      body: {
        shipment_id: shipment.id,
        type: "delivery",
      },
    }
  );

  if (emailError) {
    console.log("   ❌ Error calling Edge Function:");
    console.log(`      Code: ${emailError.context?.status || "UNKNOWN"}`);
    console.log(`      Message: ${emailError.message}`);
    if (emailError.context?.error) {
      console.log(`      Details: ${JSON.stringify(emailError.context.error, null, 2)}`);
    }
    return;
  }

  if (!emailData?.success) {
    console.log("   ❌ Edge Function returned failure:");
    console.log(`      ${JSON.stringify(emailData, null, 2)}`);
    return;
  }

  console.log("   ✅ Edge Function executed successfully");
  console.log(`      Email ID: ${emailData.email_id}`);
  console.log(`      QR Code: ${emailData.qr_code}`);

  // Step 4: Check Resend Dashboard
  console.log("\n🔍 STEP 4: Verify in Resend Dashboard\n");

  console.log("   📧 Recipient: " + (shipment.users?.email || "UNKNOWN"));
  console.log("   📝 Subject: Tu código QR para recoger: " + (shipment.sets?.set_name || "UNKNOWN"));
  console.log("   🔗 Dashboard: https://resend.com/emails");
  console.log("   ⏰ Expected arrival: 1-2 seconds");
  console.log("   ✅ Status should be: Delivered or Sent");

  // Step 5: Summary
  console.log("\n╔════════════════════════════════════════════════════════════╗");
  console.log("║                    DIAGNOSIS COMPLETE                      ║");
  console.log("╚════════════════════════════════════════════════════════════╝\n");

  console.log("📋 Summary:");
  console.log("   1. Check RESEND_API_KEY above");
  console.log("   2. If it shows 're_test' → Update the .env files with real key");
  console.log("   3. Restart Supabase: supabase stop && supabase start");
  console.log("   4. Run this script again to verify");
  console.log("   5. Check https://resend.com/emails for the sent email\n");

  console.log("🔧 Next Steps:");
  console.log("   • If API key is wrong: Update supabase/functions/.env");
  console.log("   • If key is correct but email doesn't arrive:");
  console.log("     - Check Resend API status");
  console.log("     - Verify email address is valid");
  console.log("     - Check browser console for errors\n");
}

diagnoseResendIssue().catch((error) => {
  console.error("❌ Diagnostic failed:", error);
  process.exit(1);
});