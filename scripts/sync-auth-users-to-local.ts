#!/usr/bin/env ts-node
/**
 * Sync Auth Users to Local Database
 * 
 * This script reads users from a remote Supabase auth.users table
 * and creates them in the local PostgreSQL database with a generic password.
 * 
 * Usage:
 *   1. Set REMOTE_SUPABASE_URL and REMOTE_SUPABASE_SERVICE_ROLE_KEY in .env.main
 *   2. Ensure local Supabase is running: supabase start
 *   3. Run: npx ts-node scripts/sync-auth-users-to-local.ts
 * 
 * What it does:
 *   - Reads all users from remote auth.users
 *   - Creates them in local auth.users with password "Test1234"
 *   - Creates profile in public.users
 *   - Creates identity in auth.identities
 *   - Assigns 'user' role in user_roles
 */

import { createClient } from '@supabase/supabase-js';
import { Client } from 'pg';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env.main') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

// Remote Supabase configuration (where users will be read from)
const REMOTE_SUPABASE_URL = process.env.REMOTE_SUPABASE_URL;
const REMOTE_SUPABASE_SERVICE_ROLE_KEY = process.env.REMOTE_SUPABASE_SERVICE_ROLE_KEY;

// Local Supabase configuration (where users will be created)
const LOCAL_SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const LOCAL_DB_URL = 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';

// Generic password for all synced users (bcrypt hash will be generated)
const GENERIC_PASSWORD = 'Test1234';

// Validation
if (!REMOTE_SUPABASE_URL || !REMOTE_SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ Missing required environment variables:');
  console.error('   - REMOTE_SUPABASE_URL');
  console.error('   - REMOTE_SUPABASE_SERVICE_ROLE_KEY');
  console.error('\nPlease add them to .env.main file');
  process.exit(1);
}

// Create Supabase client for remote instance
const remoteSupabase = createClient(REMOTE_SUPABASE_URL, REMOTE_SUPABASE_SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

interface RemoteUser {
  id: string;
  email: string;
  email_confirmed_at: string | null;
  raw_user_meta_data: any;
  raw_app_meta_data: any;
  created_at: string;
  updated_at: string;
}

interface RemoteProfile {
  user_id: string;
  full_name: string | null;
  phone: string | null;
  address: string | null;
  city: string | null;
  postal_code: string | null;
  subscription_status: string | null;
  subscription_type: string | null;
  user_status: string | null;
  stripe_customer_id: string | null;
  stripe_subscription_id: string | null;
  stripe_payment_method_id: string | null;
}

async function fetchRemoteUsers(): Promise<RemoteUser[]> {
  console.log('\n📥 Fetching users from remote Supabase...');
  console.log(`   URL: ${REMOTE_SUPABASE_URL}`);

  const { data, error } = await remoteSupabase.auth.admin.listUsers();

  if (error) {
    console.error('❌ Error fetching remote users:', error.message);
    throw error;
  }

  console.log(`✅ Found ${data.users.length} users in remote auth.users`);
  return data.users as any;
}

async function fetchRemoteProfiles(userIds: string[]): Promise<Map<string, RemoteProfile>> {
  console.log('\n📥 Fetching user profiles from remote database...');

  const { data, error } = await remoteSupabase
    .from('users')
    .select('*')
    .in('user_id', userIds);

  if (error) {
    console.error('⚠️  Error fetching remote profiles:', error.message);
    return new Map();
  }

  const profileMap = new Map<string, RemoteProfile>();
  data?.forEach((profile: any) => {
    profileMap.set(profile.user_id, profile);
  });

  console.log(`✅ Found ${profileMap.size} user profiles`);
  return profileMap;
}

async function syncUsersToLocal(users: RemoteUser[], profiles: Map<string, RemoteProfile>) {
  const pgClient = new Client({ connectionString: LOCAL_DB_URL });
  
  try {
    await pgClient.connect();
    console.log('\n✅ Connected to local PostgreSQL database');

    let successCount = 0;
    let skipCount = 0;
    let errorCount = 0;

    for (const user of users) {
      try {
        // Check if user already exists locally
        const checkResult = await pgClient.query(
          'SELECT id FROM auth.users WHERE id = $1',
          [user.id]
        );

        if (checkResult.rows.length > 0) {
          console.log(`⏭️  Skipping ${user.email} - already exists locally`);
          skipCount++;
          continue;
        }

        console.log(`\n🔄 Syncing user: ${user.email}`);

        // Start transaction
        await pgClient.query('BEGIN');

        // 1. Create user in auth.users with generic password
        await pgClient.query(`
          INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            confirmation_token,
            recovery_token,
            email_change_token_new,
            email_change
          ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            $1,
            'authenticated',
            'authenticated',
            $2,
            crypt($3, gen_salt('bf')),
            COALESCE($4, NOW()),
            $5,
            $6,
            $7,
            $8,
            '',
            '',
            '',
            ''
          )
        `, [
          user.id,
          user.email,
          GENERIC_PASSWORD,
          user.email_confirmed_at,
          JSON.stringify(user.raw_app_meta_data || {}),
          JSON.stringify(user.raw_user_meta_data || {}),
          user.created_at,
          user.updated_at
        ]);

        // 2. Create user profile in public.users
        const profile = profiles.get(user.id);
        const fullName = profile?.full_name || user.raw_user_meta_data?.full_name || user.email?.split('@')[0] || 'User';

        await pgClient.query(`
          INSERT INTO public.users (
            user_id,
            email,
            full_name,
            phone,
            address,
            city,
            postal_code,
            subscription_status,
            subscription_type,
            user_status,
            stripe_customer_id,
            stripe_subscription_id,
            stripe_payment_method_id,
            profile_completed,
            created_at,
            updated_at
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
          )
        `, [
          user.id,
          user.email,
          fullName,
          profile?.phone || null,
          profile?.address || null,
          profile?.city || null,
          profile?.postal_code || null,
          profile?.subscription_status || 'inactive',
          profile?.subscription_type || 'basic',
          profile?.user_status || 'active',
          profile?.stripe_customer_id || null,
          profile?.stripe_subscription_id || null,
          profile?.stripe_payment_method_id || null,
          true,
          user.created_at,
          user.updated_at
        ]);

        // 3. Create identity in auth.identities
        await pgClient.query(`
          INSERT INTO auth.identities (
            id,
            user_id,
            identity_data,
            provider,
            last_sign_in_at,
            created_at,
            updated_at
          ) VALUES (
            gen_random_uuid(),
            $1,
            $2,
            'email',
            NOW(),
            $3,
            $4
          )
        `, [
          user.id,
          JSON.stringify({
            sub: user.id,
            email: user.email
          }),
          user.created_at,
          user.updated_at
        ]);

        // 4. Assign user role in user_roles
        await pgClient.query(`
          INSERT INTO public.user_roles (user_id, role)
          VALUES ($1, 'user'::app_role)
          ON CONFLICT (user_id, role) DO NOTHING
        `, [user.id]);

        // Commit transaction
        await pgClient.query('COMMIT');

        console.log(`   ✅ Successfully synced: ${user.email}`);
        console.log(`      - ID: ${user.id}`);
        console.log(`      - Name: ${fullName}`);
        console.log(`      - Password: ${GENERIC_PASSWORD}`);
        successCount++;

      } catch (error: any) {
        await pgClient.query('ROLLBACK');
        console.error(`   ❌ Error syncing ${user.email}:`, error.message);
        errorCount++;
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('📊 Sync Summary:');
    console.log(`   ✅ Successfully synced: ${successCount}`);
    console.log(`   ⏭️  Skipped (already exist): ${skipCount}`);
    console.log(`   ❌ Errors: ${errorCount}`);
    console.log(`   📝 Total processed: ${users.length}`);
    console.log('='.repeat(60));

    if (successCount > 0) {
      console.log('\n🔐 Generic Password for all synced users: Test1234');
      console.log('💡 Users can now log in to local instance with their email and this password');
    }

  } catch (error: any) {
    console.error('\n❌ Fatal error:', error.message);
    throw error;
  } finally {
    await pgClient.end();
  }
}

async function main() {
  console.log('🚀 Starting Auth Users Sync to Local Database');
  console.log('='.repeat(60));

  try {
    // Fetch remote users
    const users = await fetchRemoteUsers();

    if (users.length === 0) {
      console.log('\n⚠️  No users found in remote database');
      return;
    }

    // Fetch remote profiles
    const userIds = users.map(u => u.id);
    const profiles = await fetchRemoteProfiles(userIds);

    // Sync to local
    await syncUsersToLocal(users, profiles);

    console.log('\n✅ Sync completed successfully!');
    
  } catch (error: any) {
    console.error('\n❌ Sync failed:', error.message);
    process.exit(1);
  }
}

// Run the script
main();