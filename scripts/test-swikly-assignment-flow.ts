import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || "http://127.0.0.1:54331";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvY2FsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMDAwMDAwMCwiZXhwIjoyMDAwMDAwMDAwfQ.delegated_token_placeholder";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function testSwiklyAssignmentFlow() {
  console.log("🧪 [Test] Starting Swikly Assignment Flow Test\n");

  try {
    // 1️⃣ Get user3 details
    console.log("1️⃣ Fetching user3 details...");
    const { data: user3, error: userError } = await supabase
      .from("users")
      .select("id, user_id, full_name, email, user_status")
      .eq("full_name", "User 3")
      .maybeSingle();

    if (userError || !user3) {
      throw new Error(`Could not find user3: ${userError?.message}`);
    }
    console.log(`✅ User3 found: ${user3.full_name} (${user3.user_id})\n`);

    // 2️⃣ Check for existing shipments with swikly_status
    console.log("2️⃣ Checking existing shipments for user3...");
    const { data: existingShipments, error: shipmentError } = await supabase
      .from("shipments")
      .select("id, set_ref, shipment_status, swikly_status, swikly_wish_id")
      .eq("user_id", user3.user_id);

    if (shipmentError) throw shipmentError;

    console.log(`Found ${existingShipments?.length || 0} shipments:`);
    existingShipments?.forEach((s) => {
      console.log(
        `  - ${s.set_ref}: status=${s.shipment_status}, swikly_status=${s.swikly_status || "NULL"}, wish_id=${s.swikly_wish_id || "NULL"}`
      );
    });
    console.log();

    // 3️⃣ Verify the most recent shipment has correct status
    if (existingShipments && existingShipments.length > 0) {
      const latestShipment = existingShipments[0];
      console.log("3️⃣ Analyzing latest shipment...");
      console.log(`   Shipment ID: ${latestShipment.id}`);
      console.log(`   Set Ref: ${latestShipment.set_ref}`);
      console.log(`   Shipment Status: ${latestShipment.shipment_status}`);
      console.log(`   Swikly Status: ${latestShipment.swikly_status || "NOT SET"}`);
      console.log(`   Swikly Wish ID: ${latestShipment.swikly_wish_id || "NOT SET"}\n`);

      if (latestShipment.shipment_status === "assigned") {
        if (latestShipment.swikly_status === "accepted") {
          console.log("✅ PASS: Shipment has swikly_status = 'accepted'");
          console.log("✅ Shipment is ready for label printing!\n");
        } else if (latestShipment.swikly_status) {
          console.log(`⚠️  Status is '${latestShipment.swikly_status}', not 'accepted'`);
        } else {
          console.log("❌ FAIL: swikly_status is NULL");
          console.log("🔧 Swikly deposit was likely NOT created for this shipment\n");
        }
      }
    } else {
      console.log("❌ No shipments found for user3");
    }

    // 4️⃣ Check if set has price configured
    console.log("4️⃣ Checking set price configuration...");
    if (existingShipments && existingShipments.length > 0) {
      const { data: setData, error: setError } = await supabase
        .from("sets")
        .select("set_ref, set_name, set_pvp_release")
        .eq("set_ref", existingShipments[0].set_ref)
        .maybeSingle();

      if (setError) throw setError;

      if (setData) {
        console.log(`   Set: ${setData.set_name} (${setData.set_ref})`);
        console.log(`   Price (set_pvp_release): €${setData.set_pvp_release || "NOT SET"}\n`);

        if (!setData.set_pvp_release) {
          console.log("⚠️  WARNING: set_pvp_release is not configured!");
          console.log("   This would cause Swikly creation to fail\n");
        }
      }
    }

    console.log("✅ [Test] Swikly Assignment Flow Test Complete");
  } catch (error: any) {
    console.error("❌ Test failed:", error.message);
    process.exit(1);
  }
}

testSwiklyAssignmentFlow();