import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text } from 'react-native';
import type { MainTabsParamList } from './types';
import CatalogTabScreen from '../screens/CatalogTabScreen';
import DashboardTabScreen from '../screens/DashboardTabScreen';
import ProfileTabScreen from '../screens/ProfileTabScreen';

const Tab = createBottomTabNavigator<MainTabsParamList>();

export default function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#0f766e',
        tabBarInactiveTintColor: '#64748b',
        tabBarLabelStyle: { fontSize: 12, fontWeight: '500' },
      }}
    >
      <Tab.Screen
        name="CatalogTab"
        component={CatalogTabScreen}
        options={{ tabBarLabel: 'Catálogo', tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 20 }}>📦</Text> }}
      />
      <Tab.Screen
        name="DashboardTab"
        component={DashboardTabScreen}
        options={{ tabBarLabel: 'Mi área', tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 20 }}>🏠</Text> }}
      />
      <Tab.Screen
        name="ProfileTab"
        component={ProfileTabScreen}
        options={{ tabBarLabel: 'Perfil', tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 20 }}>👤</Text> }}
      />
    </Tab.Navigator>
  );
}
