import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY!);

async function verify() {
  console.log('--- Verifying Default Subscription Status ---');
  
  // Insert a dummy user directly into public.users (simulating handle_new_user)
  const dummyId = '00000000-0000-0000-0000-000000000000';
  
  // Clean up first if exists
  await supabase.from('users').delete().eq('user_id', dummyId);
  
  const { data, error } = await supabase.from('users').insert({
    user_id: dummyId,
    email: 'test-default@example.com',
    full_name: 'Test Default'
  }).select();
  
  if (error) {
    console.error('Error inserting test user:', error.message);
  } else {
    console.log('Inserted user:', data[0]);
    if (data[0].subscription_status === 'inactive') {
      console.log('✅ SUCCESS: subscription_status defaulted to "inactive"');
    } else {
      console.log('❌ FAILURE: subscription_status is', data[0].subscription_status);
    }
  }
  
  // Clean up
  await supabase.from('users').delete().eq('user_id', dummyId);
}

verify();
