import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });
dotenv.config({ path: path.join(__dirname, '../.env.local'), override: true });

const BRICKSET_API_KEY = process.env.BRICKSET_API_KEY || '3-Vz2Y-d9eO-WJojN';
const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_ROLE_KEY = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ Missing VITE_SUPABASE_SERVICE_ROLE_KEY in .env.local');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const THEMES = ['City', 'Star Wars', 'Architecture'];
const SETS_PER_THEME = 10;

function calculateRentalPrice(pieces: number): number {
  if (pieces < 250) return 25;
  if (pieces < 500) return 50;
  if (pieces < 750) return 75;
  if (pieces < 1000) return 100;
  return 150;
}

async function fetchSetsFromBrickset(theme: string) {
  const params = {
    theme,
    pageSize: SETS_PER_THEME,
    orderBy: 'Year-desc',
    category: 'Normal'
  };

  const url = `https://brickset.com/api/v3.asmx/getSets?apiKey=${BRICKSET_API_KEY}&userHash=&params=${encodeURIComponent(JSON.stringify(params))}`;

  try {
    const response = await fetch(url);
    const data = await response.json();

    if (data.status !== 'success') {
      console.error(`❌ Error fetching ${theme}:`, data.message);
      return [];
    }

    return data.sets || [];
  } catch (error) {
    console.error(`❌ Network error fetching ${theme}:`, error);
    return [];
  }
}

async function seed() {
  console.log('🚀 Starting Brickset Seed...');
  console.log(`📍 Targeting Supabase: ${SUPABASE_URL}`);

  let totalInserted = 0;

  for (const theme of THEMES) {
    console.log(`\n📦 Fetching sets for theme: ${theme}...`);
    const sets = await fetchSetsFromBrickset(theme);
    
    console.log(`✅ Found ${sets.length} sets.`);

    for (const s of sets) {
      if (!s.image?.imageURL) {
        console.log(`⚠️ Skipping ${s.number} - No image URL`);
        continue;
      }

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
        set_weight: s.dimensions?.weight ? s.dimensions.weight * 1000 : null, // Assuming weight is in kg from Brickset
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
        continue;
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
          continue;
        }
        insertedSet = updatedSet;
      } else {
        const { data: newlyInsertedSet, error: insertError } = await supabase
          .from('sets')
          .insert(setData)
          .select()
          .single();

        if (insertError) {
          console.error(`❌ Error inserting set ${s.number}:`, insertError.message);
          continue;
        }
        insertedSet = newlyInsertedSet;
      }

      if (insertedSet) {
        // Handle inventory_sets
        // Check if inventory exists
        const { data: existingInv, error: fetchInvError } = await supabase
          .from('inventory_sets')
          .select('id')
          .eq('set_id', insertedSet.id)
          .maybeSingle();
        
        if (fetchInvError) {
          console.error(`❌ Error checking inventory for ${s.number}:`, fetchInvError.message);
          continue;
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
        } else {
          console.log(`✅ Seeded: ${s.number} - ${s.name} (Qty: 5)`);
          totalInserted++;
        }
      }
    }
  }

  console.log(`\n🎉 Seed finished! Total sets processed: ${totalInserted}`);
}

seed();
