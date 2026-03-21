import { useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";

export interface ReferralRecord {
  id: string;
  referrer_id: string;
  referee_id: string;
  status: "pending" | "credited" | "rejected";
  reward_credits: number;
  credited_at: string | null;
  created_at: string;
  referee?: { full_name: string | null };
}

export interface ReferralStats {
  referral_code: string | null;
  referral_credits: number;
  total_referrals: number;
  credited_referrals: number;
  pending_referrals: number;
}

export const useMyReferral = () => {
  const { user } = useAuth();

  return useQuery({
    queryKey: ["referral", "my", user?.id],
    queryFn: async () => {
      if (!user) throw new Error("Not authenticated");

      const { data: profile, error: profileError } = await supabase
        .from("profiles")
        .select("referral_code, referral_credits")
        .eq("id", user.id)
        .single();

      if (profileError) throw profileError;

      const { data: referrals, error: referralsError } = await supabase
        .from("referrals")
        .select("id, referee_id, status, reward_credits, credited_at, created_at")
        .eq("referrer_id", user.id)
        .order("created_at", { ascending: false });

      if (referralsError) throw referralsError;

      const stats: ReferralStats = {
        referral_code: (profile as any).referral_code,
        referral_credits: (profile as any).referral_credits ?? 0,
        total_referrals: referrals?.length ?? 0,
        credited_referrals: referrals?.filter((r: any) => r.status === "credited").length ?? 0,
        pending_referrals: referrals?.filter((r: any) => r.status === "pending").length ?? 0,
      };

      return { stats, referrals: (referrals ?? []) as ReferralRecord[] };
    },
    enabled: !!user,
    staleTime: 1000 * 60 * 5,
  });
};

export const useApplyReferralCode = () => {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async (referralCode: string) => {
      if (!user) throw new Error("Not authenticated");
      const code = referralCode.trim().toUpperCase();

      const { data: referrerProfile, error: lookupError } = await supabase
        .from("profiles")
        .select("id, full_name, referral_code")
        .ilike("referral_code", code)
        .maybeSingle();

      if (lookupError) throw lookupError;
      if (!referrerProfile) throw new Error("Código de referido no válido");
      if ((referrerProfile as any).id === user.id)
        throw new Error("No puedes usar tu propio código");

      const { data: existing } = await supabase
        .from("referrals")
        .select("id")
        .eq("referee_id", user.id)
        .maybeSingle();

      if (existing) throw new Error("Ya tienes un código de referido aplicado");

      const { error: insertError } = await supabase.from("referrals").insert({
        referrer_id: (referrerProfile as any).id,
        referee_id: user.id,
        status: "pending",
        reward_credits: 1,
      });
      if (insertError) throw insertError;

      const { error: profileError } = await supabase
        .from("profiles")
        .update({ referred_by: (referrerProfile as any).id })
        .eq("id", user.id);
      if (profileError) throw profileError;

      return { referrerName: (referrerProfile as any).full_name ?? "otro usuario" };
    },
    onSuccess: ({ referrerName }) => {
      toast({
        title: "¡Código aplicado! 🎉",
        description: `Código de ${referrerName} registrado. Ambos recibiréis un mes gratis cuando actives tu suscripción.`,
      });
      queryClient.invalidateQueries({ queryKey: ["referral"] });
    },
    onError: (error: Error) => {
      toast({
        title: "Error al aplicar código",
        description: error.message,
        variant: "destructive",
      });
    },
  });
};

export const useShareReferral = () => {
  const { toast } = useToast();

  const shareLink = useCallback(
    async (referralCode: string | null) => {
      if (!referralCode) return;
      const url = `${window.location.origin}/como-funciona?ref=${referralCode}`;
      if (navigator.share) {
        try {
          await navigator.share({
            title: "Brickshare — Alquila sets de LEGO®",
            text: `¡Te invito a Brickshare! Usa mi código ${referralCode} y consigue un mes gratis. 🧱`,
            url,
          });
        } catch {
          await copyToClipboard(url, toast);
        }
      } else {
        await copyToClipboard(url, toast);
      }
    },
    [toast]
  );

  const copyCode = useCallback(
    async (referralCode: string | null) => {
      if (!referralCode) return;
      await copyToClipboard(referralCode, toast, "Código copiado al portapapeles");
    },
    [toast]
  );

  return { shareLink, copyCode };
};

async function copyToClipboard(
  text: string,
  toast: ReturnType<typeof useToast>["toast"],
  message = "Enlace copiado al portapapeles"
) {
  try {
    await navigator.clipboard.writeText(text);
    toast({ title: message });
  } catch {
    toast({
      title: "No se pudo copiar",
      description: "Copia el enlace manualmente.",
      variant: "destructive",
    });
  }
}