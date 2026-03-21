import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useNavigate, Link, useSearchParams } from "react-router-dom";
import { Blocks, Mail, Lock, User, Eye, EyeOff, Loader2, ArrowLeft, Check, Sparkles, LogIn, UserPlus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";
import { z } from "zod";

const emailSchema = z.string().email("Email no válido");
const passwordSchema = z.string()
  .min(8, "La contraseña debe tener al menos 8 caracteres")
  .regex(/[A-Z]/, "Debe contener al menos una mayúscula")
  .regex(/[0-9]/, "Debe contener al menos un número");

const Auth = () => {
  const [searchParams] = useSearchParams();
  const type = searchParams.get("type");

  const onlySignup = searchParams.get("onlySignup") === "true";

  const [mode, setMode] = useState<"login" | "signup" | "update-password">(
    type === "recovery" ? "update-password" : (searchParams.get("mode") === "signup" || onlySignup ? "signup" : "login")
  );

  useEffect(() => {
    if (onlySignup) {
      setMode("signup");
    }
  }, [onlySignup]);

  const [email, setEmail] = useState("");
  const [isForgotPasswordOpen, setIsForgotPasswordOpen] = useState(false);
  const [forgotPasswordEmail, setForgotPasswordEmail] = useState("");
  const [isForgotPasswordSubmitting, setIsForgotPasswordSubmitting] = useState(false);
  const [isVerificationOpen, setIsVerificationOpen] = useState(false);
  const [registeredEmail, setRegisteredEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [policyAccepted, setPolicyAccepted] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<{ email?: string; password?: string; confirmPassword?: string; policy?: string }>({});

  const { signIn, signUp, signInWithGoogle, resetPassword, updateUserPassword, user, isAdmin, isOperador, isLoading: authLoading } = useAuth();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [isGoogleLoading, setIsGoogleLoading] = useState(false);

  const redirectBasedOnRole = () => {
    if (isAdmin) {
      navigate("/admin");
    } else if (isOperador) {
      navigate("/operaciones");
    } else {
      navigate("/");
    }
  };

  useEffect(() => {
    if (user && !authLoading) {
      redirectBasedOnRole();
    }
  }, [user, isAdmin, isOperador, authLoading, navigate]);

  const validateForm = () => {
    const newErrors: { email?: string; password?: string; confirmPassword?: string; policy?: string } = {};

    if (mode !== "update-password") {
      const emailResult = emailSchema.safeParse(email);
      if (!emailResult.success) {
        newErrors.email = emailResult.error.errors[0].message;
      }
    }

    const passwordResult = passwordSchema.safeParse(password);
    if (!passwordResult.success) {
      newErrors.password = passwordResult.error.errors[0].message;
    }

    if (mode === "update-password") {
      if (password !== confirmPassword) {
        newErrors.confirmPassword = "Las contraseñas no coinciden";
      }
    }

    if (mode === "signup" && !policyAccepted) {
      newErrors.policy = "Debes aceptar la política de privacidad";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;

    setIsSubmitting(true);

    if (mode === "login") {
      const { error } = await signIn(email, password);
      if (error) {
        toast({
          title: "Error al iniciar sesión",
          description: error.message === "Invalid login credentials"
            ? "Credenciales incorrectas"
            : error.message,
          variant: "destructive",
        });
      } else {
        toast({
          title: "¡Bienvenido de nuevo!",
          description: "Has iniciado sesión correctamente",
        });
      }
    } else if (mode === "signup") {
      const { error } = await signUp(email, password, fullName);
      if (error) {
        let errorMessage = error.message;
        if (error.message.includes("already registered")) {
          errorMessage = "Este email ya está registrado";
        }
        toast({
          title: "Error al registrarse",
          description: errorMessage,
          variant: "destructive",
        });
      } else {
        setRegisteredEmail(email);
        setIsVerificationOpen(true);
      }

    } else if (mode === "update-password") {
      const { error } = await updateUserPassword(password);
      if (error) {
        toast({
          title: "Error",
          description: error.message,
          variant: "destructive",
        });
      } else {
        toast({
          title: "Contraseña actualizada",
          description: "Tu contraseña ha sido cambiada correctamente. Por favor, inicia sesión.",
        });
        setMode("login");
        navigate("/auth"); // Reset query params to avoid staying in recovery mode
      }
    }

    setIsSubmitting(false);
  };

  const handleForgotPasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const emailResult = emailSchema.safeParse(forgotPasswordEmail);
    if (!emailResult.success) {
      toast({ title: "Error", description: emailResult.error.errors[0].message, variant: "destructive" });
      return;
    }

    setIsForgotPasswordSubmitting(true);
    const { error } = await resetPassword(forgotPasswordEmail);
    setIsForgotPasswordSubmitting(false);

    if (error) {
      toast({ title: "Error", description: error.message, variant: "destructive" });
    } else {
      toast({ title: "Email enviado", description: "Revisa tu bandeja de entrada para recuperar tu contraseña" });
      setIsForgotPasswordOpen(false);
      setForgotPasswordEmail("");
    }
  };

  const handleGoogleSignIn = async () => {
    setIsGoogleLoading(true);
    const { error } = await signInWithGoogle();
    if (error) {
      toast({
        title: "Error con Google",
        description: error.message,
        variant: "destructive",
      });
      setIsGoogleLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col items-center justify-center px-4 py-12 relative overflow-hidden">
      {/* Background blobs for aesthetics */}
      <div className="absolute top-0 right-0 -translate-y-1/2 translate-x-1/2 w-[500px] h-[500px] bg-primary/5 rounded-full blur-3xl -z-10" />
      <div className="absolute bottom-0 left-0 translate-y-1/2 -translate-x-1/2 w-[400px] h-[400px] bg-accent/5 rounded-full blur-3xl -z-10" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md"
      >
        {/* Logo */}
        <div className="text-center mb-8">
          <Link to="/" className="inline-flex items-center gap-2 group">
            <div className="p-2 rounded-xl gradient-hero group-hover:scale-105 transition-transform duration-300 shadow-lg shadow-primary/20">
              <Blocks className="h-7 w-7 text-primary-foreground" />
            </div>
            <span className="text-3xl font-display font-bold tracking-tight text-foreground">
              Brickshare
            </span>
          </Link>
        </div>

        {/* Form Card */}
        <div className="bg-card rounded-3xl shadow-card border border-border/50 overflow-hidden">
          {(mode === "login" || mode === "signup") ? (
            <div className="w-full">
              {!onlySignup && (
                <Tabs
                  value={mode}
                  onValueChange={(v) => setMode(v as "login" | "signup")}
                  className="w-full"
                >
                  <TabsList className="grid w-full grid-cols-2 p-1 bg-muted/50 rounded-none h-14">
                    <TabsTrigger
                      value="login"
                      className="rounded-none h-full data-[state=active]:bg-card data-[state=active]:shadow-none border-b-2 border-transparent data-[state=active]:border-primary transition-all duration-300"
                    >
                      <LogIn className="w-4 h-4 mr-2" />
                      Entrar
                    </TabsTrigger>
                    <TabsTrigger
                      value="signup"
                      className="rounded-none h-full data-[state=active]:bg-card data-[state=active]:shadow-none border-b-2 border-transparent data-[state=active]:border-primary transition-all duration-300"
                    >
                      <UserPlus className="w-4 h-4 mr-2" />
                      Registrarse
                    </TabsTrigger>
                  </TabsList>
                </Tabs>
              )}

              <div className="p-8">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={mode}
                    initial={{ opacity: 0, x: mode === "login" ? -10 : 10 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: mode === "login" ? 10 : -10 }}
                    transition={{ duration: 0.2 }}
                  >
                    <div className="mb-6">
                      <h1 className="text-2xl font-display font-bold text-foreground mb-1">
                        {mode === "login" ? "¡Hola de nuevo!" : "Registra nuevo usuario"}
                      </h1>
                      <p className="text-muted-foreground text-sm">
                        {mode === "login"
                          ? "Accede para gestionar tus sets y wishlist"
                          : "Únete a la revolución de la suscripción circular"}
                      </p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-4">
                      {mode === "signup" && (
                        <div className="space-y-2">
                          <Label htmlFor="fullName" className="text-sm font-medium">Nombre completo</Label>
                          <div className="relative">
                            <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground transition-colors group-focus-within:text-primary" />
                            <Input
                              id="fullName"
                              type="text"
                              placeholder="Tu nombre"
                              value={fullName}
                              onChange={(e) => setFullName(e.target.value)}
                              className="pl-10 h-11 bg-muted/30 border-border/50 focus-visible:ring-primary/20"
                              required
                            />
                          </div>
                        </div>
                      )}

                      <div className="space-y-2">
                        <Label htmlFor="email" className="text-sm font-medium">Email</Label>
                        <div className="relative">
                          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground transition-colors" />
                          <Input
                            id="email"
                            type="email"
                            placeholder="tu@email.com"
                            value={email}
                            onChange={(e) => {
                              setEmail(e.target.value);
                              setErrors((prev) => ({ ...prev, email: undefined }));
                            }}
                            className={`pl-10 h-11 bg-muted/30 border-border/50 focus-visible:ring-primary/20 ${errors.email ? "border-destructive focus-visible:ring-destructive/20" : ""}`}
                            required
                          />
                        </div>
                        {errors.email && (
                          <p className="text-xs text-destructive mt-1 flex items-center gap-1">
                            <span className="w-1 h-1 rounded-full bg-destructive" />
                            {errors.email}
                          </p>
                        )}
                      </div>

                      <div className="space-y-2">
                        <div className="flex justify-between items-center">
                          <Label htmlFor="password" className="text-sm font-medium">Contraseña</Label>
                          {mode === "login" && (
                            <button
                              type="button"
                              onClick={() => setIsForgotPasswordOpen(true)}
                              className="text-xs text-primary font-medium hover:text-primary/80 transition-colors"
                            >
                              ¿Olvidaste tu contraseña?
                            </button>
                          )}
                        </div>
                        <div className="relative">
                          <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground transition-colors" />
                          <Input
                            id="password"
                            type={showPassword ? "text" : "password"}
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => {
                              setPassword(e.target.value);
                              setErrors((prev) => ({ ...prev, password: undefined }));
                            }}
                            className={`pl-10 pr-10 h-11 bg-muted/30 border-border/50 focus-visible:ring-primary/20 ${errors.password ? "border-destructive focus-visible:ring-destructive/20" : ""}`}
                            required
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                          >
                            {showPassword ? (
                              <EyeOff className="h-4 w-4" />
                            ) : (
                              <Eye className="h-4 w-4" />
                            )}
                          </button>
                        </div>
                        {errors.password && (
                          <p className="text-xs text-destructive mt-1 flex items-center gap-1">
                            <span className="w-1 h-1 rounded-full bg-destructive" />
                            {errors.password}
                          </p>
                        )}
                      </div>

                      {mode === "signup" && (
                        <div className="space-y-3 pt-2">
                          <div className="flex items-start space-x-2">
                            <Checkbox
                              id="policy"
                              checked={policyAccepted}
                              onCheckedChange={(checked) => {
                                setPolicyAccepted(checked === true);
                                setErrors(prev => ({ ...prev, policy: undefined }));
                              }}
                              className="mt-0.5"
                            />
                            <label
                              htmlFor="policy"
                              className="text-xs leading-normal text-muted-foreground"
                            >
                              He leído y acepto la{" "}
                              <Link to="/privacidad" className="text-primary hover:underline font-medium">
                                Política de Privacidad
                              </Link>
                              .
                            </label>
                          </div>
                          {errors.policy && (
                            <p className="text-xs text-destructive">{errors.policy}</p>
                          )}

                          <div className="bg-primary/5 rounded-xl p-3 border border-primary/10 flex gap-3 items-start">
                            <Sparkles className="w-5 h-5 text-primary shrink-0 mt-0.5" />
                            <div className="text-[11px] text-primary-foreground/90 text-navy">
                              <p className="font-bold mb-0.5">Ventajas de registrarse:</p>
                              <ul className="list-disc list-inside space-y-0.5 opacity-80">
                                <li>Gestiona tu wishlist personalizada</li>
                                <li>Accede a ofertas exclusivas</li>
                                <li>Historial de sets construidos</li>
                              </ul>
                            </div>
                          </div>
                        </div>
                      )}

                      <Button
                        type="submit"
                        disabled={isSubmitting}
                        className="w-full h-11 gradient-hero font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-[0.98] transition-all"
                      >
                        {isSubmitting ? (
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        ) : (
                          mode === "login" ? "Iniciar sesión" : "Crea usuario"
                        )}
                      </Button>
                    </form>

                    <div className="relative my-8">
                      <div className="absolute inset-0 flex items-center">
                        <div className="w-full border-t border-border/60" />
                      </div>
                      <div className="relative flex justify-center text-xs uppercase">
                        <span className="bg-card px-4 text-muted-foreground font-medium tracking-wider">
                          O continúa con
                        </span>
                      </div>
                    </div>

                    <Button
                      type="button"
                      variant="outline"
                      onClick={handleGoogleSignIn}
                      disabled={isGoogleLoading || isSubmitting}
                      className="w-full h-11 border-border/60 hover:bg-muted/50 hover:border-border transition-all flex items-center justify-center gap-3"
                    >
                      {isGoogleLoading ? (
                        <Loader2 className="h-4 w-4 animate-spin text-primary" />
                      ) : (
                        <>
                          <svg className="h-5 w-5" viewBox="0 0 24 24">
                            <path
                              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                              fill="#4285F4"
                            />
                            <path
                              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                              fill="#34A853"
                            />
                            <path
                              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                              fill="#FBBC05"
                            />
                            <path
                              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                              fill="#EA4335"
                            />
                          </svg>
                          <span className="font-semibold text-foreground/80">Google</span>
                        </>
                      )}
                    </Button>
                  </motion.div>
                </AnimatePresence>
              </div>
            </div>
          ) : (
            /* Update Password View */
            <div className="p-8">
              <h1 className="text-2xl font-display font-bold text-foreground text-center mb-2">
                Nueva contraseña
              </h1>
              <p className="text-muted-foreground text-center text-sm mb-8">
                Introduce tu nueva contraseña segura
              </p>

              <form onSubmit={handleSubmit} className="space-y-4">
                <>
                  <>
                    <div className="space-y-2">
                      <Label htmlFor="password">Nueva contraseña</Label>
                      <div className="relative">
                        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                        <Input
                          id="password"
                          type={showPassword ? "text" : "password"}
                          placeholder="••••••••"
                          value={password}
                          onChange={(e) => setPassword(e.target.value)}
                          className="pl-10 h-11 bg-muted/30 border-border/50"
                          required
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="confirmPassword">Confirmar contraseña</Label>
                      <div className="relative">
                        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                        <Input
                          id="confirmPassword"
                          type="password"
                          placeholder="Repite la contraseña"
                          value={confirmPassword}
                          onChange={(e) => setConfirmPassword(e.target.value)}
                          className="pl-10 h-11 bg-muted/30 border-border/50"
                          required
                        />
                      </div>
                    </div>
                  </>
                </>

                <Button
                  type="submit"
                  disabled={isSubmitting}
                  className="w-full h-11 gradient-hero font-bold mt-4"
                >
                  {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Actualizar contraseña
                </Button>
              </form>
            </div>
          )}
        </div>

        {/* Password Reset Dialog */}
        <Dialog open={isForgotPasswordOpen} onOpenChange={setIsForgotPasswordOpen}>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle>Recuperar contraseña</DialogTitle>
              <DialogDescription>
                Introduce tu email y te enviaremos un enlace para restablecer tu contraseña.
              </DialogDescription>
            </DialogHeader>
            <form onSubmit={handleForgotPasswordSubmit} className="space-y-4 pt-4">
              <div className="space-y-2">
                <Label htmlFor="forgot-email">Email</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="forgot-email"
                    type="email"
                    placeholder="tu@email.com"
                    value={forgotPasswordEmail}
                    onChange={(e) => setForgotPasswordEmail(e.target.value)}
                    className="pl-10 h-11 bg-muted/30 border-border/50"
                    required
                  />
                </div>
              </div>
              <Button type="submit" disabled={isForgotPasswordSubmitting} className="w-full gradient-hero font-bold">
                {isForgotPasswordSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Enviar enlace
              </Button>
            </form>
          </DialogContent>
        </Dialog>

        {/* Verification Dialog */}
        <Dialog open={isVerificationOpen} onOpenChange={(open) => {
          setIsVerificationOpen(open);
          if (!open) setMode("login");
        }}>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle>Verifica tu cuenta</DialogTitle>
              <DialogDescription>
                Hemos enviado un correo a <span className="font-semibold">{registeredEmail}</span> para confirmar tu registro.
              </DialogDescription>
            </DialogHeader>
            <div className="flex flex-col items-center justify-center py-6 space-y-4 text-center">
              <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center">
                <Mail className="h-6 w-6 text-primary" />
              </div>
              <p className="text-sm text-muted-foreground">
                Por favor, revisa tu bandeja de entrada o la carpeta de spam y haz clic en el enlace para activar tu cuenta.
              </p>
              <Button type="button" onClick={() => {
                setIsVerificationOpen(false);
                setMode("login");
              }} className="w-full font-bold mt-2">
                Entendido
              </Button>
            </div>
          </DialogContent>
        </Dialog>

        {/* Footer info */}
        <p className="mt-8 text-center text-xs text-muted-foreground/60">
          Al continuar, aceptas nuestros{" "}
          <Link to="/terminos" className="hover:text-primary underline transition-colors">Términos de Servicio</Link>
          {" "}y{" "}
          <Link to="/privacidad" className="hover:text-primary underline transition-colors">Política de Privacidad</Link>.
        </p>
      </motion.div>
    </div>
  );
};

export default Auth;

