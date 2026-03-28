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
import { Eye, CheckCircle, XCircle, Trash2, Package2, RefreshCw, UserCheck } from "lucide-react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
} from "@/components/ui/tooltip";

interface PreviewAssignment {
    user_id: string;
    user_name: string;
    set_id: string;
    set_name: string;
    set_ref: string;
    set_price: number;
    current_stock: number;
    matches_wishlist: boolean;
    pudo_type: string;
}

interface ConfirmedShipment {
    shipment_id: string;
    user_id: string;
    set_id: string;
    user_name: string;
    set_name: string;
    set_ref: string;
    set_price: number;
    correos_shipment_id?: string;
    label_url?: string;
    created_at: string;
}

interface PaymentErrorInfo {
    open: boolean;
    userName: string;
    userEmail: string;
    errorMessage: string;
    errorCode: string;
}

type ViewMode = "initial" | "preview" | "confirmed";

const SetAssignment = () => {
    const queryClient = useQueryClient();
    const [viewMode, setViewMode] = useState<ViewMode>("initial");
    const [previewAssignments, setPreviewAssignments] = useState<PreviewAssignment[]>([]);
    const [confirmedShipments, setConfirmedShipments] = useState<ConfirmedShipment[]>([]);
    const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
    const [envioToDelete, setEnvioToDelete] = useState<string | null>(null);
    const [paymentErrorDialog, setPaymentErrorDialog] = useState<PaymentErrorInfo>({
        open: false,
        userName: "",
        userEmail: "",
        errorMessage: "",
        errorCode: ""
    });
    const [confirmingUserId, setConfirmingUserId] = useState<string | null>(null);

    // Preview mutation - shows proposal without making changes
    const previewMutation = useMutation({
        mutationFn: async () => {
            const { data, error } = await supabase.rpc("preview_assign_sets_to_users");
            if (error) throw error;
            return data as PreviewAssignment[];
        },
        onSuccess: (data: PreviewAssignment[]) => {
            console.log('🔍 [DEBUG] Preview assignments received from SQL:', data);
            if (data.length > 0) {
                setPreviewAssignments(data);
                setViewMode("preview");
                toast.success(`Se encontraron ${data.length} asignaciones posibles`);
            } else {
                toast.info("No se encontraron asignaciones posibles (sin usuarios elegibles o sin stock)");
            }
        },
        onError: (error: Error) => {
            toast.error("Error al generar propuesta: " + error.message);
        },
    });

    // Confirm mutation - assigns sets without payment (payment happens at label printing)
    const confirmMutation = useMutation({
        mutationFn: async (assignments: PreviewAssignment[]) => {
            const userIds = assignments.map(a => a.user_id);
            const { data, error } = await supabase.rpc("confirm_assign_sets_to_users", {
                p_user_ids: userIds,
            });

            if (error) {
                throw new Error(`Error al confirmar asignaciones: ${error.message}`);
            }

            return data as ConfirmedShipment[];
        },
        onSuccess: (data: ConfirmedShipment[]) => {
            setConfirmedShipments(data);
            setViewMode("confirmed");
            setPreviewAssignments([]);
            toast.success(`¡Éxito! Se crearon ${data.length} asignaciones. Los pagos se procesarán al imprimir etiquetas.`);

            queryClient.invalidateQueries({ queryKey: ["admin-set-assignment-inventory"] });
            queryClient.invalidateQueries({ queryKey: ["admin-shipments"] });
        },
        onError: (error: any) => {
            toast.error("Error al confirmar asignaciones: " + (error.message || error));
        },
    });

    // Delete mutation - removes confirmed assignment with rollback
    // Confirm single user mutation
    const confirmSingleMutation = useMutation({
        mutationFn: async (assignment: PreviewAssignment) => {
            const { data, error } = await supabase.rpc("confirm_assign_sets_to_users", {
                p_user_ids: [assignment.user_id],
            });

            if (error) {
                throw new Error(`Error al confirmar asignación: ${error.message}`);
            }

            return { shipment: data[0] as ConfirmedShipment, pudoType: assignment.pudo_type };
        },
        onSuccess: ({ shipment, pudoType }) => {
            // Add to confirmed shipments
            setConfirmedShipments(prev => [...prev, shipment]);
            
            // Remove from preview assignments
            setPreviewAssignments(prev => prev.filter(a => a.user_id !== shipment.user_id));
            
            toast.success(`¡Asignación confirmada para ${shipment.user_name}! El pago se procesará al imprimir la etiqueta.`);

            queryClient.invalidateQueries({ queryKey: ["admin-set-assignment-inventory"] });
            queryClient.invalidateQueries({ queryKey: ["admin-shipments"] });
            
            setConfirmingUserId(null);
        },
        onError: (error: any) => {
            setConfirmingUserId(null);
            toast.error("Error al confirmar asignación: " + (error.message || error));
        },
    });

    const deleteMutation = useMutation({
        mutationFn: async (envioId: string) => {
            const { error } = await supabase.rpc("delete_assignment_and_rollback", {
                p_envio_id: envioId,
            });
            if (error) throw error;
        },
        onSuccess: () => {
            toast.success("Asignación eliminada correctamente");
            if (envioToDelete) {
                setConfirmedShipments((prev) => prev.filter((e) => e.shipment_id !== envioToDelete));
            }
            queryClient.invalidateQueries({ queryKey: ["admin-set-assignment-inventory"] });
            queryClient.invalidateQueries({ queryKey: ["admin-shipments"] });
        },
        onError: (error: Error) => {
            toast.error("Error al eliminar asignación: " + error.message);
        },
    });

    const handleGenerateProposal = () => {
        setConfirmedShipments([]);
        previewMutation.mutate();
    };

    const handleConfirmAllAssignments = () => {
        confirmMutation.mutate(previewAssignments);
    };

    const handleConfirmSingleAssignment = (assignment: PreviewAssignment) => {
        setConfirmingUserId(assignment.user_id);
        confirmSingleMutation.mutate(assignment);
    };

    const handleCancelPreview = () => {
        setPreviewAssignments([]);
        setViewMode("initial");
        toast.info("Propuesta cancelada");
    };

    const handleDeleteClick = (envioId: string) => {
        setEnvioToDelete(envioId);
        setDeleteConfirmOpen(true);
    };

    const handleDeleteConfirm = () => {
        if (envioToDelete) {
            deleteMutation.mutate(envioToDelete);
        }
        setDeleteConfirmOpen(false);
        setEnvioToDelete(null);
    };

    return (
        <div className="space-y-6">
            <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                        <CardTitle data-testid="assignment-title">Asignación Automática de Sets</CardTitle>
                        <p className="text-sm text-muted-foreground mt-1" data-testid="assignment-subtitle">
                            {viewMode === "initial" && "Genera una propuesta de asignaciones basada en wishlists y stock disponible"}
                            {viewMode === "preview" && "Revisa la propuesta y confírmala o cancélala"}
                            {viewMode === "confirmed" && "Asignaciones confirmadas - puedes eliminar aquí si es necesario"}
                        </p>
                    </div>
                    <div className="flex gap-2">
                        {viewMode === "initial" && (
                            <Button
                                onClick={handleGenerateProposal}
                                disabled={previewMutation.isPending}
                                className="bg-primary hover:bg-primary/90"
                                data-testid="assignment-generate-preview-button"
                            >
                                {previewMutation.isPending ? (
                                    <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                                ) : (
                                    <Eye className="h-4 w-4 mr-2" />
                                )}
                                Genera propuesta de asignación
                            </Button>
                        )}
                        {viewMode === "preview" && (
                            <>
                                <Button
                                    onClick={handleCancelPreview}
                                    variant="outline"
                                    disabled={confirmMutation.isPending}
                                    data-testid="assignment-cancel-preview-button"
                                >
                                    <XCircle className="h-4 w-4 mr-2" />
                                    Cancelar
                                </Button>
                                <Button
                                    onClick={handleConfirmAllAssignments}
                                    disabled={confirmMutation.isPending || confirmSingleMutation.isPending}
                                    className="bg-green-600 hover:bg-green-700"
                                    data-testid="assignment-confirm-button"
                                >
                                    {confirmMutation.isPending ? (
                                        <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                                    ) : (
                                        <CheckCircle className="h-4 w-4 mr-2" />
                                    )}
                                    Confirmar asignaciones (todas)
                                </Button>
                            </>
                        )}
                        {viewMode === "confirmed" && (
                            <Button
                                onClick={() => setViewMode("initial")}
                                variant="outline"
                                data-testid="assignment-new-proposal-button"
                            >
                                <RefreshCw className="h-4 w-4 mr-2" />
                                Nueva propuesta
                            </Button>
                        )}
                    </div>
                </CardHeader>
                <CardContent>
                    {viewMode === "initial" && (
                        <div className="text-center py-12" data-testid="assignment-initial-state">
                            <Package2 className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                            <p className="text-muted-foreground">
                                Haz clic en "Genera propuesta de asignación" para ver qué sets se asignarían.
                            </p>
                        </div>
                    )}

                    {viewMode === "preview" && (
                        <div data-testid="assignment-preview-content">
                            <div className="mb-4 p-4 bg-blue-50 dark:bg-blue-950 rounded-lg border border-blue-200 dark:border-blue-800">
                                <p className="text-sm text-blue-900 dark:text-blue-100">
                                    <strong>Vista previa:</strong> Esta es una propuesta. No se han realizado cambios en la base de datos.
                                    Revisa las asignaciones y confirma o cancela.
                                </p>
                            </div>
                            <div className="rounded-md border">
                                <Table data-testid="assignment-preview-table">
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>Usuario</TableHead>
                                            <TableHead>Set Propuesto (Ref)</TableHead>
                                            <TableHead className="text-center">Stock Actual</TableHead>
                                            <TableHead className="text-right">Confirmar Individual</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {previewAssignments.map((assignment) => (
                                            <TableRow key={assignment.user_id} data-testid={`assignment-row-${assignment.user_id}`}>
                                                <TableCell className="font-medium">
                                                    {assignment.user_name}
                                                </TableCell>
                                                <TableCell>
                                                    {assignment.set_name} ({assignment.set_ref})
                                                </TableCell>
                                                <TableCell className="text-center">
                                                    <Badge variant="outline">{assignment.current_stock} disponible</Badge>
                                                </TableCell>
                                                <TableCell className="text-right">
                                                    <Button
                                                        variant="outline"
                                                        size="sm"
                                                        onClick={() => handleConfirmSingleAssignment(assignment)}
                                                        disabled={confirmMutation.isPending || confirmSingleMutation.isPending || confirmingUserId === assignment.user_id}
                                                        className="text-green-600 border-green-600 hover:bg-green-600 hover:text-white"
                                                        data-testid={`confirm-single-${assignment.user_id}`}
                                                    >
                                                        {confirmingUserId === assignment.user_id ? (
                                                            <>
                                                                <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
                                                                Procesando...
                                                            </>
                                                        ) : (
                                                            <>
                                                                <UserCheck className="h-4 w-4 mr-2" />
                                                                Confirmar
                                                            </>
                                                        )}
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </div>
                        </div>
                    )}

                    {viewMode === "confirmed" && (
                        <div data-testid="assignment-confirmed-content">
                            {confirmedShipments.length === 0 ? (
                                <div className="text-center py-12">
                                    <Package2 className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                                    <p className="text-muted-foreground">
                                        No hay asignaciones confirmadas.
                                    </p>
                                </div>
                            ) : (
                                <div className="rounded-md border">
                                    <Table data-testid="assignment-confirmed-table">
                                        <TableHeader>
                                            <TableRow>
                                                <TableHead>Usuario</TableHead>
                                                <TableHead>Set (Ref)</TableHead>
                                                <TableHead>Fecha</TableHead>
                                                <TableHead className="text-center">Acciones</TableHead>
                                            </TableRow>
                                        </TableHeader>
                                        <TableBody>
                                            {confirmedShipments.map((shipment) => (
                                                <TableRow key={shipment.shipment_id} data-testid={`confirmed-shipment-row-${shipment.shipment_id}`}>
                                                    <TableCell className="font-medium">
                                                        {shipment.user_name}
                                                    </TableCell>
                                                    <TableCell>
                                                        {shipment.set_name} ({shipment.set_ref})
                                                    </TableCell>
                                                    <TableCell>
                                                        <div className="flex flex-col gap-1">
                                                            <span>{new Date(shipment.created_at).toLocaleDateString()}</span>
                                                            {shipment.correos_shipment_id && (
                                                                <Badge variant="outline" className="w-fit text-[10px] font-mono">
                                                                    {shipment.correos_shipment_id}
                                                                </Badge>
                                                            )}
                                                        </div>
                                                    </TableCell>
                                                    <TableCell className="text-center">
                                                        <div className="flex justify-center gap-1" data-testid={`shipment-actions-${shipment.shipment_id}`}>
                                                            {shipment.correos_shipment_id ? (
                                                                <Button
                                                                    variant="ghost"
                                                                    size="sm"
                                                                    onClick={() => {
                                                                        supabase.functions.invoke('correos-logistics', {
                                                                            body: { action: 'get_label', p_shipment_id: shipment.shipment_id }
                                                                        }).then(({ data }) => {
                                                                            if (data?.label_url) window.open(data.label_url, '_blank');
                                                                        });
                                                                    }}
                                                                    className="text-blue-600 hover:text-blue-700 hover:bg-blue-50"
                                                                    data-testid={`shipment-label-button-${shipment.shipment_id}`}
                                                                >
                                                                    <Package2 className="h-4 w-4 mr-1" />
                                                                    Etiqueta
                                                                </Button>
                                                            ) : (
                                                                <Button
                                                                    variant="ghost"
                                                                    size="sm"
                                                                    onClick={() => {
                                                                        toast.info("Reintentando preregistro...");
                                                                        supabase.functions.invoke('correos-logistics', {
                                                                            body: { action: 'preregister', p_shipment_id: shipment.shipment_id }
                                                                        }).then(() => toast.success("Preregistro solicitado"));
                                                                    }}
                                                                    data-testid={`shipment-retry-button-${shipment.shipment_id}`}
                                                                >
                                                                    <RefreshCw className="h-4 w-4" />
                                                                </Button>
                                                            )}
                                                            <Button
                                                                variant="ghost"
                                                                size="sm"
                                                                onClick={() => handleDeleteClick(shipment.shipment_id)}
                                                                disabled={deleteMutation.isPending}
                                                                className="text-destructive hover:text-destructive hover:bg-destructive/10"
                                                                data-testid={`shipment-delete-button-${shipment.shipment_id}`}
                                                            >
                                                                <Trash2 className="h-4 w-4" />
                                                            </Button>
                                                        </div>
                                                    </TableCell>
                                                </TableRow>
                                            ))}
                                        </TableBody>
                                    </Table>
                                </div>
                            )}
                        </div>
                    )}
                </CardContent>
            </Card>

            <AlertDialog open={deleteConfirmOpen} onOpenChange={setDeleteConfirmOpen}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>¿Eliminar asignación?</AlertDialogTitle>
                        <AlertDialogDescription>
                            Esta acción eliminará el envío, el pedido asociado y devolverá el set al inventario.
                            El estado del usuario se actualizará a "no_set".
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Cancelar</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDeleteConfirm}
                            className="bg-destructive hover:bg-destructive/90"
                        >
                            Eliminar
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>

        </div>
    );
};

export default SetAssignment;
