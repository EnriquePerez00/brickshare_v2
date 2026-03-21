import { useQuery } from '@tanstack/react-query';
import { supabase } from '../lib/supabase';
import type { SetData } from '@brickshare/shared';

const SETS_COLS = 'id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, year_released, set_weight, catalogue_visibility, set_ref';

export function useSets(limit = 50, offset = 0) {
  return useQuery({
    queryKey: ['sets', limit, offset],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('sets')
        .select(SETS_COLS)
        .eq('catalogue_visibility', true)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);
      if (error) throw error;
      return (data ?? []) as SetData[];
    },
    staleTime: 1000 * 60 * 5,
  });
}

export function useFeaturedSets(limit = 4) {
  return useQuery({
    queryKey: ['featured-sets', limit],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('sets')
        .select(SETS_COLS)
        .eq('catalogue_visibility', true)
        .order('set_piece_count', { ascending: false })
        .limit(limit);
      if (error) throw error;
      return (data ?? []) as SetData[];
    },
    staleTime: 1000 * 60 * 5,
  });
}
