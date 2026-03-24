/**
 * Type for PUDO point selection.
 * 'brickshare' is an alias for 'brickshare_deposit' for backwards compatibility.
 */
export type PudoType = 'correos' | 'brickshare' | 'brickshare_deposit';

/**
 * Correos PUDO Point (table: users_correos_dropping).
 * Shared between web and iOS.
 */
export interface CorreosPudoPoint {
  user_id: string;
  correos_id_pudo: string;
  correos_name: string;
  correos_point_type: 'Oficina' | 'Citypaq' | 'Locker';
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
  correos_structured_hours?: unknown;
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