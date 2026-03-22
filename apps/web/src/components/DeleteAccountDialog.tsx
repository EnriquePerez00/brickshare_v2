import { useState } from "react";
import { AlertTriangle, Loader2 } from "lucide-react";
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";

interface DeleteAccountDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: () => Promise<void>;
  subscriptionType?: string | null;
}

const DeleteAccountDialog = ({
  open,
  onOpenChange,
  onConfirm,
  subscriptionType,
}: DeleteAccountDialogProps) => {
  const [confirmed, setConfirmed] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  const handleConfirm = async () => {
    if (!confirmed) return;
    setIsDeleting(true);
    try {
      await onConfirm();
    } finally {
      setIsDeleting(false);
      setConfirmed(false);
    }
  };

  const handleOpenChange = (value: boolean) => {
    if (!isDeleting) {
      onOpenChange(value);
      if (!value) {
        setConfirmed(false);
      }
    }
  };

  const hasActiveSubscription = subscriptionType && subscriptionType !== "none";

  return (
    <AlertDialog open={open} onOpenChange={handleOpenChange}>
      <AlertDialogContent className="max-w-md">
        <AlertDialogHeader>
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 rounded-full bg-destructive/10">
              <AlertTriangle className="h-6 w-6 text-destructive" />
            </div>
            <AlertDialogTitle className="text-xl">
              Dar de baja tu cuenta
            </AlertDialogTitle>
          </div>
          <AlertDialogDescription asChild>
            <div className="space-y-3 text-sm text-muted-foreground">
              <p>
                Al dar de baja tu cuenta:
              </p>
              <ul className="list-disc pl-5 space-y-1">
                {hasActiveSubscription && (
                  <li>
                    Tu suscripción <span className="font-semibold text-foreground capitalize">{subscriptionType}</span> será cancelada inmediatamente.
                  </li>
                )}
                <li>No podrás acceder a tu cuenta ni a tus datos.</li>
                <li>Tu wishlist e historial se mantendrán durante 30 días.</li>
                <li>
                  Para reactivar tu cuenta, contacta con{" "}
                  <span className="font-medium text-foreground">soporte@brickshare.es</span>.
                </li>
              </ul>
            </div>
          </AlertDialogDescription>
        </AlertDialogHeader>

        <div className="flex items-start gap-3 p-4 rounded-lg bg-destructive/5 border border-destructive/20 my-2">
          <Checkbox
            id="confirm-delete"
            checked={confirmed}
            onCheckedChange={(checked) => setConfirmed(checked === true)}
            disabled={isDeleting}
            className="mt-0.5"
          />
          <Label
            htmlFor="confirm-delete"
            className="text-sm font-medium leading-snug cursor-pointer select-none"
          >
            Confirmo que deseo dar de baja mi cuenta y entiendo las consecuencias.
          </Label>
        </div>

        <AlertDialogFooter>
          <AlertDialogCancel disabled={isDeleting}>Cancelar</AlertDialogCancel>
          <Button
            variant="destructive"
            onClick={handleConfirm}
            disabled={!confirmed || isDeleting}
          >
            {isDeleting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Procesando...
              </>
            ) : (
              "Confirmar baja"
            )}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};

export default DeleteAccountDialog;