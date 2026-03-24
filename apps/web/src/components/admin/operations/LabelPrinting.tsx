import { useState, useRef } from "react";
import { useReactToPrint } from "react-to-print";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { QRCodeSVG } from "qrcode.react";
import { useAssignedShipments, AssignedShipment } from "@/hooks/useAssignedShipments";
import {
  formatPudoAddress,
  getTrackingLastDigits,
  getShortReference,
  generateQRData,
  updateShipmentStatus,
  getPudoTypeLabel,
} from "@/lib/labelPrintService";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Printer, Package } from "lucide-react";
import { toast } from "sonner";

// Print label component
interface ShippingLabelProps {
  shipment: AssignedShipment;
}

const ShippingLabel = ({ shipment }: ShippingLabelProps) => {
  const pudoAddress = formatPudoAddress(shipment);
  const trackingDigits = getTrackingLastDigits(shipment.tracking_code);
  const shortRef = getShortReference(shipment.id);
  const qrData = generateQRData(shipment.id);
  const pudoTypeLabel = getPudoTypeLabel(shipment.pudo_type);

  return (
    <div className="label-container" style={{ pageBreakAfter: "always" }}>
      <div className="label-content">
        <div className="label-header">
          <h1>BRICKSHARE</h1>
          <div className="divider"></div>
        </div>
        
        <div className="label-section">
          <div className="label-icon">👤</div>
          <div className="label-text">
            <strong>{shipment.users?.full_name || "Usuario"}</strong>
          </div>
        </div>

        <div className="label-section">
          <div className="label-icon">📍</div>
          <div className="label-text">
            <div className="pudo-type">{pudoTypeLabel}</div>
            <div className="pudo-address">{pudoAddress}</div>
          </div>
        </div>

        <div className="label-section">
          <div className="label-icon">📦</div>
          <div className="label-text">
            <strong>Set: {shipment.set_ref}</strong>
          </div>
        </div>

        <div className="label-section ref-section">
          <div className="label-icon">🔢</div>
          <div className="label-text">
            <div className="ref-line">
              <span className="ref-label">REF:</span>
              <span className="ref-code">#{shortRef}</span>
            </div>
            <div className="tracking-line">
              <span className="tracking-label">Envío:</span>
              <span className="tracking-code">{trackingDigits}</span>
            </div>
          </div>
        </div>

        <div className="qr-section">
          <QRCodeSVG 
            value={qrData} 
            size={80}
            level="M"
            includeMargin={false}
          />
          <div className="qr-uuid">{shipment.id}</div>
        </div>
      </div>
    </div>
  );
};

// Multiple labels component
interface ShippingLabelsProps {
  shipments: AssignedShipment[];
}

const ShippingLabels = ({ shipments }: ShippingLabelsProps) => {
  return (
    <div>
      {shipments.map((shipment) => (
        <ShippingLabel key={shipment.id} shipment={shipment} />
      ))}
    </div>
  );
};

const LabelPrinting = () => {
  const { data: shipments, isLoading } = useAssignedShipments();
  const queryClient = useQueryClient();
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [selectedShipments, setSelectedShipments] = useState<string[]>([]);
  const [printMode, setPrintMode] = useState<"single" | "all">("single");
  
  const singleLabelRef = useRef<HTMLDivElement>(null);
  const allLabelsRef = useRef<HTMLDivElement>(null);

  // Update shipment status mutation
  const updateStatusMutation = useMutation({
    mutationFn: (shipmentIds: string[]) =>
      updateShipmentStatus(shipmentIds, "in_transit_pudo"),
    onSuccess: (_, shipmentIds) => {
      toast.success(
        `${shipmentIds.length} etiqueta(s) procesada(s). Estado actualizado a "En tránsito → PUDO"`
      );
      queryClient.invalidateQueries({ queryKey: ["assigned-shipments"] });
      queryClient.invalidateQueries({ queryKey: ["admin-shipments"] });
      setSelectedShipments([]);
      setConfirmDialogOpen(false);
    },
    onError: (error: Error) => {
      toast.error("Error al actualizar estado: " + error.message);
    },
  });

  // Print handlers
  const handlePrintSingle = useReactToPrint({
    contentRef: singleLabelRef,
    documentTitle: `etiqueta-${getTrackingLastDigits(
      shipments?.find((s) => s.id === selectedShipments[0])?.tracking_code || null
    )}`,
    onAfterPrint: () => {
      // Update status after printing
      updateStatusMutation.mutate(selectedShipments);
    },
  });

  const handlePrintAll = useReactToPrint({
    contentRef: allLabelsRef,
    documentTitle: `etiquetas-masivas-${new Date().toISOString().slice(0, 10)}`,
    onAfterPrint: () => {
      // Update all shipments status
      if (shipments) {
        updateStatusMutation.mutate(shipments.map((s) => s.id));
      }
    },
  });

  const onPrintSingleClick = (shipmentId: string) => {
    setSelectedShipments([shipmentId]);
    setPrintMode("single");
    setConfirmDialogOpen(true);
  };

  const onPrintAllClick = () => {
    if (shipments && shipments.length > 0) {
      setSelectedShipments(shipments.map((s) => s.id));
      setPrintMode("all");
      setConfirmDialogOpen(true);
    }
  };

  const confirmPrint = () => {
    setConfirmDialogOpen(false);
    // Trigger print after dialog closes
    setTimeout(() => {
      if (printMode === "single") {
        handlePrintSingle();
      } else {
        handlePrintAll();
      }
    }, 100);
  };

  if (isLoading) {
    return (
      <div className="animate-pulse space-y-4">
        {[1, 2, 3].map((i) => (
          <div key={i} className="h-12 bg-muted rounded"></div>
        ))}
      </div>
    );
  }

  if (!shipments || shipments.length === 0) {
    return (
      <div className="text-center py-12 bg-card rounded-xl border border-dashed border-border">
        <Package className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
        <p className="text-muted-foreground text-lg">
          No hay envíos con estado "Assigned" para imprimir etiquetas.
        </p>
        <p className="text-sm text-muted-foreground mt-2">
          Los envíos aparecerán aquí una vez se confirmen asignaciones en "Asignación de Sets".
        </p>
      </div>
    );
  }

  const selectedShipment = shipments.find((s) => s.id === selectedShipments[0]);

  return (
    <div className="space-y-4">
      {/* Header with Print All button */}
      <div className="flex items-center justify-between bg-card rounded-xl border border-border p-4">
        <div>
          <h3 className="text-lg font-semibold">Etiquetas de Envío</h3>
          <p className="text-sm text-muted-foreground mt-1">
            {shipments.length} etiqueta(s) lista(s) para imprimir
          </p>
        </div>
        <Button
          onClick={onPrintAllClick}
          className="bg-primary hover:bg-primary/90 gap-2"
          disabled={updateStatusMutation.isPending}
        >
          <Printer className="h-4 w-4" />
          Imprimir Todas ({shipments.length})
        </Button>
      </div>

      {/* Table with shipments */}
      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Usuario</TableHead>
              <TableHead>Set</TableHead>
              <TableHead>REF</TableHead>
              <TableHead>PUDO</TableHead>
              <TableHead className="text-right">Acciones</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {shipments.map((shipment) => (
              <TableRow key={shipment.id}>
                <TableCell className="font-medium">
                  {shipment.users?.full_name || shipment.users?.email || "-"}
                </TableCell>
                <TableCell>
                  <code className="text-xs">{shipment.set_ref}</code>
                </TableCell>
                <TableCell>
                  <code className="text-xs font-mono bg-muted px-2 py-1 rounded">
                    #{getShortReference(shipment.id)}
                  </code>
                </TableCell>
                <TableCell>
                  <Badge variant="outline">
                    {getPudoTypeLabel(shipment.pudo_type)}
                  </Badge>
                </TableCell>
                <TableCell className="text-right">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onPrintSingleClick(shipment.id)}
                    disabled={updateStatusMutation.isPending}
                    className="gap-2"
                  >
                    <Printer className="h-4 w-4" />
                    Imprimir
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* Hidden print components */}
      <div style={{ display: "none" }}>
        <div ref={singleLabelRef}>
          {selectedShipment && <ShippingLabel shipment={selectedShipment} />}
        </div>
        <div ref={allLabelsRef}>
          <ShippingLabels shipments={shipments} />
        </div>
      </div>

      {/* Confirmation Dialog */}
      <AlertDialog open={confirmDialogOpen} onOpenChange={setConfirmDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Confirmar Impresión de Etiquetas</AlertDialogTitle>
            <AlertDialogDescription>
              {printMode === "single" ? (
                <>
                  Vas a imprimir <strong>1 etiqueta</strong>. Tras la impresión,
                  el estado del envío se actualizará automáticamente a "En tránsito → PUDO".
                </>
              ) : (
                <>
                  Vas a imprimir <strong>{shipments.length} etiquetas</strong>. Tras la impresión,
                  el estado de todos los envíos se actualizará automáticamente a "En tránsito → PUDO".
                </>
              )}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction
              onClick={confirmPrint}
              className="bg-primary hover:bg-primary/90"
            >
              Imprimir
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Print Styles */}
      <style>{`
        @media print {
          body * {
            visibility: hidden;
          }
          
          .label-container,
          .label-container * {
            visibility: visible;
          }
          
          .label-container {
            position: absolute;
            left: 0;
            top: 0;
            width: 10cm;
            height: 5cm;
            margin: 0;
            padding: 0;
          }
        }
        
        .label-container {
          width: 10cm;
          height: 5cm;
          padding: 0.4cm;
          box-sizing: border-box;
          font-family: Arial, sans-serif;
          border: 2px solid #000;
          margin-bottom: 0.5cm;
          display: flex;
          flex-direction: column;
        }
        
        .label-content {
          display: flex;
          flex-direction: column;
          height: 100%;
        }
        
        .label-header {
          text-align: center;
          margin-bottom: 4px;
        }
        
        .label-header h1 {
          margin: 0;
          font-size: 16px;
          font-weight: bold;
          letter-spacing: 2px;
        }
        
        .divider {
          height: 2px;
          background: #000;
          margin: 3px 0;
        }
        
        .label-section {
          display: flex;
          align-items: flex-start;
          gap: 6px;
          margin: 3px 0;
        }
        
        .label-icon {
          font-size: 14px;
          min-width: 18px;
        }
        
        .label-text {
          flex: 1;
          font-size: 10px;
          line-height: 1.2;
        }
        
        .label-text strong {
          font-size: 11px;
        }
        
        .pudo-type {
          font-weight: bold;
          margin-bottom: 2px;
        }
        
        .pudo-address {
          white-space: pre-line;
          color: #333;
        }
        
        .ref-section {
          margin-top: auto;
          padding-top: 3px;
          border-top: 1px solid #ccc;
        }
        
        .ref-line,
        .tracking-line {
          display: flex;
          gap: 6px;
          margin: 2px 0;
        }
        
        .ref-label,
        .tracking-label {
          font-size: 9px;
          color: #666;
        }
        
        .ref-code {
          font-size: 12px;
          font-weight: bold;
          font-family: 'Courier New', monospace;
        }
        
        .tracking-code {
          font-size: 11px;
          font-weight: bold;
          font-family: 'Courier New', monospace;
          letter-spacing: 1px;
        }
        
        .qr-section {
          display: flex;
          flex-direction: column;
          align-items: center;
          margin-top: 4px;
          padding-top: 4px;
          border-top: 2px solid #000;
        }
        
        .qr-section svg {
          display: block;
        }
        
        .qr-uuid {
          font-size: 6px;
          font-family: 'Courier New', monospace;
          color: #666;
          margin-top: 2px;
          word-break: break-all;
          text-align: center;
          max-width: 80px;
        }
      `}</style>
    </div>
  );
};

export default LabelPrinting;