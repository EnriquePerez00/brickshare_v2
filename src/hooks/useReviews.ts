import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";

export interface Review {
  id: string;
  set_id: string;
  user_id: string;
  rating: number;
  comment: string | null;
  status: "pending" | "approved" | "rejected";
  created_at: string;
  profiles?: { full_name: string | null };
}

export const useSetReviews = (setId: string) =>
  useQuery({
    queryKey: ["reviews", "set", setId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("reviews")
        .select("id, rating, comment, created_at, profiles(full_name)")
        .eq("set_id", setId)
        .eq("status", "approved")
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data as unknown as Review[];
    },
    enabled: !!setId,
    staleTime: 1000 * 60 * 5,
  });

export const useMyReviewForSet = (setId: string) => {
  const { user } = useAuth();
  return useQuery({
    queryKey: ["reviews", "my", setId, user?.id],
    queryFn: async () => {
      const { data } = await supabase
        .from("reviews")
        .select("*")
        .eq("set_id", setId)
        .eq("user_id", user!.id)
        .maybeSingle();
      return data as Review | null;
    },
    enabled: !!user && !!setId,
  });
};

export const useSubmitReview = () => {
  const qc = useQueryClient();
  const { user } = useAuth();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async ({
      setId,
      rating,
      comment,
    }: {
      setId: string;
      rating: number;
      comment: string;
    }) => {
      if (!user) throw new Error("Not authenticated");
      const { error } = await supabase.from("reviews").upsert(
        { set_id: setId, user_id: user.id, rating, comment, status: "pending" },
        { onConflict: "set_id,user_id" }
      );
      if (error) throw error;
    },
    onSuccess: (_, { setId }) => {
      toast({ title: "¡Reseña enviada! Será revisada pronto." });
      qc.invalidateQueries({ queryKey: ["reviews", "set", setId] });
      qc.invalidateQueries({ queryKey: ["reviews", "my", setId] });
    },
    onError: () =>
      toast({ title: "Error al enviar reseña", variant: "destructive" }),
  });
};