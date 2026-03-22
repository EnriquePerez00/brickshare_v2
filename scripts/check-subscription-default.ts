import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY!);

async function checkDefault() {
  const { data, error } = await supabase.rpc('get_column_default', { 
    p_table_name: 'users', 
    p_column_name: 'subscription_status' 
  });
  
  if (error) {
    // Fallback: use a generic query to information_schema if RPC fails
    const { data: info, error: infoError } = await supabase
      .from('information_schema_columns') // This might not be accessible via REST
      .select('column_default')
      .eq('table_name', 'users')
      .eq('column_name', 'subscription_status');
      
    // Better fallback: just try to insert a dummy user and see what happens (in a transaction or just check)
    // Actually, I'll just check the migration files again or use a direct SQL if I can.
    
    console.log('Trying direct SQL via RPC...');
    const { data: sqlData, error: sqlError } = await supabase.rpc('exec_sql', {
      sql_query: "SELECT column_default FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'subscription_status'"
    });
    
    if (sqlError) {
      console.error('Failed to check default:', sqlError.message);
    } else {
      console.log('Default value:', sqlData);
    }
  } else {
    console.log('Default value:', data);
  }
}

checkDefault();
