-- Marks a member as having missed a screening when they haven't rated it
-- within a week. Runs once now (covering past films) and then every day.
-- Run once in the Supabase SQL editor.

-- Tell automatic marks apart from ones members record themselves.
alter table public.absences add column auto boolean not null default false;

-- Mark every blank rating that is more than a week old as missed. Returns how many were marked.
create or replace function public.mark_missed() returns integer
language sql security definer set search_path = public as $$
  with marked as (
    insert into public.absences (slot, member, auto)
    select s.date, m.name, true
    from public.slots s
    cross join public.members m
    where s.watched
      and s.date <= current_date - 7
      and m.pick_order is not null
      and not exists (select 1 from public.ratings r where r.slot = s.date and r.member = m.name)
      and not exists (select 1 from public.absences a where a.slot = s.date and a.member = m.name)
    on conflict do nothing
    returning 1
  )
  select count(*)::int from marked;
$$;
revoke execute on function public.mark_missed() from public, anon, authenticated;

-- Rating a film later clears an automatic "missed" for it.
create or replace function public.clear_auto_missed() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  delete from public.absences where slot = new.slot and member = new.member and auto;
  return new;
end;
$$;
create trigger ratings_clear_auto_missed
  after insert or update on public.ratings
  for each row execute function public.clear_auto_missed();

-- Run it every day at 07:00 UTC.
create extension if not exists pg_cron with schema pg_catalog;
select cron.schedule('mark-missed-screenings', '0 7 * * *', $$select public.mark_missed()$$);

-- And once now, for films already more than a week old.
select public.mark_missed() as marked_missed_now;
