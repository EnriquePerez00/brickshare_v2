import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Printer, Tag, RefreshCw, Package, ShieldCheck } from "lucide-react";
import { toast } from "sonner";

// ── Cost configuration ─────────────────────────────────────────────────────────
// Shipping cost for Correos PUDO (in EUR). Must match the value used in
// process-assignment-payment Edge Function.
const COSTE_ENVIO_DEVOLUCION = 8;

interface PendingShipment {
    id: string;
    user_id: string;
    set_ref: string;
    pudo_type: string;
    delivery_qr_code: string;
    correos_shipment_id: string | null;
    swikly_wish_id: string | null;
    swikly_status: string | null;
    swikly_deposit_amount: number | null;
    users: {
        full_name: string | null;
        email: string | null;
    };
    sets: {
        set_name: string;
        set_ref: string;
        set_pvp_release: number | null;
    } | null;
}

// ── Swikly deposit helper ──────────────────────────────────────────────────────
// Creates a Swikly wish (deposit guarantee) for the shipment.
// Amount equals sets.set_pvp_release for the shipped set.
// Must succeed before the process can continue.
const createSwiklyDeposit = async (shipmentId: string): Promise<{ wish_id: string; wish_url: string; deposit_amount: number }> => {
    try {
        const { data, error } = await supabase.functions.invoke(
            'create-swikly-wish-shipment',
            { body: { shipment_id: shipmentId } }
        );

        if (error) {
            throw new Error(error.message || 'Error al crear la fianza Swikly');
        }

        if (!data?.success) {
            throw new Error(data?.error || 'Swikly no devolvió una respuesta válida');
        }

        // If skipped (already existed), that's OK
        if (data.skipped) {
            console.log(`ℹ️ Swikly wish already existed for shipment ${shipmentId}`);
        } else {
            console.log(`✅ Swikly wish created: ${data.wish_id} — €${(data.deposit_amount / 100).toFixed(2)}`);
        }

        return {
            wish_id: data.wish_id,
            wish_url: data.wish_url ?? '',
            deposit_amount: data.deposit_amount,
        };
    } catch (error: any) {
        console.error('❌ Error creando fianza Swikly:', error);
        throw new Error(`Error fianza Swikly: ${error.message}`);
    }
};

// Helper function to process payment for Correos PUDO users
const processCorreosPayment = async (userId: string, setRef: string): Promise<boolean> => {
    try {
        const { data: paymentResponse, error: paymentError } = await supabase.functions.invoke(
            'process-assignment-payment',
            {
                body: {
                    userId,
                    setRef,
                    pudoType: 'correos'
                }
            }
        );

        if (paymentError || !paymentResponse?.success) {
            throw new Error(paymentResponse?.error || paymentError?.message || 'Error en el pago');
        }

        console.log('✅ Pago procesado exitosamente para usuario:', userId);
        return true;
    } catch (error) {
        console.error('❌ Error en pago Correos:', error);
        throw error;
    }
};

// Print service helper - configured but not operational yet
const printLabelPDF = async (url: string, autoPrint: boolean = false) => {
    if (!autoPrint) {
        // Manual mode: open in new window
        window.open(url, '_blank');
        return;
    }

    // Auto-print mode (configured but disabled)
    // TODO: Enable when print infrastructure is ready
    console.log('[Auto-print] Would print:', url);
    
    // Future implementation:
    // const iframe = document.createElement('iframe');
    // iframe.style.display = 'none';
    // iframe.src = url;
    // document.body.appendChild(iframe);
    // iframe.onload = () => {
    //     iframe.contentWindow?.print();
    //     setTimeout(() => document.body.removeChild(iframe), 1000);
    // };
    
    // For now, fall back to manual
    window.open(url, '_blank');
};

const LabelGeneration = () => {
    const queryClient = useQueryClient();
    const [generatingIds, setGeneratingIds] = useState<Set<string>>(new Set());
    const [generatingAll, setGeneratingAll] = useState(false);

    // Fetch assigned shipments (ready for label generation)
    const { data: pendingShipments, isLoading } = useQuery({
        queryKey: ["pending-shipments"],
        queryFn: async () => {
            const { data, error } = await supabase
                .from("shipments")
                .select(`
                    id,
                    user_id,
                    set_ref,
                    pudo_type,
                    delivery_qr_code,
                    correos_shipment_id,
                    swikly_wish_id,
                    swikly_status,
                    swikly_deposit_amount,
                    users:user_id (
                        full_name,
                        email,
                        pudo_id,
                        pudo_type
                    )
                `)
                .eq("shipment_status", "assigned")
                .order("created_at", { ascending: true });

            if (error) throw error;

            // Fetch sets separately using set_ref
            if (data && data.length > 0) {
                const setRefs = [...new Set(data.map(s => s.set_ref))];
                const { data: setsData } = await supabase
                    .from("sets")
                    .select("set_name, set_ref, set_pvp_release")
                    .in("set_ref", setRefs);

                // Map sets data to shipments
                return data.map(shipment => ({
                    ...shipment,
                    sets: setsData?.find(s => s.set_ref === shipment.set_ref)
                })) as unknown as PendingShipment[];
            }

            return data as unknown as PendingShipment[];
        },
    });

    // Generate label for Correos PUDO
    const generateCorreosLabel = async (shipmentId: string) => {
        const shipment = pendingShipments?.find(s => s.id === shipmentId);
        if (!shipment) throw new Error('Shipment not found');

        // Step 1: Process shipping payment (required for Correos PUDO)
        console.log(`📤 Processing Correos shipping payment (€${COSTE_ENVIO_DEVOLUCION}) for shipment:`, shipmentId);
        await processCorreosPayment(shipment.user_id, shipment.set_ref);
        toast.info(`Pago de envío (€${COSTE_ENVIO_DEVOLUCION}) procesado correctamente`);

        // Step 2: Preregister if not already done
        if (!shipment?.correos_shipment_id) {
            const { data: preregData, error: preregError } = await supabase.functions.invoke(
                'correos-logistics',
                {
                    body: {
                        action: 'preregister',
                        p_shipment_id: shipmentId
                    }
                }
            );

            if (preregError) throw preregError;
            
            toast.info(`Preregistro completado: ${preregData.correos_shipment_id}`);
        }

        // Step 3: Get label PDF
        const { data: labelData, error: labelError } = await supabase.functions.invoke(
            'correos-logistics',
            {
                body: {
                    action: 'get_label',
                    p_shipment_id: shipmentId
                }
            }
        );

        if (labelError) throw labelError;

        // Step 4: Print label (manual mode for now)
        if (labelData.label_url) {
            printLabelPDF(labelData.label_url, false);
        }

        return labelData;
    };

    // Generate label for Brickshare PUDO
    const generateBrickshareLabel = async (shipmentId: string) => {
        const shipment = pendingShipments?.find(s => s.id === shipmentId);
        
        // Check if QR code exists, generate if missing
        if (!shipment?.delivery_qr_code) {
            console.log('Delivery QR code missing, generating...');
            const qrCode = `BS-DEL-${shipmentId.substring(0, 12).toUpperCase()}`;
            
            const { error: updateError } = await supabase
                .from('shipments')
                .update({ delivery_qr_code: qrCode })
                .eq('id', shipmentId);
            
            if (updateError) {
                throw new Error(`Error generando código QR: ${updateError.message}`);
            }
            
            console.log('QR code generated:', qrCode);
        }

        // Send QR email to user and generate PUDO reception label
        const { data, error } = await supabase.functions.invoke(
            'send-brickshare-qr-email',
            {
                body: {
                    shipment_id: shipmentId,
                    type: 'delivery'
                }
            }
        );

        if (error) {
            console.error('QR Email Error:', error);
            throw new Error(`Error enviando email QR: ${error.message || 'Error desconocido'}`);
        }

        toast.success('Email con QR enviado al usuario');
        
        // Store the label HTML for printing
        if (data?.label_html) {
            // Store in session storage for printing in new window
            sessionStorage.setItem(`label-${shipmentId}`, data.label_html);
            
            // Trigger print window after a short delay
            setTimeout(() => {
                openLabelPrintWindow(shipmentId, data.label_html);
            }, 500);
        }
        
        return data;
    };

    // Open label in print-friendly window
    const openLabelPrintWindow = (shipmentId: string, labelHTML: string) => {
        const printWindow = window.open('', `print-label-${shipmentId}`, 'width=400,height=300');
        if (printWindow) {
            printWindow.document.write(labelHTML);
            printWindow.document.close();
            
            // Trigger print dialog after content loads
            setTimeout(() => {
                printWindow.print();
            }, 250);
        }
    };

    // Update shipment status
    const updateShipmentStatus = async (shipmentId: string) => {
        const { error } = await supabase
            .from('shipments')
            .update({
                shipment_status: 'in_transit_pudo',
                updated_at: new Date().toISOString()
            })
            .eq('id', shipmentId);

        if (error) throw error;
    };

    // Single label generation mutation
    const generateSingleMutation = useMutation({
        mutationFn: async (shipment: PendingShipment) => {
            setGeneratingIds(prev => new Set(prev).add(shipment.id));

            try {
                // ── STEP 0: Create Swikly deposit (MANDATORY for ALL pudo types) ──
                console.log('🔒 Creating Swikly deposit for shipment:', shipment.id);
                const depositInfo = await createSwiklyDeposit(shipment.id);
                toast.info(
                    `Fianza Swikly creada (€${(depositInfo.deposit_amount / 100).toFixed(2)})`,
                    { description: `Wish ID: ${depositInfo.wish_id}` }
                );

                // ── STEP 1: Generate label based on PUDO type ─────────────────────
                if (shipment.pudo_type === 'correos') {
                    await generateCorreosLabel(shipment.id);
                } else if (shipment.pudo_type === 'brickshare') {
                    await generateBrickshareLabel(shipment.id);
                } else {
                    throw new Error(`Tipo de PUDO desconocido: ${shipment.pudo_type}`);
                }

                // Update status
                await updateShipmentStatus(shipment.id);

                return shipment;
            } finally {
                setGeneratingIds(prev => {
                    const next = new Set(prev);
                    next.delete(shipment.id);
                    return next;
                });
            }
        },
        onSuccess: (shipment) => {
            const pudoTypeLabel = shipment.pudo_type === 'brickshare' ? 'Email con QR' : 'Etiqueta';
            toast.success(`${pudoTypeLabel} generada para ${shipment.users?.full_name}`);
            queryClient.invalidateQueries({ queryKey: ["pending-shipments"] });
            queryClient.invalidateQueries({ queryKey: ["admin-shipments"] });
        },
        onError: (error: Error, shipment) => {
            console.error('Label generation error:', error);
            
            let errorMessage = error.message;
            
            // Provide more specific error messages
            if (errorMessage.includes('Swikly') || errorMessage.includes('fianza')) {
                errorMessage = `Error de fianza para ${shipment.users?.full_name}: ${error.message}`;
            } else if (errorMessage.includes('set_pvp_release')) {
                errorMessage = `El set ${shipment.set_ref} no tiene precio PVP configurado. Actualiza el set antes de generar la etiqueta.`;
            } else if (errorMessage.includes('PUDO')) {
                errorMessage = `${shipment.users?.full_name} no tiene punto PUDO configurado`;
            } else if (errorMessage.includes('QR')) {
                errorMessage = `Error generando código QR para ${shipment.users?.full_name}`;
            } else if (errorMessage.includes('email')) {
                errorMessage = `Error enviando email a ${shipment.users?.full_name}`;
            } else if (errorMessage.includes('non-2xx')) {
                errorMessage = `Error del servidor al procesar ${shipment.users?.full_name}. Verifica los datos del envío.`;
            } else if (errorMessage.includes('non-2xx status code') || errorMessage.includes('Unauthorized')) {
                errorMessage = `Error de pago para ${shipment.users?.full_name}. Verifica su configuración de Stripe y tarjeta de crédito.`;
            }
            
            toast.error(`Error: ${errorMessage}`, {
                description: 'Verifica que el usuario tenga todos los datos necesarios'
            });
        },
    });

    // Batch generation mutation
    const generateAllMutation = useMutation({
        mutationFn: async () => {
            if (!pendingShipments || pendingShipments.length === 0) {
                throw new Error("No hay envíos pendientes");
            }

            setGeneratingAll(true);
            const results = {
                success: 0,
                failed: 0,
                errors: [] as string[]
            };

            for (const shipment of pendingShipments) {
                try {
                    console.log(`Processing shipment ${shipment.id} for ${shipment.users?.full_name}`);

                    // STEP 0: Create Swikly deposit (MANDATORY for ALL pudo types)
                    console.log('🔒 Creating Swikly deposit for shipment:', shipment.id);
                    await createSwiklyDeposit(shipment.id);
                    
                    // STEP 1: Generate label based on PUDO type
                    if (shipment.pudo_type === 'correos') {
                        await generateCorreosLabel(shipment.id);
                    } else if (shipment.pudo_type === 'brickshare') {
                        await generateBrickshareLabel(shipment.id);
                    }

                    // Update status
                    await updateShipmentStatus(shipment.id);

                    results.success++;
                } catch (error: any) {
                    results.failed++;
                    results.errors.push(`${shipment.users?.full_name}: ${error.message}`);
                    console.error(`Error processing shipment ${shipment.id}:`, error);
                }
            }

            return results;
        },
        onSuccess: (results) => {
            setGeneratingAll(false);
            
            if (results.failed === 0) {
                toast.success(`¡Todas las etiquetas generadas! (${results.success})`);
            } else {
                toast.warning(
                    `Proceso completado: ${results.success} exitosas, ${results.failed} fallidas`,
                    {
                        description: results.errors.length > 0 ? results.errors[0] : undefined
                    }
                );
            }

            queryClient.invalidateQueries({ queryKey: ["pending-shipments"] });
            queryClient.invalidateQueries({ queryKey: ["admin-shipments"] });
        },
        onError: (error: Error) => {
            setGeneratingAll(false);
            toast.error(`Error al generar etiquetas: ${error.message}`);
        },
    });

    const getPudoBadge = (pudoType: string) => {
        if (pudoType === 'correos') {
            return <Badge variant="outline" className="bg-yellow-100 text-yellow-800 border-yellow-300">Correos</Badge>;
        } else if (pudoType === 'brickshare') {
            return <Badge variant="outline" className="bg-purple-100 text-purple-800 border-purple-300">Brickshare</Badge>;
        }
        return <Badge variant="outline">{pudoType}</Badge>;
    };

    if (isLoading) {
        return (
            <div className="flex justify-center py-12">
                <RefreshCw className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                        <CardTitle className="flex items-center gap-2">
                            <Tag className="h-5 w-5" />
                            Generación de Etiquetas
                        </CardTitle>
                        <p className="text-sm text-muted-foreground mt-1">
                            Procesa los envíos pendientes generando etiquetas y notificando a los usuarios
                        </p>
                    </div>
                    {pendingShipments && pendingShipments.length > 0 && (
                        <Button
                            onClick={() => generateAllMutation.mutate()}
                            disabled={generatingAll || generateSingleMutation.isPending}
                            className="bg-primary hover:bg-primary/90"
                        >
                            {generatingAll ? (
                                <>
                                    <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                                    Generando...
                                </>
                            ) : (
                                <>
                                    <Printer className="h-4 w-4 mr-2" />
                                    Generar Todas las Etiquetas ({pendingShipments.length})
                                </>
                            )}
                        </Button>
                    )}
                </CardHeader>
                <CardContent>
                    {!pendingShipments || pendingShipments.length === 0 ? (
                        <div className="text-center py-12 bg-muted/20 rounded-xl border border-dashed">
                            <Package className="h-12 w-12 mx-auto text-muted-foreground mb-4 opacity-50" />
                            <h3 className="text-lg font-medium text-foreground">
                                No hay envíos asignados pendientes de etiqueta
                            </h3>
                            <p className="text-muted-foreground mt-2">
                                Todos los envíos han sido procesados o no hay asignaciones confirmadas en estado "assigned".
                            </p>
                        </div>
                    ) : (
                        <>
                            <div className="rounded-md border">
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>Usuario</TableHead>
                                            <TableHead>Set (Ref)</TableHead>
                                            <TableHead className="text-center">Tipo PUDO</TableHead>
                                            <TableHead className="text-center">Fianza</TableHead>
                                            <TableHead className="text-center">QR/Código</TableHead>
                                            <TableHead className="text-right">Acción</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {pendingShipments.map((shipment) => {
                                            const isGenerating = generatingIds.has(shipment.id);
                                            
                                            return (
                                                <TableRow key={shipment.id}>
                                                    <TableCell className="font-medium">
                                                        <div className="flex flex-col">
                                                            <span>{shipment.users?.full_name || "Sin nombre"}</span>
                                                            <span className="text-xs text-muted-foreground">
                                                                {shipment.users?.email}
                                                            </span>
                                                        </div>
                                                    </TableCell>
                                                    <TableCell>
                                                        <div className="flex flex-col">
                                                            <span className="font-medium">{shipment.sets?.set_name}</span>
                                                            <span className="text-xs font-mono text-muted-foreground">
                                                                {shipment.sets?.set_ref}
                                                            </span>
                                                        </div>
                                                    </TableCell>
                                                    <TableCell className="text-center">
                                                        {getPudoBadge(shipment.pudo_type)}
                                                    </TableCell>
                                                    <TableCell className="text-center">
                                                        {shipment.swikly_wish_id ? (
                                                            <Badge variant="outline" className="bg-green-100 text-green-800 border-green-300 gap-1">
                                                                <ShieldCheck className="h-3 w-3" />
                                                                €{shipment.swikly_deposit_amount ? (shipment.swikly_deposit_amount / 100).toFixed(0) : '?'}
                                                            </Badge>
                                                        ) : (
                                                            <span className="text-xs text-muted-foreground">
                                                                Pendiente
                                                            </span>
                                                        )}
                                                    </TableCell>
                                                    <TableCell className="text-center">
                                                        {shipment.pudo_type === 'brickshare' && shipment.delivery_qr_code ? (
                                                            <code className="text-xs bg-muted px-2 py-1 rounded">
                                                                {shipment.delivery_qr_code.substring(0, 12)}...
                                                            </code>
                                                        ) : shipment.correos_shipment_id ? (
                                                            <code className="text-xs bg-muted px-2 py-1 rounded">
                                                                {shipment.correos_shipment_id}
                                                            </code>
                                                        ) : (
                                                            <span className="text-xs text-muted-foreground">
                                                                Pendiente
                                                            </span>
                                                        )}
                                                    </TableCell>
                                                    <TableCell className="text-right">
                                                        <Button
                                                            variant="outline"
                                                            size="sm"
                                                            onClick={() => generateSingleMutation.mutate(shipment)}
                                                            disabled={isGenerating || generatingAll}
                                                            className="gap-2"
                                                        >
                                                            {isGenerating ? (
                                                                <>
                                                                    <RefreshCw className="h-4 w-4 animate-spin" />
                                                                    Procesando...
                                                                </>
                                                            ) : (
                                                                <>
                                                                    <Printer className="h-4 w-4" />
                                                                    Generar Etiqueta
                                                                </>
                                                            )}
                                                        </Button>
                                                    </TableCell>
                                                </TableRow>
                                            );
                                        })}
                                    </TableBody>
                                </Table>
                            </div>
                        </>
                    )}
                </CardContent>
            </Card>
        </div>
    );
};

export default LabelGeneration;