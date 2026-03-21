import { Star, MessageSquare, ThumbsUp } from "lucide-react";
import { cn } from "@/lib/utils";
import { useSetReviews, useSetReviewStats, type Review } from "@/hooks/useReviews";
import { Skeleton } from "@/components/ui/skeleton";

// ─── Star display (read-only) ─────────────────────────────────────────────────

function StarDisplay({ rating, size = 14 }: { rating: number; size?: number }) {
  return (
    <div className="flex gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          size={size}
          className={cn(
            star <= Math.round(rating)
              ? "fill-amber-400 text-amber-400"
              : "fill-none text-gray-200"
          )}
        />
      ))}
    </div>
  );
}

// ─── Rating bar (for distribution) ───────────────────────────────────────────

function RatingBar({ label, count, total }: { label: string; count: number; total: number }) {
  const pct = total > 0 ? Math.round((count / total) * 100) : 0;
  return (
    <div className="flex items-center gap-2 text-sm">
      <span className="w-6 text-right text-muted-foreground">{label}</span>
      <Star size={12} className="fill-amber-400 text-amber-400 shrink-0" />
      <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
        <div
          className="h-full bg-amber-400 rounded-full transition-all"
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className="w-6 text-muted-foreground text-xs">{count}</span>
    </div>
  );
}

// ─── Single review card ───────────────────────────────────────────────────────

function ReviewCard({ review }: { review: Review }) {
  const authorName =
    review.profiles?.full_name
      ? review.profiles.full_name.split(" ")[0]
      : "Usuario";
  const date = new Date(review.created_at).toLocaleDateString("es-ES", {
    year: "numeric",
    month: "long",
  });

  return (
    <div className="border border-gray-100 rounded-xl p-4 space-y-2 bg-white">
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center text-orange-600 font-bold text-sm">
            {authorName[0]?.toUpperCase()}
          </div>
          <div>
            <p className="text-sm font-medium leading-none">{authorName}</p>
            <p className="text-xs text-muted-foreground mt-0.5">{date}</p>
          </div>
        </div>
        <StarDisplay rating={review.rating} />
      </div>

      {review.comment && (
        <p className="text-sm text-gray-700 leading-relaxed">{review.comment}</p>
      )}

      <div className="flex flex-wrap gap-2 pt-1">
        {review.difficulty != null && (
          <span className="text-xs bg-gray-50 text-gray-500 border border-gray-100 px-2 py-0.5 rounded-full">
            Dificultad: {["", "Muy fácil", "Fácil", "Normal", "Difícil", "Muy difícil"][review.difficulty]}
          </span>
        )}
        {review.would_reorder === true && (
          <span className="text-xs bg-green-50 text-green-600 border border-green-100 px-2 py-0.5 rounded-full flex items-center gap-1">
            <ThumbsUp size={10} /> Lo repetiría
          </span>
        )}
        {review.age_fit === true && (
          <span className="text-xs bg-blue-50 text-blue-600 border border-blue-100 px-2 py-0.5 rounded-full">
            Edad adecuada ✓
          </span>
        )}
      </div>
    </div>
  );
}

// ─── Main Section ─────────────────────────────────────────────────────────────

interface SetReviewsSectionProps {
  setId: string;
}

export function SetReviewsSection({ setId }: SetReviewsSectionProps) {
  const { data: reviews, isLoading: reviewsLoading } = useSetReviews(setId, 10);
  const { data: stats, isLoading: statsLoading } = useSetReviewStats(setId);

  const isLoading = reviewsLoading || statsLoading;

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-6 w-40" />
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-20 w-full" />
      </div>
    );
  }

  if (!stats || stats.review_count === 0) {
    return (
      <div className="flex flex-col items-center gap-2 py-10 text-center">
        <MessageSquare size={32} className="text-gray-300" />
        <p className="text-muted-foreground text-sm">
          Todavía no hay valoraciones para este set.
        </p>
        <p className="text-xs text-muted-foreground">
          ¡Sé el primero en valorarlo después de devolverlo!
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="flex flex-col sm:flex-row gap-6 p-5 bg-orange-50 rounded-2xl border border-orange-100">
        {/* Average */}
        <div className="flex flex-col items-center justify-center gap-1 sm:min-w-[100px]">
          <span className="text-4xl font-extrabold text-gray-900">
            {stats.avg_rating.toFixed(1)}
          </span>
          <StarDisplay rating={stats.avg_rating} size={16} />
          <span className="text-xs text-muted-foreground">
            {stats.review_count} valoración{stats.review_count !== 1 ? "es" : ""}
          </span>
        </div>

        {/* Distribution */}
        <div className="flex-1 space-y-1">
          <RatingBar label="5" count={stats.five_stars} total={stats.review_count} />
          <RatingBar label="4" count={stats.four_stars} total={stats.review_count} />
          <RatingBar label="3" count={stats.three_stars} total={stats.review_count} />
          <RatingBar label="2" count={stats.two_stars} total={stats.review_count} />
          <RatingBar label="1" count={stats.one_star} total={stats.review_count} />
        </div>

        {/* Extra stats */}
        {stats.would_reorder_count > 0 && (
          <div className="flex flex-col items-center justify-center gap-1 sm:min-w-[120px]">
            <span className="text-2xl font-bold text-green-600">
              {Math.round((stats.would_reorder_count / stats.review_count) * 100)}%
            </span>
            <p className="text-xs text-muted-foreground text-center leading-tight">
              lo pediría<br />de nuevo
            </p>
          </div>
        )}
      </div>

      {/* Review list */}
      <div className="space-y-3">
        {reviews?.map((review) => (
          <ReviewCard key={review.id} review={review} />
        ))}
      </div>
    </div>
  );
}