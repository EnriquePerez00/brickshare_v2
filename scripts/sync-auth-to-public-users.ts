#!/usr/bin/env ts-node
/**
 * Sync Auth Users to Public Users (Internal Sync)
 * 
 * This script reads users from auth.users and creates missing entries in public.users
 * for the SAME database instance (not remote to local, but internal sync).
 * 
 * Usage:
 *   1. Ensure local Supabase is running: supabase start
 *   2. Run: npx ts-node scripts/sync-auth-to-public-users.ts
 * 
 * What it does:
 *   - Reads all users from auth.users
 *   - Checks which ones are missing in public.users
 *   - Creates profile entries in public.users for missing users
 *   - Assigns 'user' role in user_roles if not present
 */

import { Client } from 'pg';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

// Local database configuration
const LOCAL_DB_URL = 'postgresql://postgres:postgres@127.0.0.1:5433/postgres';

interface AuthUser {
  id: string;
  email: string;
  email_confirmed_at: string | null;
  raw_user_meta_data: any;
  created_at: string;
  updated_at: string;
}

async function syncAuthToPublicUsers() {
  const pgClient = new Client({ connectionString: LOCAL_DB_URL });
  
  try {
    await pgClient.connect();
    console.log('🚀 Starting Internal Auth → Public Users Sync');
    console.log('=' .repeat(60));
    console.log('✅ Connected to local PostgreSQL database');

    // 1. Fetch all users from auth.users
    console.log('\n📥 Fetching users from auth.users...');
    const authUsersResult = await pgClient.query<AuthUser>(`
      SELECT 
        id,
        email,
        email_confirmed_at,
        raw_user_meta_data,
        created_at,
        updated_at
      FROM auth.users
      ORDER BY created_at DESC
    `);

    console.log(`✅ Found ${authUsersResult.rows.length} users in auth.users`);

    if (authUsersResult.rows.length === 0) {
      console.log('\n⚠️  No users found in auth.users');
      return;
    }

    // 2. Check which users are missing in public.users
    console.log('\n🔍 Checking for users missing in public.users...');
    const userIds = authUsersResult.rows.map(u => u.id);
    
    const existingUsersResult = await pgClient.query(`
      SELECT user_id 
      FROM public.users 
      WHERE user_id = ANY($1)
    `, [userIds]);

    const existingUserIds = new Set(existingUsersResult.rows.map((r: any) => r.user_id));
    const missingUsers = authUsersResult.rows.filter(u => !existingUserIds.has(u.id));

    console.log(`   - Existing in public.users: ${existingUserIds.size}`);
    console.log(`   - Missing in public.users: ${missingUsers.length}`);

    if (missingUsers.length === 0) {
      console.log('\n✅ All auth.users already have entries in public.users');
      console.log('   Nothing to sync!');
      return;
    }

    // 3. Create missing profiles
    console.log('\n🔄 Creating missing user profiles...\n');
    let successCount = 0;
    let errorCount = 0;

    for (const user of missingUsers) {
      try {
        // Start transaction
        await pgClient.query('BEGIN');

        // Extract name from metadata or email
        const fullName = user.raw_user_meta_data?.full_name 
          || user.raw_user_meta_data?.name
          || user.email?.split('@')[0] 
          || 'User';

        console.log(`🔄 Creating profile for: ${user.email}`);

        // Create user profile in public.users
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
          null, // phone
          null, // address
          null, // city
          null, // postal_code
          'inactive', // subscription_status
          'basic', // subscription_type
          'active', // user_status
          null, // stripe_customer_id
          null, // stripe_subscription_id
          null, // stripe_payment_method_id
          false, // profile_completed (false because no profile data)
          user.created_at,
          user.updated_at
        ]);

        // Assign user role if not present
        await pgClient.query(`
          INSERT INTO public.user_roles (user_id, role)
          VALUES ($1, 'user'::app_role)
          ON CONFLICT (user_id, role) DO NOTHING
        `, [user.id]);

        // Commit transaction
        await pgClient.query('COMMIT');

        console.log(`   ✅ Successfully created profile for: ${user.email}`);
        console.log(`      - ID: ${user.id}`);
        console.log(`      - Name: ${fullName}`);
        successCount++;

      } catch (error: any) {
        await pgClient.query('ROLLBACK');
        console.error(`   ❌ Error creating profile for ${user.email}:`, error.message);
        errorCount++;
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('📊 Sync Summary:');
    console.log(`   ✅ Successfully created: ${successCount}`);
    console.log(`   ❌ Errors: ${errorCount}`);
    console.log(`   📝 Total processed: ${missingUsers.length}`);
    console.log('='.repeat(60));

    if (successCount > 0) {
      console.log('\n💡 Users now have complete profiles in public.users');
      console.log('   They can log in with their existing credentials');
    }

  } catch (error: any) {
    console.error('\n❌ Fatal error:', error.message);
    throw error;
  } finally {
    await pgClient.end();
  }
}

async function main() {
  try {
    await syncAuthToPublicUsers();
    console.log('\n✅ Sync completed successfully!');
  } catch (error: any) {
    console.error('\n❌ Sync failed:', error.message);
    process.exit(1);
  }
}

// Run the script
main();