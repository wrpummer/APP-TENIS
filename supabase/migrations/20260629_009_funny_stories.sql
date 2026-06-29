create table if not exists public.funny_stories (
  id uuid primary key default gen_random_uuid(),
  author_name text not null,
  event_date date not null,
  location text not null,
  content text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint funny_stories_author_name_check check (char_length(trim(author_name)) between 2 and 80),
  constraint funny_stories_location_check check (char_length(trim(location)) between 2 and 120),
  constraint funny_stories_content_check check (char_length(trim(content)) between 3 and 2000)
);

create index if not exists idx_funny_stories_event_date
  on public.funny_stories (event_date desc, created_at desc);

alter table public.funny_stories enable row level security;

drop policy if exists "public read funny stories" on public.funny_stories;
create policy "public read funny stories"
on public.funny_stories for select
using (true);

drop policy if exists "public create funny stories" on public.funny_stories;
create policy "public create funny stories"
on public.funny_stories for insert
with check (true);

drop policy if exists "public update funny stories" on public.funny_stories;
create policy "public update funny stories"
on public.funny_stories for update
using (true)
with check (true);

drop policy if exists "public delete funny stories" on public.funny_stories;
create policy "public delete funny stories"
on public.funny_stories for delete
using (true);

grant select, insert, update, delete on table public.funny_stories to anon, authenticated;

drop trigger if exists funny_stories_touch_updated_at on public.funny_stories;
create trigger funny_stories_touch_updated_at
before update on public.funny_stories
for each row execute function public.touch_updated_at();

