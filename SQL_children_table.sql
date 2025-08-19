-- Children table & policies
create table if not exists public.children (
  id uuid primary key default gen_random_uuid(),
  parent_user_id uuid not null,
  name text not null,
  birthdate date,
  avatar_url text,
  created_at timestamptz not null default now()
);

alter table public.children enable row level security;

create policy "parent can select own children"
on public.children for select using (auth.uid() = parent_user_id);

create policy "parent can insert own children"
on public.children for insert with check (auth.uid() = parent_user_id);

create policy "parent can update own children"
on public.children for update using (auth.uid() = parent_user_id)
with check (auth.uid() = parent_user_id);

create policy "parent can delete own children"
on public.children for delete using (auth.uid() = parent_user_id);