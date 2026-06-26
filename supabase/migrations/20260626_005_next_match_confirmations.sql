create table if not exists public.next_match_confirmations (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  match_date date not null,
  player_id uuid not null references public.players(id) on delete cascade,
  confirmed_at timestamptz not null default timezone('utc', now()),
  unique (season_id, match_date, player_id)
);

create index if not exists idx_next_match_confirmations_game
  on public.next_match_confirmations (season_id, match_date, confirmed_at);

alter table public.next_match_confirmations enable row level security;

drop policy if exists "public read next match confirmations" on public.next_match_confirmations;
create policy "public read next match confirmations"
on public.next_match_confirmations
for select
using (true);

create or replace function public.confirm_next_match_presence(
  target_season_id uuid,
  target_match_date date,
  target_player_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  next_match_value jsonb;
begin
  if not exists (
    select 1
    from public.players
    where id = target_player_id
      and status = 'active'
  ) then
    raise exception 'Jogador não encontrado ou inativo.';
  end if;

  select value
    into next_match_value
  from public.system_settings
  where key = 'next-match:' || target_season_id::text;

  if next_match_value is null
    or coalesce(next_match_value->>'date', '') <> target_match_date::text
    or coalesce(next_match_value->>'status', 'pending') = 'cancelled'
  then
    raise exception 'Este jogo não está disponível para confirmação.';
  end if;

  insert into public.next_match_confirmations (season_id, match_date, player_id)
  values (target_season_id, target_match_date, target_player_id);
end;
$$;

revoke all on function public.confirm_next_match_presence(uuid, date, uuid) from public;
grant execute on function public.confirm_next_match_presence(uuid, date, uuid) to anon, authenticated;

