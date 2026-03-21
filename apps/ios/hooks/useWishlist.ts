import { useState, useEffect, useCallback } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';

export function useWishlist() {
  const { user, profile } = useAuth();
  const [wishlistIds, setWishlistIds] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const fetchWishlist = useCallback(async () => {
    if (!user) {
      setWishlistIds([]);
      return;
    }
    setIsLoading(true);
    const { data, error } = await supabase
      .from('wishlist')
      .select('set_id')
      .eq('user_id', user.id)
      .eq('status', true);
    if (!error && data) setWishlistIds(data.map((i) => i.set_id));
    setIsLoading(false);
  }, [user?.id]);

  useEffect(() => {
    fetchWishlist();
  }, [fetchWishlist]);

  const toggleWishlist = async (setId: string): Promise<boolean> => {
    if (!user) {
      Alert.alert('Inicia sesión', 'Debes iniciar sesión para añadir sets a tu wishlist.');
      return false;
    }

    const isCurrentlyWishlisted = wishlistIds.includes(setId);
    if (!isCurrentlyWishlisted) {
      if (!profile?.subscription_status || profile.subscription_status !== 'active') {
        Alert.alert('Suscripción inactiva', 'Necesitas una suscripción activa para añadir sets a tu wishlist.');
        return false;
      }
    }

    if (isCurrentlyWishlisted) {
      setWishlistIds((prev) => prev.filter((id) => id !== setId));
    } else {
      setWishlistIds((prev) => [...prev, setId]);
    }

    if (isCurrentlyWishlisted) {
      const { error } = await supabase
        .from('wishlist')
        .update({ status: false, status_changed_at: new Date().toISOString() })
        .eq('user_id', user.id)
        .eq('set_id', setId);
      if (error) {
        setWishlistIds((prev) => [...prev, setId]);
        Alert.alert('Error', 'No se pudo eliminar de la wishlist.');
        return false;
      }
      Alert.alert('Eliminado', 'Set eliminado de tu wishlist.');
    } else {
      const { error } = await supabase
        .from('wishlist')
        .upsert({
          user_id: user.id,
          set_id: setId,
          status: true,
          status_changed_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,set_id'
        });
      if (error) {
        setWishlistIds((prev) => prev.filter((id) => id !== setId));
        Alert.alert('Error', 'No se pudo añadir a la wishlist.');
        return false;
      }
      Alert.alert('Añadido', 'Set añadido a tu wishlist.');
    }
    return true;
  };

  return {
    wishlistIds,
    isLoading,
    toggleWishlist,
    isWishlisted: (setId: string) => wishlistIds.includes(setId),
    refreshWishlist: fetchWishlist,
  };
}
