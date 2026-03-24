import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export interface AssignedShipment {
  id: string;
  user_id: string;
  set_ref: string;
  tracking_code: string;
  pudo_type: "brickshare" | "correos";
  updated_at: string;
  users: {
    full_name: string;
    email: string;
  } | null;
  brickshare_pudo_locations?: {
    name: string;
    address: string;
    city: string;
    postal_code: string;
  } | null;
  users_correos_dropping?: {
    selected_pudo_id: string;
    selected_pudo_name: string;
    selected_pudo_address: string;
    selected_pudo_postal_code: string;
    selected_pudo_city: string;
  } | null;
}

export function useAssignedShipments() {
  return useQuery({
    queryKey: ["assigned-shipments"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("shipments")
        .select(`
          id,
          user_id,
          set_ref,
          tracking_code,
          pudo_type,
          updated_at,
          users!inner (
            full_name,
            email
          ),
          brickshare_pudo_locations (
            name,
            address,
            city,
            postal_code
          ),
          users_correos_dropping!shipments_user_id_fkey (
            selected_pudo_id,
            selected_pudo_name,
            selected_pudo_address,
            selected_pudo_postal_code,
            selected_pudo_city
          )
        `)
        .eq("shipping_status", "assigned")
        .order("updated_at", { ascending: false });

      if (error) throw error;
      return data as AssignedShipment[];
    },
    staleTime: 30000, // 30 seconds
  });
}