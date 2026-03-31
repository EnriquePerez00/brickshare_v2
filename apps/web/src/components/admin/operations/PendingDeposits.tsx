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
import { Badge } from "@/components/ui/badge";
import { ShieldAlert, Mail, Trash2, RefreshCw, ExternalLink, Clock } from "lucide-react";
import { toast } from "sonner";
import { formatDistanceToNow } from "date-fns";
import { es } from "date-fns/locale";

interface PendingDeposit {
    id: string;
    user_id: string;
    set_ref: string;
    pudo_type: string;
    swikly_wish_id: string | null;
    swikly_wish_url: string | null;
    swikly_status: string | null;
    swikly_deposit_amount: number | null;
    created_at: string;
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

const PendingDeposits = () => {
    const queryClient = useQueryClient();
    const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
    const [shipmentToDelete, setShipmentToDelete] = useState<string | null>(null);
    const [resendingIds, setResendingIds] = useState<Set<string>>(new Set());

    const { data: pendingDeposits, isLoading } = useQuery({
        queryKey: ["pending-deposits"],
        queryFn: async () => {
            const { data, error } = await supabase
                .from("shipments")
                .select(`
                    id,
                    user_id,
                    set_ref,
                    pudo_type,
                    swikly_wish_id,
                    swikly_wish_url,
                    swikly_status,
                    swikly_deposit_amount,
                    created_at,
                    users:user_id (
                        full_name,
                        email
                    )
                `)
                .eq("shipment_status", "assigned")
                .in("swikly_status", ["pending", "wish_created"])
                .order("created_at", { ascending: false });

            if (error) throw error;

            if (data && data.length > 0) {
                const setRefs = [...new Set(data.map(s => s.set_ref))];
                const { data: setsData } = await supabase
                    .from("sets")
                    .select("set_name, set_ref, set_pvp_release")
                    .in("set_ref", setRefs);

                return data.map(shipment => ({
                    ...shipment,
                    sets: setsData?.find(s => s.set_ref === shipment.set_ref)
                })) as unknown as PendingDeposit[];
            }

            return data as unknown as PendingDeposit[];
        },
    });

    const resendEmailMutation = useMutation({
        mutationFn: async (shipmentId: string) => {
            const { data, error } = await supabase.functions.invoke(
                'create-swikly-wish-shipment',
                { body: { shipment_id: shipmentId } }
            );

            if (error) throw error;
            return data;
        },
        onSuccess: () => {
            toast.success("Email de garantía reenviado correctamente");
            queryClient.invalidateQueries({ queryKey: ["pending-deposits"] });
        },
        onError: (error: Error) => {
            toast.error(`Error al reenviar email: ${error.message}`);
        },
    });

    const deleteMutation = useMutation({
        mutationFn: async (shipmentId: string) => {
            const { error } = await supabase.rpc("delete_assignment_and_rollback", {
                p_envio_id: shipmentId,
            });
            if (error) throw error;
        },
        onSuccess: () => {
            toast.success("Asignación cancelada correctamente");
            queryClient.invalidateQueries({ queryKey: ["pending-deposits"] });
            queryClient.invalidateQueries({ queryKey: ["pending-shipments"] });
        },
        onError: (error: Error) => {
            toast.error(`Error al cancelar asignación: ${error.message}`);
        },
    });

    const handleResendEmail = (shipmentId: string) => {
        setResendingIds(prev => new Set(prev).add(shipmentId));
        resendEmailMutation.mutate(shipmentId, {
            onSettled: () => {
                setResendingIds(prev => {
                    const next = new Set(prev);
                    next.delete(shipmentId);
                    return next;
                });
            }
        });
    };

    const handleDeleteClick = (shipmentId: string) => {
        setShipmentToDelete(shipmentId);
        setDeleteConfirmOpen(true);
    };

    const handleDeleteConfirm = () => {
        if (shipmentToDelete) {
            deleteMutation.mutate(shipmentToDelete);
        }
        setDeleteConfirmOpen(false);
        setShipmentToDelete(null);
    };

    const getStatusBadge = (status: string | null) => {
        if (status === "wish_created") {
            return <Badge variant="outline" className="bg-yellow-100 text-yellow-800 border-yellow-300">Creada</Badge>;
        } else if (status === "pending") {
            return <Badge variant="outline" className="bg-gray-100 text-gray-800 border-gray-300">Pendiente</Badge>;
        }
        return <Badge variant="outline">{status}</Badge>;
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
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <ShieldAlert className="h-5 w-5" />
                        Garantías Swikly Pendientes
                    </CardTitle>
                    <p className="text-sm text-muted-foreground mt-1">
                        Envíos asignados esperando confirmación de garantía por parte del usuario
                    </p>
                </CardHeader>
                <CardContent>
                    {!pendingDeposits || pendingDeposits.length === 0 ? (
                        <div className="text-center py-12 bg-muted/20 rounded-xl border border-dashed">
                            <ShieldAlert className="h-12 w-12 mx-auto text-muted-foreground mb-4 opacity-50" />
                            <h3 className="text-lg font-medium text-foreground">
                                No hay garantías pendientes
                            </h3>
                            <p className="text-muted-foreground mt-2">
                                Todos los usuarios han confirmado sus garantías Swikly o no hay asignaciones pendientes.
                            </p>
                        </div>
                    ) : (
                        <div className="rounded-md border">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Usuario</TableHead>
                                        <TableHead>Set (Ref)</TableHead>
                                        <TableHead className="text-center">Estado</TableHead>
                                        <TableHead className="text-center">Monto</TableHead>
                                        <TableHead className="text-center">Creada</TableHead>
                                        <TableHead className="text-right">Acciones</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {pendingDeposits.map((deposit) => {
                                        const isResending = resendingIds.has(deposit.id);
                                        const timeSinceCreated = formatDistanceToNow(new Date(deposit.created_at), { addSuffix: true, locale: es });
                                        
                                        return (
                                            <TableRow key={deposit.id}>
                                                <TableCell className="font-medium">
                                                    <div className="flex flex-col">
                                                        <span>{deposit.users?.full_name || "Sin nombre"}</span>
                                                        <span className="text-xs text-muted-foreground">
                                                            {deposit.users?.email}
                                                        </span>
                                                    </div>
                                                </TableCell>
                                                <TableCell>
                                                    <div className="flex flex-col">
                                                        <span className="font-medium">{deposit.sets?.set_name}</span>
                                                        <span className="text-xs font-mono text-muted-foreground">
                                                            {deposit.sets?.set_ref}
                                                        </span>
                                                    </div>
                                                </TableCell>
                                                <TableCell className="text-center">
                                                    {getStatusBadge(deposit.swikly_status)}
                                                </TableCell>
                                                <TableCell className="text-center">
                                                    <span className="font-semibold">
                                                        €{deposit.swikly_deposit_amount ? (deposit.swikly_deposit_amount / 100).toFixed(0) : '0'}
                                                    </span>
                                                </TableCell>
                                                <TableCell className="text-center">
                                                    <div className="flex items-center justify-center gap-1 text-xs text-muted-foreground">
                                                        <Clock className="h-3 w-3" />
                                                        {timeSinceCreated}
                                                    </div>
                                                </TableCell>
                                                <TableCell className="text-right">
                                                    <div className="flex justify-end gap-1">
                                                        {deposit.swikly_wish_url && (
                                                            <Button
                                                                variant="ghost"
                                                                size="sm"
                                                                onClick={() => window.open(deposit.swikly_wish_url!, '_blank')}
                                                                className="text-blue-600 hover:text-blue-700 hover:bg-blue-50"
                                                            >
                                                                <ExternalLink className="h-4 w-4" />
                                                            </Button>
                                                        )}
                                                        <Button
                                                            variant="ghost"
                                                            size="sm"
                                                            onClick={() => handleResendEmail(deposit.id)}
                                                            disabled={isResending || resendEmailMutation.isPending}
                                                            className="text-green-600 hover:text-green-700 hover:bg-green-50"
                                                        >
                                                            {isResending ? (
                                                                <RefreshCw className="h-4 w-4 animate-spin" />
                                                            ) : (
                                                                <Mail className="h-4 w-4" />
                                                            )}
                                                        </Button>
                                                        <Button
                                                            variant="ghost"
                                                            size="sm"
                                                            onClick={() => handleDeleteClick(deposit.id)}
                                                            disabled={deleteMutation.isPending}
                                                            className="text-destructive hover:text-destructive hover:bg-destructive/10"
                                                        >
                                                            <Trash2 className="h-4 w-4" />
                                                        </Button>
                                                    </div>
                                                </TableCell>
                                            </TableRow>
                                        );
                                    })}
                                </TableBody>
                            </Table>
                        </div>
                    )}
                </CardContent>
            </Card>

            <AlertDialog open={deleteConfirmOpen} onOpenChange={setDeleteConfirmOpen}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>¿Cancelar asignación?</AlertDialogTitle>
                        <AlertDialogDescription>
                            Esta acción eliminará el envío y devolverá el set al inventario. El usuario será notificado.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Cancelar</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDeleteConfirm}
                            className="bg-destructive hover:bg-destructive/90"
                        >
                            Confirmar
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </div>
    );
};

export default PendingDeposits;
