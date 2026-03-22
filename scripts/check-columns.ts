import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY!);

async function check() {
  const { data, error } = await supabase.rpc('inspect_table', { table_name: 'users' });
  
  if (error) {
    // If RPC doesn't exist, try to list columns another way.
    // We can use the information_schema REST interface if enabled, but usually it's not.
    console.log('RPC check failed, trying selective query...');
    const columns = ['id', 'user_id', 'full_name', 'address', 'zip_code', 'city', 'phone', 'profile_completed'];
    for (const col of columns) {
      const { error: colError } = await supabase.from('users').select(col).limit(0);
      if (colError) {
        console.log(`❌ Column ${col} NOT FOUND:`, colError.message);
      } else {
        console.log(`✅ Column ${col} FOUND`);
      }
    }
  }
}

check();
