# Brickshare — Development Roadmap

> Last updated: 19 March 2026  
> Status legend: ✅ Done · 🚧 In progress · 📋 Planned · ❌ Blocked

---

## Sprint 1 — Foundation & Quality (DONE ✅)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Remove debug files from root (`check_*.js`, `quick_scope_test*.js`, etc.) | ✅ | Cleaned |
| 1.2 | CI/CD — GitHub Actions pipeline | ✅ | `.github/workflows/ci.yml` |
| 1.3 | Unit tests — `useProducts`, `useOrders`, `useWishlist` | ✅ | `apps/web/src/test/unit/hooks/` |
| 1.4 | Vitest config for monorepo (`apps/web`) | ✅ | `apps/web/vitest.config.ts` |

---

## Sprint 2 — Transactional Emails & DB Foundations (DONE ✅)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Email templates system (`send-email` Edge Function) | ✅ | `supabase/functions/send-email/templates.ts` |
| 2.2 | Templates: welcome, shipment sent, return confirmed | ✅ | 6 templates total |
| 2.3 | Templates: subscription changed/cancelled, wishlist match, review request | ✅ | Part of `templates.ts` |
| 2.4 | DB migration — `reviews` table + `set_review_stats` view | ✅ | `supabase/migrations/20260319000000_create_reviews_table.sql` |
| 2.5 | DB migration — `referrals` table + `profiles` referral columns | ✅ | `supabase/migrations/20260319000100_create_referrals_table.sql` |

---

## Sprint 3 — User-Facing Features (DONE ✅)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 3.1 | `useReviews` hook (set reviews, stats, submit, delete) | ✅ | `apps/web/src/hooks/useReviews.ts` |
| 3.2 | `ReviewModal` component (star rating, difficulty, age fit) | ✅ | `apps/web/src/components/ReviewModal.tsx` |
| 3.3 | `SetReviewsSection` component (summary + rating bars + list) | ✅ | `apps/web/src/components/SetReviewsSection.tsx` |
| 3.4 | `useCatalogueFilters` hook (search, theme, age, pieces, sort, pagination) | ✅ | `apps/web/src/hooks/useCatalogueFilters.ts` |
| 3.5 | `CatalogueFilterBar` + `CatalogueFilterTrigger` components | ✅ | `apps/web/src/components/CatalogueFilters.tsx` |
| 3.6 | `ShipmentTimeline` component (tracking timeline with return phase) | ✅ | `apps/web/src/components/ShipmentTimeline.tsx` |

---

## Sprint 4 — Growth Features (DONE ✅)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | `useReferral` hook (my stats, apply code, share link) | ✅ | `apps/web/src/hooks/useReferral.ts` |
| 4.2 | `ReferralPanel` component (code share, stats, history) | ✅ | `apps/web/src/components/ReferralPanel.tsx` |

---

## Sprint 5 — Integration & Polish (📋 Next)

### 5.1 Wire up new components into existing pages

| Task | File to modify | What to add |
|------|---------------|-------------|
| Replace basic catalogue with filtered version | `apps/web/src/pages/Catalogo.tsx` | Import `useCatalogueFilters` + `useFilteredSets` + `CatalogueFilterBar` |
| Add `ShipmentTimeline` to Dashboard active orders | `apps/web/src/pages/Dashboard.tsx` | Replace status badge with full timeline card |
| Add `ReferralPanel` tab to Dashboard | `apps/web/src/pages/Dashboard.tsx` | Add "Referidos" tab |
| Show `SetReviewsSection` on product detail / catalogue modal | Catalogue page or new modal | Add reviews section below set info |
| Trigger `ReviewModal` after return confirmed | `Dashboard.tsx` order history | Auto-open after envio status = `returned` |

### 5.2 Edge Functions — remaining integrations

| Task | File | Notes |
|------|------|-------|
| Send welcome email on new user signup | Supabase DB webhook or trigger | Call `send-email` with template `welcome` |
| Send shipment email when envio status → `in_transit` | `stripe-webhook` or new trigger function | Template `shipmentSent` |
| Send return confirmed email when status → `return_requested` | Operations Edge Function | Template `returnConfirmed` |
| Send review request email 24h after return | Scheduled Edge Function or webhook | Template `reviewRequest` |
| Process referral credit on subscription activation | `stripe-webhook` | Call `process_referral_credit()` |

### 5.3 Admin panel improvements

| Task | Notes |
|------|-------|
| Reviews moderation table (list, publish/hide, delete) | Add to `Admin.tsx` |
| Referral program stats dashboard | Total referrals, credited %, top referrers |
| Export CSV of reviews per set | For marketing / product decisions |

---

## Sprint 6 — iOS App Alignment (📋 Planned)

| Task | Notes |
|------|-------|
| Mirror `useReviews` hook in iOS app | `apps/ios/hooks/` |
| Mirror `useReferral` hook in iOS app | `apps/ios/hooks/` |
| Add referral code entry on iOS onboarding | `apps/ios/screens/` |
| Push notifications for wishlist match | Expo notifications |

---

## Sprint 7 — Performance & SEO (📋 Planned)

| Task | Notes |
|------|-------|
| Enable Supabase FTS (tsvector) on `sets` table | `ALTER TABLE sets ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (...)` |
| Implement `useFilteredSets` with `.textSearch()` instead of `ilike` | Requires FTS column |
| React.lazy + Suspense for heavy pages (Catalogo, Dashboard) | Reduce initial bundle |
| Dynamic OG meta tags per set (for social sharing) | `react-helmet-async` |
| Sitemap generation for SEO | `vite-plugin-sitemap` or server-side |

---

## Known Technical Debt

| Issue | Priority | Notes |
|-------|----------|-------|
| Root-level `src/` and `apps/web/src/` duplication | High | Legacy root structure; migrate fully to `apps/web` |
| Supabase TypeScript types not auto-generated | Medium | Run `supabase gen types typescript` and commit |
| No E2E tests | Medium | Consider Playwright for critical user flows |
| `useApplyReferralCode` does client-side validation | Medium | Move to Edge Function for security (RLS bypass risk) |
| `catalogue_visibility` column may not exist in older migrations | Low | Verify against live DB schema |

---

## How to run migrations

```bash
# Against local Supabase
supabase db reset

# Against remote
supabase db push

# Generate TypeScript types after schema changes
supabase gen types typescript --project-id <id> > src/integrations/supabase/types.ts
```

---

## Component / Hook Reference

| Component/Hook | Purpose | Sprint |
|----------------|---------|--------|
| `ReviewModal` | Submit star rating + review for a rented set | 3 |
| `SetReviewsSection` | Display reviews + stats for a set | 3 |
| `useReviews` | All review data fetching & mutations | 3 |
| `CatalogueFilterBar` | Filter bar (search, theme, age, pieces, sort) | 3 |
| `CatalogueFilterTrigger` | Mobile filter button with badge count | 3 |
| `useCatalogueFilters` | Filter state + server-side query logic | 3 |
| `ShipmentTimeline` | Full shipment lifecycle timeline | 3 |
| `ReferralPanel` | User referral code + stats + history | 4 |
| `useReferral` | Referral data, apply code, share utils | 4 |
| `send-email` (EF) | Resend-based transactional email + 6 templates | 2 |