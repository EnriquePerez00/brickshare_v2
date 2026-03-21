import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { GuestStackParamList } from './types';
import HomeScreen from '../screens/HomeScreen';
import AuthScreen from '../screens/AuthScreen';
import CatalogScreen from '../screens/CatalogScreen';
import DashboardScreen from '../screens/DashboardScreen';

const Stack = createNativeStackNavigator<GuestStackParamList>();

export default function GuestNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="Home"
      screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#fff' } }}
    >
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="Auth" component={AuthScreen} />
      <Stack.Screen name="Catalog" component={CatalogScreen} />
      <Stack.Screen name="Dashboard" component={DashboardScreen} />
    </Stack.Navigator>
  );
}
