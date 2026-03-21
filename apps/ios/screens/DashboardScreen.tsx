import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { GuestStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<GuestStackParamList, 'Dashboard'>;

export default function DashboardScreen({ navigation }: Props) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.backText}>← Volver</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Mi área</Text>
      </View>
      <View style={styles.content}>
        <Text style={styles.welcome}>Área de usuario</Text>
        <Text style={styles.hint}>
          Inicia sesión para ver tu wishlist, pedidos y punto de entrega PUDO.
        </Text>
        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Auth')}
        >
          <Text style={styles.buttonText}>Iniciar sesión</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.button, styles.buttonSecondary]}
          onPress={() => navigation.navigate('Catalog')}
        >
          <Text style={styles.buttonTextSecondary}>Ver catálogo</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  header: {
    paddingTop: 56,
    paddingHorizontal: 16,
    paddingBottom: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  backText: {
    color: '#0f766e',
    fontSize: 16,
    marginBottom: 8,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    color: '#111',
  },
  content: {
    flex: 1,
    padding: 24,
    justifyContent: 'center',
  },
  welcome: {
    fontSize: 20,
    fontWeight: '600',
    color: '#111',
    marginBottom: 8,
  },
  hint: {
    fontSize: 15,
    color: '#666',
    marginBottom: 24,
  },
  button: {
    backgroundColor: '#0f766e',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 12,
  },
  buttonSecondary: {
    backgroundColor: '#f0fdfa',
    borderWidth: 1,
    borderColor: '#0f766e',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  buttonTextSecondary: {
    color: '#0f766e',
    fontSize: 16,
    fontWeight: '600',
  },
});
