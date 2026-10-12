-- Add Jack (#10 in the pick order) and re-deal open dates so Gio and Jack get picks.
-- First create Jack's login: Authentication > Users > Add user > jack@movieclub.com, tick Auto Confirm.

insert into public.members (name, pick_order) values ('Jack', 10)
on conflict (name) do update set pick_order = excluded.pick_order;

update public.members m set user_id = u.id
from auth.users u
where m.name = 'Jack' and lower(u.email) = 'jack@movieclub.com';

-- Dates with no film yet: deal the full pick order in turn (Jared ... Jeff, Gio, Jack),
-- carrying on from Raito (the person after Tim, who has the last date with a film before them).
-- Dates that already have a film keep their picker.
with open_dates as (
  select date, row_number() over (order by date) - 1 as n
  from public.slots where title is null and not watched
), rotation as (
  select name, row_number() over (order by pick_order) - 1 as k, count(*) over () as total
  from public.members where pick_order is not null
)
update public.slots s set picker = r.name
from open_dates o, rotation r
where s.date = o.date and r.k = (o.n + 4) % r.total;

-- Check: Jack should show linked = true.
select name, pick_order, user_id is not null as linked from public.members order by pick_order;
