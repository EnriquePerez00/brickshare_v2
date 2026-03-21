import { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Alert,
  ScrollView,
} from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { GuestStackParamList } from '../navigation/types';
import { useAuth } from '../contexts/AuthContext';

type Props = NativeStackScreenProps<GuestStackParamList, 'Auth'>;

export default function AuthScreen({ navigation }: Props) {
  const { signIn, signUp, resetPassword } = useAuth();
  const [mode, setMode] = useState<'login' | 'signup' | 'forgot'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSubmit = async () => {
    const emailTrim = email.trim();
    if (!emailTrim) {
      setMessage('Introduce tu email.');
      return;
    }
    if (mode === 'forgot') {
      setLoading(true);
      setMessage('');
      const { error } = await resetPassword(emailTrim);
      setLoading(false);
      if (error) {
        Alert.alert('Error', error.message);
        return;
      }
      Alert.alert('Email enviado', 'Revisa tu bandeja para restablecer la contraseña.');
      setMode('login');
      return;
    }
    if (mode === 'signup' && !fullName.trim()) {
      setMessage('Introduce tu nombre.');
      return;
    }
    if (!password) {
      setMessage('Introduce la contraseña.');
      return;
    }
    if (password.length < 8) {
      setMessage('La contraseña debe tener al menos 8 caracteres.');
      return;
    }

    setLoading(true);
    setMessage('');
    if (mode === 'login') {
      const { error } = await signIn(emailTrim, password);
      setLoading(false);
      if (error) {
        Alert.alert('Error', error.message);
        return;
      }
      // Navigation will switch to MainTabs automatically
    } else {
      const { error } = await signUp(emailTrim, password, fullName.trim() || undefined);
      setLoading(false);
      if (error) {
        Alert.alert('Error', error.message);
        return;
      }
      Alert.alert('Cuenta creada', 'Revisa tu email para confirmar la cuenta.');
      setMode('login');
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <View style={styles.form}>
          <Text style={styles.title}>
            {mode === 'login' && 'Iniciar sesión'}
            {mode === 'signup' && 'Crear cuenta'}
            {mode === 'forgot' && 'Recuperar contraseña'}
          </Text>
          {message ? <Text style={styles.error}>{message}</Text> : null}
          <TextInput
            style={styles.input}
            placeholder="Email"
            placeholderTextColor="#999"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            keyboardType="email-address"
            autoComplete="email"
          />
          {mode === 'signup' && (
            <TextInput
              style={styles.input}
              placeholder="Nombre completo"
              placeholderTextColor="#999"
              value={fullName}
              onChangeText={setFullName}
              autoComplete="name"
            />
          )}
          {mode !== 'forgot' && (
            <TextInput
              style={styles.input}
              placeholder="Contraseña (mín. 8 caracteres)"
              placeholderTextColor="#999"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              autoComplete={mode === 'login' ? 'password' : 'new-password'}
            />
          )}
          <TouchableOpacity
            style={[styles.button, loading && styles.buttonDisabled]}
            onPress={handleSubmit}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>
                {mode === 'login' && 'Entrar'}
                {mode === 'signup' && 'Registrarme'}
                {mode === 'forgot' && 'Enviar enlace'}
              </Text>
            )}
          </TouchableOpacity>
          {mode === 'login' && (
            <TouchableOpacity style={styles.link} onPress={() => setMode('forgot')}>
              <Text style={styles.linkText}>¿Olvidaste la contraseña?</Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity
            style={styles.link}
            onPress={() => setMode(mode === 'login' ? 'signup' : 'login')}
          >
            <Text style={styles.linkText}>
              {mode === 'login' ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión'}
            </Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.back} onPress={() => navigation.goBack()}>
            <Text style={styles.backText}>← Volver</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  scroll: { flexGrow: 1, justifyContent: 'center', padding: 24 },
  form: { maxWidth: 400, width: '100%', alignSelf: 'center' },
  title: { fontSize: 24, fontWeight: '700', color: '#111', marginBottom: 24 },
  error: { color: '#b91c1c', marginBottom: 12, fontSize: 14 },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 16,
    fontSize: 16,
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#0f766e',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonDisabled: { opacity: 0.7 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  link: { marginTop: 16, alignItems: 'center' },
  linkText: { color: '#0f766e', fontSize: 14 },
  back: { marginTop: 24, alignItems: 'center' },
  backText: { color: '#666', fontSize: 14 },
});
