-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: create_reviews_table
-- Purpose:   Allow users to rate and review LEGO sets they have rented.
--            Reviews are tied to a specific envio (rental), ensuring one review
--            per rental session. Includes star rating (1-5) + optional comment.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Table ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reviews (
    id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    set_id        UUID NOT NULL REFERENCES public.sets(id) ON DELETE CASCADE,
    envio_id      UUID REFERENCES public.envios(id) ON DELETE SET NULL,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    age_fit       BOOLEAN,          -- ¿Fue adecuado para la edad indicada?
    difficulty    SMALLINT CHECK (difficulty BETWEEN 1 AND 5),  -- 1=muy fácil, 5=muy difícil
    would_reorder BOOLEAN,          -- ¿Volvería a pedir este set?
    is_published  BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── One review per rental session ────────────────────────────────────────────
-- A user can review the same set multiple times (once per envio), 
-- but only once per envio if envio_id is provided.
CREATE UNIQUE INDEX IF NOT EXISTS reviews_envio_unique
    ON public.reviews (envio_id)
    WHERE envio_id IS NOT NULL;

-- ── General index for fetching reviews per set ───────────────────────────────
CREATE INDEX IF NOT EXISTS reviews_set_id_idx
    ON public.reviews (set_id, is_published, created_at DESC);

-- ── Index for user history ────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS reviews_user_id_idx
    ON public.reviews (user_id, created_at DESC);

-- ── Aggregate stats view (avg rating + count per set) ────────────────────────
CREATE OR REPLACE VIEW public.set_review_stats AS
SELECT
    set_id,
    COUNT(*)                                AS review_count,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    COUNT(*) FILTER (WHERE rating = 5)      AS five_stars,
    COUNT(*) FILTER (WHERE rating = 4)      AS four_stars,
    COUNT(*) FILTER (WHERE rating = 3)      AS three_stars,
    COUNT(*) FILTER (WHERE rating = 2)      AS two_stars,
    COUNT(*) FILTER (WHERE rating = 1)      AS one_star,
    ROUND(AVG(difficulty)::NUMERIC, 1)      AS avg_difficulty,
    COUNT(*) FILTER (WHERE would_reorder = true) AS would_reorder_count
FROM public.reviews
WHERE is_published = true
GROUP BY set_id;

-- ── Auto-update updated_at ────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS reviews_updated_at ON public.reviews;
CREATE TRIGGER reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Row Level Security ────────────────────────────────────────────────────────
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can read published reviews
CREATE POLICY "reviews_select_published"
    ON public.reviews
    FOR SELECT
    USING (is_published = true);

-- Users can read their own reviews (including unpublished)
CREATE POLICY "reviews_select_own"
    ON public.reviews
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Authenticated users can insert their own reviews
CREATE POLICY "reviews_insert_own"
    ON public.reviews
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own reviews
CREATE POLICY "reviews_update_own"
    ON public.reviews
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own reviews
CREATE POLICY "reviews_delete_own"
    ON public.reviews
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Admins and operadores have full access
CREATE POLICY "reviews_admin_all"
    ON public.reviews
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid()
            AND role IN ('admin', 'operador')
        )
    );

-- ── Comments ──────────────────────────────────────────────────────────────────
COMMENT ON TABLE public.reviews IS 'User reviews and ratings for rented LEGO sets';
COMMENT ON COLUMN public.reviews.rating IS '1-5 star rating';
COMMENT ON COLUMN public.reviews.difficulty IS '1=very easy, 5=very hard building difficulty';
COMMENT ON COLUMN public.reviews.would_reorder IS 'Would the user rent this set again?';
COMMENT ON COLUMN public.reviews.age_fit IS 'Was the set appropriate for the stated age range?';
COMMENT ON COLUMN public.reviews.is_published IS 'Set to false to hide a review without deleting it';