import { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { AppStackParamList } from '../navigation/types';
import { useDonation, type DonationFormData } from '../hooks/useDonation';

type Props = NativeStackScreenProps<AppStackParamList, 'Donaciones'>;

export default function DonacionesScreen({ navigation }: Props) {
  const { submitDonation, isLoading } = useDonation();
  const [nombre, setNombre] = useState('');
  const [email, setEmail] = useState('');
  const [telefono, setTelefono] = useState('');
  const [direccion, setDireccion] = useState('');
  const [peso, setPeso] = useState('');
  const [metodoEntrega, setMetodoEntrega] = useState<'punto-recogida' | 'recogida-domicilio'>('punto-recogida');
  const [recompensa, setRecompensa] = useState<'economica' | 'social'>('social');

  const handleSubmit = async () => {
    const pesoNum = parseInt(peso, 10);
    const data: DonationFormData = {
      nombre: nombre.trim(),
      email: email.trim(),
      telefono: telefono.trim() || undefined,
      direccion: direccion.trim() || undefined,
      peso_estimado: pesoNum,
      metodo_entrega: metodoEntrega,
      recompensa,
    };
    const result = await submitDonation(data);
    if (result?.success) navigation.goBack();
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.backText}>← Cerrar</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Donar sets</Text>
      </View>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <Text style={styles.label}>Nombre *</Text>
        <TextInput
          style={styles.input}
          value={nombre}
          onChangeText={setNombre}
          placeholder="Tu nombre"
          placeholderTextColor="#999"
        />
        <Text style={styles.label}>Email *</Text>
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="email@ejemplo.com"
          placeholderTextColor="#999"
          keyboardType="email-address"
          autoCapitalize="none"
        />
        <Text style={styles.label}>Teléfono</Text>
        <TextInput
          style={styles.input}
          value={telefono}
          onChangeText={setTelefono}
          placeholder="Opcional"
          placeholderTextColor="#999"
          keyboardType="phone-pad"
        />
        <Text style={styles.label}>Dirección</Text>
        <TextInput
          style={[styles.input, styles.inputMultiline]}
          value={direccion}
          onChangeText={setDireccion}
          placeholder="Para recogida a domicilio"
          placeholderTextColor="#999"
          multiline
        />
        <Text style={styles.label}>Peso estimado (kg) *</Text>
        <TextInput
          style={styles.input}
          value={peso}
          onChangeText={setPeso}
          placeholder="1-100"
          placeholderTextColor="#999"
          keyboardType="number-pad"
        />
        <Text style={styles.label}>Método de entrega</Text>
        <View style={styles.row}>
          <TouchableOpacity
            style={[styles.chip, metodoEntrega === 'punto-recogida' && styles.chipActive]}
            onPress={() => setMetodoEntrega('punto-recogida')}
          >
            <Text style={[styles.chipText, metodoEntrega === 'punto-recogida' && styles.chipTextActive]}>
              Punto de recogida
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.chip, metodoEntrega === 'recogida-domicilio' && styles.chipActive]}
            onPress={() => setMetodoEntrega('recogida-domicilio')}
          >
            <Text style={[styles.chipText, metodoEntrega === 'recogida-domicilio' && styles.chipTextActive]}>
              Recogida a domicilio
            </Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.label}>Recompensa</Text>
        <View style={styles.row}>
          <TouchableOpacity
            style={[styles.chip, recompensa === 'economica' && styles.chipActive]}
            onPress={() => setRecompensa('economica')}
          >
            <Text style={[styles.chipText, recompensa === 'economica' && styles.chipTextActive]}>Económica</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.chip, recompensa === 'social' && styles.chipActive]}
            onPress={() => setRecompensa('social')}
          >
            <Text style={[styles.chipText, recompensa === 'social' && styles.chipTextActive]}>Social</Text>
          </TouchableOpacity>
        </View>
        <TouchableOpacity
          style={[styles.submit, isLoading && styles.submitDisabled]}
          onPress={handleSubmit}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.submitText}>Enviar donación</Text>
          )}
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  header: {
    paddingTop: 56,
    paddingHorizontal: 16,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  backText: { color: '#0f766e', fontSize: 16, marginBottom: 8 },
  title: { fontSize: 24, fontWeight: '700', color: '#111' },
  content: { padding: 16, paddingBottom: 32 },
  label: { fontSize: 14, fontWeight: '600', color: '#334', marginBottom: 6, marginTop: 12 },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 16,
    fontSize: 16,
  },
  inputMultiline: { minHeight: 80, textAlignVertical: 'top' },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 4 },
  chip: {
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#0f766e',
  },
  chipActive: { backgroundColor: '#0f766e' },
  chipText: { color: '#0f766e', fontSize: 14 },
  chipTextActive: { color: '#fff' },
  submit: {
    backgroundColor: '#0f766e',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 24,
  },
  submitDisabled: { opacity: 0.7 },
  submitText: { color: '#fff', fontSize: 16, fontWeight: '600' },
});
