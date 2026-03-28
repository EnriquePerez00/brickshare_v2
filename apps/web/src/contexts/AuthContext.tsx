import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { User, Session } from "@supabase/supabase-js";
import { supabase } from "@/integrations/supabase/client";

export interface Profile {
  id: string;
  user_id: string;
  full_name: string | null;
  email: string | null;
  avatar_url: string | null;
  user_status: string | null;
  impact_points: number | null;
  address: string | null;
  zip_code: string | null;
  city: string | null;
  phone: string | null;
  subscription_status: string | null;
  subscription_type: string | null;
  profile_completed: boolean | null;
}

interface AuthContextType {
  user: User | null;
  session: Session | null;
  profile: Profile | null;
  isLoading: boolean;
  isAdmin: boolean;
  isOperador: boolean;
  signUp: (email: string, password: string, fullName?: string) => Promise<{ error: Error | null }>;
  signIn: (email: string, password: string) => Promise<{ error: Error | null }>;
  signInWithGoogle: () => Promise<{ error: Error | null }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
  resetPassword: (email: string) => Promise<{ error: Error | null }>;
  updateUserPassword: (password: string) => Promise<{ error: Error | null }>;
  deleteUserAccount: () => Promise<{ error: Error | null }>;
  updateProfile: (data: Partial<Profile>) => Promise<{ error: Error | null }>;
  openAuthModal: (mode?: "login" | "signup" | "forgot-password") => void;
  closeAuthModal: () => void;
  isAuthModalOpen: boolean;
  authModalMode: "login" | "signup" | "forgot-password";
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);
  const [isOperador, setIsOperador] = useState(false);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authModalMode, setAuthModalMode] = useState<"login" | "signup" | "forgot-password">("login");

  const fetchProfile = async (userId: string) => {
    const { data, error } = await supabase
      .from("users")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();

    if (!error && data) {
      setProfile(data);
    }
  };

  const checkUserRoles = async (userId: string) => {
    const { data, error } = await supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", userId);

    if (!error && data) {
      const roles = data.map(r => r.role);
      setIsAdmin(roles.includes("admin"));
      setIsOperador(roles.includes("operador"));
    } else {
      setIsAdmin(false);
      setIsOperador(false);
    }
  };

  useEffect(() => {
    // Set up auth state listener FIRST
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setSession(session);
        setUser(session?.user ?? null);

        // Defer Supabase calls with setTimeout
        if (session?.user) {
          setTimeout(() => {
            fetchProfile(session.user.id);
            checkUserRoles(session.user.id);
          }, 0);
        } else {
          setProfile(null);
          setIsAdmin(false);
          setIsOperador(false);
        }

        setIsLoading(false);
      }
    );

    // THEN check for existing session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);

      if (session?.user) {
        fetchProfile(session.user.id);
        checkUserRoles(session.user.id);
      }

      setIsLoading(false);
    });

    // Set up periodic session validation (every 5 minutes)
    // This catches cases where auth.users.id exists but public.users.user_id doesn't (corrupted sessions)
    const validationInterval = setInterval(async () => {
      const { data: { session } } = await supabase.auth.getSession();
      
      if (session?.user) {
        try {
          const { data: userExists } = await supabase
            .from('users')
            .select('user_id')
            .eq('user_id', session.user.id)
            .maybeSingle();

          if (!userExists) {
            console.error(
              '❌ [AuthContext] Session validation failed: user_id not found in public.users',
              'User Auth ID:', session.user.id,
              'This indicates a corrupted session. Forcing logout.'
            );
            
            // Force logout to clear corrupted session
            await supabase.auth.signOut();
            setUser(null);
            setSession(null);
            setProfile(null);
            setIsAdmin(false);
            setIsOperador(false);
          }
        } catch (error) {
          console.error('❌ [AuthContext] Error during session validation:', error);
        }
      }
    }, 5 * 60 * 1000); // Run every 5 minutes

    return () => {
      subscription.unsubscribe();
      clearInterval(validationInterval);
    };
  }, []);

  const signUp = async (email: string, password: string, fullName?: string) => {
    const redirectUrl = `${window.location.origin}/`;

    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: redirectUrl,
        data: {
          full_name: fullName,
        },
      },
    });

    return { error: error as Error | null };
  };

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    return { error: error as Error | null };
  };

  const signInWithGoogle = async () => {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/`,
      },
    });

    return { error: error as Error | null };
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setSession(null);
    setProfile(null);
    setIsAdmin(false);
    setIsOperador(false);
  };

  const resetPassword = async (email: string) => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/?type=recovery`,
    });
    return { error: error as Error | null };
  };

  const updateUserPassword = async (password: string) => {
    const { error } = await supabase.auth.updateUser({ password });
    return { error: error as Error | null };
  };

  const deleteUserAccount = async () => {
    if (!user) return { error: new Error("No user logged in") };

    try {
      // Call the edge function that deactivates the account (soft-delete)
      const { data, error } = await supabase.functions.invoke('delete-user');

      if (error) {
        return { error: new Error(error.message || 'Failed to deactivate account') };
      }

      if (data?.error) {
        return { error: new Error(data.error) };
      }

      // Sign out and clear local state after successful deactivation
      await supabase.auth.signOut();
      setUser(null);
      setSession(null);
      setProfile(null);
      setIsAdmin(false);
      setIsOperador(false);

      return { error: null };
    } catch (err) {
      return { error: err as Error };
    }
  };

  const refreshProfile = async () => {
    if (user) {
      await fetchProfile(user.id);
    }
  };

  const updateProfile = async (data: Partial<Profile>) => {
    if (!user) return { error: new Error("No user logged in") };

    const { error } = await supabase
      .from("users")
      .update(data)
      .eq("user_id", user.id);

    if (!error) {
      await fetchProfile(user.id);
    }

    return { error: error as Error | null };
  };

  const openAuthModal = (mode: "login" | "signup" | "forgot-password" = "login") => {
    setAuthModalMode(mode);
    setIsAuthModalOpen(true);
  };

  const closeAuthModal = () => {
    setIsAuthModalOpen(false);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        profile,
        isLoading,
        isAdmin,
        isOperador,
        signUp,
        signIn,
        signInWithGoogle,
        signOut,
        refreshProfile,
        resetPassword,
        updateUserPassword,
        deleteUserAccount,
        updateProfile,
        openAuthModal,
        closeAuthModal,
        isAuthModalOpen,
        authModalMode,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
