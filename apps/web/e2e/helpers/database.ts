import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

if (!supabaseServiceKey) {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY is required for E2E tests');
}

export const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false
  }
});

/**
 * Create a test user with auto-verified email
 */
export async function createTestUser(
  email: string,
  password: string = 'Test1234!'
) {
  // 1. Create auth user
  const { data: authData, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true // Auto-verify for tests
  });

  if (authError) throw new Error(`Auth error: ${authError.message}`);
  if (!authData.user) throw new Error('No user returned from auth.createUser');

  // 2. Create user profile
  const { data: profileData, error: profileError } = await supabase
    .from('users')
    .insert({
      user_id: authData.user.id,
      email,
      full_name: 'Test User',
      address: 'Test Street 123',
      zip_code: '28001',
      city: 'Madrid',
      phone: '+34 600 000 000',
      profile_completed: true,
      subscription_type: 'basic',
      subscription_status: 'active'
    })
    .select()
    .single();

  if (profileError) throw new Error(`Profile error: ${profileError.message}`);

  return {
    userId: authData.user.id,
    email,
    profile: profileData
  };
}

/**
 * Create a test set with proper inventory
 */
export async function createTestSet(
  setRef: string = `TEST-${Date.now()}`,
  setName: string = 'Test Set',
  quantity: number = 10
) {
  // 1. Create set
  const { data: setData, error: setError } = await supabase
    .from('sets')
    .insert({
      set_ref: setRef,
      set_name: setName,
      set_theme: 'Test',
      set_piece_count: 100,
      set_price: 50.00,
      set_age_range: '8+',
      set_status: 'available'
    })
    .select()
    .single();

  if (setError) throw new Error(`Set error: ${setError.message}`);
  if (!setData) throw new Error('No set data returned');

  // 2. Add to inventory
  const { error: inventoryError } = await supabase
    .from('inventory_sets')
    .insert({
      set_id: setData.id,
      stock: quantity,
      in_use: 0,
      in_transit: 0,
      in_maintenance: 0
    });

  if (inventoryError) throw new Error(`Inventory error: ${inventoryError.message}`);

  return {
    setId: setData.id,
    setRef: setData.set_ref,
    setName: setData.set_name,
    price: setData.set_price
  };
}

/**
 * Add set to user's wishlist
 */
export async function addToWishlist(userId: string, setId: string) {
  const { error } = await supabase
    .from('wishlist')
    .insert({
      user_id: userId,
      set_id: setId,
      status: true
    });

  if (error) throw new Error(`Wishlist error: ${error.message}`);
}

/**
 * Get user profile
 */
export async function getUserProfile(userId: string) {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('user_id', userId)
    .single();

  if (error) throw new Error(`Profile fetch error: ${error.message}`);
  return data;
}

/**
 * Get shipments for user
 */
export async function getUserShipments(userId: string) {
  const { data, error } = await supabase
    .from('shipments')
    .select('*, sets(*)')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw new Error(`Shipments fetch error: ${error.message}`);
  return data || [];
}

/**
 * Get inventory for a set
 */
export async function getSetInventory(setId: string) {
  const { data, error } = await supabase
    .from('inventory_sets')
    .select('*')
    .eq('set_id', setId)
    .single();

  if (error) throw new Error(`Inventory fetch error: ${error.message}`);
  return data;
}

/**
 * Get PUDO point for user
 */
export async function getUserPudoPoint(userId: string) {
  const { data, error } = await supabase
    .from('users_correos_dropping')
    .select('*')
    .eq('user_id', userId)
    .single();

  if (error && error.code !== 'PGRST116') {
    throw new Error(`PUDO fetch error: ${error.message}`);
  }
  return data || null;
}

/**
 * Clean up test data
 */
export async function cleanupTestData(userId: string) {
  try {
    // Delete in reverse order due to foreign keys
    await supabase.from('wishlist').delete().eq('user_id', userId);
    await supabase.from('shipments').delete().eq('user_id', userId);
    await supabase.from('users_correos_dropping').delete().eq('user_id', userId);
    await supabase.from('users').delete().eq('user_id', userId);
    await supabase.auth.admin.deleteUser(userId);
  } catch (error) {
    console.error('Cleanup error:', error);
    throw error;
  }
}

/**
 * Clean up test set
 */
export async function cleanupTestSet(setId: string) {
  try {
    await supabase.from('inventory_sets').delete().eq('set_id', setId);
    await supabase.from('sets').delete().eq('id', setId);
  } catch (error) {
    console.error('Set cleanup error:', error);
    throw error;
  }
}