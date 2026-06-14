alter table public.players enable row level security;
alter table public.matches enable row level security;
alter table public.match_sets enable row level security;
alter table public.season_rankings enable row level security;
alter table public.player_statistics enable row level security;
alter table public.player_partners enable row level security;
alter table public.player_rivals enable row level security;
alter table public.hall_of_fame enable row level security;
alter table public.system_settings enable row level security;
alter table public.admin_access enable row level security;
alter table public.seasons enable row level security;

create or replace function public.is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_access aa
    where aa.auth_user_id = auth.uid()
      and aa.is_active = true
  );
$$;

drop policy if exists "public read seasons" on public.seasons;
create policy "public read seasons" on public.seasons
for select using (true);

drop policy if exists "public read players" on public.players;
create policy "public read players" on public.players
for select using (true);

drop policy if exists "public read matches" on public.matches;
create policy "public read matches" on public.matches
for select using (true);

drop policy if exists "public read match sets" on public.match_sets;
create policy "public read match sets" on public.match_sets
for select using (true);

drop policy if exists "public read season rankings" on public.season_rankings;
create policy "public read season rankings" on public.season_rankings
for select using (true);

drop policy if exists "public read player statistics" on public.player_statistics;
create policy "public read player statistics" on public.player_statistics
for select using (true);

drop policy if exists "public read player partners" on public.player_partners;
create policy "public read player partners" on public.player_partners
for select using (true);

drop policy if exists "public read player rivals" on public.player_rivals;
create policy "public read player rivals" on public.player_rivals
for select using (true);

drop policy if exists "public read hall of fame" on public.hall_of_fame;
create policy "public read hall of fame" on public.hall_of_fame
for select using (true);

drop policy if exists "public read settings" on public.system_settings;
create policy "public read settings" on public.system_settings
for select using (true);

drop policy if exists "admin read access rows" on public.admin_access;
create policy "admin read access rows" on public.admin_access
for select using (auth.uid() = auth_user_id);

drop policy if exists "admins manage players" on public.players;
create policy "admins manage players" on public.players
for all using (public.is_admin_user()) with check (public.is_admin_user());

drop policy if exists "admins manage matches" on public.matches;
create policy "admins manage matches" on public.matches
for all using (public.is_admin_user()) with check (public.is_admin_user());

drop policy if exists "admins manage match sets" on public.match_sets;
create policy "admins manage match sets" on public.match_sets
for all using (public.is_admin_user()) with check (public.is_admin_user());

drop policy if exists "admins manage settings" on public.system_settings;
create policy "admins manage settings" on public.system_settings
for all using (public.is_admin_user()) with check (public.is_admin_user());

drop policy if exists "admins manage seasons" on public.seasons;
create policy "admins manage seasons" on public.seasons
for all using (public.is_admin_user()) with check (public.is_admin_user());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'player-photos',
  'player-photos',
  true,
  1048576,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public read player photos" on storage.objects;
create policy "public read player photos" on storage.objects
for select using (bucket_id = 'player-photos');

drop policy if exists "admins upload player photos" on storage.objects;
create policy "admins upload player photos" on storage.objects
for insert to authenticated
with check (bucket_id = 'player-photos' and public.is_admin_user());

drop policy if exists "admins update player photos" on storage.objects;
create policy "admins update player photos" on storage.objects
for update to authenticated
using (bucket_id = 'player-photos' and public.is_admin_user())
with check (bucket_id = 'player-photos' and public.is_admin_user());

drop policy if exists "admins delete player photos" on storage.objects;
create policy "admins delete player photos" on storage.objects
for delete to authenticated
using (bucket_id = 'player-photos' and public.is_admin_user());
