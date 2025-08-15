-- Creates a starter family for the currently authenticated user.
insert into public.families (name, owner_id)
values ('My Family', auth.uid());
