import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/contexts/AuthContext";
import {
    getUserActivePudo,
    getUserCorreosPudo,
    getUserBricksharePudo,
    saveUserCorreosPudo,
    saveUserBricksharePudo,
    deleteUserPudoPoint,
    type CorreosPudoPoint,
    type BricksharePudoPoint,
    type ActivePudoPoint,
} from "@/lib/pudoService";

/**
 * Get the user's active PUDO point (either Correos or Brickshare)
 */
export function useUserActivePudo() {
    const { user } = useAuth();

    return useQuery({
        queryKey: ["user-active-pudo", user?.id],
        queryFn: async () => {
            if (!user) return null;
            return getUserActivePudo(user.id);
        },
        enabled: !!user,
    });
}

/**
 * Get the user's selected Correos PUDO point
 */
export function useUserCorreosPudo() {
    const { user } = useAuth();

    return useQuery({
        queryKey: ["user-correos-pudo", user?.id],
        queryFn: async () => {
            if (!user) return null;
            return getUserCorreosPudo(user.id);
        },
        enabled: !!user,
    });
}

/**
 * Get the user's selected Brickshare PUDO point
 */
export function useUserBricksharePudo() {
    const { user } = useAuth();

    return useQuery({
        queryKey: ["user-brickshare-pudo", user?.id],
        queryFn: async () => {
            if (!user) return null;
            return getUserBricksharePudo(user.id);
        },
        enabled: !!user,
    });
}

/**
 * Save a Correos PUDO point
 */
export function useSaveCorreosPudo() {
    const { user } = useAuth();
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async (pudoData: Partial<CorreosPudoPoint>) => {
            if (!user) throw new Error("User not authenticated");
            await saveUserCorreosPudo(user.id, pudoData);
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["user-active-pudo", user?.id] });
            queryClient.invalidateQueries({ queryKey: ["user-correos-pudo", user?.id] });
            queryClient.invalidateQueries({ queryKey: ["user-brickshare-pudo", user?.id] });
        },
    });
}

/**
 * Save a Brickshare PUDO point
 */
export function useSaveBricksharePudo() {
    const { user } = useAuth();
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async (pudoData: Partial<BricksharePudoPoint>) => {
            if (!user) throw new Error("User not authenticated");
            await saveUserBricksharePudo(user.id, pudoData);
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["user-active-pudo", user?.id] });
            queryClient.invalidateQueries({ queryKey: ["user-correos-pudo", user?.id] });
            queryClient.invalidateQueries({ queryKey: ["user-brickshare-pudo", user?.id] });
        },
    });
}

/**
 * Delete the user's PUDO point (either type)
 */
export function useDeletePudoPoint() {
    const { user } = useAuth();
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async () => {
            if (!user) throw new Error("User not authenticated");
            await deleteUserPudoPoint(user.id);
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["user-active-pudo", user?.id] });
            queryClient.invalidateQueries({ queryKey: ["user-correos-pudo", user?.id] });
            queryClient.invalidateQueries({ queryKey: ["user-brickshare-pudo", user?.id] });
        },
    });
}

// Legacy hook for backwards compatibility
export function useUserPudoPoint() {
    return useUserActivePudo();
}

// Legacy hook for backwards compatibility
export function useSavePudoPoint() {
    return useSaveCorreosPudo();
}