import { useState, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";

// ─── Types ───────────────────────────────────────────────────────────────────

export interface Review {
  id: string;
  user_id: string;
  set_id: string;
  envio_id: string | null;
  rating: number;
  comment: string | null;
  age_fit: boolean | null;
  difficulty: number | null;
  would_reorder: boolean | null;
  is_published: boolean;
  created_at: string;
  profiles?: {
    full_name: string | null;
  } | null;
}

export interface ReviewStats {
  set_id: string;
  review_count: number;
  avg_rating: number;
  five_stars: number;
  four_stars: number;
  three_stars: number;
  two_stars: number;
  one_star: number;
  avg_difficulty: number | null;
  would_reorder_count: number;
}

export interface SubmitReviewData {
  set_id: string;
  envio_id?: string;
  rating: number;
  comment?: string;
  age_fit?: boolean;
  difficulty?: number;
  would_reorder?: boolean;
}

// ─── Hook: reviews for a specific set ────────────────────────────────────────

export const useSetReviews = (setId: string, limit = 10) => {
  return useQuery({
    queryKey: ["reviews", "set", setId, limit],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("reviews")
        .select(
          `
          id, user_id, set_id, envio_id, rating, comment,
          age_fit, difficulty, would_reorder, created_at,
          profiles:user_id ( full_name )
        `
        )
        .eq("set_id", setId)
        .eq("is_published", true)
        .order("created_at", { ascending: false })
        .limit(limit);

      if (error) throw error;
      return data as Review[];
    },
    enabled: !!setId,
    staleTime: 1000 * 60 * 5,
  });
};

// ─── Hook: review stats for a set (from the view) ────────────────────────────

export const useSetReviewStats = (setId: string) => {
  return useQuery({
    queryKey: ["review-stats", setId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("set_review_stats")
        .select("*")
        .eq("set_id", setId)
        .maybeSingle();

      if (error) throw error;
      return data as ReviewStats | null;
    },
    enabled: !!setId,
    staleTime: 1000 * 60 * 5,
  });
};

// ─── Hook: current user's review for a specific envio ────────────────────────

export const useMyReviewForEnvio = (envioId: string | null) => {
  return useQuery({
    queryKey: ["reviews", "my-envio", envioId],
    queryFn: async () => {
      if (!envioId) return null;
      const { data, error } = await supabase
        .from("reviews")
        .select("*")
        .eq("envio_id", envioId)
        .maybeSingle();

      if (error) throw error;
      return data as Review | null;
    },
    enabled: !!envioId,
    staleTime: 1000 * 60 * 5,
  });
};

// ─── Hook: submit a review ────────────────────────────────────────────────────

export const useSubmitReview = () => {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async (reviewData: SubmitReviewData) => {
      if (!user) throw new Error("User not authenticated");

      const { data, error } = await supabase
        .from("reviews")
        .upsert(
          {
            user_id: user.id,
            set_id: reviewData.set_id,
            envio_id: reviewData.envio_id ?? null,
            rating: reviewData.rating,
            comment: reviewData.comment ?? null,
            age_fit: reviewData.age_fit ?? null,
            difficulty: reviewData.difficulty ?? null,
            would_reorder: reviewData.would_reorder ?? null,
            is_published: true,
          },
          { onConflict: "envio_id" }
        )
        .select()
        .single();

      if (error) throw error;

      // Trigger review-request email after a delay (via Edge Function)
      // This is handled server-side on return, not here.

      return data as Review;
    },
    onSuccess: (_, variables) => {
      toast({
        title: "¡Gracias por tu valoración! ⭐",
        description: "Tu opinión ayuda a otros usuarios a elegir el set perfecto.",
      });
      queryClient.invalidateQueries({ queryKey: ["reviews", "set", variables.set_id] });
      queryClient.invalidateQueries({ queryKey: ["review-stats", variables.set_id] });
      if (variables.envio_id) {
        queryClient.invalidateQueries({
          queryKey: ["reviews", "my-envio", variables.envio_id],
        });
      }
    },
    onError: (error: Error) => {
      toast({
        title: "Error al enviar valoración",
        description: error.message,
        variant: "destructive",
      });
    },
  });
};

// ─── Hook: delete own review ──────────────────────────────────────────────────

export const useDeleteReview = () => {
  const queryClient = useQueryClient();
  const { toast } = useToast();

  return useMutation({
    mutationFn: async ({
      reviewId,
      setId,
    }: {
      reviewId: string;
      setId: string;
    }) => {
      const { error } = await supabase
        .from("reviews")
        .delete()
        .eq("id", reviewId);

      if (error) throw error;
      return { reviewId, setId };
    },
    onSuccess: ({ setId }) => {
      toast({ title: "Valoración eliminada" });
      queryClient.invalidateQueries({ queryKey: ["reviews", "set", setId] });
      queryClient.invalidateQueries({ queryKey: ["review-stats", setId] });
    },
    onError: (error: Error) => {
      toast({
        title: "Error al eliminar valoración",
        description: error.message,
        variant: "destructive",
      });
    },
  });
};