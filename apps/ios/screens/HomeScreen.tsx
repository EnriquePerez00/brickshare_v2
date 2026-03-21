import { View, Text, StyleSheet, TouchableOpacity, ImageBackground, SafeAreaView } from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { GuestStackParamList } from '../navigation/types';

type Props = NativeStackScreenProps<GuestStackParamList, 'Home'>;

export default function HomeScreen({ navigation }: Props) {
  return (
    <ImageBackground
      source={require('../assets/hero-lego.jpg')}
      style={styles.backgroundImage}
    >
      <View style={styles.overlay}>
        <SafeAreaView style={styles.safeArea}>
          {/* Header */}
          <View style={styles.header}>
            <Text style={styles.logo}>Brickshare</Text>
            <View style={styles.navLinks}>
              <TouchableOpacity onPress={() => navigation.navigate('Catalog')}>
                <Text style={styles.navLink}>Catálogo</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={() => navigation.navigate('Dashboard')}>
                <Text style={styles.navLink}>Cómo funciona</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Centered Content */}
          <View style={styles.content}>
            <Text style={styles.title}>Juega con propósito</Text>
            <Text style={styles.subtitle}>
              Suscripción circular de sets de construcción que impulsa el desarrollo infantil y la inclusión social.
            </Text>

            <View style={styles.buttons}>
              <TouchableOpacity
                style={styles.buttonPrimary}
                onPress={() => navigation.navigate('Auth')}
              >
                <Text style={styles.buttonTextPrimary}>Iniciar sesión</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.buttonSecondary}
                onPress={() => navigation.navigate('Auth')}
              >
                <Text style={styles.buttonTextSecondary}>Registrarse</Text>
              </TouchableOpacity>
            </View>
          </View>
        </SafeAreaView>
      </View>
    </ImageBackground>
  );
}

const styles = StyleSheet.create({
  backgroundImage: {
    flex: 1,
    width: '100%',
    height: '100%',
  },
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.85)',
  },
  safeArea: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 15,
  },
  logo: {
    fontSize: 22,
    fontWeight: '800',
    color: '#0f766e',
  },
  navLinks: {
    flexDirection: 'row',
    gap: 15,
  },
  navLink: {
    fontSize: 14,
    fontWeight: '600',
    color: '#64748b',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 30,
  },
  title: {
    fontSize: 36,
    fontWeight: '800',
    color: '#0f172a',
    textAlign: 'center',
    marginBottom: 16,
  },
  subtitle: {
    fontSize: 18,
    color: '#475569',
    textAlign: 'center',
    lineHeight: 26,
    marginBottom: 40,
  },
  buttons: {
    width: '100%',
    gap: 12,
  },
  buttonPrimary: {
    backgroundColor: '#0f766e',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#0f766e',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 4,
  },
  buttonSecondary: {
    backgroundColor: 'transparent',
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#0f766e',
  },
  buttonTextPrimary: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
  buttonTextSecondary: {
    color: '#0f766e',
    fontSize: 16,
    fontWeight: '700',
  },
});
