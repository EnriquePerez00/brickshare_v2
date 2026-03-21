import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";

interface GenerateQRResult {
  qr_code: string;
  expires_at: string;
}

interface QRValidationResult {
  shipment_id: string;
  validation_type: 'delivery' | 'return';
  is_valid: boolean;
  error_message: string | null;
  shipment_info: {
    assignment_id: string;
    set_id: string;
    set_name: string;
    set_number: string;
    theme: string;
    status: string;
    brickshare_pudo_id: string;
  };
}

interface BricksharePudoLocation {
  id: string;
  name: string;
  address: string;
  city: string;
  postal_code: string;
  province: string;
  latitude: number | null;
  longitude: number | null;
  contact_phone: string | null;
  contact_email: string | null;
  opening_hours: any;
  is_active: boolean;
}

export const useBrickshareShipments = () => {
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Fetch Brickshare PUDO locations
  const { data: pudoLocations, isLoading: isLoadingLocations } = useQuery({
    queryKey: ['brickshare-pudo-locations'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('brickshare_pudo_locations')
        .select('*')
        .eq('is_active', true)
        .order('name');

      if (error) throw error;
      return data as BricksharePudoLocation[];
    },
  });

  // Generate delivery QR code
  const generateDeliveryQR = useMutation({
    mutationFn: async (shipmentId: string) => {
      const { data, error } = await supabase.rpc('generate_delivery_qr', {
        p_shipment_id: shipmentId,
      });

      if (error) throw error;
      return data[0] as GenerateQRResult;
    },
    onSuccess: (data, shipmentId) => {
      queryClient.invalidateQueries({ queryKey: ['shipments'] });
      queryClient.invalidateQueries({ queryKey: ['shipment', shipmentId] });
      toast({
        title: "QR de entrega generado",
        description: "El código QR se ha enviado por email al usuario",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error al generar QR",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  // Generate return QR code
  const generateReturnQR = useMutation({
    mutationFn: async (shipmentId: string) => {
      const { data, error } = await supabase.rpc('generate_return_qr', {
        p_shipment_id: shipmentId,
      });

      if (error) throw error;
      return data[0] as GenerateQRResult;
    },
    onSuccess: (data, shipmentId) => {
      queryClient.invalidateQueries({ queryKey: ['shipments'] });
      queryClient.invalidateQueries({ queryKey: ['shipment', shipmentId] });
      toast({
        title: "QR de devolución generado",
        description: "El código QR se ha enviado por email al usuario",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error al generar QR",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  // Validate QR code
  const validateQRCode = async (qrCode: string): Promise<QRValidationResult> => {
    const { data, error } = await supabase.rpc('validate_qr_code', {
      p_qr_code: qrCode,
    });

    if (error) throw error;
    return data[0] as QRValidationResult;
  };

  // Confirm QR validation
  const confirmQRValidation = useMutation({
    mutationFn: async ({ 
      qrCode, 
      validatedBy 
    }: { 
      qrCode: string; 
      validatedBy?: string 
    }) => {
      const { data, error } = await supabase.rpc('confirm_qr_validation', {
        p_qr_code: qrCode,
        p_validated_by: validatedBy || null,
      });

      if (error) throw error;
      return data[0];
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['shipments'] });
      queryClient.invalidateQueries({ queryKey: ['shipment', data.shipment_id] });
      toast({
        title: "Validación exitosa",
        description: data.message,
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error en validación",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  // Update shipment to use Brickshare PUDO
  const updateToBricksharePudo = useMutation({
    mutationFn: async ({ 
      shipmentId, 
      pudoId 
    }: { 
      shipmentId: string; 
      pudoId: string 
    }) => {
      const { data, error } = await supabase
        .from('shipments')
        .update({
          pickup_type: 'brickshare',
          brickshare_pudo_id: pudoId,
          updated_at: new Date().toISOString(),
        })
        .eq('id', shipmentId)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['shipments'] });
      queryClient.invalidateQueries({ queryKey: ['shipment', data.id] });
      toast({
        title: "Punto de recogida actualizado",
        description: "Se ha configurado el punto Brickshare",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error al actualizar",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  return {
    pudoLocations,
    isLoadingLocations,
    generateDeliveryQR,
    generateReturnQR,
    validateQRCode,
    confirmQRValidation,
    updateToBricksharePudo,
  };
};