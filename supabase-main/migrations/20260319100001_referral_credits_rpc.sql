-- ─── RPC: increment_referral_credits ─────────────────────────────────────────
-- Atomically increments referral_credits on a profile row.
-- Called from the stripe-webhook Edge Function (service role).
create or replace function public.increment_referral_credits(
  p_user_id uuid,
  p_amount  integer default 1
)
returns void
language plpgsql
security definer          -- runs as postgres, bypasses RLS
set search_path = public
as $$
begin
  update public.profiles
  set    referral_credits = coalesce(referral_credits, 0) + p_amount
  where  id = p_user_id;
end;
$$;

-- Grant execute to the authenticated role (edge functions run as service role anyway)
grant execute on function public.increment_referral_credits(uuid, integer)
  to service_role, authenticated;