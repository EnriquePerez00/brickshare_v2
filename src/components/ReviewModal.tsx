import { useState } from "react";
import { Star } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { cn } from "@/lib/utils";
import { useSubmitReview } from "@/hooks/useReviews";

interface ReviewModalProps {
  open: boolean;
  onClose: () => void;
  setId: string;
  setName: string;
}

export default function ReviewModal({ open, onClose, setId, setName }: ReviewModalProps) {
  const [rating, setRating] = useState(0);
  const [hovered, setHovered] = useState(0);
  const [comment, setComment] = useState("");
  const submit = useSubmitReview();

  const handleSubmit = async () => {
    if (rating === 0) return;
    await submit.mutateAsync({ setId, rating, comment });
    onClose();
    setRating(0);
    setComment("");
  };

  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Valora tu experiencia</DialogTitle>
          <DialogDescription>
            ¿Qué te pareció <strong>{setName}</strong>?
          </DialogDescription>
        </DialogHeader>

        {/* Star rating */}
        <div className="flex justify-center gap-2 py-4">
          {[1, 2, 3, 4, 5].map((star) => (
            <button
              key={star}
              type="button"
              className="transition-transform hover:scale-110"
              onMouseEnter={() => setHovered(star)}
              onMouseLeave={() => setHovered(0)}
              onClick={() => setRating(star)}
            >
              <Star
                className={cn(
                  "h-8 w-8 transition-colors",
                  star <= (hovered || rating)
                    ? "fill-yellow-400 text-yellow-400"
                    : "text-muted-foreground"
                )}
              />
            </button>
          ))}
        </div>

        <Textarea
          placeholder="Cuéntanos qué te gustó (opcional)…"
          rows={3}
          value={comment}
          onChange={(e) => setComment(e.target.value)}
          className="resize-none"
        />

        <div className="flex justify-end gap-3 pt-2">
          <Button variant="ghost" onClick={onClose}>
            Ahora no
          </Button>
          <Button onClick={handleSubmit} disabled={rating === 0 || submit.isPending}>
            {submit.isPending ? "Enviando…" : "Enviar reseña"}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}