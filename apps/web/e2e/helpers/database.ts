import { createClient } from '@supabase/supabase-js';

// Use the same Supabase URL and keys from environment
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54331';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

if (!supabaseServiceKey) {
  console.warn('⚠️ SUPABASE_SERVICE_ROLE_KEY not found in environment, using default demo key');
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

/**
 * Reset database to clean state
 * WARNING: This deletes all test data
 */
export async function resetDatabase() {
  try {
    // Delete in reverse order due to foreign keys
    await supabase.from('qr_validation_logs').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('reviews').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('wishlist').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('shipments').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('inventory_sets').delete().neq('set_id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('sets').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('users_correos_dropping').delete().neq('user_id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('user_roles').delete().neq('user_id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('users').delete().neq('user_id', '00000000-0000-0000-0000-000000000000');
    
    // Delete auth users (admin API)
    const { data: authUsers } = await supabase.auth.admin.listUsers();
    if (authUsers?.users) {
      for (const user of authUsers.users) {
        // Keep system admin if exists
        if (!user.email?.includes('admin@brickshare.test')) {
          await supabase.auth.admin.deleteUser(user.id);
        }
      }
    }
    
    console.log('✅ Database reset complete');
  } catch (error) {
    console.error('❌ Database reset error:', error);
    throw error;
  }
}

/**
 * Seed test data for E2E tests
 */
export async function seedTestData() {
  try {
    // 1. Create admin user
    const { data: adminAuth, error: adminAuthError } = await supabase.auth.admin.createUser({
      email: 'admin@brickshare.test',
      password: 'test123456',
      email_confirm: true
    });

    if (adminAuthError && !adminAuthError.message.includes('already registered')) {
      throw adminAuthError;
    }

    const adminUserId = adminAuth?.user?.id || (await supabase.auth.admin.listUsers()).data?.users.find(
      u => u.email === 'admin@brickshare.test'
    )?.id;

    if (adminUserId) {
      // Create admin profile
      await supabase.from('users').upsert({
        user_id: adminUserId,
        email: 'admin@brickshare.test',
        full_name: 'Admin Test',
        address: 'Admin Street 1',
        zip_code: '28001',
        city: 'Madrid',
        phone: '+34 600 000 001',
        profile_completed: true,
        subscription_type: 'premium',
        subscription_status: 'active'
      });

      // Assign admin role
      await supabase.from('user_roles').upsert({
        user_id: adminUserId,
        role: 'admin'
      });
    }

    // 2. Create test user with completed profile
    const { data: userAuth, error: userAuthError } = await supabase.auth.admin.createUser({
      email: 'test@brickshare.test',
      password: 'test123456',
      email_confirm: true
    });

    if (userAuthError && !userAuthError.message.includes('already registered')) {
      throw userAuthError;
    }

    const testUserId = userAuth?.user?.id || (await supabase.auth.admin.listUsers()).data?.users.find(
      u => u.email === 'test@brickshare.test'
    )?.id;

    if (testUserId) {
      // Create user profile with PUDO
      await supabase.from('users').upsert({
        user_id: testUserId,
        email: 'test@brickshare.test',
        full_name: 'Test User',
        address: 'Test Street 123',
        zip_code: '28001',
        city: 'Madrid',
        phone: '+34 600 000 002',
        profile_completed: true,
        subscription_type: 'basic',
        subscription_status: 'active'
      });

      // Assign PUDO point
      await supabase.from('users_correos_dropping').upsert({
        user_id: testUserId,
        pudo_id: 'BS-MAD-001',
        pudo_name: 'Brickshare Madrid Centro',
        pudo_address: 'Calle Gran Vía 1',
        pudo_zip_code: '28001',
        pudo_city: 'Madrid',
        pudo_type: 'brickshare'
      });
    }

    // 3. Create operator user
    const { data: operatorAuth, error: operatorAuthError } = await supabase.auth.admin.createUser({
      email: 'operator@brickshare.test',
      password: 'test123456',
      email_confirm: true
    });

    if (operatorAuthError && !operatorAuthError.message.includes('already registered')) {
      throw operatorAuthError;
    }

    const operatorUserId = operatorAuth?.user?.id || (await supabase.auth.admin.listUsers()).data?.users.find(
      u => u.email === 'operator@brickshare.test'
    )?.id;

    if (operatorUserId) {
      // Create operator profile
      await supabase.from('users').upsert({
        user_id: operatorUserId,
        email: 'operator@brickshare.test',
        full_name: 'Operator Test',
        address: 'Warehouse Street 1',
        zip_code: '28001',
        city: 'Madrid',
        phone: '+34 600 000 003',
        profile_completed: true,
        subscription_type: 'basic',
        subscription_status: 'active'
      });

      // Assign operator role
      await supabase.from('user_roles').upsert({
        user_id: operatorUserId,
        role: 'operador'
      });
    }

    // 4. Create test sets with inventory
    const testSets = [
      {
        set_ref: '75192',
        set_name: 'Millennium Falcon',
        set_theme: 'Star Wars',
        set_piece_count: 7541,
        set_price: 849.99,
        set_age_range: '16+',
        set_status: 'available'
      },
      {
        set_ref: '10497',
        set_name: 'Galaxy Explorer',
        set_theme: 'Icons',
        set_piece_count: 1254,
        set_price: 99.99,
        set_age_range: '18+',
        set_status: 'available'
      }
    ];

    for (const set of testSets) {
      const { data: setData } = await supabase
        .from('sets')
        .upsert(set, { onConflict: 'set_ref' })
        .select()
        .single();

      if (setData) {
        // Add inventory
        await supabase.from('inventory_sets').upsert({
          set_id: setData.id,
          stock: 10,
          in_use: 0,
          in_transit: 0,
          in_maintenance: 0
        });
      }
    }

    console.log('✅ Test data seeded successfully');
    
    // Return created IDs for use in tests
    return {
      adminUserId,
      testUserId,
      operatorUserId
    };
  } catch (error) {
    console.error('❌ Seed test data error:', error);
    throw error;
  }
}

/**
 * Create a return shipment for testing
 */
export async function createReturnShipment(userId: string, setId: string) {
  const { data: shipment, error } = await supabase
    .from('shipments')
    .insert({
      user_id: userId,
      set_id: setId,
      shipment_type: 'return',
      shipment_status: 'pending',
      sender_name: 'Test User',
      sender_address: 'Test Street 123',
      sender_zip_code: '28001',
      sender_city: 'Madrid',
      sender_phone: '+34 600 000 000',
      recipient_name: 'Brickshare',
      recipient_address: 'Warehouse Street 1',
      recipient_zip_code: '28001',
      recipient_city: 'Madrid',
      recipient_phone: '+34 900 000 000'
    })
    .select()
    .single();

  if (error) throw new Error(`Create return shipment error: ${error.message}`);
  return shipment;
}
