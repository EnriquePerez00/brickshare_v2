import { supabase } from "@/integrations/supabase/client";

/**
 * Interface for the PUDO point returned from PudoSelector component
 */
export interface PUDOPoint {
    id_correos_pudo: string;
    nombre: string;
    direccion: string;
    cp: string;
    ciudad: string;
    lat: number;
    lng: number;
    horario: string;
    tipo_punto: "Oficina" | "Citypaq" | "Deposito" | "Locker" | string;
}

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

export interface BricksharePudoPoint {
    user_id: string;
    brickshare_pudo_id: string;
    location_name: string;
    address: string;
    city: string;
    postal_code: string;
    province: string;
    latitude?: number;
    longitude?: number;
    contact_email?: string;
    contact_phone?: string;
    opening_hours?: any;
    selection_date?: string;
    created_at?: string;
    updated_at?: string;
}

export type ActivePudoPoint = {
    pudo_type: 'correos' | 'brickshare';
    pudo_id: string;
    pudo_name: string;
    pudo_address: string;
    pudo_city: string;
    pudo_postal_code: string;
};

/**
 * Get the user's active PUDO point (either Correos or Brickshare)
 */
export async function getUserActivePudo(userId: string): Promise<ActivePudoPoint | null> {
    const { data, error } = await supabase
        .from("users")
        .select("pudo_id, pudo_type")
        .eq("user_id", userId)
        .single();

    if (error || !data?.pudo_type) {
        return null;
    }

    // Fetch full details based on type
    if (data.pudo_type === 'correos') {
        const { data: correos, error: correosError } = await supabase
            .from("users_correos_dropping")
            .select("*")
            .eq("user_id", userId)
            .single();

        if (correosError || !correos) return null;

        return {
            pudo_type: 'correos',
            pudo_id: correos.correos_id_pudo,
            pudo_name: correos.correos_name,
            pudo_address: correos.correos_full_address,
            pudo_city: correos.correos_city,
            pudo_postal_code: correos.correos_zip_code,
        };
    } else {
        const { data: brickshare, error: brickshareError } = await supabase
            .from("users_brickshare_dropping")
            .select("*")
            .eq("user_id", userId)
            .single();

        if (brickshareError || !brickshare) return null;

        return {
            pudo_type: 'brickshare',
            pudo_id: brickshare.brickshare_pudo_id,
            pudo_name: brickshare.location_name,
            pudo_address: brickshare.address,
            pudo_city: brickshare.city,
            pudo_postal_code: brickshare.postal_code,
        };
    }
}

/**
 * Get the user's selected Correos PUDO point
 */
export async function getUserCorreosPudo(userId: string): Promise<CorreosPudoPoint | null> {
    const { data, error } = await supabase
        .from("users_correos_dropping")
        .select("*")
        .eq("user_id", userId)
        .single();

    if (error) {
        if (error.code === "PGRST116") {
            return null;
        }
        throw error;
    }

    return data;
}

/**
 * Get the user's selected Brickshare PUDO point
 */
export async function getUserBricksharePudo(userId: string): Promise<BricksharePudoPoint | null> {
    const { data, error } = await supabase
        .from("users_brickshare_dropping")
        .select("*")
        .eq("user_id", userId)
        .single();

    if (error) {
        if (error.code === "PGRST116") {
            return null;
        }
        throw error;
    }

    return data;
}

/**
 * Save or update the user's selected Correos PUDO point
 */
export async function saveUserCorreosPudo(userId: string, pudoData: Partial<CorreosPudoPoint>): Promise<void> {
    // Delete any existing Brickshare PUDO
    await supabase
        .from("users_brickshare_dropping")
        .delete()
        .eq("user_id", userId);

    // Save Correos PUDO
    const { error } = await supabase
        .from("users_correos_dropping")
        .upsert({
            user_id: userId,
            ...pudoData,
            correos_selection_date: new Date().toISOString(),
        });

    if (error) throw error;

    // Update users table with unified reference
    const { error: userError } = await supabase
        .from("users")
        .update({
            pudo_id: pudoData.correos_id_pudo,
            pudo_type: 'correos',
        })
        .eq("user_id", userId);

    if (userError) throw userError;
}

/**
 * Save or update the user's selected Brickshare PUDO point
 */
export async function saveUserBricksharePudo(userId: string, pudoData: Partial<BricksharePudoPoint>): Promise<void> {
    console.log('🏢 [saveUserBricksharePudo] Starting save for user:', userId);
    console.log('🏢 [saveUserBricksharePudo] PUDO data:', pudoData);
    
    // Delete any existing Correos PUDO
    console.log('🗑️ [saveUserBricksharePudo] Deleting existing Correos PUDO...');
    await supabase
        .from("users_correos_dropping")
        .delete()
        .eq("user_id", userId);

    // Save Brickshare PUDO
    console.log('💾 [saveUserBricksharePudo] Saving Brickshare PUDO to users_brickshare_dropping...');
    const { error } = await supabase
        .from("users_brickshare_dropping")
        .upsert({
            user_id: userId,
            ...pudoData,
            selection_date: new Date().toISOString(),
        });

    if (error) {
        console.error('❌ [saveUserBricksharePudo] Error saving to users_brickshare_dropping:', error);
        throw error;
    }
    console.log('✅ [saveUserBricksharePudo] Saved to users_brickshare_dropping successfully');

    // Update users table with unified reference
    console.log('💾 [saveUserBricksharePudo] Updating users table with unified reference...');
    const { error: userError } = await supabase
        .from("users")
        .update({
            pudo_id: pudoData.brickshare_pudo_id,
            pudo_type: 'brickshare',
        })
        .eq("user_id", userId);

    if (userError) {
        console.error('❌ [saveUserBricksharePudo] Error updating users table:', userError);
        throw userError;
    }
    console.log('✅ [saveUserBricksharePudo] Users table updated successfully');
}

/**
 * Delete the user's selected PUDO point (either type)
 */
export async function deleteUserPudoPoint(userId: string): Promise<void> {
    // Delete from both tables (only one will have data)
    await supabase.from("users_correos_dropping").delete().eq("user_id", userId);
    await supabase.from("users_brickshare_dropping").delete().eq("user_id", userId);

    // Clear users table reference
    const { error } = await supabase
        .from("users")
        .update({
            pudo_id: null,
            pudo_type: null,
        })
        .eq("user_id", userId);

    if (error) throw error;
}

/**
 * Normalize punto_tipo values from external APIs to match database constraint
 * Database accepts: 'Oficina', 'Citypaq', 'Locker', 'Deposito'
 */
export function normalizePudoPointType(tipo: string): "Oficina" | "Citypaq" | "Locker" | "Deposito" {
    if (!tipo || typeof tipo !== 'string') {
        console.warn('⚠️ Invalid tipo_punto value:', tipo, 'defaulting to Oficina');
        return 'Oficina';
    }

    const normalized = tipo.toLowerCase().trim();

    if (normalized.includes('citypaq') || normalized.includes('citypak') || normalized.includes('citypack')) {
        return 'Citypaq';
    }

    if (normalized.includes('locker') || normalized.includes('lockers')) {
        return 'Locker';
    }

    if (normalized.includes('deposito') || normalized.includes('depósito') || normalized.includes('deposit')) {
        return 'Deposito';
    }

    if (normalized.includes('oficina') || normalized.includes('office') || normalized.includes('correos')) {
        return 'Oficina';
    }

    console.warn('⚠️ Unknown tipo_punto value:', tipo, 'defaulting to Oficina');
    return 'Oficina';
}

/**
 * Transform a PUDOPoint from PudoSelector into CorreosPudoPoint format
 */
export function transformPUDOPointToCorreosPudo(pudoPoint: PUDOPoint): Partial<CorreosPudoPoint> {
    const normalizedType = normalizePudoPointType(pudoPoint.tipo_punto);
    
    // Only valid for Correos types
    if (normalizedType === 'Deposito') {
        throw new Error('Cannot transform Deposito to CorreosPudo');
    }
    
    return {
        correos_id_pudo: pudoPoint.id_correos_pudo,
        correos_name: pudoPoint.nombre,
        correos_point_type: normalizedType as "Oficina" | "Citypaq" | "Locker",
        correos_street: pudoPoint.direccion,
        correos_zip_code: pudoPoint.cp,
        correos_city: pudoPoint.ciudad,
        correos_province: pudoPoint.ciudad,
        correos_country: "España",
        correos_full_address: `${pudoPoint.direccion}, ${pudoPoint.cp} ${pudoPoint.ciudad}`,
        correos_latitude: pudoPoint.lat,
        correos_longitude: pudoPoint.lng,
        correos_opening_hours: pudoPoint.horario,
        correos_available: true,
    };
}

/**
 * Transform a PUDOPoint from PudoSelector into BricksharePudoPoint format
 */
export function transformPUDOPointToBricksharePudo(pudoPoint: PUDOPoint): Partial<BricksharePudoPoint> {
    console.log('🔄 [transformPUDOPointToBricksharePudo] Transforming point:', pudoPoint);
    
    // IMPORTANT: id_correos_pudo from PudoSelector is the universal ID field
    // For Brickshare deposits, this contains the Brickshare location ID
    if (!pudoPoint.id_correos_pudo) {
        console.error('❌ [transformPUDOPointToBricksharePudo] Missing id_correos_pudo');
        throw new Error('Cannot transform PUDO point: missing ID');
    }
    
    const transformed = {
        brickshare_pudo_id: pudoPoint.id_correos_pudo, // This is the key mapping
        location_name: pudoPoint.nombre,
        address: pudoPoint.direccion,
        city: pudoPoint.ciudad,
        postal_code: pudoPoint.cp,
        province: pudoPoint.ciudad,
        latitude: pudoPoint.lat,
        longitude: pudoPoint.lng,
        opening_hours: { description: pudoPoint.horario },
    };
    
    console.log('✅ [transformPUDOPointToBricksharePudo] Transformed result:', transformed);
    return transformed;
}
