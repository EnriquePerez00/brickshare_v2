import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import {
  User, Heart, Award, Loader2, AlertTriangle, MapPin, Phone, Mail,
  Pencil, Package, ArrowLeftRight, Building2, Info, Users, Store,
} from "lucide-react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ProductRow from "@/components/ProductRow";
import { ShipmentTimeline } from "@/components/ShipmentTimeline";
import ReviewModal from "@/components/ReviewModal";
import ReferralPanel from "@/components/ReferralPanel";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { useAuth } from "@/contexts/AuthContext";
import { useWishlist } from "@/hooks/useWishlist";
import { useSets } from "@/hooks/useProducts";
import { useOrders, useActiveOrders, useReturnSet } from "@/hooks/useOrders";
import ProfileCompletionModal from "@/components/ProfileCompletionModal";
import PudoSelector from "@/components/PudoSelector";
import { toast } from "sonner";
import { useUserPudoPoint, useSavePudoPoint } from "@/hooks/usePudo";

interface ReviewPending {
  setId: string;
  setName: string;
}

const Dashboard = () => {
  const { user, profile, isLoading: authLoading, deleteUserAccount, isAdmin, isOperador } = useAuth();
  const { wishlistIds, toggleWishlist, isLoading: wishlistLoading } = useWishlist();
  const { data: sets = [], isLoading: setsLoading } = useSets(100);
  const { data: orders = [], isLoading: ordersLoading } = useOrders();
  const { data: activeOrders = [], isLoading: activeOrdersLoading } = useActiveOrders();
  const { data: pudoPoint, isLoading: pudoLoading, refetch: refetchPudo } = useUserPudoPoint();
  const savePudoMutation = useSavePudoPoint();
  const returnMutation = useReturnSet();
  const navigate = useNavigate();

  const [showProfileModal, setShowProfileModal] = useState(false);
  const [isPudoSelectorOpen, setIsPudoSelectorOpen] = useState(false);
  const [returnDialogOpen, setReturnDialogOpen] = useState(false);
  const [selectedEnvioId, setSelectedEnvioId] = useState<string | null>(null);
  const [selectedEnvioSet, setSelectedEnvioSet] = useState<{ id: string; name: string } | null>(null);
  const [reviewPending, setReviewPending] = useState<ReviewPending | null>(null);

  const handlePudoSelect = async (point: any) => {
    try {
      const pudoData = {
        correos_id_pudo: point.id_correos_pudo || point.code || point.id,
        correos_nombre: point.nombre || point.name,
        correos_tipo_punto: point.tipo_punto || (point._source === "deposit" ? "Deposito" : "Oficina"),
        correos_direccion_calle: point.direccion || point.address,
        correos_codigo_postal: point.cp || point.postal_code,
        correos_ciudad: point.ciudad || point.city,
        correos_provincia: point.ciudad || point.city,
        correos_pais: "España",
        correos_direccion_completa: point._source === "deposit" 
          ? `${point.address}, ${point.postal_code} ${point.city}`
          : `${point.direccion}, ${point.cp} ${point.ciudad}`,
        correos_latitud: point.lat,
        correos_longitud: point.lng,
        correos_horario_apertura: point.horario || "Consultar horarios",
        correos_disponible: true,
      };
      
      await savePudoMutation.mutateAsync(pudoData);
      // Force immediate refetch to ensure UI updates
      await refetchPudo();
      toast.success("Punto de recogida/devolución actualizado correctamente");
      setIsPudoSelectorOpen(false);
    } catch (error) {
      console.error("Error updating PUDO point:", error);
      toast.error("Error al actualizar el punto de recogida/devolución");
    }
  };

  const handleReturnClick = (envioId: string, setId?: string, setName?: string) => {
    setSelectedEnvioId(envioId);
    if (setId && setName) setSelectedEnvioSet({ id: setId, name: setName });
    setReturnDialogOpen(true);
  };

  const handleConfirmReturn = () => {
    if (selectedEnvioId) {
      returnMutation.mutate(selectedEnvioId, {
        onSuccess: () => {
          // Prompt review after return confirmed
          if (selectedEnvioSet) {
            setReviewPending({ setId: selectedEnvioSet.id, setName: selectedEnvioSet.name });
          }
        },
      });
      setReturnDialogOpen(false);
      setSelectedEnvioId(null);
    }
  };

  useEffect(() => {
    if (!authLoading) {
      if (!user) navigate("/auth");
      else if (isAdmin) navigate("/admin");
      else if (isOperador) navigate("/operaciones");
    }
  }, [user, isAdmin, isOperador, authLoading, navigate]);

  if (authLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }
  if (!user) return null;

  const wishlistSets = sets.filter((s) => wishlistIds.includes(s.id));
  const impactPoints = profile?.impact_points || 0;
  const impactHours = Math.floor(impactPoints / 10);

  // ─── Status helpers ──────────────────────────────────────────────────────────
  const STATUS_CONFIG: Record<string, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
    preparacion: { label: "En Preparación", variant: "outline" },
    ruta_envio: { label: "En Ruta (Envío)", variant: "default" },
    entregado: { label: "Entregado", variant: "default" },
    devuelto: { label: "Devuelto", variant: "secondary" },
    ruta_devolucion: { label: "En Ruta (Devolución)", variant: "secondary" },
  };

  const formatDate = (d: string) =>
    new Date(d).toLocaleDateString("es-ES", { year: "numeric", month: "short", day: "numeric" });

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <main className="pt-24 pb-16">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          {/* Page header */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="mb-8"
          >
            <h1 className="text-3xl sm:text-4xl font-display font-bold text-foreground mb-1">
              Mi Panel
            </h1>
            <p className="text-muted-foreground">
              Bienvenido, {profile?.full_name || user.email}
            </p>
          </motion.div>

          {/* Stats row */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8"
          >
            <div className="bg-card rounded-2xl p-6 shadow-card flex items-center gap-4">
              <div className="w-14 h-14 rounded-full gradient-hero flex items-center justify-center">
                <User className="h-7 w-7 text-primary-foreground" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Suscripción</p>
                <p className="text-lg font-semibold text-foreground capitalize">
                  {(!profile?.subscription_type || profile.subscription_type === "none")
                    ? "Sin suscripción"
                    : profile.subscription_type}
                </p>
              </div>
            </div>

            <div className="bg-card rounded-2xl p-6 shadow-card flex items-center gap-4">
              <div className="w-14 h-14 rounded-full bg-destructive/10 flex items-center justify-center">
                <Heart className="h-7 w-7 text-destructive" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">En tu Wishlist</p>
                <p className="text-lg font-semibold text-foreground">{wishlistIds.length} sets</p>
              </div>
            </div>

            <div className="bg-card rounded-2xl p-6 shadow-card flex items-center gap-4">
              <div className="w-14 h-14 rounded-full bg-accent/10 flex items-center justify-center">
                <Award className="h-7 w-7 text-accent" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Impacto Social</p>
                <p className="text-lg font-semibold text-foreground">{impactHours} horas</p>
              </div>
            </div>
          </motion.div>

          {/* ─── Tabs ──────────────────────────────────────────────────────────── */}
          <Tabs defaultValue="panel" className="space-y-8">
            <TabsList className="h-11 rounded-xl bg-muted/60 p-1">
              <TabsTrigger value="panel" className="rounded-lg px-5 gap-2">
                <User className="h-4 w-4" /> Mi Panel
              </TabsTrigger>
              <TabsTrigger value="envios" className="rounded-lg px-5 gap-2">
                <Package className="h-4 w-4" /> Mis Envíos
              </TabsTrigger>
              <TabsTrigger value="referidos" className="rounded-lg px-5 gap-2">
                <Users className="h-4 w-4" /> Referidos
              </TabsTrigger>
            </TabsList>

            {/* ── TAB: MI PANEL ─────────────────────────────────────────────────── */}
            <TabsContent value="panel" className="space-y-10">
              {/* Impact banner */}
              <div className="bg-gradient-to-r from-primary/10 via-accent/10 to-primary/10 rounded-2xl p-6">
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-full gradient-hero flex items-center justify-center shrink-0">
                    <Award className="h-6 w-6 text-primary-foreground" />
                  </div>
                  <div>
                    <h3 className="font-display font-semibold text-foreground mb-1">
                      Tu impacto este mes
                    </h3>
                    <p className="text-muted-foreground">
                      Con tu suscripción has apoyado{" "}
                      <span className="font-semibold text-primary">{impactHours} horas</span> de trabajo
                      inclusivo. Gracias a ti, personas con discapacidad tienen una ocupación digna
                      preparando tus sets de LEGO.
                    </p>
                  </div>
                </div>
              </div>

              {/* Wishlist */}
              <div>
                <h2 className="text-2xl font-display font-bold text-foreground mb-6">
                  Mi Wishlist
                </h2>
                {wishlistLoading || setsLoading ? (
                  <div className="flex justify-center py-12">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                  </div>
                ) : wishlistSets.length > 0 ? (
                  <div className="flex flex-col gap-3">
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
                        legoRef={set.set_ref ?? undefined}
                        description={set.set_description}
                        isWishlisted={true}
                        onWishlistToggle={toggleWishlist}
                      />
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-12 bg-card rounded-2xl">
                    <Heart className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                    <p className="text-lg text-muted-foreground mb-4">Tu wishlist está vacía</p>
                    <Button asChild>
                      <a href="/catalogo">Explorar catálogo</a>
                    </Button>
                  </div>
                )}
              </div>

              {/* Set en curso */}
              <div className="pt-8 border-t border-border">
                <h2 className="text-2xl font-display font-bold text-foreground mb-6">
                  Set en curso
                </h2>
                {activeOrdersLoading ? (
                  <div className="flex justify-center py-12">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                  </div>
                ) : activeOrders.length > 0 ? (
                  <div className="space-y-4">
                    {activeOrders.map((order) => {
                      const cfg = STATUS_CONFIG[order.estado_envio] ?? { label: order.estado_envio, variant: "outline" as const };
                      return (
                        <div key={order.id} className="bg-card rounded-2xl shadow-card overflow-hidden">
                          {/* Header row */}
                          <div className="flex items-center gap-4 p-5 border-b border-border">
                            {order.sets?.set_image_url && (
                              <img
                                src={order.sets.set_image_url}
                                alt={order.sets.set_name}
                                className="w-14 h-14 rounded-xl object-cover bg-secondary shrink-0"
                              />
                            )}
                            <div className="flex-1 min-w-0">
                              <p className="font-semibold text-foreground truncate">
                                {order.sets?.set_name ?? "Set Desconocido"}
                              </p>
                              <p className="text-xs text-muted-foreground font-mono">
                                Ref: {order.set_ref || "—"} · Actualizado: {formatDate(order.updated_at)}
                              </p>
                            </div>
                            <div className="flex items-center gap-3 shrink-0">
                              <Badge variant={cfg.variant}>{cfg.label}</Badge>
                            </div>
                          </div>

                          {/* Timeline */}
                          <div className="px-6 py-4 bg-muted/30">
                            <ShipmentTimeline
                              shipmentId={order.id}
                              status={order.estado_envio}
                              trackingNumber={(order as any).tracking_number}
                            />
                          </div>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <div className="text-center py-12 bg-card rounded-2xl">
                    <Package className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                    <p className="text-lg text-muted-foreground mb-2">No tienes sets en curso</p>
                    <p className="text-sm text-muted-foreground">
                      Tus sets asignados aparecerán aquí
                    </p>
                  </div>
                )}
              </div>

              {/* PUDO */}
              <div className="pt-8 border-t border-border">
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-yellow-100 flex items-center justify-center">
                      <MapPin className="h-5 w-5 text-yellow-600" />
                    </div>
                    <h2 className="text-xl font-display font-bold text-foreground">
                      Punto de Recogida / Devolución
                    </h2>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsPudoSelectorOpen(true)}
                    className="gap-2 border-yellow-200 hover:bg-yellow-50 text-yellow-700"
                  >
                    <MapPin className="h-4 w-4" />
                    {pudoPoint?.correos_id_pudo ? "Cambiar punto" : "Seleccionar punto"}
                  </Button>
                </div>
                <div className="bg-card rounded-2xl p-6 shadow-card border border-border/50">
                  {pudoLoading ? (
                    <div className="flex justify-center py-8">
                      <Loader2 className="h-6 w-6 animate-spin text-primary" />
                    </div>
                  ) : pudoPoint?.correos_id_pudo ? (
                    <div className="space-y-4">
                      <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
                        <div className="flex items-start gap-4 flex-1">
                          <div className="mt-1 p-2 rounded-full bg-primary/10">
                            {pudoPoint.correos_tipo_punto === "Oficina" ? (
                              <Building2 className="h-6 w-6 text-primary" />
                            ) : pudoPoint.correos_tipo_punto === "Deposito" ? (
                              <Store className="h-6 w-6 text-green-600" />
                            ) : (
                              <Package className="h-6 w-6 text-primary" />
                            )}
                          </div>
                          <div className="flex-1">
                            <div className="flex items-start justify-between gap-4 mb-1">
                              <h3 className="font-bold text-foreground flex items-center gap-2 flex-wrap">
                                {pudoPoint.correos_nombre}
                                <Badge 
                                  variant="secondary" 
                                  className={`font-medium text-[0.7rem] uppercase py-0.5 px-2 ${
                                    pudoPoint.correos_tipo_punto === "Deposito" 
                                      ? "bg-green-100 text-green-700 border-green-200" 
                                      : pudoPoint.correos_tipo_punto === "Citypaq"
                                      ? "bg-yellow-100 text-yellow-700 border-yellow-200"
                                      : "bg-blue-100 text-blue-700 border-blue-200"
                                  }`}
                                >
                                  PUNTO {pudoPoint.correos_tipo_punto === "Deposito" ? "BRICKSHARE" : pudoPoint.correos_tipo_punto.toUpperCase()}
                                </Badge>
                              </h3>
                            </div>
                            <p className="text-sm text-muted-foreground">{pudoPoint.correos_direccion_completa}</p>
                            {pudoPoint.updated_at && (
                              <p className="text-xs text-muted-foreground mt-1">
                                Seleccionado el {formatDate(pudoPoint.updated_at)}
                              </p>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Cost information banner */}
                      <div className={`p-4 rounded-xl border-2 ${
                        pudoPoint.correos_tipo_punto === "Deposito"
                          ? "bg-green-50 border-green-200"
                          : "bg-orange-50 border-orange-200"
                      }`}>
                        <div className="flex items-start gap-3">
                          <Info className={`h-5 w-5 mt-0.5 shrink-0 ${
                            pudoPoint.correos_tipo_punto === "Deposito"
                              ? "text-green-600"
                              : "text-orange-600"
                          }`} />
                          <div>
                            {pudoPoint.correos_tipo_punto === "Deposito" ? (
                              <>
                                <p className="font-bold text-green-900 mb-1">
                                  ✓ ENTREGAS Y RECOGIDAS SIN COSTE
                                </p>
                                <p className="text-sm text-green-700">
                                  Has seleccionado un Depósito Brickshare. Todos tus envíos y devoluciones son completamente gratuitos.
                                </p>
                              </>
                            ) : (
                              <>
                                <p className="font-bold text-orange-900 mb-1">
                                  Coste de envío y devolución: 10 EUR
                                </p>
                                <p className="text-sm text-orange-700">
                                  Has seleccionado un punto {pudoPoint.correos_tipo_punto === "Citypaq" ? "Citypaq" : "Oficina de Correos"}. 
                                  Se aplicará un coste de 10 EUR por cada envío y devolución.
                                </p>
                              </>
                            )}
                          </div>
                        </div>
                      </div>

                      <div className="text-xs p-3 bg-blue-50 text-blue-700 rounded-xl border border-blue-100 flex items-center gap-2">
                        <Info className="h-4 w-4 shrink-0" />
                        <p>Todos tus próximos envíos y devoluciones se gestionarán por defecto a través de este punto.</p>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center py-6 flex flex-col items-center">
                      <MapPin className="h-10 w-10 text-muted-foreground/30 mb-2" />
                      <p className="text-sm text-muted-foreground mb-4">
                        No has seleccionado ningún punto de recogida.
                      </p>
                      <Button onClick={() => setIsPudoSelectorOpen(true)}>Configurar ahora</Button>
                    </div>
                  )}
                </div>
              </div>

              {/* Contact data */}
              <div className="pt-8 border-t border-border">
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center gap-2">
                    <User className="h-5 w-5 text-muted-foreground" />
                    <h2 className="text-xl font-display font-bold text-foreground">Datos de contacto</h2>
                  </div>
                  <Button variant="outline" size="sm" onClick={() => setShowProfileModal(true)}>
                    <Pencil className="h-4 w-4 mr-2" /> Editar datos
                  </Button>
                </div>
                <div className="bg-card rounded-2xl p-6 shadow-card mb-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {[
                      { icon: User, label: "Nombre", value: profile?.full_name || "No especificado" },
                      { icon: Mail, label: "Email", value: user?.email || "No especificado" },
                      {
                        icon: MapPin, label: "Dirección", value: profile?.address
                          ? `${profile.address}${profile.zip_code ? `, ${profile.zip_code}` : ""}${profile.city ? ` ${profile.city}` : ""}`
                          : "No especificada",
                      },
                      { icon: Phone, label: "Teléfono", value: profile?.phone || "No especificado" },
                    ].map(({ icon: Icon, label, value }) => (
                      <div key={label} className="flex items-start gap-3">
                        <Icon className="h-5 w-5 text-muted-foreground mt-0.5" />
                        <div>
                          <p className="text-sm text-muted-foreground">{label}</p>
                          <p className="text-foreground">{value}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Danger zone */}
                <div className="bg-destructive/5 rounded-2xl p-6 border border-destructive/20 flex flex-col md:flex-row items-center justify-between gap-6">
                  <div className="flex gap-4">
                    <div className="p-3 rounded-xl bg-destructive/10 text-destructive h-fit">
                      <AlertTriangle className="h-6 w-6" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-foreground mb-1">Zona de Peligro</h3>
                      <p className="text-sm text-muted-foreground max-w-md">
                        Al eliminar tu cuenta, todos tus datos, wishlist e historial se borrarán permanentemente.
                      </p>
                    </div>
                  </div>
                  <Button
                    variant="destructive"
                    className="shrink-0"
                    onClick={async () => {
                      if (confirm("¿Seguro que deseas eliminar tu cuenta? Esta acción es irreversible.")) {
                        const { error } = await deleteUserAccount();
                        if (error) alert("Error: " + error.message);
                      }
                    }}
                  >
                    Eliminar Cuenta
                  </Button>
                </div>
              </div>
            </TabsContent>

            {/* ── TAB: MIS ENVÍOS ───────────────────────────────────────────────── */}
            <TabsContent value="envios">
              {ordersLoading ? (
                <div className="flex justify-center py-16">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : orders.length > 0 ? (
                <div className="space-y-4">
                  {orders.map((order, index) => {
                    const cfg = STATUS_CONFIG[order.estado_envio] ?? { label: order.estado_envio, variant: "outline" as const };
                    const canReturn = index === 0 && order.estado_envio === "entregado";
                    return (
                      <div key={order.id} className="bg-card rounded-2xl shadow-card overflow-hidden">
                        {/* Header row */}
                        <div className="flex items-center gap-4 p-5 border-b border-border">
                          {order.sets?.set_image_url && (
                            <img
                              src={order.sets.set_image_url}
                              alt={order.sets.set_name}
                              className="w-14 h-14 rounded-xl object-cover bg-secondary shrink-0"
                            />
                          )}
                          <div className="flex-1 min-w-0">
                            <p className="font-semibold text-foreground truncate">
                              {order.sets?.set_name ?? "Set Desconocido"}
                            </p>
                            <p className="text-xs text-muted-foreground font-mono">
                              Ref: {order.set_ref || "—"} · Actualizado: {formatDate(order.updated_at)}
                            </p>
                          </div>
                          <div className="flex items-center gap-3 shrink-0">
                            <Badge variant={cfg.variant}>{cfg.label}</Badge>
                            {canReturn && (
                              <Button
                                size="sm"
                                variant="outline"
                                className="gap-2 text-orange-600 hover:text-orange-700 hover:bg-orange-50 border-orange-200"
                                onClick={() =>
                                  handleReturnClick(
                                    order.id,
                                    (order as any).set_id ?? undefined,
                                    order.sets?.set_name ?? undefined
                                  )
                                }
                                disabled={returnMutation.isPending}
                              >
                                <ArrowLeftRight className="h-3.5 w-3.5" />
                                Devolver
                              </Button>
                            )}
                          </div>
                        </div>

                        {/* Timeline */}
                        <div className="px-6 py-4 bg-muted/30">
                          <ShipmentTimeline
                            shipmentId={order.id}
                            status={order.estado_envio}
                            trackingNumber={(order as any).tracking_number}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div className="text-center py-16 bg-card rounded-2xl">
                  <Package className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-lg text-muted-foreground mb-2">No tienes envíos registrados</p>
                  <p className="text-sm text-muted-foreground">
                    Tus asignaciones de sets aparecerán aquí
                  </p>
                </div>
              )}
            </TabsContent>

            {/* ── TAB: REFERIDOS ────────────────────────────────────────────────── */}
            <TabsContent value="referidos">
              <div className="mb-6">
                <h2 className="text-2xl font-display font-bold text-foreground mb-1">
                  Programa de Referidos
                </h2>
                <p className="text-muted-foreground">
                  Invita a tus amigos y consigue <strong>1 mes gratis</strong> por cada uno que se
                  suscriba con tu código.
                </p>
              </div>
              <ReferralPanel />
            </TabsContent>
          </Tabs>
        </div>
      </main>

      {/* ── Modals ─────────────────────────────────────────────────────────────── */}
      <ProfileCompletionModal open={showProfileModal} onClose={() => setShowProfileModal(false)} />

      <PudoSelector
        isOpen={isPudoSelectorOpen}
        onClose={() => setIsPudoSelectorOpen(false)}
        onSelect={handlePudoSelect}
        initialZipCode={profile?.zip_code || undefined}
        initialAddress={profile?.address || undefined}
      />

      <AlertDialog open={returnDialogOpen} onOpenChange={setReturnDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>¿Confirmar devolución?</AlertDialogTitle>
            <AlertDialogDescription>
              Se cambiará el estado a "En Ruta (Devolución)". Prepara el paquete para su recogida en tu
              punto PUDO.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirmReturn}
              className="bg-orange-600 hover:bg-orange-700"
            >
              Confirmar Devolución
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Review modal — shown automatically after a return */}
      {reviewPending && (
        <ReviewModal
          open={true}
          onClose={() => setReviewPending(null)}
          setId={reviewPending.setId}
          setName={reviewPending.setName}
        />
      )}

      <Footer />
    </div>
  );
};

export default Dashboard;