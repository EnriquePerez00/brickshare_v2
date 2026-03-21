import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";

export interface OrderData {
    id: string;
    user_id: string;
    set_ref: string | null;
    shipment_status: string;
    updated_at: string;
    sets?: {
        set_name: string;
        set_image_url: string | null;
        set_theme: string;
        set_piece_count: number;
    } | null;
}

export const useOrders = () => {
    const { user } = useAuth();

    return useQuery({
        queryKey: ["orders", user?.id],
        queryFn: async () => {
            if (!user) throw new Error("User not authenticated");

            const { data, error } = await supabase
                .from("shipments" as any)
                .select(`
                  id,
                  user_id,
                  set_ref,
                  shipment_status,
                  updated_at,
                  sets:sets!left(set_name, set_image_url, set_theme, set_piece_count)
                `)
                .eq("user_id", user.id)
                .order("updated_at", { ascending: false });

            if (error) throw error;
            return data as unknown as OrderData[];
        },
        enabled: !!user,
        staleTime: 1000 * 60 * 5,
    });
};

export const useReturnSet = () => {
    const queryClient = useQueryClient();
    const { toast } = useToast();

    return useMutation({
        mutationFn: async (envioId: string) => {
            const { error: dbError } = await supabase
                .from("shipments" as any)
                .update({ shipment_status: "return_in_transit" } as any)
                .eq("id", envioId);

            if (dbError) throw dbError;

            const { data, error: functionError } = await supabase.functions.invoke('correos-logistics', {
                body: {
                    action: 'return_preregister',
                    p_envios_id: envioId
                }
            });

            if (functionError) {
                console.error("Function Error:", functionError);
                throw new Error("Error registering return with Correos: " + functionError.message);
            }

            return data;
        },
        onSuccess: () => {
            toast({
                title: "Return initiated",
                description: "The return has been registered. You will receive an email with the Correos code.",
            });
            queryClient.invalidateQueries({ queryKey: ["orders"] });
        },
        onError: (error: Error) => {
            toast({
                title: "Error",
                description: "Could not initiate return: " + error.message,
                variant: "destructive",
            });
        },
    });
};