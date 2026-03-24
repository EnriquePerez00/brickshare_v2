import { useShipments } from "@/hooks/useShipments";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Package, X, ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { useState, useMemo } from "react";
import { format } from "date-fns";
import { es } from "date-fns/locale";

const ITEMS_PER_PAGE = 20;

const ShipmentsList = () => {
    const { data: shipments, isLoading } = useShipments();
    
    // Filter states
    const [filters, setFilters] = useState({
        userName: "",
        setRef: "",
        status: "all",
    });
    
    // Pagination state
    const [currentPage, setCurrentPage] = useState(1);

    // Apply filters and sort
    const filteredShipments = useMemo(() => {
        if (!shipments) return [];

        let filtered = shipments.filter((shipment) => {
            // Filter by user name
            if (filters.userName) {
                const userName = shipment.users?.full_name?.toLowerCase() || "";
                if (!userName.includes(filters.userName.toLowerCase())) {
                    return false;
                }
            }

            // Filter by set ref
            if (filters.setRef) {
                const setRef = shipment.set_ref?.toLowerCase() || "";
                if (!setRef.includes(filters.setRef.toLowerCase())) {
                    return false;
                }
            }

            // Filter by status
            if (filters.status !== "all" && shipment.shipment_status !== filters.status) {
                return false;
            }

            return true;
        });

        // Sort by updated_at DESC (most recent first)
        return filtered.sort((a, b) => 
            new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
        );
    }, [shipments, filters]);

    // Pagination
    const totalPages = Math.ceil(filteredShipments.length / ITEMS_PER_PAGE);
    const paginatedShipments = filteredShipments.slice(
        (currentPage - 1) * ITEMS_PER_PAGE,
        currentPage * ITEMS_PER_PAGE
    );

    // Reset to page 1 when filters change
    const handleFilterChange = (key: string, value: string) => {
        setFilters((prev) => ({ ...prev, [key]: value }));
        setCurrentPage(1);
    };

    const clearFilters = () => {
        setFilters({
            userName: "",
            setRef: "",
            status: "all",
        });
        setCurrentPage(1);
    };


    const getStatusBadge = (status: string) => {
        switch (status) {
            case 'assigned':
                return <Badge variant="outline" className="bg-indigo-100 text-indigo-800 border-indigo-300">Assigned</Badge>;
            case 'pending':
                return <Badge variant="outline" className="bg-gray-100 text-gray-800 border-gray-300">Pending</Badge>;
            case 'preparation':
                return <Badge variant="outline" className="bg-yellow-100 text-yellow-800 border-yellow-300">In Preparation</Badge>;
            case 'in_transit_pudo':
                return <Badge variant="outline" className="bg-blue-100 text-blue-800 border-blue-300">In Transit → PUDO</Badge>;
            case 'delivered_pudo':
                return <Badge variant="outline" className="bg-purple-100 text-purple-800 border-purple-300">Delivered PUDO</Badge>;
            case 'delivered_user':
                return <Badge variant="outline" className="bg-green-100 text-green-800 border-green-300">Delivered User</Badge>;
            case 'in_return_pudo':
                return <Badge variant="outline" className="bg-orange-100 text-orange-800 border-orange-300">Return at PUDO</Badge>;
            case 'in_return':
                return <Badge variant="outline" className="bg-amber-100 text-amber-800 border-amber-300">In Return Transit</Badge>;
            case 'returned':
                return <Badge variant="outline" className="bg-teal-100 text-teal-800 border-teal-300">Returned</Badge>;
            default:
                return <Badge variant="outline">{status}</Badge>;
        }
    };

    if (isLoading) {
        return <div className="animate-pulse space-y-4">
            {[1, 2, 3].map(i => <div key={i} className="h-12 bg-muted rounded"></div>)}
        </div>;
    }

    if (!shipments || shipments.length === 0) {
        return (
            <div className="text-center py-12 bg-card rounded-xl border border-dashed border-border">
                <Package className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <p className="text-muted-foreground text-lg">No shipments registered.</p>
            </div>
        );
    }

    return (
        <div className="space-y-4">
            {/* Filters Section */}
            <div className="bg-card rounded-xl border border-border p-4">
                <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold">Filtros</h3>
                    <Button
                        variant="ghost"
                        size="sm"
                        onClick={clearFilters}
                        className="gap-2"
                    >
                        <X className="h-4 w-4" />
                        Limpiar
                    </Button>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label className="text-sm font-medium mb-2 block">
                            Nombre Usuario
                        </label>
                        <Input
                            placeholder="Buscar por nombre..."
                            value={filters.userName}
                            onChange={(e) => handleFilterChange("userName", e.target.value)}
                        />
                    </div>

                    <div>
                        <label className="text-sm font-medium mb-2 block">
                            Set Reference
                        </label>
                        <Input
                            placeholder="Ej: 75192"
                            value={filters.setRef}
                            onChange={(e) => handleFilterChange("setRef", e.target.value)}
                        />
                    </div>

                    <div>
                        <label className="text-sm font-medium mb-2 block">
                            Estado
                        </label>
                        <Select
                            value={filters.status}
                            onValueChange={(value) => handleFilterChange("status", value)}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder="Todos los estados" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">Todos los estados</SelectItem>
                                <SelectItem value="assigned">Assigned</SelectItem>
                                <SelectItem value="pending">Pending</SelectItem>
                                <SelectItem value="preparation">In Preparation</SelectItem>
                                <SelectItem value="in_transit_pudo">In Transit → PUDO</SelectItem>
                                <SelectItem value="delivered_pudo">Delivered PUDO</SelectItem>
                                <SelectItem value="delivered_user">Delivered User</SelectItem>
                                <SelectItem value="in_return_pudo">Return at PUDO</SelectItem>
                                <SelectItem value="in_return">In Return Transit</SelectItem>
                                <SelectItem value="returned">Returned</SelectItem>
                                <SelectItem value="completed">Completed</SelectItem>
                                <SelectItem value="cancelled">Cancelled</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>

                <div className="mt-4 text-sm text-muted-foreground">
                    Mostrando {filteredShipments.length} de {shipments?.length || 0} envíos
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-card rounded-xl border border-border overflow-hidden">
                <div className="max-h-[600px] overflow-y-auto">
                    <Table>
                        <TableHeader className="sticky top-0 bg-card z-10">
                            <TableRow>
                                <TableHead>Nombre Usuario</TableHead>
                                <TableHead>Set Ref</TableHead>
                                <TableHead>Estado</TableHead>
                                <TableHead>Última Actualización</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {paginatedShipments.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={4} className="text-center py-8 text-muted-foreground">
                                        No se encontraron envíos con los filtros aplicados
                                    </TableCell>
                                </TableRow>
                            ) : (
                                paginatedShipments.map((shipment) => (
                                    <TableRow key={shipment.id}>
                                        <TableCell className="font-medium">
                                            {shipment.users?.full_name || shipment.users?.email || "-"}
                                        </TableCell>
                                        <TableCell>
                                            {shipment.set_ref || "-"}
                                        </TableCell>
                                        <TableCell>
                                            {getStatusBadge(shipment.shipment_status)}
                                        </TableCell>
                                        <TableCell>
                                            {format(new Date(shipment.updated_at), "dd/MM/yyyy HH:mm", { locale: es })}
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
                <div className="flex items-center justify-between">
                    <div className="text-sm text-muted-foreground">
                        Página {currentPage} de {totalPages}
                    </div>
                    <div className="flex gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                            disabled={currentPage === 1}
                            className="gap-2"
                        >
                            <ChevronLeft className="h-4 w-4" />
                            Anterior
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                            disabled={currentPage === totalPages}
                            className="gap-2"
                        >
                            Siguiente
                            <ChevronRight className="h-4 w-4" />
                        </Button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ShipmentsList;