import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { AppStackParamList } from './types';
import MainTabs from './MainTabs';
import DonacionesScreen from '../screens/DonacionesScreen';

const Stack = createNativeStackNavigator<AppStackParamList>();

export default function AppNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="MainTabs"
      screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#fff' } }}
    >
      <Stack.Screen name="MainTabs" component={MainTabs} />
      <Stack.Screen name="Donaciones" component={DonacionesScreen} />
    </Stack.Navigator>
  );
}
