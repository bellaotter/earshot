-- Saved listening sessions. Run once in the Supabase SQL editor.
-- Each row belongs to one user; Row Level Security keeps every user to their own rows.

create table if not exists public.sessions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  started_at  timestamptz not null,
  ended_at    timestamptz not null,
  language    text,
  summary     text,
  -- Caption log: [{ "text": "...", "translation": "...", "unsure": true }, ...]
  lines       jsonb not null default '[]'::jsonb,
  created_at  timestamptz not null default now()
);

create index if not exists sessions_user_started_idx on public.sessions (user_id, started_at desc);

alter table public.sessions enable row level security;

create policy "Read own sessions"   on public.sessions for select using (auth.uid() = user_id);
create policy "Add own sessions"    on public.sessions for insert with check (auth.uid() = user_id);
create policy "Update own sessions" on public.sessions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Delete own sessions" on public.sessions for delete using (auth.uid() = user_id);
