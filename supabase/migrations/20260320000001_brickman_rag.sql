-- Brickman Knowledge Base table
-- Stores the full knowledge base text for the Brickman chatbot assistant.
-- No vector embeddings needed: the KB is small enough to fit in the LLM context window.

create table if not exists public.brickman_knowledge (
  id serial primary key,
  content text not null,
  version text not null default 'v1',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS: public read (Edge Function reads without auth), service_role can write
alter table public.brickman_knowledge enable row level security;

drop policy if exists "Public read access for brickman knowledge" on public.brickman_knowledge;
create policy "Public read access for brickman knowledge"
  on public.brickman_knowledge
  for select
  using (true);

drop policy if exists "Service role full access for brickman knowledge" on public.brickman_knowledge;
create policy "Service role full access for brickman knowledge"
  on public.brickman_knowledge
  for all
  using (auth.role() = 'service_role');

-- Auto-update updated_at on changes
create or replace function public.update_brickman_knowledge_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists update_brickman_knowledge_updated_at on public.brickman_knowledge;
create trigger update_brickman_knowledge_updated_at
  before update on public.brickman_knowledge
  for each row
  execute function public.update_brickman_knowledge_updated_at();
