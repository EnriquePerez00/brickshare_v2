import type { NativeStackScreenProps } from '@react-navigation/native-stack';

export type GuestStackParamList = {
  Home: undefined;
  Auth: undefined;
  Catalog: undefined;
  Dashboard: undefined;
};

export type MainTabsParamList = {
  CatalogTab: undefined;
  DashboardTab: undefined;
  ProfileTab: undefined;
};

export type AppStackParamList = {
  MainTabs: undefined;
  Donaciones: undefined;
};

export type RootStackScreenProps<T extends keyof GuestStackParamList> =
  NativeStackScreenProps<GuestStackParamList, T>;

declare global {
  namespace ReactNavigation {
    interface RootParamList extends GuestStackParamList, AppStackParamList {}
  }
}
