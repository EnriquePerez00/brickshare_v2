import { CheckCircle, Circle, Lock, Package, Truck } from "lucide-react";

interface ShipmentTimelineProps {
  shipmentId: string;
  status: string;
  trackingNumber?: string;
  estimatedDelivery?: string;
  swiklyStatus?: string;
}

export function ShipmentTimeline({
  shipmentId,
  status,
  trackingNumber,
  estimatedDelivery,
  swiklyStatus,
}: ShipmentTimelineProps) {
  // Determine deposit step completion
  const depositAccepted =
    swiklyStatus === "accepted" ||
    swiklyStatus === "released" ||
    swiklyStatus === "captured";

  const steps = [
    {
      key: "paid",
      label: "Pago confirmado",
      icon: CheckCircle,
      done: true, // if timeline is shown, payment is already confirmed
    },
    {
      key: "deposit",
      label: "Fianza validada",
      icon: Lock,
      done: depositAccepted,
      pending: swiklyStatus === "wish_created",
    },
    {
      key: "preparing",
      label: "Preparando envío",
      icon: Package,
      done: ["shipped", "delivered", "completed"].includes(status),
    },
    {
      key: "shipped",
      label: "En camino",
      icon: Truck,
      done: ["shipped", "delivered", "completed"].includes(status),
    },
    {
      key: "delivered",
      label: "Entregado",
      icon: CheckCircle,
      done: ["delivered", "completed"].includes(status),
    },
  ];

  return (
    <div className="mt-2">
      <div className="flex items-start justify-between gap-1">
        {steps.map((step, index) => {
          const Icon = step.icon;
          const isPending = step.pending && !step.done;

          return (
            <div key={step.key} className="flex flex-col items-center flex-1 relative">
              {/* Connector line (before) */}
              {index > 0 && (
                <div
                  className={`absolute top-4 right-1/2 h-0.5 w-full -translate-y-0 z-0 ${
                    steps[index - 1].done ? "bg-green-500" : "bg-gray-200"
                  }`}
                />
              )}

              {/* Step circle */}
              <div
                className={`relative z-10 w-8 h-8 rounded-full flex items-center justify-center border-2 ${
                  step.done
                    ? "bg-green-500 border-green-500 text-white"
                    : isPending
                    ? "bg-yellow-400 border-yellow-400 text-white"
                    : "bg-white border-gray-300 text-gray-300"
                }`}
              >
                <Icon size={14} />
              </div>

              {/* Label */}
              <p
                className={`text-xs text-center mt-1 leading-tight ${
                  step.done
                    ? "text-green-700 font-medium"
                    : isPending
                    ? "text-yellow-700 font-medium"
                    : "text-gray-400"
                }`}
              >
                {step.label}
                {isPending && (
                  <span className="block text-yellow-600">⏳ pendiente</span>
                )}
              </p>
            </div>
          );
        })}
      </div>

      {trackingNumber && (
        <p className="text-sm text-gray-600 mt-3">
          Seguimiento: <strong>{trackingNumber}</strong>
        </p>
      )}
      {estimatedDelivery && (
        <p className="text-sm text-gray-600">
          Entrega estimada:{" "}
          <strong>{new Date(estimatedDelivery).toLocaleDateString("es-ES")}</strong>
        </p>
      )}
    </div>
  );
}