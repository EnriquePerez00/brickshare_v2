import { useEffect, useState, useMemo } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import {
    Loader2,
    ShoppingCart,
    Package,
    RefreshCw,
    CheckCircle2,
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface MissingPieceRow {
    id: string;
    set_id: string;
    piece_ref: string;
    quantity: number;
    status: string;
    created_at: string;
}

interface GroupedPiece {
    piece_ref: string;
    total_quantity: number;
    occurrences: number; // número de registros distintos
    ids: string[];
}

const PurchasePiecesList = () => {
    const [pieces, setPieces] = useState<MissingPieceRow[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [isOrdering, setIsOrdering] = useState(false);
    const [selectedRefs, setSelectedRefs] = useState<Set<string>>(new Set());
    const { toast } = useToast();

    const fetchPendingPieces = async () => {
        setIsLoading(true);
        try {
            const { data, error } = await supabase
                .from("reception_missing_pieces" as any)
                .select("id, set_id, piece_ref, quantity, status, created_at")
                .eq("status", "pending")
                .order("piece_ref", { ascending: true });

            if (error) throw error;
            setPieces((data as any) || []);
            setSelectedRefs(new Set());
        } catch (error: any) {
            console.error("Error fetching pending pieces:", error);
            toast({
                title: "Error al cargar piezas",
                description: error.message || "No se pudieron cargar las piezas pendientes.",
                variant: "destructive",
            });
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchPendingPieces();
    }, []);

    // Agrupar piezas por piece_ref y sumar quantities
    const groupedPieces = useMemo<GroupedPiece[]>(() => {
        const map = new Map<string, GroupedPiece>();

        for (const piece of pieces) {
            const existing = map.get(piece.piece_ref);
            if (existing) {
                existing.total_quantity += piece.quantity;
                existing.occurrences += 1;
                existing.ids.push(piece.id);
            } else {
                map.set(piece.piece_ref, {
                    piece_ref: piece.piece_ref,
                    total_quantity: piece.quantity,
                    occurrences: 1,
                    ids: [piece.id],
                });
            }
        }

        return Array.from(map.values()).sort((a, b) =>
            a.piece_ref.localeCompare(b.piece_ref)
        );
    }, [pieces]);

    const totalPiecesCount = useMemo(
        () => groupedPieces.reduce((sum, g) => sum + g.total_quantity, 0),
        [groupedPieces]
    );

    const selectedCount = selectedRefs.size;
    const allSelected =
        groupedPieces.length > 0 && selectedRefs.size === groupedPieces.length;

    const toggleSelectAll = () => {
        if (allSelected) {
            setSelectedRefs(new Set());
        } else {
            setSelectedRefs(new Set(groupedPieces.map((g) => g.piece_ref)));
        }
    };

    const toggleSelect = (pieceRef: string) => {
        setSelectedRefs((prev) => {
            const next = new Set(prev);
            if (next.has(pieceRef)) {
                next.delete(pieceRef);
            } else {
                next.add(pieceRef);
            }
            return next;
        });
    };

    const selectedTotalQuantity = useMemo(() => {
        return groupedPieces
            .filter((g) => selectedRefs.has(g.piece_ref))
            .reduce((sum, g) => sum + g.total_quantity, 0);
    }, [groupedPieces, selectedRefs]);

    const handleGeneratePurchaseList = async () => {
        if (selectedRefs.size === 0) {
            toast({
                title: "Sin selección",
                description: "Selecciona al menos un tipo de pieza para generar el listado.",
                variant: "destructive",
            });
            return;
        }

        setIsOrdering(true);
        try {
            const pieceRefsArray = Array.from(selectedRefs);

            // TODO: En el futuro, aquí se generará un JSON para la aplicación de compra de piezas
            // const purchaseJson = groupedPieces
            //     .filter(g => selectedRefs.has(g.piece_ref))
            //     .map(g => ({ piece_ref: g.piece_ref, quantity: g.total_quantity }));

            const { data, error } = await supabase.rpc(
                "mark_pieces_as_ordered",
                {
                    p_piece_refs: pieceRefsArray,
                }
            );

            if (error) throw error;

            const result = data as any;
            if (!result.success) {
                throw new Error(result.error || "Error desconocido");
            }

            toast({
                title: "Listado de compra generado",
                description: `${result.updated_count} pieza(s) marcadas como "ordered". ${pieceRefsArray.length} referencia(s) procesada(s).`,
                className:
                    "bg-green-100 border-green-200 dark:bg-green-900/30 dark:border-green-800",
            });

            // Refrescar lista
            await fetchPendingPieces();
        } catch (error: any) {
            console.error("Error marking pieces as ordered:", error);
            toast({
                title: "Error",
                description:
                    error.message || "No se pudo generar el listado de compra.",
                variant: "destructive",
            });
        } finally {
            setIsOrdering(false);
        }
    };

    if (isLoading) {
        return (
            <div className="flex justify-center p-8">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    if (groupedPieces.length === 0) {
        return (
            <div className="text-center p-8 bg-muted/20 rounded-xl border border-dashed border-muted-foreground/30">
                <CheckCircle2 className="h-12 w-12 mx-auto text-green-500 mb-3 opacity-70" />
                <h3 className="text-lg font-medium text-foreground">
                    Sin piezas pendientes de compra
                </h3>
                <p className="text-muted-foreground">
                    No hay piezas faltantes con estado "pending" registradas.
                </p>
                <Button
                    variant="ghost"
                    size="sm"
                    onClick={fetchPendingPieces}
                    className="mt-4"
                >
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Actualizar
                </Button>
            </div>
        );
    }

    return (
        <div className="space-y-4">
            {/* Summary bar */}
            <div className="flex flex-wrap items-center justify-between gap-4 p-4 bg-muted/30 rounded-lg border border-muted">
                <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2">
                        <Package className="h-5 w-5 text-muted-foreground" />
                        <span className="text-sm text-muted-foreground">
                            <strong className="text-foreground">
                                {groupedPieces.length}
                            </strong>{" "}
                            tipo(s) de pieza
                        </span>
                    </div>
                    <div className="h-4 w-px bg-border" />
                    <span className="text-sm text-muted-foreground">
                        <strong className="text-foreground">
                            {totalPiecesCount}
                        </strong>{" "}
                        piezas totales pendientes
                    </span>
                </div>
                <Button
                    variant="ghost"
                    size="sm"
                    onClick={fetchPendingPieces}
                    disabled={isOrdering}
                >
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Actualizar
                </Button>
            </div>

            {/* Pieces table */}
            <div className="rounded-md border">
                <Table>
                    <TableHeader>
                        <TableRow className="bg-muted/50">
                            <TableHead className="w-12">
                                <Checkbox
                                    checked={allSelected}
                                    onCheckedChange={toggleSelectAll}
                                    aria-label="Seleccionar todas"
                                    disabled={isOrdering}
                                />
                            </TableHead>
                            <TableHead>Ref. Pieza</TableHead>
                            <TableHead className="text-center">
                                Cantidad Total
                            </TableHead>
                            <TableHead className="text-center">
                                Nº Registros
                            </TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {groupedPieces.map((group) => (
                            <TableRow
                                key={group.piece_ref}
                                className={
                                    selectedRefs.has(group.piece_ref)
                                        ? "bg-primary/5"
                                        : ""
                                }
                            >
                                <TableCell>
                                    <Checkbox
                                        checked={selectedRefs.has(
                                            group.piece_ref
                                        )}
                                        onCheckedChange={() =>
                                            toggleSelect(group.piece_ref)
                                        }
                                        aria-label={`Seleccionar pieza ${group.piece_ref}`}
                                        disabled={isOrdering}
                                    />
                                </TableCell>
                                <TableCell>
                                    <span className="font-mono font-bold bg-muted px-2 py-1 rounded">
                                        {group.piece_ref}
                                    </span>
                                </TableCell>
                                <TableCell className="text-center">
                                    <Badge variant="secondary" className="text-sm font-semibold">
                                        {group.total_quantity}
                                    </Badge>
                                </TableCell>
                                <TableCell className="text-center text-muted-foreground text-sm">
                                    {group.occurrences} set(s)
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>

            {/* Action bar */}
            <div className="flex flex-wrap items-center justify-between gap-4 p-4 bg-muted/30 rounded-lg border border-muted">
                <div className="text-sm text-muted-foreground">
                    {selectedCount > 0 ? (
                        <>
                            <strong className="text-foreground">
                                {selectedCount}
                            </strong>{" "}
                            referencia(s) seleccionada(s) —{" "}
                            <strong className="text-foreground">
                                {selectedTotalQuantity}
                            </strong>{" "}
                            piezas en total
                        </>
                    ) : (
                        "Selecciona piezas para generar el listado de compra"
                    )}
                </div>
                <Button
                    onClick={handleGeneratePurchaseList}
                    disabled={selectedCount === 0 || isOrdering}
                    className="gap-2"
                >
                    {isOrdering ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                        <ShoppingCart className="h-4 w-4" />
                    )}
                    Generar Listado de Compra
                    {selectedCount > 0 && (
                        <Badge
                            variant="secondary"
                            className="ml-1 bg-primary-foreground/20"
                        >
                            {selectedCount}
                        </Badge>
                    )}
                </Button>
            </div>
        </div>
    );
};

export default PurchasePiecesList;