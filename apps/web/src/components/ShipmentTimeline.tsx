import {
  PackageCheck,
  Truck,
  Home,
  RotateCcw,
  CheckCircle2,
  Clock,
  AlertCircle,
} from "lucide-react";
import { cn } from "@/lib/utils";

// ─── Types ────────────────────────────────────────────────────────────────────

export type ShipmentStatus =
  | "pending"
  | "prepared"
  | "in_transit"
  | "delivered"
  | "return_requested"
  | "return_in_transit"
  | "returned"
  | "cancelled";

interface TimelineStep {
  key: ShipmentStatus;
  label: string;
  description: string;
  icon: React.ElementType;
}

// ─── Step definitions ─────────────────────────────────────────────────────────

const OUTBOUND_STEPS: TimelineStep[] = [
  {
    key: "pending",
    label: "Pedido confirmado",
    description: "Hemos recibido tu pedido y lo estamos preparando.",
    icon: Clock,
  },
  {
    key: "prepared",
    label: "Set preparado",
    description: "El set ha sido inspeccionado y embalado.",
    icon: PackageCheck,
  },
  {
    key: "in_transit",
    label: "En camino",
    description: "Tu set está en tránsito con Correos.",
    icon: Truck,
  },
  {
    key: "delivered",
    label: "Entregado",
    description: "Set entregado. ¡Disfrútalo!",
    icon: Home,
  },
];

const RETURN_STEPS: TimelineStep[] = [
  {
    key: "return_requested",
    label: "Devolución solicitada",
    description: "Hemos generado tu etiqueta de devolución.",
    icon: RotateCcw,
  },
  {
    key: "return_in_transit",
    label: "Devolución en tránsito",
    description: "El set está de camino a nuestro almacén.",
    icon: Truck,
  },
  {
    key: "returned",
    label: "Devolución completada",
    description: "Hemos recibido el set. ¡Gracias!",
    icon: CheckCircle2,
  },
];

// ─── Status helpers ───────────────────────────────────────────────────────────

type StepState = "completed" | "current" | "upcoming";

function getOutboundStepState(
  stepKey: ShipmentStatus,
  currentStatus: ShipmentStatus
): StepState {
  const order: ShipmentStatus[] = ["pending", "prepared", "in_transit", "delivered"];
  const returnOrder: ShipmentStatus[] = [
    "return_requested",
    "return_in_transit",
    "returned",
  ];

  const stepIdx = order.indexOf(stepKey);
  const currentIdx = order.indexOf(currentStatus);
  const isInReturn = returnOrder.includes(currentStatus);

  if (isInReturn || currentStatus === "returned") return "completed";
  if (currentIdx < 0) return "upcoming";
  if (stepIdx < currentIdx) return "completed";
  if (stepIdx === currentIdx) return "current";
  return "upcoming";
}

function getReturnStepState(
  stepKey: ShipmentStatus,
  currentStatus: ShipmentStatus
): StepState {
  const order: ShipmentStatus[] = [
    "return_requested",
    "return_in_transit",
    "returned",
  ];
  const stepIdx = order.indexOf(stepKey);
  const currentIdx = order.indexOf(currentStatus);

  if (currentIdx < 0) return "upcoming";
  if (stepIdx < currentIdx) return "completed";
  if (stepIdx === currentIdx) return "current";
  return "upcoming";
}

// ─── Single step ──────────────────────────────────────────────────────────────

function TimelineStepItem({
  step,
  state,
  isLast,
  timestamp,
}: {
  step: TimelineStep;
  state: StepState;
  isLast: boolean;
  timestamp?: string;
}) {
  const Icon = step.icon;

  const iconStyles: Record<StepState, string> = {
    completed:
      "bg-green-500 text-white border-green-500 shadow-sm shadow-green-200",
    current:
      "bg-orange-500 text-white border-orange-500 shadow-sm shadow-orange-200 ring-4 ring-orange-100",
    upcoming: "bg-white text-gray-300 border-gray-200",
  };

  const labelStyles: Record<StepState, string> = {
    completed: "text-gray-700 font-medium",
    current: "text-orange-600 font-semibold",
    upcoming: "text-gray-400",
  };

  const connectorStyles: Record<StepState, string> = {
    completed: "bg-green-300",
    current: "bg-gradient-to-b from-green-300 to-gray-200",
    upcoming: "bg-gray-200",
  };

  const formattedDate = timestamp
    ? new Date(timestamp).toLocaleDateString("es-ES", {
        day: "numeric",
        month: "short",
        hour: "2-digit",
        minute: "2-digit",
      })
    : null;

  return (
    <div className="flex gap-4">
      {/* Icon + connector */}
      <div className="flex flex-col items-center">
        <div
          className={cn(
            "w-9 h-9 rounded-full border-2 flex items-center justify-center transition-all shrink-0",
            iconStyles[state]
          )}
        >
          <Icon size={16} />
        </div>
        {!isLast && (
          <div className={cn("w-0.5 flex-1 mt-1 min-h-[28px]", connectorStyles[state])} />
        )}
      </div>

      {/* Content */}
      <div className={cn("pb-6 flex-1", isLast && "pb-0")}>
        <div className="flex items-baseline justify-between gap-2">
          <p className={cn("text-sm", labelStyles[state])}>{step.label}</p>
          {formattedDate && state !== "upcoming" && (
            <span className="text-xs text-muted-foreground shrink-0">{formattedDate}</span>
          )}
        </div>
        {state !== "upcoming" && (
          <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed">
            {step.description}
          </p>
        )}
      </div>
    </div>
  );
}

// ─── Section divider ──────────────────────────────────────────────────────────

function SectionDivider({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-2 my-2">
      <div className="flex-1 h-px bg-gray-100" />
      <span className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider whitespace-nowrap">
        {label}
      </span>
      <div className="flex-1 h-px bg-gray-100" />
    </div>
  );
}

// ─── Main component ───────────────────────────────────────────────────────────

interface ShipmentTimelineProps {
  status: ShipmentStatus;
  timestamps?: Partial<Record<ShipmentStatus, string>>;
  trackingCode?: string;
  returnCode?: string;
  className?: string;
}

export function ShipmentTimeline({
  status,
  timestamps = {},
  trackingCode,
  returnCode,
  className,
}: ShipmentTimelineProps) {
  const isReturnPhase = [
    "return_requested",
    "return_in_transit",
    "returned",
  ].includes(status);

  const isCancelled = status === "cancelled";

  if (isCancelled) {
    return (
      <div className={cn("flex items-center gap-3 p-4 bg-red-50 rounded-xl border border-red-100", className)}>
        <AlertCircle size={20} className="text-red-400 shrink-0" />
        <div>
          <p className="text-sm font-medium text-red-700">Pedido cancelado</p>
          <p className="text-xs text-red-500 mt-0.5">
            Este pedido fue cancelado. Contacta con soporte si tienes dudas.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className={cn("", className)}>
      {/* Outbound steps */}
      <div>
        {OUTBOUND_STEPS.map((step, i) => (
          <TimelineStepItem
            key={step.key}
            step={step}
            state={getOutboundStepState(step.key, status)}
            isLast={i === OUTBOUND_STEPS.length - 1 && !isReturnPhase}
            timestamp={timestamps[step.key]}
          />
        ))}
      </div>

      {/* Tracking code */}
      {trackingCode && ["in_transit", "delivered"].includes(status) && (
        <div className="mx-0 mb-4 p-3 bg-blue-50 border border-blue-100 rounded-xl">
          <p className="text-[11px] font-semibold text-blue-500 uppercase tracking-wider mb-1">
            Código de seguimiento Correos
          </p>
          <p className="text-sm font-mono font-bold text-blue-800 tracking-widest">
            {trackingCode}
          </p>
        </div>
      )}

      {/* Return steps */}
      {isReturnPhase && (
        <>
          <SectionDivider label="Devolución" />
          {RETURN_STEPS.map((step, i) => (
            <TimelineStepItem
              key={step.key}
              step={step}
              state={getReturnStepState(step.key, status)}
              isLast={i === RETURN_STEPS.length - 1}
              timestamp={timestamps[step.key]}
            />
          ))}
          {/* Return code */}
          {returnCode && (
            <div className="mt-2 p-3 bg-green-50 border border-green-100 rounded-xl">
              <p className="text-[11px] font-semibold text-green-600 uppercase tracking-wider mb-1">
                Código de devolución Correos
              </p>
              <p className="text-sm font-mono font-bold text-green-800 tracking-widest">
                {returnCode}
              </p>
            </div>
          )}
        </>
      )}
    </div>
  );
}