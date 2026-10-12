-- Party mode: images members drop onto the page, like the old spreadsheet.
-- Run once in the Supabase SQL editor.

-- Image files: public to view, members upload and delete. 5 MB per file.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('party', 'party', true, 5242880, array['image/png', 'image/jpeg', 'image/gif', 'image/webp']);

create policy "Members upload party images" on storage.objects for insert to authenticated
  with check (bucket_id = 'party' and public.my_name() is not null);
create policy "Members delete party images" on storage.objects for delete to authenticated
  using (bucket_id = 'party' and public.my_name() is not null);

-- Where each image sits. x and w are fractions of the page width; y is pixels from the top of the page.
create table public.stickers (
  id          uuid primary key default gen_random_uuid(),
  path        text not null,
  tab         text not null default 'next',
  x           real not null,
  y           real not null,
  w           real not null,
  z           int not null default 0,
  added_by    text references public.members (name) on update cascade,
  created_at  timestamptz not null default now()
);

alter table public.stickers enable row level security;

create policy "Anyone can read stickers" on public.stickers for select using (true);
-- Like the spreadsheet, any member can add, move, resize or remove any image.
create policy "Members add stickers" on public.stickers for insert to authenticated
  with check (public.my_name() is not null and added_by = public.my_name());
create policy "Members move stickers" on public.stickers for update to authenticated
  using (public.my_name() is not null) with check (public.my_name() is not null);
create policy "Members remove stickers" on public.stickers for delete to authenticated
  using (public.my_name() is not null);

grant select on public.stickers to anon, authenticated;
grant insert, update, delete on public.stickers to authenticated;

alter publication supabase_realtime add table public.stickers;
