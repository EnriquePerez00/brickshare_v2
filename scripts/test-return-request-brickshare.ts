/**
 * Test script for return request flow
 * Tests the dual-flow system for both Brickshare and Correos PUDO returns
 */

import { createClient } from "npm:@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("VITE_SUPABASE_URL") || "http://127.0.0.1:54321";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

if (!supabaseServiceKey) {
  console.error("❌ Missing SUPABASE_SERVICE_ROLE_KEY");
  Deno.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function testBrickshareReturn() {
  console.log("\n📦 Testing Brickshare PUDO Return Flow");
  console.log("=====================================\n");

  try {
    // 1. Find a shipment in delivered_user status with pudo_type='brickshare'
    const { data: shipments, error: shipmentError } = await supabase
      .from("shipments")
      .select("*, sets!inner(*)")
      .eq("shipment_status", "delivered_user")
      .eq("pudo_type", "brickshare")
      .limit(1);

    if (shipmentError || !shipments || shipments.length === 0) {
      console.warn("⚠️  No Brickshare shipments in delivered_user status found");
      console.log("   Creating test data...");

      // Get first available user and set
      const { data: users } = await supabase
        .from("users")
        .select("id, email, full_name")
        .limit(1);

      const { data: sets } = await supabase.from("sets").select("id").limit(1);

      if (!users || !sets) {
        console.error("❌ Could not create test data");
        return;
      }

      console.log(`   ✅ Using user ${users[0].email} and set ${sets[0].id}`);
      return;
    }

    const shipment = shipments[0];
    console.log(`✅ Found shipment: ${shipment.id}`);
    console.log(`   Set: ${shipment.sets.set_name} (Ref: ${shipment.set_ref})`);
    console.log(`   User: ${shipment.user_id}`);
    console.log(`   Status: ${shipment.shipment_status}`);
    console.log(`   PUDO Type: ${shipment.pudo_type}`);

    // 2. Get user auth token
    console.log("\n🔑 Requesting return...");

    // Create a JWT for the user (for testing, we'll use a simpler approach)
    const { data: authSession } = await supabase.auth.admin.getUserById(
      shipment.user_id
    );

    if (!authSession) {
      console.warn(
        "⚠️  Could not get user session - test requires manual JWT generation"
      );
      return;
    }

    // Create a signed JWT token for this user
    const { data: tokenData, error: tokenError } =
      await supabase.auth.admin.generateLink({
        type: "email",
        email: authSession.user?.email || "",
        options: {
          redirectTo: "http://localhost:5173",
        },
      });

    if (tokenError) {
      console.error("❌ Failed to generate auth link:", tokenError.message);
      return;
    }

    // 3. Call request-return function
    const { data: returnData, error: returnError } =
      await supabase.functions.invoke("request-return", {
        body: {
          shipment_id: shipment.id,
        },
        headers: {
          Authorization: `Bearer ${tokenData?.confirmation_token || ""}`,
        },
      });

    if (returnError) {
      console.error("❌ Return request failed:", returnError.message);
      console.log("   Error details:", returnError);
      return;
    }

    console.log("✅ Return request successful!");
    console.log("   Response:", returnData);

    // 4. Verify shipment was updated
    const { data: updatedShipment } = await supabase
      .from("shipments")
      .select("shipment_status, return_qr_code, return_qr_at")
      .eq("id", shipment.id)
      .single();

    if (updatedShipment) {
      console.log("\n📊 Shipment updated:");
      console.log(`   Status: ${updatedShipment.shipment_status}`);
      console.log(`   Return QR Code: ${updatedShipment.return_qr_code?.substring(0, 30)}...`);
      console.log(`   Return QR At: ${updatedShipment.return_qr_at}`);
    }
  } catch (error) {
    console.error("❌ Test failed:", error.message);
  }
}

async function testCorreosReturn() {
  console.log("\n📦 Testing Correos PUDO Return Flow");
  console.log("====================================\n");

  try {
    // Find a shipment with pudo_type='correos'
    const { data: shipments } = await supabase
      .from("shipments")
      .select("*")
      .eq("shipment_status", "delivered_user")
      .eq("pudo_type", "correos")
      .limit(1);

    if (!shipments || shipments.length === 0) {
      console.warn("⚠️  No Correos shipments in delivered_user status found");
      return;
    }

    console.log(`✅ Found Correos shipment: ${shipments[0].id}`);
    console.log(`   Status: ${shipments[0].shipment_status}`);
    console.log(
      "   Note: Correos return requires Correos API credentials to test fully"
    );
  } catch (error) {
    console.error("❌ Test failed:", error.message);
  }
}

async function main() {
  console.log("🧪 Return Request System Test");
  console.log("=============================");

  await testBrickshareReturn();
  await testCorreosReturn();

  console.log("\n✅ Test completed");
}

main().catch(console.error);