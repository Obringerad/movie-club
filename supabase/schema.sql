-- JBOIZ Movie Club: tables, access rules and live updates.
-- Run this once in the Supabase SQL editor, then run seed.sql.

-- Club members. user_id links a name to a login account (see link-accounts.sql).
create table public.members (
  name        text primary key,
  user_id     uuid unique references auth.users (id) on delete set null,
  pick_order  int,            -- null = not in the pick rotation (guest critic)
  created_at  timestamptz not null default now()
);

-- One row per screening date.
create table public.slots (
  date      date primary key,
  title     text,
  director  text,
  genre     text,
  mins      int check (mins > 0),
  imdb      text check (imdb ~ '^tt[0-9]{5,10}$'),
  picker    text not null,
  watched   boolean not null default false
);

create table public.ratings (
  slot        date not null references public.slots (date) on delete cascade,
  member      text not null references public.members (name) on update cascade,
  score       smallint not null check (score between 1 and 5),
  updated_at  timestamptz not null default now(),
  primary key (slot, member)
);

create table public.vetoes (
  id          bigint generated always as identity primary key,
  slot        date not null references public.slots (date) on delete cascade,
  member      text references public.members (name) on update cascade,  -- null for vetoes logged before accounts existed
  created_at  timestamptz not null default now(),
  unique (slot, member)
);

-- The member name tied to whoever is logged in, or null.
create function public.my_name() returns text
language sql stable security definer set search_path = public as $$
  select name from public.members where user_id = auth.uid()
$$;

alter table public.members enable row level security;
alter table public.slots   enable row level security;
alter table public.ratings enable row level security;
alter table public.vetoes  enable row level security;

-- Anyone with the link can look.
create policy "Anyone can read members" on public.members for select using (true);
create policy "Anyone can read slots"   on public.slots   for select using (true);
create policy "Anyone can read ratings" on public.ratings for select using (true);
create policy "Anyone can read vetoes"  on public.vetoes  for select using (true);

-- Any logged-in member can fill in or edit a screening.
create policy "Members edit screenings" on public.slots for update to authenticated
  using (public.my_name() is not null)
  with check (public.my_name() is not null);

-- Members rate only as themselves, and only films the club has watched.
create policy "Members add their own rating" on public.ratings for insert to authenticated
  with check (member = public.my_name()
    and exists (select 1 from public.slots s where s.date = slot and s.watched));
create policy "Members change their own rating" on public.ratings for update to authenticated
  using (member = public.my_name())
  with check (member = public.my_name());
create policy "Members remove their own rating" on public.ratings for delete to authenticated
  using (member = public.my_name());

-- Members veto only as themselves, and only films not yet watched.
create policy "Members add their own veto" on public.vetoes for insert to authenticated
  with check (member = public.my_name()
    and exists (select 1 from public.slots s where s.date = slot and not s.watched));
create policy "Members withdraw their own veto" on public.vetoes for delete to authenticated
  using (member = public.my_name());

grant select on public.members, public.slots, public.ratings, public.vetoes to anon, authenticated;
grant update on public.slots to authenticated;
grant insert, update, delete on public.ratings to authenticated;
grant insert, delete on public.vetoes to authenticated;
grant execute on function public.my_name() to anon, authenticated;

-- Push changes to open pages so everyone sees updates without reloading.
alter publication supabase_realtime add table public.slots, public.ratings, public.vetoes;

insert into public.members (name, pick_order) values
  ('Jared', 1), ('Theo', 2), ('Ella', 3), ('Tim', 4),
  ('Raito', 5), ('Kwams', 6), ('Alex', 7), ('Jeff', 8),
  ('Gio', null);
