/**
 * Pedido/envío (tabla envios + join sets).
 * Compartido entre web e iOS.
 */
export interface OrderData {
  id: string;
  user_id: string;
  set_ref: string | null;
  estado_envio: string;
  updated_at: string;
  sets?: {
    set_name: string;
    set_image_url: string | null;
    set_theme: string;
    set_piece_count: number;
  } | null;
}

export const ESTADOS_ENVIO = [
  'preparacion',
  'ruta_envio',
  'entregado',
  'devuelto',
  'ruta_devolucion',
  'cancelado',
] as const;
export type EstadoEnvio = (typeof ESTADOS_ENVIO)[number];
