-- Optional helpers for role resolution and a default family context.
-- Your Swift code in this package does NOT require these to function.

create or replace view public.v_user_family_roles as
select f.id as family_id, f.owner_id as user_id, 'parent'::text as role
from public.families f
union all
select m.family_id, m.user_id, 'child'::text as role
from public.family_members m;

grant select on public.v_user_family_roles to anon, authenticated;

create or replace function public.current_user_roles()
returns table (family_id uuid, role text)
language sql
security definer
set search_path = public
as $$
  select f.id as family_id, 'parent'::text as role
  from public.families f
  where f.owner_id = auth.uid()
  union
  select m.family_id, 'child'::text as role
  from public.family_members m
  where m.user_id = auth.uid();
$$;

create or replace function public.current_user_primary_context()
returns table (family_id uuid, role text)
language sql
security definer
set search_path = public
as $$
  with roles as (
    select * from public.current_user_roles()
  )
  -- prefer parent; otherwise first membership
  select family_id, role from roles
  where role = 'parent'
  union all
  select family_id, role from roles
  where role <> 'parent'
  limit 1;
$$;

grant execute on function public.current_user_roles() to anon, authenticated;
grant execute on function public.current_user_primary_context() to anon, authenticated;
