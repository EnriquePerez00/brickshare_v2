import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import GuestNavigator from './navigation/GuestNavigator';
import AppNavigator from './navigation/AppNavigator';
import LoadingScreen from './screens/LoadingScreen';

const queryClient = new QueryClient();

function RootNavigator() {
  const { user, isLoading } = useAuth();
  if (isLoading) return <LoadingScreen />;
  return user ? <AppNavigator /> : <GuestNavigator />;
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <SafeAreaProvider>
          <NavigationContainer>
            <RootNavigator />
            <StatusBar style="auto" />
          </NavigationContainer>
        </SafeAreaProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
}
