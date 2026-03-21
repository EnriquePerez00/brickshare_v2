import { useState } from "react";
import { Star, ThumbsUp, ThumbsDown, Minus } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { useSubmitReview, type SubmitReviewData } from "@/hooks/useReviews";

// ─── Types ────────────────────────────────────────────────────────────────────

interface ReviewModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  setId: string;
  setName: string;
  envioId?: string;
}

// ─── Star Rating Component ────────────────────────────────────────────────────

function StarRating({
  value,
  onChange,
  size = 28,
}: {
  value: number;
  onChange: (v: number) => void;
  size?: number;
}) {
  const [hovered, setHovered] = useState(0);
  const labels = ["", "Muy malo", "Malo", "Regular", "Bueno", "Excelente"];

  return (
    <div className="flex flex-col items-center gap-2">
      <div className="flex gap-1">
        {[1, 2, 3, 4, 5].map((star) => (
          <button
            key={star}
            type="button"
            onClick={() => onChange(star)}
            onMouseEnter={() => setHovered(star)}
            onMouseLeave={() => setHovered(0)}
            className="transition-transform hover:scale-110 focus:outline-none"
            aria-label={`${star} estrella${star > 1 ? "s" : ""}`}
          >
            <Star
              size={size}
              className={cn(
                "transition-colors",
                star <= (hovered || value)
                  ? "fill-amber-400 text-amber-400"
                  : "fill-none text-gray-300"
              )}
            />
          </button>
        ))}
      </div>
      <span className="text-sm text-muted-foreground h-5">
        {labels[hovered || value] || "Selecciona una puntuación"}
      </span>
    </div>
  );
}

// ─── Difficulty Selector ──────────────────────────────────────────────────────

function DifficultySelector({
  value,
  onChange,
}: {
  value: number | null;
  onChange: (v: number) => void;
}) {
  const levels = [
    { v: 1, label: "Muy fácil" },
    { v: 2, label: "Fácil" },
    { v: 3, label: "Normal" },
    { v: 4, label: "Difícil" },
    { v: 5, label: "Muy difícil" },
  ];

  return (
    <div className="flex gap-2 flex-wrap">
      {levels.map(({ v, label }) => (
        <button
          key={v}
          type="button"
          onClick={() => onChange(v)}
          className={cn(
            "px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
            value === v
              ? "bg-orange-500 text-white border-orange-500"
              : "bg-white text-gray-600 border-gray-200 hover:border-orange-300"
          )}
        >
          {label}
        </button>
      ))}
    </div>
  );
}

// ─── Yes/No/Skip selector ─────────────────────────────────────────────────────

function YesNoSelector({
  value,
  onChange,
  yesLabel = "Sí",
  noLabel = "No",
}: {
  value: boolean | null;
  onChange: (v: boolean | null) => void;
  yesLabel?: string;
  noLabel?: string;
}) {
  return (
    <div className="flex gap-2">
      <button
        type="button"
        onClick={() => onChange(value === true ? null : true)}
        className={cn(
          "flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
          value === true
            ? "bg-green-500 text-white border-green-500"
            : "bg-white text-gray-600 border-gray-200 hover:border-green-300"
        )}
      >
        <ThumbsUp size={12} />
        {yesLabel}
      </button>
      <button
        type="button"
        onClick={() => onChange(value === false ? null : false)}
        className={cn(
          "flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors",
          value === false
            ? "bg-red-500 text-white border-red-500"
            : "bg-white text-gray-600 border-gray-200 hover:border-red-300"
        )}
      >
        <ThumbsDown size={12} />
        {noLabel}
      </button>
    </div>
  );
}

// ─── Main Modal ───────────────────────────────────────────────────────────────

export function ReviewModal({
  open,
  onOpenChange,
  setId,
  setName,
  envioId,
}: ReviewModalProps) {
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState("");
  const [difficulty, setDifficulty] = useState<number | null>(null);
  const [ageFit, setAgeFit] = useState<boolean | null>(null);
  const [wouldReorder, setWouldReorder] = useState<boolean | null>(null);

  const submitReview = useSubmitReview();

  const handleSubmit = async () => {
    if (rating === 0) return;

    const data: SubmitReviewData = {
      set_id: setId,
      envio_id: envioId,
      rating,
      comment: comment.trim() || undefined,
      difficulty: difficulty ?? undefined,
      age_fit: ageFit ?? undefined,
      would_reorder: wouldReorder ?? undefined,
    };

    await submitReview.mutateAsync(data);
    onOpenChange(false);
    // Reset form
    setRating(0);
    setComment("");
    setDifficulty(null);
    setAgeFit(null);
    setWouldReorder(null);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-lg font-bold">
            Valorar set
          </DialogTitle>
          <DialogDescription className="text-sm text-muted-foreground">
            {setName}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-2">
          {/* Star rating */}
          <div className="flex flex-col items-center gap-1">
            <Label className="text-sm font-medium">Puntuación general *</Label>
            <StarRating value={rating} onChange={setRating} />
          </div>

          {/* Comment */}
          <div className="space-y-2">
            <Label htmlFor="review-comment" className="text-sm font-medium">
              Comentario <span className="text-muted-foreground font-normal">(opcional)</span>
            </Label>
            <Textarea
              id="review-comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="¿Qué te pareció el set? ¿Algo que destacar?"
              rows={3}
              maxLength={500}
              className="resize-none text-sm"
            />
            <p className="text-xs text-muted-foreground text-right">
              {comment.length}/500
            </p>
          </div>

          {/* Difficulty */}
          <div className="space-y-2">
            <Label className="text-sm font-medium">
              Dificultad de montaje <span className="text-muted-foreground font-normal">(opcional)</span>
            </Label>
            <DifficultySelector value={difficulty} onChange={setDifficulty} />
          </div>

          {/* Age fit */}
          <div className="space-y-2">
            <Label className="text-sm font-medium">
              ¿Fue adecuado para la edad indicada? <span className="text-muted-foreground font-normal">(opcional)</span>
            </Label>
            <YesNoSelector value={ageFit} onChange={setAgeFit} />
          </div>

          {/* Would reorder */}
          <div className="space-y-2">
            <Label className="text-sm font-medium">
              ¿Volverías a pedir este set? <span className="text-muted-foreground font-normal">(opcional)</span>
            </Label>
            <YesNoSelector
              value={wouldReorder}
              onChange={setWouldReorder}
              yesLabel="Sí, lo pediría de nuevo"
              noLabel="No"
            />
          </div>
        </div>

        <div className="flex gap-3 pt-2">
          <Button
            variant="outline"
            className="flex-1"
            onClick={() => onOpenChange(false)}
          >
            Cancelar
          </Button>
          <Button
            className="flex-1 bg-orange-500 hover:bg-orange-600"
            disabled={rating === 0 || submitReview.isPending}
            onClick={handleSubmit}
          >
            {submitReview.isPending ? "Enviando..." : "Enviar valoración"}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}