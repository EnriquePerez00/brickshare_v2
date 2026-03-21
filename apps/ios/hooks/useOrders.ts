import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert } from 'react-native';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import type { OrderData } from '@brickshare/shared';

export function useOrders() {
  const { user } = useAuth();
  return useQuery({
    queryKey: ['orders', user?.id],
    queryFn: async () => {
      if (!user) throw new Error('No autenticado');
      const { data, error } = await supabase
        .from('envios')
        .select(`
          id,
          user_id,
          set_ref,
          estado_envio,
          updated_at,
          sets:sets!left(set_name, set_image_url, set_theme, set_piece_count)
        `)
        .eq('user_id', user.id)
        .order('updated_at', { ascending: false });
      if (error) throw error;
      return (data ?? []) as unknown as OrderData[];
    },
    enabled: !!user,
    staleTime: 1000 * 60 * 5,
  });
}

export function useReturnSet() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (envioId: string) => {
      const { error: dbError } = await supabase
        .from('envios')
        .update({ estado_envio: 'ruta_devolucion' })
        .eq('id', envioId);
      if (dbError) throw dbError;

      const { error: fnError } = await supabase.functions.invoke('correos-logistics', {
        body: { action: 'return_preregister', p_envios_id: envioId },
      });
      if (fnError) throw new Error('Error al registrar la devolución: ' + fnError.message);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      Alert.alert('Devolución iniciada', 'Recibirás un email con el código de Correos.');
    },
    onError: (e: Error) => {
      Alert.alert('Error', e.message);
    },
  });
}
