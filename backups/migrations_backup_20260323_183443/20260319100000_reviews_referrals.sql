-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: reviews_referrals (reconciliation)
-- Purpose:   Ensures reviews and referrals schema is complete and consistent.
--            Runs AFTER 20260319000000 and 20260319000100 which already created
--            the base tables. This migration adds missing pieces and fixes policies.
-- ─────────────────────────────────────────────────────────────────────────────

-- ─── reviews: add missing columns if not present ─────────────────────────────
-- The reviews table was created in 20260319000000 with is_published boolean.
-- Add extra columns for richer reviews if they don't exist.
alter table public.reviews
  add column if not exists age_fit       boolean,
  add column if not exists difficulty    smallint check (difficulty between 1 and 5),
  add column if not exists would_reorder boolean;

-- ─── avg rating view (consolidated, using is_published) ──────────────────────
create or replace view public.set_avg_ratings as
  select set_id,
         round(avg(rating)::numeric, 1) as avg_rating,
         count(*) as review_count
  from public.reviews
  where is_published = true
  group by set_id;

-- ─── referrals: table already created in 20260319000100 ──────────────────────
-- Nothing to do for referrals table structure.

-- ─── users: columns already added in 20260319000100 ───────────────────────
-- Add referral_code unique constraint if not yet applied via index
-- (the index was already created in 20260319000100 via CREATE UNIQUE INDEX IF NOT EXISTS)

-- ─── Backfill referral codes for any users missing them ───────────────────
update public.users
set referral_code = upper(substring(md5(user_id::text || clock_timestamp()::text) for 7))
where referral_code is null;

-- ─── set_review_stats view (alias with simpler name) ─────────────────────────
create or replace view public.set_review_stats as
  select
    set_id,
    count(*)                                           as review_count,
    round(avg(rating)::numeric, 2)                     as avg_rating,
    count(*) filter (where rating = 5)                 as five_stars,
    count(*) filter (where rating = 4)                 as four_stars,
    count(*) filter (where rating = 3)                 as three_stars,
    count(*) filter (where rating = 2)                 as two_stars,
    count(*) filter (where rating = 1)                 as one_star,
    round(avg(difficulty)::numeric, 1)                 as avg_difficulty,
    count(*) filter (where would_reorder = true)       as would_reorder_count
  from public.reviews
  where is_published = true
  group by set_id;