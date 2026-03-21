import { Copy, Share2, Gift, Clock, CheckCircle2, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import { useMyReferral, useShareReferral, type ReferralRecord } from "@/hooks/useReferral";

// ─── Stat card ────────────────────────────────────────────────────────────────

function StatCard({
  icon: Icon,
  label,
  value,
  accent = false,
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  accent?: boolean;
}) {
  return (
    <div
      className={cn(
        "rounded-xl p-4 flex flex-col gap-1 border",
        accent
          ? "bg-orange-50 border-orange-200"
          : "bg-gray-50 border-gray-100"
      )}
    >
      <Icon
        size={18}
        className={accent ? "text-orange-500" : "text-gray-400"}
      />
      <span
        className={cn(
          "text-2xl font-extrabold",
          accent ? "text-orange-600" : "text-gray-800"
        )}
      >
        {value}
      </span>
      <span className="text-xs text-muted-foreground">{label}</span>
    </div>
  );
}

// ─── Referral row ─────────────────────────────────────────────────────────────

function ReferralRow({ referral }: { referral: ReferralRecord }) {
  const date = new Date(referral.created_at).toLocaleDateString("es-ES", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });

  const statusConfig = {
    pending: {
      label: "Pendiente",
      className: "bg-amber-50 text-amber-700 border-amber-200",
      icon: Clock,
    },
    credited: {
      label: "Acreditado",
      className: "bg-green-50 text-green-700 border-green-200",
      icon: CheckCircle2,
    },
    rejected: {
      label: "Rechazado",
      className: "bg-red-50 text-red-700 border-red-200",
      icon: Clock,
    },
  }[referral.status];

  const { icon: StatusIcon } = statusConfig;

  return (
    <div className="flex items-center justify-between py-3 border-b border-gray-50 last:border-0">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center text-orange-600 font-bold text-xs">
          {(referral.referee?.full_name ?? "U")[0].toUpperCase()}
        </div>
        <div>
          <p className="text-sm font-medium">
            {referral.referee?.full_name ?? "Usuario referido"}
          </p>
          <p className="text-xs text-muted-foreground">{date}</p>
        </div>
      </div>
      <span
        className={cn(
          "flex items-center gap-1 text-xs font-medium px-2 py-1 rounded-full border",
          statusConfig.className
        )}
      >
        <StatusIcon size={11} />
        {statusConfig.label}
      </span>
    </div>
  );
}

// ─── Main Panel ───────────────────────────────────────────────────────────────

export function ReferralPanel() {
  const { data, isLoading } = useMyReferral();
  const { shareLink, copyCode } = useShareReferral();

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-6 w-48" />
        <div className="grid grid-cols-3 gap-3">
          <Skeleton className="h-24" />
          <Skeleton className="h-24" />
          <Skeleton className="h-24" />
        </div>
        <Skeleton className="h-16 w-full" />
      </div>
    );
  }

  const { stats, referrals } = data ?? {
    stats: {
      referral_code: null,
      referral_credits: 0,
      total_referrals: 0,
      credited_referrals: 0,
      pending_referrals: 0,
    },
    referrals: [],
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-lg font-bold flex items-center gap-2">
          <Gift size={20} className="text-orange-500" />
          Programa de referidos
        </h2>
        <p className="text-sm text-muted-foreground mt-1">
          Comparte tu código y gana un mes gratis por cada amigo que se suscriba.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-3">
        <StatCard
          icon={Gift}
          label="Créditos ganados"
          value={stats.referral_credits}
          accent
        />
        <StatCard
          icon={Users}
          label="Referidos totales"
          value={stats.total_referrals}
        />
        <StatCard
          icon={CheckCircle2}
          label="Acreditados"
          value={stats.credited_referrals}
        />
      </div>

      {/* Share code */}
      <div className="border border-orange-200 rounded-xl p-4 bg-orange-50 space-y-3">
        <p className="text-xs font-semibold text-orange-700 uppercase tracking-wider">
          Tu código personal
        </p>
        <div className="flex items-center gap-2">
          <div className="flex-1 bg-white border border-orange-200 rounded-lg px-4 py-2.5 text-center">
            <span className="text-2xl font-extrabold tracking-[0.2em] text-orange-600">
              {stats.referral_code ?? "------"}
            </span>
          </div>
          <Button
            variant="outline"
            size="icon"
            className="border-orange-200 hover:bg-orange-100"
            onClick={() => copyCode(stats.referral_code)}
            title="Copiar código"
          >
            <Copy size={16} />
          </Button>
          <Button
            className="bg-orange-500 hover:bg-orange-600 text-white"
            size="icon"
            onClick={() => shareLink(stats.referral_code)}
            title="Compartir enlace"
          >
            <Share2 size={16} />
          </Button>
        </div>
        <p className="text-xs text-orange-600">
          Tú y tu amigo recibiréis <strong>1 mes gratis</strong> cuando active su suscripción.
        </p>
      </div>

      {/* Pending credits notice */}
      {stats.pending_referrals > 0 && (
        <div className="flex items-start gap-3 p-3 bg-amber-50 border border-amber-200 rounded-xl text-sm text-amber-800">
          <Clock size={16} className="mt-0.5 shrink-0 text-amber-500" />
          <span>
            Tienes <strong>{stats.pending_referrals}</strong> referido{stats.pending_referrals > 1 ? "s" : ""} pendiente{stats.pending_referrals > 1 ? "s" : ""} de activar su suscripción.
          </span>
        </div>
      )}

      {/* Referral list */}
      {referrals.length > 0 && (
        <div>
          <h3 className="text-sm font-semibold mb-3 text-gray-700">
            Historial de referidos
          </h3>
          <div className="border border-gray-100 rounded-xl px-4 divide-y divide-gray-50">
            {referrals.map((r) => (
              <ReferralRow key={r.id} referral={r} />
            ))}
          </div>
        </div>
      )}

      {referrals.length === 0 && (
        <div className="text-center py-8 text-muted-foreground text-sm">
          <Users size={32} className="mx-auto mb-2 text-gray-200" />
          <p>Aún no has referido a nadie.</p>
          <p className="text-xs mt-1">¡Comparte tu código y empieza a ganar!</p>
        </div>
      )}
    </div>
  );
}