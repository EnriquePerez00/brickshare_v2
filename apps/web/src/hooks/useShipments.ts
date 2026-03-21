import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";

export interface ShipmentData {
    id: string;
    user_id: string;
    set_id: string | null;
    set_ref: string | null;
    assigned_date: string | null;
    estimated_delivery_date: string | null;
    actual_delivery_date: string | null;
    user_delivery_date: string | null;
    warehouse_reception_date: string | null;
    warehouse_pickup_date: string | null;
    return_request_date: string | null;
    estimated_return_date: string | null;
    shipment_status: string;
    shipping_address: string;
    shipping_city: string;
    shipping_zip_code: string;
    shipping_country: string;
    shipping_provider: string | null;
    pickup_provider: string | null;
    tracking_number: string | null;
    carrier: string | null;
    additional_notes: string | null;
    correos_shipment_id: string | null;
    label_url: string | null;
    pickup_id: string | null;
    last_tracking_update: string | null;
    created_at: string;
    updated_at: string;
    users?: {
        full_name: string | null;
        email: string | null;
        user_id: string;
    } | null;
}

export const useShipments = () => {
    const { user, isOperador, isAdmin } = useAuth();

    return useQuery({
        queryKey: ["admin-shipments"],
        queryFn: async () => {
            if (!user || (!isOperador && !isAdmin)) {
                throw new Error("Unauthorized");
            }

            const { data, error } = await supabase
                .from("shipments" as any)
                .select(`
                    *,
                    users:user_id (
                        full_name,
                        email,
                        user_id
                    )
                `)
                .order("created_at", { ascending: false });

            if (error) throw error;
            return data as unknown as ShipmentData[];
        },
        enabled: !!user && (isOperador || isAdmin),
    });
};