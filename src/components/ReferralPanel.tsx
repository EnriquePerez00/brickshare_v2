import { useState } from "react";
import { Copy, Share2, Users, Gift, Clock, CheckCircle2, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { useMyReferral, useApplyReferralCode, useShareReferral } from "@/hooks/useReferral";
import { useAuth } from "@/contexts/AuthContext";
import { cn } from "@/lib/utils";

export default function ReferralPanel() {
  const { user } = useAuth();
  const { data, isLoading } = useMyReferral();
  const applyCode = useApplyReferralCode();
  const { shareLink, copyCode } = useShareReferral();
  const [inputCode, setInputCode] = useState("");

  if (!user) return null;

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    );
  }

  const stats = data?.stats;
  const referrals = data?.referrals ?? [];
  const code = stats?.referral_code;

  return (
    <div className="space-y-6">
      {/* Credits banner */}
      {(stats?.referral_credits ?? 0) > 0 && (
        <div className="rounded-2xl bg-gradient-to-r from-primary/10 to-accent/10 p-4 flex items-center gap-4">
          <Gift className="h-8 w-8 text-primary shrink-0" />
          <div>
            <p className="font-semibold text-foreground">
              Tienes {stats!.referral_credits} mes{stats!.referral_credits > 1 ? "es" : ""} gratis acumulado{stats!.referral_credits > 1 ? "s" : ""}
            </p>
            <p className="text-sm text-muted-foreground">Se aplicarán automáticamente en tu próxima renovación.</p>
          </div>
        </div>
      )}

      {/* Stats row */}
      <div className="grid grid-cols-3 gap-3">
        {[
          { label: "Referidos totales", value: stats?.total_referrals ?? 0, icon: Users },
          { label: "Confirmados", value: stats?.credited_referrals ?? 0, icon: CheckCircle2 },
          { label: "Pendientes", value: stats?.pending_referrals ?? 0, icon: Clock },
        ].map(({ label, value, icon: Icon }) => (
          <div key={label} className="bg-card rounded-xl p-4 shadow-card text-center">
            <Icon className="h-5 w-5 mx-auto mb-1 text-primary" />
            <p className="text-2xl font-bold text-foreground">{value}</p>
            <p className="text-xs text-muted-foreground">{label}</p>
          </div>
        ))}
      </div>

      {/* My code */}
      {code ? (
        <div className="bg-card rounded-2xl p-5 shadow-card">
          <h3 className="font-semibold text-foreground mb-3">Tu código de referido</h3>
          <div className="flex gap-2">
            <div className="flex-1 bg-muted rounded-lg px-4 py-2 font-mono text-lg font-bold tracking-widest text-center text-primary">
              {code}
            </div>
            <Button variant="outline" size="icon" onClick={() => copyCode(code)} title="Copiar código">
              <Copy className="h-4 w-4" />
            </Button>
            <Button variant="outline" size="icon" onClick={() => shareLink(code)} title="Compartir enlace">
              <Share2 className="h-4 w-4" />
            </Button>
          </div>
          <p className="mt-3 text-sm text-muted-foreground">
            Comparte este código. Cuando alguien se suscriba con él, ambos ganáis <strong>1 mes gratis</strong>.
          </p>
        </div>
      ) : null}

      {/* Apply a code (only if user hasn't used one yet) */}
      {!data?.referrals?.some((r) => r.referee_id === user.id) && (
        <div className="bg-card rounded-2xl p-5 shadow-card">
          <h3 className="font-semibold text-foreground mb-1">¿Tienes un código de referido?</h3>
          <p className="text-sm text-muted-foreground mb-3">
            Introduce el código de quien te invitó para que ambos obtengáis vuestro mes gratis.
          </p>
          <div className="flex gap-2">
            <Input
              placeholder="CÓDIGO"
              value={inputCode}
              onChange={(e) => setInputCode(e.target.value.toUpperCase())}
              className="font-mono tracking-widest"
              maxLength={10}
            />
            <Button
              onClick={() => applyCode.mutateAsync(inputCode)}
              disabled={inputCode.trim().length < 4 || applyCode.isPending}
            >
              {applyCode.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : "Aplicar"}
            </Button>
          </div>
        </div>
      )}

      {/* Referral history */}
      {referrals.length > 0 && (
        <div className="bg-card rounded-2xl overflow-hidden shadow-card">
          <div className="px-5 py-4 border-b border-border">
            <h3 className="font-semibold text-foreground">Historial de referidos</h3>
          </div>
          <ul className="divide-y divide-border">
            {referrals.map((r) => (
              <li key={r.id} className="px-5 py-3 flex items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-bold text-primary">
                    {r.referee?.full_name?.[0]?.toUpperCase() ?? "?"}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-foreground">
                      {r.referee?.full_name ?? "Usuario"}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(r.created_at).toLocaleDateString("es-ES")}
                    </p>
                  </div>
                </div>
                <Badge
                  variant={r.status === "credited" ? "default" : r.status === "rejected" ? "destructive" : "secondary"}
                  className="shrink-0"
                >
                  {r.status === "credited" ? "Confirmado" : r.status === "rejected" ? "Rechazado" : "Pendiente"}
                </Badge>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}