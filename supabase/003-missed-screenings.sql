-- Records which members missed a screening. Run once in the Supabase SQL editor.

create table public.absences (
  slot        date not null references public.slots (date) on delete cascade,
  member      text not null references public.members (name) on update cascade,
  created_at  timestamptz not null default now(),
  primary key (slot, member)
);

alter table public.absences enable row level security;

create policy "Anyone can read absences" on public.absences for select using (true);

-- Members mark (and unmark) only themselves.
create policy "Members record their own absence" on public.absences for insert to authenticated
  with check (member = public.my_name());
create policy "Members remove their own absence" on public.absences for delete to authenticated
  using (member = public.my_name());

grant select on public.absences to anon, authenticated;
grant insert, delete on public.absences to authenticated;

alter publication supabase_realtime add table public.absences;
