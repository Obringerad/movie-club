-- Run after creating the login accounts (see README step 4).
-- Ties each account (ella@jboiz.example.com, ...) to that member's name.
update public.members m
set user_id = u.id
from auth.users u
where lower(u.email) = lower(m.name) || '@jboiz.example.com';

-- Every row should say linked = true.
select name, user_id is not null as linked
from public.members
order by pick_order nulls last;
