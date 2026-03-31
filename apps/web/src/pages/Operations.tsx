import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Truck, ClipboardList, Boxes, Settings, UserPlus, Tag, ShoppingCart } from "lucide-react";
import SetAssignment from "@/components/admin/operations/SetAssignment";
import LabelGeneration from "@/components/admin/operations/LabelGeneration";
import ShipmentsList from "@/components/admin/operations/ShipmentsList";
import ReturnsList from "@/components/admin/operations/ReturnsList";
import RepairsList from "@/components/admin/operations/RepairsList";
import PurchasePiecesList from "@/components/admin/operations/PurchasePiecesList";
import MaintenanceList from "@/components/admin/inventory/MaintenanceList";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

const Operations = () => {
    const { user, isOperador, isAdmin, isLoading } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        if (!isLoading && (!user || (!isOperador && !isAdmin))) {
            navigate("/");
        }
    }, [user, isOperador, isAdmin, isLoading, navigate]);

    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            </div>
        );
    }

    if (!user || (!isOperador && !isAdmin)) {
        return null;
    }

    return (
        <div className="min-h-screen bg-background flex flex-col">
            <Navbar />
            <div className="container mx-auto px-4 py-8 mt-16 flex-grow">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-foreground">Panel de Operaciones</h1>
                    <p className="text-muted-foreground mt-2">
                        Gestión logística, envíos, devoluciones y mantenimiento de sets.
                    </p>
                </div>

                <Tabs defaultValue="assignment" className="space-y-6">
                    <TabsList className="grid w-full grid-cols-7 lg:w-auto">
                        <TabsTrigger value="assignment" className="flex items-center gap-2">
                            <UserPlus className="h-4 w-4" />
                            <span className="hidden sm:inline">Asignación</span>
                            <span className="sm:hidden">Sets</span>
                        </TabsTrigger>
                        <TabsTrigger value="labels" className="flex items-center gap-2">
                            <Tag className="h-4 w-4" />
                            <span className="hidden sm:inline">Etiquetas</span>
                            <span className="sm:hidden">QR</span>
                        </TabsTrigger>
                        <TabsTrigger value="shipments" className="flex items-center gap-2">
                            <Truck className="h-4 w-4" />
                            <span className="hidden sm:inline">Envíos</span>
                            <span className="sm:hidden">📦</span>
                        </TabsTrigger>
                        <TabsTrigger value="returns" className="flex items-center gap-2">
                            <ClipboardList className="h-4 w-4" />
                            <span className="hidden sm:inline">Devoluciones</span>
                            <span className="sm:hidden">✓</span>
                        </TabsTrigger>
                        <TabsTrigger value="repairs" className="flex items-center gap-2">
                            <Settings className="h-4 w-4" />
                            <span className="hidden sm:inline">Reparaciones</span>
                            <span className="sm:hidden">🔧</span>
                        </TabsTrigger>
                        <TabsTrigger value="purchase" className="flex items-center gap-2">
                            <ShoppingCart className="h-4 w-4" />
                            <span className="hidden sm:inline">Comprar Piezas</span>
                            <span className="sm:hidden">🛒</span>
                        </TabsTrigger>
                        <TabsTrigger value="maintenance" className="flex items-center gap-2">
                            <Boxes className="h-4 w-4" />
                            <span className="hidden sm:inline">Mantenimiento</span>
                            <span className="sm:hidden">🧹</span>
                        </TabsTrigger>
                    </TabsList>

                    <TabsContent value="assignment" className="space-y-4">
                        <SetAssignment />
                    </TabsContent>

                    <TabsContent value="labels" className="space-y-4">
                        <LabelGeneration />
                    </TabsContent>

                    <TabsContent value="shipments">
                        <ShipmentsList />
                    </TabsContent>

                    <TabsContent value="returns">
                        <div className="bg-card p-4 rounded-xl border border-border">
                            <h3 className="text-xl font-semibold mb-2">Devoluciones de Sets</h3>
                            <p className="text-muted-foreground mb-6">Procesa sets devueltos por usuarios. Pésalos para detectar piezas faltantes automáticamente según tolerancia de peso.</p>
                            <ReturnsList />
                        </div>
                    </TabsContent>

                    <TabsContent value="repairs">
                        <div className="bg-card p-4 rounded-xl border border-border">
                            <h3 className="text-xl font-semibold mb-2">Registro de Reparaciones</h3>
                            <p className="text-muted-foreground mb-6">Gestiona sets que necesitan reparación. Registra piezas faltantes o dañadas para ordenas reemplazos y coordinar reparaciones.</p>
                            <RepairsList />
                        </div>
                    </TabsContent>

                    <TabsContent value="purchase">
                        <div className="bg-card p-4 rounded-xl border border-border">
                            <h3 className="text-xl font-semibold mb-2">Comprar Piezas</h3>
                            <p className="text-muted-foreground mb-6">Gestiona piezas faltantes pendientes de compra. Agrupa por referencia de pieza y genera listados de compra para reposición.</p>
                            <PurchasePiecesList />
                        </div>
                    </TabsContent>

                    <TabsContent value="maintenance">
                        <div className="bg-card p-4 rounded-xl border border-border">
                            <h3 className="text-xl font-semibold mb-2">Registro de Mantenimiento e Higienización</h3>
                            <p className="text-muted-foreground mb-6">Administra sets en limpieza e higienización. Marca como completado para devolverlos al inventario central.</p>
                            <MaintenanceList />
                        </div>
                    </TabsContent>
                </Tabs>
            </div>
            <Footer />
        </div >
    );
};

export default Operations;
