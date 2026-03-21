import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import type { CorreosPudoPoint } from '@brickshare/shared';

export function useUserPudoPoint() {
  const { user } = useAuth();
  return useQuery({
    queryKey: ['user-pudo-point', user?.id],
    queryFn: async () => {
      if (!user) return null;
      const { data, error } = await supabase
        .from('users_correos_dropping')
        .select('*')
        .eq('user_id', user.id)
        .maybeSingle();
      if (error && error.code !== 'PGRST116') throw error;
      return data as CorreosPudoPoint | null;
    },
    enabled: !!user,
  });
}

export function useSavePudoPoint() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (pudoData: Partial<CorreosPudoPoint>) => {
      if (!user) throw new Error('No autenticado');
      const { error } = await supabase
        .from('users_correos_dropping')
        .upsert({
          user_id: user.id,
          ...pudoData,
          correos_fecha_seleccion: new Date().toISOString(),
        });
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user-pudo-point', user?.id] });
    },
  });
}

export function useDeletePudoPoint() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      if (!user) throw new Error('No autenticado');
      const { error } = await supabase
        .from('users_correos_dropping')
        .delete()
        .eq('user_id', user.id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user-pudo-point', user?.id] });
    },
  });
}
