import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://localhost:54331';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ Missing VITE_SUPABASE_SERVICE_ROLE_KEY in .env.local');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function verify() {
  console.log('🔍 Verifying seeded sets...\n');

  const { data: sets, error } = await supabase
    .from('sets')
    .select('set_ref, set_name, set_theme, year_released, set_piece_count, set_price')
    .in('set_theme', ['Star Wars', 'City', 'Architecture'])
    .gte('year_released', 2020)
    .order('set_theme')
    .order('year_released', { ascending: false });

  if (error) {
    console.error('❌ Error fetching sets:', error.message);
    process.exit(1);
  }

  if (!sets || sets.length === 0) {
    console.log('⚠️ No sets found matching the criteria');
    process.exit(0);
  }

  console.log(`✅ Found ${sets.length} sets in total\n`);

  const groupedByTheme: { [key: string]: any[] } = {};
  sets.forEach(set => {
    if (!groupedByTheme[set.set_theme]) {
      groupedByTheme[set.set_theme] = [];
    }
    groupedByTheme[set.set_theme].push(set);
  });

  for (const [theme, themeSets] of Object.entries(groupedByTheme)) {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`${theme} (${themeSets.length} sets)`);
    console.log(`${'='.repeat(60)}`);
    
    themeSets.forEach(set => {
      console.log(`  ${set.set_ref} - ${set.set_name}`);
      console.log(`    Year: ${set.year_released} | Pieces: ${set.set_piece_count} | Price: €${set.set_price}`);
    });
  }

  console.log('\n');
}

verify().catch(console.error);