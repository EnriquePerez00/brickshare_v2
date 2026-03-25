import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import { User, Heart, Award, Loader2, Trash2, Shield, AlertTriangle, MapPin, Phone, Mail, Pencil, Package, ArrowLeftRight, Building2, Info } from "lucide-react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ProductCard from "@/components/ProductCard";
import ProductRow from "@/components/ProductRow";
import DeleteAccountDialog from "@/components/DeleteAccountDialog";
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
import { useAuth } from "@/contexts/AuthContext";
import { useWishlist } from "@/hooks/useWishlist";
import { useSets } from "@/hooks/useProducts";
import { useOrders, useReturnSet } from "@/hooks/useOrders";
import ProfileCompletionModal from "@/components/ProfileCompletionModal";
import PudoSelector from "@/components/PudoSelector";
import { toast } from "sonner";
import { useUserActivePudo, useSaveCorreosPudo, useSaveBricksharePudo } from "@/hooks/usePudo";
import { transformPUDOPointToCorreosPudo, transformPUDOPointToBricksharePudo, normalizePudoPointType, type PUDOPoint } from "@/lib/pudoService";

const Dashboard = () => {
  const { user, profile, isLoading: authLoading, deleteUserAccount, updateProfile, isAdmin, isOperador } = useAuth();
  const { wishlistIds, toggleWishlist, isLoading: wishlistLoading } = useWishlist();
  const { data: sets = [], isLoading: setsLoading } = useSets(100);
  const { data: orders = [], isLoading: ordersLoading } = useOrders();
  const { data: activePudo } = useUserActivePudo();
  const saveCorreosPudoMutation = useSaveCorreosPudo();
  const saveBricksharePudoMutation = useSaveBricksharePudo();
  const returnMutation = useReturnSet();
  const navigate = useNavigate();
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [isPudoSelectorOpen, setIsPudoSelectorOpen] = useState(false);

  const handlePudoSelect = async (point: PUDOPoint) => {
    try {
      // Normalize the tipo_punto to match database constraints
      const normalizedType = normalizePudoPointType(point.tipo_punto);
      
      if (normalizedType === 'Deposito') {
        // This is a Brickshare PUDO
        const pudoData = transformPUDOPointToBricksharePudo(point);
        await saveBricksharePudoMutation.mutateAsync(pudoData);
      } else {
        // This is a Correos PUDO
        const pudoData = transformPUDOPointToCorreosPudo(point);
        await saveCorreosPudoMutation.mutateAsync(pudoData);
      }
      
      toast.success("Punto de entrega actualizado correctamente");
      setIsPudoSelectorOpen(false);
    } catch (error) {
      // More descriptive error message
      let errorMessage = "Error al actualizar el punto de entrega";
      if (error instanceof Error) {
        errorMessage = error.message;
      }
      
      toast.error(errorMessage);
    }
  };

  const [returnDialogOpen, setReturnDialogOpen] = useState(false);
  const [selectedEnvioId, setSelectedEnvioId] = useState<string | null>(null);
  const [deleteAccountDialogOpen, setDeleteAccountDialogOpen] = useState(false);

  const handleReturnClick = (envioId: string) => {
    setSelectedEnvioId(envioId);
    setReturnDialogOpen(true);
  };

  const handleConfirmReturn = () => {
    if (selectedEnvioId) {
      returnMutation.mutate(selectedEnvioId);
      setReturnDialogOpen(false);
      setSelectedEnvioId(null);
    }
  };

  useEffect(() => {
    if (!authLoading && profile && !profile.profile_completed) {
      setShowProfileModal(true);
    }
  }, [profile, authLoading]);

  useEffect(() => {
    if (!authLoading) {
      if (!user) {
        navigate("/");
      } else if (isAdmin) {
        navigate("/admin");
      } else if (isOperador) {
        navigate("/operaciones");
      }
    }
  }, [user, isAdmin, isOperador, authLoading, navigate]);

  if (authLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!user) {
    return null;
  }

  // Note: useWishlist() now only returns items with status=true
  const wishlistSets = sets.filter((s) => wishlistIds.includes(s.id));
  const impactPoints = profile?.impact_points || 0;
  const impactHours = Math.floor(impactPoints / 10); // 10 points = 1 hour

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <main className="pt-24 pb-16">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="mb-8"
          >
            <h1 className="text-3xl sm:text-4xl font-display font-bold text-foreground mb-2">
              Mi Panel
            </h1>
            <p className="text-muted-foreground">
              Bienvenido, {profile?.full_name || user.email}
            </p>
          </motion.div>

          {/* Stats Cards */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10"
          >
            {/* Profile Card */}
            <div className="bg-card rounded-2xl p-6 shadow-card">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full gradient-hero flex items-center justify-center">
                  <User className="h-7 w-7 text-primary-foreground" />
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Suscripción</p>
                  <p className="text-lg font-semibold text-foreground capitalize">
                    {(!profile?.subscription_type || profile.subscription_type === 'none')
                      ? "Sin Suscripción Activa"
                      : profile.subscription_type}
                  </p>
                </div>
              </div>
            </div>

            {/* Wishlist Count */}
            <div className="bg-card rounded-2xl p-6 shadow-card">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full bg-destructive/10 flex items-center justify-center">
                  <Heart className="h-7 w-7 text-destructive" />
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">En tu Wishlist</p>
                  <p className="text-lg font-semibold text-foreground">
                    {wishlistIds.length} sets
                  </p>
                </div>
              </div>
            </div>

            {/* Impact Points */}
            <div className="bg-card rounded-2xl p-6 shadow-card">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full bg-accent/10 flex items-center justify-center">
                  <Award className="h-7 w-7 text-accent" />
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Impacto Social</p>
                  <p className="text-lg font-semibold text-foreground">
                    {impactHours} horas
                  </p>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Impact Banner */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="bg-gradient-to-r from-primary/10 via-accent/10 to-primary/10 rounded-2xl p-6 mb-10"
          >
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-full gradient-hero flex items-center justify-center shrink-0">
                <Award className="h-6 w-6 text-primary-foreground" />
              </div>
              <div>
                <h3 className="font-display font-semibold text-foreground mb-1">
                  Tu impacto este mes
                </h3>
                <p className="text-muted-foreground">
                  Con tu suscripción has apoyado <span className="font-semibold text-primary">{impactHours} horas</span> de trabajo inclusivo.
                  Gracias a ti, personas con discapacidad tienen una ocupación digna preparando tus sets de LEGO.
                </p>
              </div>
            </div>
          </motion.div>

          {/* Wishlist Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
          >
            <h2 className="text-2xl font-display font-bold text-foreground mb-6" data-testid="dashboard-wishlist-title">
              Mi Wishlist
            </h2>

            {wishlistLoading || setsLoading ? (
              <div className="flex items-center justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
              </div>
            ) : wishlistSets.length > 0 ? (
              <div className="flex flex-col gap-3" data-testid="dashboard-wishlist-items">
                {wishlistSets.map((set) => (
                  <ProductRow
                    key={set.id}
                    id={set.id}
                    name={set.set_name}
                    imageUrl={set.set_image_url || "/placeholder.svg"}
                    theme={set.set_theme}
                    ageRange={set.set_age_range}
                    pieceCount={set.set_piece_count}
                    skillBoost={Array.isArray(set.skill_boost) ? (set.skill_boost as string[]).join(", ") : ""}
                    legoRef={set.set_ref || undefined}
                    description={set.set_description}
                    isWishlisted={true}
                    onWishlistToggle={toggleWishlist}
                  />
                ))}
              </div>
            ) : (
              <div className="text-center py-12 bg-card rounded-2xl" data-testid="dashboard-wishlist-empty">
                <Heart className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <p className="text-lg text-muted-foreground mb-4">
                  Tu wishlist está vacía
                </p>
                <Button asChild data-testid="dashboard-explore-catalog-button">
                  <a href="/catalogo">Explorar catálogo</a>
                </Button>
              </div>
            )}
          </motion.div>

          {/* Order History Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-16"
          >
            <h2 className="text-2xl font-display font-bold text-foreground mb-6" data-testid="dashboard-history-title">
              Mi Histórico
            </h2>

            {ordersLoading ? (
              <div className="flex items-center justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
              </div>
            ) : orders.length > 0 ? (
              <div className="overflow-hidden bg-card rounded-2xl shadow-card" data-testid="dashboard-orders-table">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-sm">
                    <thead>
                      <tr className="border-b border-border bg-muted/50">
                        <th className="p-4 font-medium text-muted-foreground">Ref</th>
                        <th className="p-4 font-medium text-muted-foreground">Set</th>
                        <th className="p-4 font-medium text-muted-foreground">Estado</th>
                        <th className="p-4 font-medium text-muted-foreground">Fecha Actualización</th>
                        <th className="p-4 font-medium text-muted-foreground text-right">Acciones</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {orders.map((order, index) => {
                        const getStatusBadge = (status: string) => {
                          const statusConfig: Record<string, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
                            pending: { label: "Pendiente", variant: "outline" },
                            preparation: { label: "En Preparación", variant: "outline" },
                            in_transit_pudo: { label: "En Ruta al PUDO", variant: "default" },
                            delivered_pudo: { label: "En PUDO", variant: "default" },
                            delivered_user: { label: "Entregado", variant: "default" },
                            in_return_pudo: { label: "Devolución en PUDO", variant: "secondary" },
                            in_return: { label: "En Retorno", variant: "secondary" },
                            returned: { label: "Devuelto", variant: "secondary" },
                            cancelled: { label: "Cancelado", variant: "destructive" },
                          };
                          const config = statusConfig[status] || { label: status, variant: "outline" };
                          return <Badge variant={config.variant}>{config.label}</Badge>;
                        };

                        const formatDate = (dateString: string) => {
                          return new Date(dateString).toLocaleDateString("es-ES", {
                            year: "numeric",
                            month: "short",
                            day: "numeric",
                            hour: "2-digit",
                            minute: "2-digit"
                          });
                        };

                        // Only the most recent order (index 0) can be returned, and only if it's delivered
                        const canReturn = index === 0 && order.shipment_status === 'delivered_user';

                        return (
                          <tr key={order.id} className="hover:bg-muted/50 transition-colors" data-testid={`dashboard-order-row-${order.id}`}>
                            <td className="p-4 font-mono text-xs">{order.set_ref || "-"}</td>
                            <td className="p-4 font-medium">
                              <div className="flex items-center gap-3">
                                {order.sets?.set_image_url && (
                                  <img
                                    src={order.sets.set_image_url}
                                    alt={order.sets.set_name}
                                    className="w-10 h-10 rounded object-cover bg-secondary"
                                  />
                                )}
                                <span>{order.sets?.set_name || "Set Desconocido"}</span>
                              </div>
                            </td>
                            <td className="p-4">{getStatusBadge(order.shipment_status)}</td>
                            <td className="p-4 text-muted-foreground">{formatDate(order.updated_at)}</td>
                            <td className="p-4 text-right">
                              {canReturn && (
                                <Button
                                  size="sm"
                                  variant="outline"
                                  className="h-8 gap-2 text-orange-600 hover:text-orange-700 hover:bg-orange-50 border-orange-200"
                                  onClick={() => handleReturnClick(order.id)}
                                  disabled={returnMutation.isPending}
                                  data-testid={`dashboard-return-button-${order.id}`}
                                >
                                  <ArrowLeftRight className="h-3.5 w-3.5" />
                                  Solicitar devolución
                                </Button>
                              )}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              </div>
            ) : (
              <div className="text-center py-12 bg-card rounded-2xl" data-testid="dashboard-orders-empty">
                <Package className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <p className="text-lg text-muted-foreground mb-4">
                  No tienes envíos registrados
                </p>
                <p className="text-sm text-muted-foreground">
                  Tus asignaciones de sets aparecerán aquí
                </p>
              </div>
            )}
          </motion.div>

          {/* Correos PUDO Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.45 }}
            className="mt-16 pt-8 border-t border-border"
          >
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-yellow-100 flex items-center justify-center">
                  <MapPin className="h-5 w-5 text-yellow-600" />
                </div>
                <h2 className="text-xl font-display font-bold text-foreground">
                  Punto de Entrega Correos (PUDO)
                </h2>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setIsPudoSelectorOpen(true)}
                className="gap-2 border-yellow-200 hover:bg-yellow-50 text-yellow-700"
                data-testid="dashboard-select-pudo-button"
              >
                <MapPin className="h-4 w-4" />
                {activePudo?.pudo_id ? "Cambiar punto" : "Seleccionar punto"}
              </Button>
            </div>

            <div className="bg-card rounded-2xl p-6 shadow-card border border-border/50" data-testid="dashboard-pudo-display">
              {activePudo?.pudo_id ? (
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4" data-testid="dashboard-pudo-selected">
                  <div className="flex items-start gap-4">
                    <div className={`mt-1 p-2 rounded-full ${
                      activePudo.pudo_type === 'brickshare' 
                        ? 'bg-green-100' 
                        : 'bg-blue-100'
                    }`}>
                      {activePudo.pudo_type === 'brickshare' ? (
                        <Building2 className="h-6 w-6 text-green-600" />
                      ) : (
                        <Package className="h-6 w-6 text-blue-600" />
                      )}
                    </div>
                    <div>
                      <h3 className="font-bold text-foreground flex items-center gap-2">
                        {activePudo.pudo_name}
                        <Badge
                          className={`font-normal text-[0.65rem] uppercase py-0 px-1.5 h-4 ${
                            activePudo.pudo_type === 'brickshare'
                              ? 'bg-green-100 text-green-700 border-green-200'
                              : 'bg-blue-100 text-blue-700 border-blue-200'
                          }`}
                        >
                          {activePudo.pudo_type === 'brickshare' ? 'Depósito Brickshare' : 'Punto Correos'}
                        </Badge>
                      </h3>
                      <p className="text-sm text-muted-foreground">{activePudo.pudo_address}</p>
                    </div>
                  </div>
                  <div className={`text-xs p-3 rounded-xl border flex items-center gap-2 max-w-xs ${
                    activePudo.pudo_type === 'brickshare'
                      ? 'bg-green-50 text-green-700 border-green-100'
                      : 'bg-blue-50 text-blue-700 border-blue-100'
                  }`}>
                    <Info className="h-4 w-4 shrink-0" />
                    <p>Todos tus próximos envíos y devoluciones se gestionarán por defecto a través de este punto.</p>
                  </div>
                </div>
              ) : (
                <div className="text-center py-6 flex flex-col items-center" data-testid="dashboard-pudo-empty">
                  <MapPin className="h-10 w-10 text-muted-foreground/30 mb-2" />
                  <p className="text-sm text-muted-foreground mb-4">
                    No has seleccionado ningún punto de recogida de Correos.
                  </p>
                  <Button onClick={() => setIsPudoSelectorOpen(true)} data-testid="dashboard-pudo-configure-button">
                    Configurar ahora
                  </Button>
                </div>
              )}
            </div>
          </motion.div>

          {/* Security & Data Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-16 pt-8 border-t border-border"
          >
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-2">
                <User className="h-5 w-5 text-muted-foreground" />
                <h2 className="text-xl font-display font-bold text-foreground">
                  Datos de contacto
                </h2>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowProfileModal(true)}
              >
                <Pencil className="h-4 w-4 mr-2" />
                Editar datos
              </Button>
            </div>

            {/* Contact Data Card */}
            <div className="bg-card rounded-2xl p-6 shadow-card mb-6">
              <h3 className="font-semibold text-foreground mb-4">Datos de Contacto</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-start gap-3">
                  <User className="h-5 w-5 text-muted-foreground mt-0.5" />
                  <div>
                    <p className="text-sm text-muted-foreground">Nombre</p>
                    <p className="text-foreground">{profile?.full_name || "No especificado"}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <Mail className="h-5 w-5 text-muted-foreground mt-0.5" />
                  <div>
                    <p className="text-sm text-muted-foreground">Email</p>
                    <p className="text-foreground">{user?.email || "No especificado"}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <MapPin className="h-5 w-5 text-muted-foreground mt-0.5" />
                  <div>
                    <p className="text-sm text-muted-foreground">Dirección</p>
                    <p className="text-foreground">
                      {profile?.address ? (
                        <>
                          {profile.address}
                          {profile.zip_code && `, ${profile.zip_code}`}
                          {profile.city && ` ${profile.city}`}
                        </>
                      ) : (
                        "No especificada"
                      )}
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <Phone className="h-5 w-5 text-muted-foreground mt-0.5" />
                  <div>
                    <p className="text-sm text-muted-foreground">Teléfono</p>
                    <p className="text-foreground">{profile?.phone || "No especificado"}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Danger Zone */}
            <div className="bg-destructive/5 rounded-2xl p-6 border border-destructive/20 flex flex-col md:flex-row items-center justify-between gap-6" data-testid="dashboard-delete-account-section">
              <div className="flex gap-4">
                <div className="p-3 rounded-xl bg-destructive/10 text-destructive h-fit">
                  <AlertTriangle className="h-6 w-6" />
                </div>
                <div>
                  <h3 className="font-semibold text-foreground mb-1">Dar de baja mi cuenta</h3>
                  <p className="text-sm text-muted-foreground max-w-md">
                    Al dar de baja tu cuenta, tu suscripción será cancelada y no podrás acceder a tu perfil. Tus datos se conservarán durante 30 días por si deseas reactivar la cuenta.
                  </p>
                </div>
              </div>
              <Button
                variant="destructive"
                onClick={() => setDeleteAccountDialogOpen(true)}
                className="shrink-0"
                data-testid="dashboard-delete-account-button"
              >
                <Trash2 className="h-4 w-4 mr-2" />
                Dar de baja
              </Button>
            </div>
          </motion.div>
        </div>
      </main>

      <ProfileCompletionModal
        open={showProfileModal}
        onClose={() => setShowProfileModal(false)}
      />

      <PudoSelector
        isOpen={isPudoSelectorOpen}
        onClose={() => setIsPudoSelectorOpen(false)}
        onSelect={handlePudoSelect}
        initialZipCode={profile?.zip_code || undefined}
        initialAddress={profile?.address || undefined}
      />

      <DeleteAccountDialog
        open={deleteAccountDialogOpen}
        onOpenChange={setDeleteAccountDialogOpen}
        subscriptionType={profile?.subscription_type}
        onConfirm={async () => {
          const { error } = await deleteUserAccount();
          if (error) {
            toast.error("Error al dar de baja la cuenta: " + error.message);
          } else {
            toast.success("Tu cuenta ha sido dada de baja correctamente. Recibirás un email de confirmación.");
            setDeleteAccountDialogOpen(false);
            navigate("/");
          }
        }}
      />

      <AlertDialog open={returnDialogOpen} onOpenChange={setReturnDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>¿Confirmar devolución?</AlertDialogTitle>
            <AlertDialogDescription>
              Se cambiará el estado del envío a "En Ruta (Devolución)". Asegúrate de preparar el paquete para su recogida.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction onClick={handleConfirmReturn} className="bg-orange-600 hover:bg-orange-700">
              Confirmar Devolución
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <Footer />
    </div>
  );
};

export default Dashboard;
