import { createClient } from "@supabase/supabase-js";

/**
 * Swikly E2E Test Helpers
 * Utilities for testing Swikly integration in sandbox mode
 */

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || "http://127.0.0.1:54331";
const SUPABASE_SERVICE_ROLE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";

const SWIKLY_API_TOKEN_SANDBOX = process.env.SWIKLY_API_TOKEN_SANDBOX || "";
const SWIKLY_ACCOUNT_ID = process.env.SWIKLY_ACCOUNT_ID || "";
const SWIKLY_SANDBOX_URL = "https://api.v2.sandbox.swikly.com/v1";

// Test VISA card for Swikly Sandbox
export const TEST_VISA_CARD = {
  number: "4970105181818183",
  expiry: "12/27",
  cvv: "123",
  email: "test-swikly@brickshare.local",
};

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

/**
 * Create a test user in the database
 * Uses an existing test user from seed data instead of creating a new one
 */
export async function createTestUser(email?: string) {
  try {
    // Query for an existing test user from seed
    // Fallback to creating one if none exists
    const { data: existingUsers } = await supabase
      .from("users")
      .select("user_id, full_name")
      .limit(1);

    if (existingUsers && existingUsers.length > 0) {
      const user = existingUsers[0];
      console.log("✅ Using existing test user:", user.user_id);
      return {
        id: user.user_id,
        email: email || `test-${user.user_id.substring(0, 8)}@brickshare.local`,
      };
    }

    // If no users exist, create one via RPC or direct SQL
    // For testing, we'll use a known test UUID that matches auth.users
    const testUserId = "550e8400-e29b-41d4-a716-000000000001";
    const testEmail = email || `test-user-1@brickshare.local`;

    const { data, error } = await supabase
      .from("users")
      .insert({
        user_id: testUserId,
        full_name: "Test User 1",
        email: testEmail,
      })
      .select()
      .single();

    if (error) {
      // If FK constraint fails, just use the test ID anyway for shipments
      console.warn("Could not create user via FK:", error.message);
      console.log("✅ Using fallback test user ID");
      return {
        id: testUserId,
        email: testEmail,
      };
    }

    console.log("✅ Test user created:", testUserId);
    return {
      id: testUserId,
      email: testEmail,
    };
  } catch (err: any) {
    // Final fallback - return a test user ID anyway
    const fallbackId = "550e8400-e29b-41d4-a716-000000000001";
    console.warn("Failed to create/fetch user, using fallback:", fallbackId);
    return {
      id: fallbackId,
      email: `test-fallback@brickshare.local`,
    };
  }
}

/**
 * Create a test shipment
 */
export async function createTestShipment(userId: string, setRef: string = "75192") {
  try {
    // Ensure set exists
    const { data: set } = await supabase
      .from("sets")
      .select("*")
      .eq("set_ref", setRef)
      .single();

    if (!set) {
      // Create test set if it doesn't exist
      await supabase.from("sets").insert({
        set_ref: setRef,
        set_name: "Test LEGO Set - Millennium Falcon",
        set_theme: "Star Wars",
        set_pieces: 7541,
        set_pvp_release: 799.99,
        set_image_url: "https://example.com/image.jpg",
      });
    }

    // Create shipment with minimal required fields
    const { data: shipment, error: shipmentError } = await supabase
      .from("shipments")
      .insert({
        user_id: userId,
        set_ref: setRef,
        status: "assigned",
        swikly_status: "pending",
      })
      .select()
      .single();

    if (shipmentError) throw new Error(`Failed to create shipment: ${shipmentError.message}`);

    console.log("✅ Test shipment created:", shipment.id);
    return shipment;
  } catch (err: any) {
    throw new Error(`Failed to create shipment: ${err.message}`);
  }
}

/**
 * Call the Swikly create-wish Edge Function
 */
export async function callCreateSwiklyWishFunction(shipmentId: string) {
  try {
    const response = await fetch(`${SUPABASE_URL}/functions/v1/create-swikly-wish-shipment`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ shipment_id: shipmentId }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Edge Function error: ${response.status} - ${error}`);
    }

    const result = await response.json();
    console.log("✅ Swikly wish created:", result.swikly_wish_id);
    return result;
  } catch (err: any) {
    throw new Error(`Failed to call Edge Function: ${err.message}`);
  }
}

/**
 * Simulate Swikly payment (mock - in real scenario, user would visit the shortLink)
 * This simulates the webhook that Swikly sends after user completes payment
 */
export async function simulateSwiklyPayment(wishId: string, shipmentId: string) {
  try {
    // Get shipment to find the wish URL
    const { data: shipment } = await supabase
      .from("shipments")
      .select("swikly_wish_url, swikly_deposit_amount")
      .eq("id", shipmentId)
      .single();

    if (!shipment) throw new Error(`Shipment ${shipmentId} not found`);

    // In a real scenario, the user would click the link and complete payment
    // For testing, we simulate the webhook callback that Swikly sends

    const webhookPayload = {
      id: wishId,
      status: "Secured", // After user completes payment
      deposit: {
        id: `DEP_${wishId}`,
        status: "Secured",
        amount: shipment.swikly_deposit_amount,
      },
    };

    console.log("✅ Swikly payment simulated for:", wishId);
    return webhookPayload;
  } catch (err: any) {
    throw new Error(`Failed to simulate payment: ${err.message}`);
  }
}

/**
 * Call the Swikly webhook endpoint (simulating Swikly's callback)
 */
export async function callSwiklyWebhookFunction(payload: any) {
  try {
    const bodyString = JSON.stringify(payload);

    // In a real scenario, Swikly would calculate the signature
    // For testing, we'll use a mock signature
    const mockSignature = "mock_signature_for_testing";

    const response = await fetch(`${SUPABASE_URL}/functions/v1/swikly-webhook`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Api-Sig": mockSignature,
      },
      body: bodyString,
    });

    if (!response.ok) {
      const error = await response.text();
      console.error(`Webhook error: ${response.status} - ${error}`);
      throw new Error(`Webhook error: ${response.status}`);
    }

    const result = await response.json();
    console.log("✅ Webhook processed successfully");
    return result;
  } catch (err: any) {
    throw new Error(`Failed to call webhook: ${err.message}`);
  }
}

/**
 * Get shipment status from database
 */
export async function getShipmentStatus(shipmentId: string) {
  try {
    const { data: shipment, error } = await supabase
      .from("shipments")
      .select("swikly_status, swikly_wish_id, swikly_wish_url, swikly_deposit_amount")
      .eq("id", shipmentId)
      .single();

    if (error) throw new Error(`Failed to get shipment: ${error.message}`);

    console.log("📊 Shipment status:", shipment.swikly_status);
    return shipment;
  } catch (err: any) {
    throw new Error(`Failed to get shipment status: ${err.message}`);
  }
}

/**
 * Cleanup: Delete test data
 */
export async function cleanupTestData(userId: string, shipmentId: string) {
  try {
    // Delete shipment
    await supabase.from("shipments").delete().eq("id", shipmentId);

    // Delete user profile
    await supabase.from("users").delete().eq("user_id", userId);

    console.log("🧹 Test data cleaned up");
  } catch (err: any) {
    console.warn("Cleanup warning:", err.message);
  }
}

/**
 * Verify test environment is properly configured
 */
export function verifySwiklyTestEnvironment() {
  const missing: string[] = [];

  if (!SWIKLY_API_TOKEN_SANDBOX) missing.push("SWIKLY_API_TOKEN_SANDBOX");
  if (!SWIKLY_ACCOUNT_ID) missing.push("SWIKLY_ACCOUNT_ID");
  if (!SUPABASE_URL) missing.push("VITE_SUPABASE_URL");
  if (!SUPABASE_SERVICE_ROLE_KEY) missing.push("SUPABASE_SERVICE_ROLE_KEY");

  if (missing.length > 0) {
    throw new Error(
      `Missing environment variables for Swikly testing: ${missing.join(", ")}\n` +
        `Please ensure supabase/functions/.env and apps/web/.env.local are properly configured.`
    );
  }

  console.log("✅ Swikly test environment verified");
  console.log(`   API Token: ${SWIKLY_API_TOKEN_SANDBOX.substring(0, 20)}...`);
  console.log(`   Account ID: ${SWIKLY_ACCOUNT_ID}`);
  console.log(`   Supabase URL: ${SUPABASE_URL}`);
}