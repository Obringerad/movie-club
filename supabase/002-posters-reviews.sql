-- Adds film posters and one-line reviews. Run once in the Supabase SQL editor.

-- Poster image for each screening ('none' = IMDb has no poster for it).
alter table public.slots
  add column poster text check (poster is null or poster = 'none' or poster ~ '^https://');

-- A short take to go with each member's stars.
alter table public.ratings
  add column review text check (char_length(review) <= 200);
