/**
 * Set de catálogo (tabla sets).
 * Compartido entre web e iOS.
 */
export interface SetData {
    id: string;
    set_name: string;
    set_description: string | null;
    set_image_url: string | null;
    set_theme: string;
    set_age_range: string;
    set_piece_count: number;
    skill_boost: string[] | null;
    created_at: string;
    year_released: number | null;
    set_weight: number | null;
    catalogue_visibility: boolean;
    set_ref: string | null;
}
//# sourceMappingURL=set.d.ts.map