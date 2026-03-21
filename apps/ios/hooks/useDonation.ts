import { useState } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../lib/supabase';

export interface DonationFormData {
  nombre: string;
  email: string;
  telefono?: string;
  direccion?: string;
  peso_estimado: number;
  metodo_entrega: 'punto-recogida' | 'recogida-domicilio';
  recompensa: 'economica' | 'social';
}

export function useDonation() {
  const [isLoading, setIsLoading] = useState(false);
  const [result, setResult] = useState<{ success: boolean; donation?: unknown; error?: string } | null>(null);

  const submitDonation = async (data: DonationFormData) => {
    if (!data.nombre?.trim()) {
      Alert.alert('Error', 'El nombre es obligatorio.');
      return { success: false, error: 'Nombre obligatorio' };
    }
    if (!data.email?.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
      Alert.alert('Error', 'Email no válido.');
      return { success: false, error: 'Email inválido' };
    }
    if (!data.peso_estimado || data.peso_estimado < 1 || data.peso_estimado > 100) {
      Alert.alert('Error', 'Peso entre 1 y 100 kg.');
      return { success: false, error: 'Peso inválido' };
    }

    setIsLoading(true);
    setResult(null);
    try {
      const { data: responseData, error } = await supabase.functions.invoke('submit-donation', {
        body: data,
      });
      if (error) {
        Alert.alert('Error', 'No se pudo registrar la donación.');
        setResult({ success: false, error: error.message });
        return { success: false, error: error.message };
      }
      if (responseData?.error) {
        Alert.alert('Error', responseData.error);
        setResult({ success: false, error: responseData.error });
        return { success: false, error: responseData.error };
      }
      Alert.alert('¡Donación registrada!', 'Recibirás un email con los detalles.');
      setResult({ success: true, donation: responseData?.donation });
      return { success: true, donation: responseData?.donation };
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Error inesperado';
      Alert.alert('Error', message);
      setResult({ success: false, error: message });
      return { success: false, error: message };
    } finally {
      setIsLoading(false);
    }
  };

  return { submitDonation, isLoading, result, resetResult: () => setResult(null) };
}
