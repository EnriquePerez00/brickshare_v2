import { expect } from '@playwright/test';
import {
  supabase,
  getSetInventory,
  getUserShipments,
  getUserProfile,
  getUserPudoPoint
} from './database';

/**
 * Assert that a shipment exists for user and set
 */
export async function assertShipmentExists(userId: string, setId: string) {
  const shipments = await getUserShipments(userId);
  const shipment = shipments.find(s => s.set_id === setId);

  expect(shipment).toBeDefined();
  expect(shipment?.user_id).toBe(userId);
  expect(shipment?.set_id).toBe(setId);

  return shipment;
}

/**
 * Assert shipment has specific status
 */
export async function assertShipmentStatus(shipmentId: string, expectedStatus: string) {
  const { data, error } = await supabase
    .from('shipments')
    .select('shipment_status')
    .eq('id', shipmentId)
    .single();

  if (error) throw new Error(`Fetch error: ${error.message}`);
  expect(data?.shipment_status).toBe(expectedStatus);

  return data;
}

/**
 * Assert inventory decreased by expected amount
 */
export async function assertInventoryDecreased(
  setId: string,
  expectedDecrease: number
) {
  const inventory = await getSetInventory(setId);
  expect(inventory.stock).toBeLessThan(expectedDecrease);

  return inventory;
}

/**
 * Assert inventory is in expected state
 */
export async function assertInventoryState(
  setId: string,
  expectedState: { stock?: number; in_use?: number; in_transit?: number; in_maintenance?: number }
) {
  const inventory = await getSetInventory(setId);

  if (expectedState.stock !== undefined) {
    expect(inventory.stock).toBe(expectedState.stock);
  }
  if (expectedState.in_use !== undefined) {
    expect(inventory.in_use).toBe(expectedState.in_use);
  }
  if (expectedState.in_transit !== undefined) {
    expect(inventory.in_transit).toBe(expectedState.in_transit);
  }
  if (expectedState.in_maintenance !== undefined) {
    expect(inventory.in_maintenance).toBe(expectedState.in_maintenance);
  }

  return inventory;
}

/**
 * Assert user profile has been updated
 */
export async function assertProfileCompleted(userId: string) {
  const profile = await getUserProfile(userId);

  expect(profile.profile_completed).toBe(true);
  expect(profile.full_name).toBeTruthy();
  expect(profile.address).toBeTruthy();
  expect(profile.phone).toBeTruthy();

  return profile;
}

/**
 * Assert user has active subscription
 */
export async function assertActiveSubscription(userId: string) {
  const profile = await getUserProfile(userId);

  expect(profile.subscription_status).toBe('active');
  expect(['basic', 'standard', 'premium']).toContain(profile.subscription_type);

  return profile;
}

/**
 * Assert user PUDO point is set
 */
export async function assertPudoPointSet(userId: string) {
  const pudoPoint = await getUserPudoPoint(userId);

  expect(pudoPoint).toBeDefined();
  expect(pudoPoint?.correos_id_pudo).toBeTruthy();
  expect(pudoPoint?.correos_name).toBeTruthy();
  expect(pudoPoint?.correos_city).toBeTruthy();

  return pudoPoint;
}

/**
 * Assert no shipments exist for user
 */
export async function assertNoShipmentsExist(userId: string) {
  const shipments = await getUserShipments(userId);
  expect(shipments).toHaveLength(0);
}

/**
 * Assert shipment has Correos tracking
 */
export async function assertShipmentHasCorreosTracking(shipmentId: string) {
  const { data, error } = await supabase
    .from('shipments')
    .select('correos_shipment_id, label_url')
    .eq('id', shipmentId)
    .single();

  if (error) throw new Error(`Fetch error: ${error.message}`);

  expect(data?.correos_shipment_id).toBeTruthy();
  expect(data?.label_url).toMatch(/^https:\/\//);

  return data;
}

/**
 * Assert set is in user's wishlist
 */
export async function assertInWishlist(userId: string, setId: string) {
  const { data, error } = await supabase
    .from('wishlist')
    .select('*')
    .eq('user_id', userId)
    .eq('set_id', setId)
    .eq('status', true)
    .single();

  if (error && error.code !== 'PGRST116') {
    throw new Error(`Fetch error: ${error.message}`);
  }

  expect(data).toBeDefined();
  expect(data?.status).toBe(true);

  return data;
}

/**
 * Assert set is NOT in user's wishlist
 */
export async function assertNotInWishlist(userId: string, setId: string) {
  const { data, error } = await supabase
    .from('wishlist')
    .select('*')
    .eq('user_id', userId)
    .eq('set_id', setId)
    .single();

  expect(data).toBeNull();
}

/**
 * Assert user exists and has correct email
 */
export async function assertUserExists(userId: string, expectedEmail: string) {
  const profile = await getUserProfile(userId);

  expect(profile.user_id).toBe(userId);
  expect(profile.email).toBe(expectedEmail);

  return profile;
}

/**
 * Wait for shipment status with retry logic
 */
export async function waitForShipmentStatus(
  shipmentId: string,
  expectedStatus: string,
  timeout: number = 30000,
  interval: number = 1000
) {
  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    const { data, error } = await supabase
      .from('shipments')
      .select('shipment_status')
      .eq('id', shipmentId)
      .single();

    if (error) throw new Error(`Fetch error: ${error.message}`);

    if (data?.shipment_status === expectedStatus) {
      return data;
    }

    await new Promise(resolve => setTimeout(resolve, interval));
  }

  throw new Error(
    `Shipment ${shipmentId} did not reach status "${expectedStatus}" within ${timeout}ms`
  );
}

/**
 * Wait for Correos preregistration to complete
 */
export async function waitForCorreosPreregistration(
  shipmentId: string,
  timeout: number = 45000
) {
  return waitForShipmentStatus(shipmentId, 'in_transit_pudo', timeout);
}

/**
 * Wait for inventory to be updated
 */
export async function waitForInventoryUpdate(
  setId: string,
  expectedStock: number,
  timeout: number = 10000
) {
  const startTime = Date.now();
  const interval = 500;

  while (Date.now() - startTime < timeout) {
    const inventory = await getSetInventory(setId);

    if (inventory.stock === expectedStock) {
      return inventory;
    }

    await new Promise(resolve => setTimeout(resolve, interval));
  }

  throw new Error(
    `Inventory for set ${setId} did not reach stock ${expectedStock} within ${timeout}ms`
  );
}