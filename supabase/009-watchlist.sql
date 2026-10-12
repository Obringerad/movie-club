-- Personal watchlists: films a member wants to pick someday. Run once in the Supabase SQL editor.
-- Private: each member can only see and change their own list.

create table public.watchlist (
  id        bigint generated always as identity primary key,
  member    text not null references public.members (name) on update cascade on delete cascade,
  tmdb_id   integer not null,
  title     text not null check (char_length(title) <= 200),
  year      text,
  poster    text,                       -- small TMDB poster for the list
  added_at  timestamptz not null default now(),
  unique (member, tmdb_id)
);

alter table public.watchlist enable row level security;

create policy "Members see their own watchlist" on public.watchlist for select to authenticated
  using (member = public.my_name());
create policy "Members add to their watchlist" on public.watchlist for insert to authenticated
  with check (member = public.my_name());
create policy "Members remove from their watchlist" on public.watchlist for delete to authenticated
  using (member = public.my_name());

grant select, insert, delete on public.watchlist to authenticated;
