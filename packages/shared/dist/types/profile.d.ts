/**
 * Perfil de usuario (tabla users / profiles).
 * Compartido entre web e iOS.
 */
export interface Profile {
    id: string;
    user_id: string;
    full_name: string | null;
    email: string | null;
    avatar_url: string | null;
    user_status: string | null;
    impact_points: number | null;
    address: string | null;
    address_extra: string | null;
    zip_code: string | null;
    city: string | null;
    province: string | null;
    phone: string | null;
    subscription_status: string | null;
    subscription_type: string | null;
}
//# sourceMappingURL=profile.d.ts.map