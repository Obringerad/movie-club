-- Upvotes and downvotes on reviews. Run once in the Supabase SQL editor.

create table public.review_votes (
  slot        date not null,
  author      text not null,            -- whose review
  voter       text not null references public.members (name) on update cascade,
  value       smallint not null check (value in (-1, 1)),
  created_at  timestamptz not null default now(),
  primary key (slot, author, voter),
  -- Votes belong to a rating; deleting the rating (and its review) removes them.
  foreign key (slot, author) references public.ratings (slot, member) on update cascade on delete cascade,
  check (voter <> author)
);

alter table public.review_votes enable row level security;

create policy "Anyone can read votes" on public.review_votes for select using (true);
-- Members vote only as themselves.
create policy "Members vote" on public.review_votes for insert to authenticated
  with check (voter = public.my_name());
create policy "Members change their vote" on public.review_votes for update to authenticated
  using (voter = public.my_name()) with check (voter = public.my_name());
create policy "Members take back their vote" on public.review_votes for delete to authenticated
  using (voter = public.my_name());

grant select on public.review_votes to anon, authenticated;
grant insert, update, delete on public.review_votes to authenticated;

alter publication supabase_realtime add table public.review_votes;
