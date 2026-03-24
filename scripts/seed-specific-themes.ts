import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const BRICKSET_API_KEY = process.env.BRICKSET_API_KEY || '3-Vz2Y-d9eO-WJojN';
const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://localhost:54331';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ Missing VITE_SUPABASE_SERVICE_ROLE_KEY in .env.local');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// Configuration: 5 sets per theme from 2020+
const THEMES_CONFIG = [
  { theme: 'Star Wars', count: 5 },
  { theme: 'City', count: 5 },
  { theme: 'Architecture', count: 5 }
];
const MIN_YEAR = 2020;

function calculateRentalPrice(pieces: number): number {
  if (pieces < 250) return 25;
  if (pieces < 500) return 50;
  if (pieces < 750) return 75;
  if (pieces < 1000) return 100;
  return 150;
}

async function fetchSetsFromBrickset(theme: string, count: number) {
  const params = {
    theme,
    pageSize: 100,  // Get a large batch to filter from
    orderBy: 'Random'
  };

  const url = `https://brickset.com/api/v3.asmx/getSets?apiKey=${BRICKSET_API_KEY}&userHash=&params=${encodeURIComponent(JSON.stringify(params))}`;

  try {
    console.log(`🔍 Fetching ${theme} sets...`);
    const response = await fetch(url);
    const data = await response.json();

    if (data.status !== 'success') {
      console.error(`❌ Error fetching ${theme}:`, data.message);
      return [];
    }

    const sets = data.sets || [];
    console.log(`   Received ${sets.length} total sets from API`);
    
    // Filter by year and image, then sort by year descending to get newest first
    const filteredSets = sets
      .filter((s: any) => {
        const hasYear = s.year >= MIN_YEAR;
        const hasImage = s.image?.imageURL;
        const hasMinPieces = s.pieces && s.pieces >= 50; // Filter out very small sets
        return hasYear && hasImage && hasMinPieces;
      })
      .sort((a: any, b: any) => b.year - a.year)
      .slice(0, count);

    console.log(`✅ Found ${filteredSets.length} valid ${theme} sets (${MIN_YEAR}+, with images, 50+ pieces)`);
    return filteredSets;
  } catch (error) {
    console.error(`❌ Network error fetching ${theme}:`, error);
    return [];
  }
}

async function seedSet(s: any, theme: string) {
  const pieces = s.pieces || 0;
  const ageMin = s.ageRange?.min || '?';
  const ageMax = s.ageRange?.max || '';
  const ageRange = ageMax ? `${ageMin}-${ageMax}` : `${ageMin}+`;

  const setData = {
    set_name: s.name,
    set_description: s.description || `Lego ${s.theme} set: ${s.name} (${s.number}).`,
    set_image_url: s.image.imageURL,
    set_theme: s.theme,
    set_age_range: ageRange,
    set_piece_count: pieces,
    year_released: s.year,
    set_ref: s.number,
    set_status: 'active',
    set_price: calculateRentalPrice(pieces),
    set_weight: s.dimensions?.weight ? s.dimensions.weight * 1000 : null,
    set_minifigs: s.minifigs || 0,
    set_subtheme: s.subtheme || null,
    barcode_upc: s.barcode?.UPC || null,
    barcode_ean: s.barcode?.EAN || null,
    catalogue_visibility: true,
    set_pvp_release: s.LEGOCom?.DE?.retailPrice || s.LEGOCom?.US?.retailPrice || null
  };

  // Check if set exists
  const { data: existingSet, error: fetchError } = await supabase
    .from('sets')
    .select('id')
    .eq('set_ref', s.number)
    .maybeSingle();

  if (fetchError) {
    console.error(`❌ Error checking set ${s.number}:`, fetchError.message);
    return false;
  }

  let insertedSet;

  if (existingSet) {
    const { data: updatedSet, error: updateError } = await supabase
      .from('sets')
      .update(setData)
      .eq('id', existingSet.id)
      .select()
      .single();
    
    if (updateError) {
      console.error(`❌ Error updating set ${s.number}:`, updateError.message);
      return false;
    }
    insertedSet = updatedSet;
    console.log(`🔄 Updated: ${s.number} - ${s.name} (${s.year})`);
  } else {
    const { data: newlyInsertedSet, error: insertError } = await supabase
      .from('sets')
      .insert(setData)
      .select()
      .single();

    if (insertError) {
      console.error(`❌ Error inserting set ${s.number}:`, insertError.message);
      return false;
    }
    insertedSet = newlyInsertedSet;
  }

  if (insertedSet) {
    // Handle inventory_sets
    const { data: existingInv, error: fetchInvError } = await supabase
      .from('inventory_sets')
      .select('id')
      .eq('set_id', insertedSet.id)
      .maybeSingle();
    
    if (fetchInvError) {
      console.error(`❌ Error checking inventory for ${s.number}:`, fetchInvError.message);
      return false;
    }

    let invError;
    if (existingInv) {
      const { error } = await supabase
        .from('inventory_sets')
        .update({ inventory_set_total_qty: 5 })
        .eq('id', existingInv.id);
      invError = error;
    } else {
      const { error } = await supabase
        .from('inventory_sets')
        .insert({
          set_id: insertedSet.id,
          inventory_set_total_qty: 5,
          in_shipping: 0,
          in_use: 0,
          in_return: 0,
          in_repair: 0
        });
      invError = error;
    }

    if (invError) {
      console.error(`❌ Error updating inventory for ${s.number}:`, invError.message);
      return false;
    } else {
      console.log(`✅ Seeded: ${s.number} - ${s.name} (${s.year}, ${pieces} pcs, €${calculateRentalPrice(pieces)})`);
      return true;
    }
  }

  return false;
}

async function seed() {
  console.log('🚀 Starting Brickshare Themed Seed...');
  console.log(`📍 Targeting Supabase: ${SUPABASE_URL}`);
  console.log(`📅 Year filter: ${MIN_YEAR}+\n`);

  let totalInserted = 0;
  const summary: { [key: string]: number } = {};

  for (const config of THEMES_CONFIG) {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`📦 Processing theme: ${config.theme} (${config.count} sets)`);
    console.log(`${'='.repeat(60)}\n`);
    
    const sets = await fetchSetsFromBrickset(config.theme, config.count);
    
    let themeCount = 0;
    for (const s of sets) {
      const success = await seedSet(s, config.theme);
      if (success) {
        themeCount++;
        totalInserted++;
      }
    }
    
    summary[config.theme] = themeCount;
  }

  console.log(`\n${'='.repeat(60)}`);
  console.log('🎉 Seed Completed!');
  console.log(`${'='.repeat(60)}`);
  console.log('\n📊 Summary:');
  for (const [theme, count] of Object.entries(summary)) {
    console.log(`  ✅ ${theme}: ${count} sets`);
  }
  console.log(`\n🎯 Total sets processed: ${totalInserted}`);
}

seed().catch(console.error);