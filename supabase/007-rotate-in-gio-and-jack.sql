-- Fit Gio and Jack into the rotation now, moving already-chosen films down to later dates.
-- Keeps the next two screenings (Better Days on Oct 16, The Pianist on Oct 17) as they are.
-- From Oct 23 on, dates follow the pick order (Gio, Jack, Jared, Theo, Ella, Tim, Raito, Kwams,
-- Alex, Jeff, ...), and each person's chosen films go onto their own turns in the same order as before.
-- Run once in the Supabase SQL editor.

-- Safety copy of the schedule first (hidden from the site), in case anything needs undoing.
create table public.slots_backup_before_rotation as select * from public.slots;
alter table public.slots_backup_before_rotation enable row level security;

with up as (
  select date, picker, title, director, genre, mins, imdb, poster,
         row_number() over (order by date) - 1 as i
  from public.slots
  where not watched
), rot as (
  select name, row_number() over (order by pick_order) - 1 as k, count(*) over () as total
  from public.members
  where pick_order is not null
), newp as (
  -- Dates 0 and 1 keep their picker; from date 2 the rotation starts at Gio (position 8 in the pick order).
  select u.date, u.i, case when u.i < 2 then u.picker else r.name end as picker
  from up u
  left join rot r on u.i >= 2 and r.k = (8 + u.i - 2) % r.total
), turns as (
  select date, picker, row_number() over (partition by picker order by date) as t
  from newp
  where i >= 2
), films as (
  select picker, title, director, genre, mins, imdb, poster,
         row_number() over (partition by picker order by date) as t
  from up
  where i >= 2 and title is not null
)
update public.slots s
set picker = tu.picker,
    title = f.title, director = f.director, genre = f.genre,
    mins = f.mins, imdb = f.imdb, poster = f.poster
from turns tu
left join films f on f.picker = tu.picker and f.t = tu.t
where s.date = tu.date;

-- Check: the next few weeks.
select date, picker, coalesce(title, '-') as film
from public.slots where not watched order by date limit 14;
