-- Replace with a real child auth.user id
insert into public.family_members (id, family_id, user_id)
select gen_random_uuid(), f.id, '00000000-0000-0000-0000-000000000000'::uuid
from public.families f where f.owner_id = auth.uid() limit 1;