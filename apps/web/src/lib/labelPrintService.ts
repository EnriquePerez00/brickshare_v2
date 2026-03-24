import { supabase } from "@/integrations/supabase/client";
import { AssignedShipment } from "@/hooks/useAssignedShipments";

export function formatPudoAddress(shipment: AssignedShipment): string {
  if (shipment.pudo_type === "brickshare" && shipment.brickshare_pudo_locations) {
    const pudo = shipment.brickshare_pudo_locations;
    return `${pudo.name}\n${pudo.address}\n${pudo.postal_code} ${pudo.city}`;
  } else if (shipment.pudo_type === "correos" && shipment.users_correos_dropping) {
    const pudo = shipment.users_correos_dropping;
    return `${pudo.selected_pudo_name}\n${pudo.selected_pudo_address}\n${pudo.selected_pudo_postal_code} ${pudo.selected_pudo_city}`;
  }
  return "Dirección no disponible";
}

export function getTrackingLastDigits(trackingCode: string | null): string {
  if (!trackingCode) return "------";
  return trackingCode.slice(-6).toUpperCase();
}

/**
 * Get short reference from shipment UUID (last 8 characters)
 * For human-readable identification on labels
 */
export function getShortReference(shipmentId: string): string {
  return shipmentId.slice(-8).toUpperCase();
}

/**
 * Generate QR code data - just the shipment UUID
 * External logistics app will use this to identify the shipment
 */
export function generateQRData(shipmentId: string): string {
  return shipmentId;
}

export async function updateShipmentStatus(
  shipmentIds: string[],
  status: "in_transit_pudo"
): Promise<void> {
  const { error } = await supabase
    .from("shipments")
    .update({ shipping_status: status })
    .in("id", shipmentIds);

  if (error) throw error;
}

export function getPudoTypeLabel(pudoType: "brickshare" | "correos"): string {
  return pudoType === "brickshare" ? "Brickshare PUDO" : "Correos Express";
}