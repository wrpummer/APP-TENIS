create extension if not exists "pgcrypto";

create table if not exists public.next_match_confirmations (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  match_date date not null,
  player_id uuid not null references public.players(id) on delete cascade,
  withdrawal_code_hash text,
  attendance_status text not null default 'awaiting',
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

alter table public.next_match_confirmations
  add column if not exists withdrawal_code_hash text,
  add column if not exists attendance_status text not null default 'awaiting';

alter table public.next_match_confirmations
  drop constraint if exists next_match_confirmations_attendance_status_check;

alter table public.next_match_confirmations
  add constraint next_match_confirmations_attendance_status_check
  check (attendance_status in ('awaiting', 'played', 'absent', 'justified'));

revoke select on table public.next_match_confirmations from anon, authenticated;
grant select (
  id,
  season_id,
  match_date,
  player_id,
  attendance_status,
  confirmed_at
) on table public.next_match_confirmations to anon, authenticated;

drop policy if exists "admins manage next match confirmations" on public.next_match_confirmations;
create policy "admins manage next match confirmations"
on public.next_match_confirmations
for all
using (public.is_admin_user())
with check (public.is_admin_user());

drop function if exists public.confirm_next_match_presence(uuid, date, uuid);

create or replace function public.confirm_next_match_presence(
  target_season_id uuid,
  target_match_date date,
  target_player_id uuid,
  target_withdrawal_code text
)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  next_match_value jsonb;
begin
  if target_withdrawal_code is null or target_withdrawal_code !~ '^[0-9]{4}$' then
    raise exception 'Crie um código com exatamente 4 números.';
  end if;

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

  insert into public.next_match_confirmations (
    season_id,
    match_date,
    player_id,
    withdrawal_code_hash,
    attendance_status
  )
  values (
    target_season_id,
    target_match_date,
    target_player_id,
    crypt(target_withdrawal_code, gen_salt('bf')),
    'awaiting'
  );
end;
$$;

create or replace function public.withdraw_next_match_presence(
  target_confirmation_id uuid,
  target_withdrawal_code text
)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  confirmation_row public.next_match_confirmations%rowtype;
  next_match_value jsonb;
  scheduled_local timestamp;
  scheduled_time text;
begin
  select *
    into confirmation_row
  from public.next_match_confirmations
  where id = target_confirmation_id;

  if confirmation_row.id is null then
    raise exception 'Confirmação não encontrada.';
  end if;

  if confirmation_row.attendance_status <> 'awaiting' then
    raise exception 'O resultado deste jogador já foi registrado pelo administrador.';
  end if;

  if confirmation_row.withdrawal_code_hash is null
    or confirmation_row.withdrawal_code_hash <> crypt(target_withdrawal_code, confirmation_row.withdrawal_code_hash)
  then
    raise exception 'Código incorreto. Digite os mesmos 4 números usados na confirmação.';
  end if;

  select value
    into next_match_value
  from public.system_settings
  where key = 'next-match:' || confirmation_row.season_id::text;

  scheduled_time := nullif(next_match_value->>'time', '');

  if scheduled_time is not null then
    scheduled_local := confirmation_row.match_date + scheduled_time::time;

    if scheduled_local - (now() at time zone 'America/Sao_Paulo') <= interval '10 hours' then
      raise exception 'Não é possível desistir nas 10 horas anteriores ao início do jogo.';
    end if;
  end if;

  delete from public.next_match_confirmations
  where id = target_confirmation_id;
end;
$$;

revoke all on function public.confirm_next_match_presence(uuid, date, uuid, text) from public;
grant execute on function public.confirm_next_match_presence(uuid, date, uuid, text) to anon, authenticated;

revoke all on function public.withdraw_next_match_presence(uuid, text) from public;
grant execute on function public.withdraw_next_match_presence(uuid, text) to anon, authenticated;
