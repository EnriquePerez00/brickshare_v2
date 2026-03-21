import { supabase } from "@/integrations/supabase/client";

export interface CorreosPudoPoint {
    user_id: string;
    correos_id_pudo: string;
    correos_name: string;
    correos_point_type: "Oficina" | "Citypaq" | "Locker";
    correos_street: string;
    correos_street_number?: string;
    correos_zip_code: string;
    correos_city: string;
    correos_province: string;
    correos_country: string;
    correos_full_address: string;
    correos_latitude: number;
    correos_longitude: number;
    correos_opening_hours?: string;
    correos_structured_hours?: any;
    correos_available: boolean;
    correos_phone?: string;
    correos_email?: string;
    correos_internal_code?: string;
    correos_locker_capacity?: number;
    correos_additional_services?: string[];
    correos_accessibility?: boolean;
    correos_parking?: boolean;
    created_at?: string;
    updated_at?: string;
    correos_selection_date?: string;
}

/**
 * Get the user's selected Correos PUDO point
 */
export async function getUserPudoPoint(userId: string): Promise<CorreosPudoPoint | null> {
    const { data, error } = await supabase
        .from("users_correos_dropping")
        .select("*")
        .eq("user_id", userId)
        .single();

    if (error) {
        if (error.code === "PGRST116") {
            // No rows found
            return null;
        }
        throw error;
    }

    return data;
}

/**
 * Save or update the user's selected Correos PUDO point
 */
export async function saveUserPudoPoint(userId: string, pudoData: Partial<CorreosPudoPoint>): Promise<void> {
    const { error } = await supabase
        .from("users_correos_dropping")
        .upsert({
            user_id: userId,
            ...pudoData,
            correos_selection_date: new Date().toISOString(),
        });

    if (error) throw error;
}

/**
 * Delete the user's selected Correos PUDO point
 */
export async function deleteUserPudoPoint(userId: string): Promise<void> {
    const { error } = await supabase
        .from("users_correos_dropping")
        .delete()
        .eq("user_id", userId);

    if (error) throw error;
}