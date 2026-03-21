import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import type { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { useAuth } from '../contexts/AuthContext';
import type { MainTabsParamList } from '../navigation/types';

type Props = BottomTabScreenProps<MainTabsParamList, 'ProfileTab'>;

export default function ProfileTabScreen({ navigation }: Props) {
  const { user, profile, signOut, deleteUserAccount } = useAuth();

  const handleSignOut = () => {
    Alert.alert('Cerrar sesión', '¿Seguro que quieres salir?', [
      { text: 'Cancelar', style: 'cancel' },
      { text: 'Salir', style: 'destructive', onPress: signOut },
    ]);
  };

  const handleDeleteAccount = () => {
    Alert.alert(
      'Eliminar cuenta',
      'Se borrarán todos tus datos. Esta acción no se puede deshacer.',
      [
        { text: 'Cancelar', style: 'cancel' },
        { text: 'Eliminar', style: 'destructive', onPress: async () => {
          const { error } = await deleteUserAccount();
          if (error) Alert.alert('Error', error.message);
        }},
      ]
    );
  };

  const goToDonaciones = () => {
    (navigation.getParent() as { navigate: (name: string) => void } | undefined)?.navigate('Donaciones');
  };

  if (!user) return null;

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Perfil</Text>
        <View style={styles.card}>
          <Text style={styles.label}>Nombre</Text>
          <Text style={styles.value}>{profile?.full_name ?? user.email ?? '—'}</Text>
          <Text style={styles.label}>Email</Text>
          <Text style={styles.value}>{user.email ?? '—'}</Text>
          <Text style={styles.label}>Suscripción</Text>
          <Text style={styles.value}>
            {profile?.subscription_status === 'active' ? 'Activa' : profile?.subscription_status ?? '—'}
          </Text>
        </View>
      </View>

      <TouchableOpacity style={styles.button} onPress={goToDonaciones}>
        <Text style={styles.buttonText}>Donar sets</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.buttonSecondary]} onPress={handleSignOut}>
        <Text style={styles.buttonTextSecondary}>Cerrar sesión</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.buttonDanger]} onPress={handleDeleteAccount}>
        <Text style={styles.buttonDangerText}>Eliminar cuenta</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16, paddingBottom: 32 },
  section: { marginBottom: 24 },
  sectionTitle: { fontSize: 18, fontWeight: '700', color: '#111', marginBottom: 12 },
  card: { backgroundColor: '#fff', padding: 16, borderRadius: 8, borderWidth: 1, borderColor: '#eee' },
  label: { fontSize: 12, color: '#666', marginTop: 12, marginBottom: 2 },
  value: { fontSize: 16, color: '#111' },
  button: {
    backgroundColor: '#0f766e',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 12,
  },
  buttonSecondary: { backgroundColor: '#f0fdfa', borderWidth: 1, borderColor: '#0f766e' },
  buttonDanger: { backgroundColor: '#fff', borderWidth: 1, borderColor: '#b91c1c', marginTop: 8 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  buttonTextSecondary: { color: '#0f766e', fontSize: 16, fontWeight: '600' },
  buttonDangerText: { color: '#b91c1c', fontSize: 16, fontWeight: '600' },
});
