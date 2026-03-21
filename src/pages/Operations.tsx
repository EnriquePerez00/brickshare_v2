import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";
import { PudoSelector } from "@/components/PudoSelector";

interface Assignment {
  id: string;
  status: string;
  payment_status: string;
  swikly_status: string;
  swikly_wish_id: string | null;
  swikly_deposit_amount: number | null;
  swikly_wish_url: string | null;
  user_id: string;
  set_id: string;
  created_at: string;
  pudo_point_id: string;
  pudo_point_name: string;
  pudo_point_address: string;
  sets: {
    name: string;
    lego_ref: string;
    retail_price: number;
    weight_grams: number;
  };
  profiles: {
    full_name: string;
    email: string;
    phone: string;
    address: string;
    city: string;
    postal_code: string;
    country: string;
  };
}

// ── Swikly status badge ───────────────────────────────────────────────────────
const SWIKLY_BADGE: Record<string, { label: string; cls: string }> = {
  pending:      { label: "Fianza pendiente",    cls: "bg-gray-100 text-gray-600" },
  wish_created: { label: "Esperando validación", cls: "bg-yellow-100 text-yellow-700" },
  accepted:     { label: "Fianza validada ✓",    cls: "bg-green-100 text-green-700" },
  released:     { label: "Fianza liberada",       cls: "bg-blue-100 text-blue-700" },
  captured:     { label: "Fianza ejecutada",      cls: "bg-red-100 text-red-700" },
  expired:      { label: "Fianza expirada",       cls: "bg-orange-100 text-orange-700" },
  cancelled:    { label: "Fianza cancelada",      cls: "bg-gray-100 text-gray-500" },
};

export default function Operations() {
  const navigate = useNavigate();
  const [assignments, setAssignments] = useState<Assignment[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  useEffect(() => {
    const checkOperator = async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        navigate("/auth");
        return;
      }

      const { data: profile } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .single();

      if (profile?.role !== "admin" && profile?.role !== "operador") {
        navigate("/");
        return;
      }

      await fetchAssignments();
    };

    checkOperator();
  }, [navigate]);

  const fetchAssignments = async () => {
    const { data } = await supabase
      .from("assignments")
      .select(
        `
        id, status, payment_status, user_id, set_id, created_at,
        swikly_status, swikly_wish_id, swikly_deposit_amount, swikly_wish_url,
        pudo_point_id, pudo_point_name, pudo_point_address,
        sets (name, lego_ref, retail_price, weight_grams),
        profiles (full_name, email, phone, address, city, postal_code, country)
      `
      )
      .eq("payment_status", "paid")
      .order("created_at", { ascending: false });

    setAssignments((data as Assignment[]) || []);
    setLoading(false);
  };

  const generateLabel = async (assignment: Assignment) => {
    // Guard: don't ship until deposit is accepted
    if (assignment.swikly_status !== "accepted") {
      alert(
        "No se puede generar la etiqueta hasta que el usuario valide la fianza Swikly."
      );
      return;
    }

    try {
      const { data, error } = await supabase.functions.invoke(
        "correos-logistics",
        {
          body: {
            assignment_id: assignment.id,
            recipient_name: assignment.profiles.full_name,
            recipient_address: assignment.profiles.address,
            recipient_city: assignment.profiles.city,
            recipient_postal_code: assignment.profiles.postal_code,
            recipient_country: assignment.profiles.country || "ES",
            recipient_phone: assignment.profiles.phone,
            recipient_email: assignment.profiles.email,
            pudo_point_id: assignment.pudo_point_id,
            weight_grams: assignment.sets.weight_grams || 1000,
          },
        }
      );

      if (error) throw error;

      if (data?.label_pdf) {
        const blob = new Blob(
          [Uint8Array.from(atob(data.label_pdf), (c) => c.charCodeAt(0))],
          { type: "application/pdf" }
        );
        const url = URL.createObjectURL(blob);
        window.open(url);
      }

      await fetchAssignments();
    } catch (err) {
      console.error("Error generating label:", err);
      alert("Error al generar la etiqueta. Consulta la consola.");
    }
  };

  // ── Release or capture the Swikly deposit ────────────────────────────────
  const handleSwiklyAction = async (
    assignment: Assignment,
    action: "release" | "capture"
  ) => {
    const actionLabel = action === "release" ? "liberar" : "ejecutar";
    if (
      !confirm(
        `¿Confirmas que quieres ${actionLabel} la fianza de €${
          ((assignment.swikly_deposit_amount ?? 0) / 100).toFixed(2)
        } para el set ${assignment.sets?.name}?`
      )
    )
      return;

    setActionLoading(`${assignment.id}-${action}`);

    try {
      const { data, error } = await supabase.functions.invoke(
        "swikly-manage-wish",
        {
          body: {
            assignment_id: assignment.id,
            action,
          },
        }
      );

      if (error) throw error;
      if (data?.error) throw new Error(data.error);

      await fetchAssignments();
    } catch (err: any) {
      console.error(`Swikly ${action} error:`, err);
      alert(`Error al ${actionLabel} la fianza: ${err.message}`);
    } finally {
      setActionLoading(null);
    }
  };

  // ── Re-send Swikly wish email ────────────────────────────────────────────
  const resendSwiklyEmail = async (assignment: Assignment) => {
    setActionLoading(`${assignment.id}-resend`);
    try {
      const { data, error } = await supabase.functions.invoke(
        "create-swikly-wish",
        { body: { assignment_id: assignment.id, force: true } }
      );
      if (error) throw error;
      alert("Email de fianza reenviado correctamente.");
    } catch (err: any) {
      alert(`Error al reenviar: ${err.message}`);
    } finally {
      setActionLoading(null);
    }
  };

  const swiklyBadge = (status: string) =>
    SWIKLY_BADGE[status] ?? SWIKLY_BADGE["pending"];

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="max-w-6xl mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold mb-8">Panel de Operaciones</h1>

        {loading ? (
          <div className="text-center py-8">Cargando...</div>
        ) : (
          <div className="space-y-4">
            {assignments.map((assignment) => {
              const badge = swiklyBadge(assignment.swikly_status ?? "pending");
              const depositEur = (
                (assignment.swikly_deposit_amount ?? 0) / 100
              ).toFixed(2);
              const canShip = assignment.swikly_status === "accepted";
              const canManageDeposit =
                assignment.swikly_status === "accepted" ||
                assignment.swikly_status === "wish_created";

              return (
                <div
                  key={assignment.id}
                  className="bg-white rounded-xl p-6 shadow-sm"
                >
                  {/* ── Header ─────────────────────────────────────────── */}
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="font-semibold text-lg">
                        {assignment.sets?.name}
                      </h3>
                      <p className="text-gray-500 text-sm">
                        {assignment.profiles?.full_name} •{" "}
                        {assignment.profiles?.email}
                      </p>
                      <p className="text-gray-500 text-sm">
                        Ref: {assignment.sets?.lego_ref} • PVP: €
                        {assignment.sets?.retail_price} • Peso:{" "}
                        {assignment.sets?.weight_grams}g
                      </p>
                      {assignment.pudo_point_name && (
                        <p className="text-gray-500 text-sm">
                          PUDO: {assignment.pudo_point_name} •{" "}
                          {assignment.pudo_point_address}
                        </p>
                      )}
                    </div>

                    {/* ── Status badges ───────────────────────────────── */}
                    <div className="flex flex-col items-end gap-2">
                      <span
                        className={`px-3 py-1 rounded-full text-sm ${
                          assignment.status === "shipped"
                            ? "bg-blue-100 text-blue-700"
                            : "bg-gray-100 text-gray-700"
                        }`}
                      >
                        Envío: {assignment.status}
                      </span>
                      <span
                        className={`px-3 py-1 rounded-full text-sm font-medium ${badge.cls}`}
                      >
                        {badge.label}
                      </span>
                      {assignment.swikly_deposit_amount && (
                        <span className="text-xs text-gray-500">
                          Fianza: €{depositEur}
                        </span>
                      )}
                    </div>
                  </div>

                  {/* ── Action buttons ──────────────────────────────────── */}
                  <div className="mt-4 flex gap-2 flex-wrap items-center">
                    {/* Generate Correos label — blocked until deposit accepted */}
                    <button
                      onClick={() => generateLabel(assignment)}
                      disabled={
                        assignment.status === "shipped" ||
                        !canShip ||
                        actionLoading !== null
                      }
                      className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
                        canShip && assignment.status !== "shipped"
                          ? "bg-blue-500 text-white hover:bg-blue-600"
                          : "bg-gray-200 text-gray-400 cursor-not-allowed"
                      }`}
                      title={
                        !canShip
                          ? "El usuario debe validar la fianza antes de generar la etiqueta"
                          : ""
                      }
                    >
                      {canShip
                        ? "📦 Generar etiqueta Correos"
                        : "🔒 Etiqueta bloqueada (fianza pendiente)"}
                    </button>

                    {/* Swikly: re-send deposit email */}
                    {(assignment.swikly_status === "wish_created" ||
                      assignment.swikly_status === "expired") && (
                      <button
                        onClick={() => resendSwiklyEmail(assignment)}
                        disabled={actionLoading !== null}
                        className="px-3 py-1.5 bg-yellow-500 text-white rounded-lg text-sm hover:bg-yellow-600 disabled:opacity-50"
                      >
                        {actionLoading === `${assignment.id}-resend`
                          ? "Enviando..."
                          : "📧 Reenviar email fianza"}
                      </button>
                    )}

                    {/* Swikly: release deposit */}
                    {assignment.swikly_status === "accepted" &&
                      assignment.status === "completed" && (
                        <button
                          onClick={() => handleSwiklyAction(assignment, "release")}
                          disabled={actionLoading !== null}
                          className="px-3 py-1.5 bg-green-500 text-white rounded-lg text-sm hover:bg-green-600 disabled:opacity-50"
                        >
                          {actionLoading === `${assignment.id}-release`
                            ? "Liberando..."
                            : "🔓 Liberar fianza"}
                        </button>
                      )}

                    {/* Swikly: capture deposit (damage) */}
                    {(assignment.swikly_status === "accepted") && (
                      <button
                        onClick={() => handleSwiklyAction(assignment, "capture")}
                        disabled={actionLoading !== null}
                        className="px-3 py-1.5 bg-red-500 text-white rounded-lg text-sm hover:bg-red-600 disabled:opacity-50"
                      >
                        {actionLoading === `${assignment.id}-capture`
                          ? "Ejecutando..."
                          : "⚠️ Ejecutar fianza (daños)"}
                      </button>
                    )}

                    {/* Swikly external link */}
                    {assignment.swikly_wish_url && (
                      <a
                        href={assignment.swikly_wish_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="px-3 py-1.5 bg-gray-100 text-gray-700 rounded-lg text-sm hover:bg-gray-200"
                      >
                        🔗 Ver en Swikly
                      </a>
                    )}
                  </div>

                  {/* ── Warning: deposit not yet validated ──────────────── */}
                  {!canShip &&
                    assignment.payment_status === "paid" &&
                    assignment.swikly_status !== "released" &&
                    assignment.swikly_status !== "captured" && (
                      <p className="mt-3 text-sm text-yellow-700 bg-yellow-50 border border-yellow-200 rounded-lg px-3 py-2">
                        ⏳ Pendiente de que el usuario valide la fianza Swikly antes de
                        proceder con el envío.
                      </p>
                    )}
                </div>
              );
            })}
          </div>
        )}
      </div>
      <Footer />
    </div>
  );
}