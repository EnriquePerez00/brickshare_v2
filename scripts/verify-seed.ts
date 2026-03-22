import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY!);

async function verify() {
  console.log('🧐 Final Verification...');

  const { data: sets, error: setsError } = await supabase
    .from('sets')
    .select('set_theme, set_ref');

  if (setsError) {
    console.error('Error fetching sets:', setsError);
    return;
  }

  const themes = ['City', 'Star Wars', 'Architecture'];
  themes.forEach(t => {
    const count = sets.filter(s => s.set_theme === t).length;
    console.log(`- Theme ${t}: ${count} sets`);
  });

  const { data: inv, error: invError } = await supabase
    .from('inventory_sets')
    .select('inventory_set_total_qty');

  if (invError) {
    console.error('Error fetching inventory:', invError);
    return;
  }

  const totalQty = inv.reduce((acc, curr) => acc + curr.inventory_set_total_qty, 0);
  console.log(`- Total inventory units: ${totalQty}`);
  console.log(`- Average units per set: ${totalQty / inv.length}`);
}

verify();
