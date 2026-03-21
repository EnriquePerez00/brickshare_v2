import React, { createContext, useContext, useEffect, useState } from 'react';
import type { User, Session } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import type { Profile } from '@brickshare/shared';

interface AuthContextType {
  user: User | null;
  session: Session | null;
  profile: Profile | null;
  isLoading: boolean;
  signUp: (email: string, password: string, fullName?: string) => Promise<{ error: Error | null }>;
  signIn: (email: string, password: string) => Promise<{ error: Error | null }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
  resetPassword: (email: string) => Promise<{ error: Error | null }>;
  updateUserPassword: (password: string) => Promise<{ error: Error | null }>;
  deleteUserAccount: () => Promise<{ error: Error | null }>;
  updateProfile: (data: Partial<Profile>) => Promise<{ error: Error | null }>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const fetchProfile = async (userId: string) => {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();
    if (!error && data) setProfile(data as Profile);
  };

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        if (session?.user) {
          fetchProfile(session.user.id);
        } else {
          setProfile(null);
        }
        setIsLoading(false);
      }
    );

    supabase.auth.getSession().then(({ data: { session: s } }) => {
      setSession(s);
      setUser(s?.user ?? null);
      if (s?.user) {
        fetchProfile(s.user.id);
      }
      setIsLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signUp = async (email: string, password: string, fullName?: string) => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
    return { error: error as Error | null };
  };

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error: error as Error | null };
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setSession(null);
    setProfile(null);
  };

  const resetPassword = async (email: string) => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'https://brickshare.es/auth?type=recovery',
    });
    return { error: error as Error | null };
  };

  const updateUserPassword = async (password: string) => {
    const { error } = await supabase.auth.updateUser({ password });
    return { error: error as Error | null };
  };

  const deleteUserAccount = async () => {
    if (!user) return { error: new Error('No hay sesión') };
    try {
      const { data, error } = await supabase.functions.invoke('delete-user');
      if (error) return { error: new Error(error.message || 'Error al eliminar cuenta') };
      if (data?.error) return { error: new Error(data.error) };
      setUser(null);
      setSession(null);
      setProfile(null);
      return { error: null };
    } catch (err) {
      return { error: err as Error };
    }
  };

  const refreshProfile = async () => {
    if (user) await fetchProfile(user.id);
  };

  const updateProfile = async (data: Partial<Profile>) => {
    if (!user) return { error: new Error('No hay sesión') };
    const { error } = await supabase
      .from('users')
      .update(data)
      .eq('user_id', user.id);
    if (!error) await fetchProfile(user.id);
    return { error: error as Error | null };
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        profile,
        isLoading,
        signUp,
        signIn,
        signOut,
        refreshProfile,
        resetPassword,
        updateUserPassword,
        deleteUserAccount,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (ctx === undefined) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
