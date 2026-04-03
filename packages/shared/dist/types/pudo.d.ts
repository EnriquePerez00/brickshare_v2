/**
 * Punto PUDO Correos (tabla users_correos_dropping).
 * Compartido entre web e iOS.
 */
export interface CorreosPudoPoint {
    user_id: string;
    correos_id_pudo: string;
    correos_nombre: string;
    correos_tipo_punto: 'Oficina' | 'Citypaq' | 'Locker';
    correos_direccion_calle: string;
    correos_direccion_numero?: string;
    correos_codigo_postal: string;
    correos_ciudad: string;
    correos_provincia: string;
    correos_pais: string;
    correos_direccion_completa: string;
    correos_latitud: number;
    correos_longitud: number;
    correos_horario_apertura?: string;
    correos_horario_estructurado?: unknown;
    correos_disponible: boolean;
    correos_telefono?: string;
    correos_email?: string;
    correos_codigo_interno?: string;
    correos_capacidad_lockers?: number;
    correos_servicios_adicionales?: string[];
    correos_accesibilidad?: boolean;
    correos_parking?: boolean;
    created_at?: string;
    updated_at?: string;
    correos_fecha_seleccion?: string;
}
//# sourceMappingURL=pudo.d.ts.map