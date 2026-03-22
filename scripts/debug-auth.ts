import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY!);

async function debugAuth() {
  console.log('--- Debugging Auth Persistence ---');
  
  // Check public users
  const { data: publicUsers, error: pError } = await supabase.from('users').select('email, user_id');
  if (pError) console.error('Error fetching public users:', pError.message);
  else console.log('Public users count:', publicUsers.length, publicUsers);

  // In local Supabase, we can use the admin API to list users
  const { data: { users }, error: authError } = await supabase.auth.admin.listUsers();
  if (authError) console.error('Error fetching auth users:', authError.message);
  else console.log('Auth users count:', users.length, users.map(u => ({ email: u.email, id: u.id })));
}

debugAuth();
