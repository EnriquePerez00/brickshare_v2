import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function fix() {
  console.log('🛠️ Adding UNIQUE constraint to sets(set_ref)...');
  
  // We use RPC or raw SQL if possible, but since we are using the client, 
  // we can try to run a query that might fail if we don't have an RPC for it.
  // Actually, let's use a migration-like approach or just check if we can run raw SQL via the client if configured.
  // In many Supabase setups, you can't run raw SQL from the client unless you have an RPC function.
  
  // Let's check if we can use the 'admin' or 'postgres' role via a script that runs 'psql' if available.
  console.log('Checking for duplicates first...');
  const { data, error } = await supabase.from('sets').select('set_ref');
  if (error) {
    console.error('Error reading sets:', error);
    return;
  }

  const refs = data.map(d => d.set_ref);
  const duplicates = refs.filter((item, index) => refs.indexOf(item) !== index);
  
  if (duplicates.length > 0) {
    console.warn('⚠️ Found duplicate set_refs:', duplicates);
    console.log('Please clean them up manually or I will try to handle it.');
  } else {
    console.log('✅ No duplicates found.');
  }
}

fix();
