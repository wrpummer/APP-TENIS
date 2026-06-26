alter table public.next_match_confirmations
  add column if not exists match_time time,
  add column if not exists match_location text;

revoke select on table public.next_match_confirmations from anon, authenticated;
grant select (
  id,
  season_id,
  match_date,
  match_time,
  match_location,
  player_id,
  attendance_status,
  confirmed_at
) on table public.next_match_confirmations to anon, authenticated;

update public.next_match_confirmations as confirmation
set
  match_time = nullif(setting.value->>'time', '')::time,
  match_location = nullif(setting.value->>'location', '')
from public.system_settings as setting
where setting.key = 'next-match:' || confirmation.season_id::text
  and setting.value->>'date' = confirmation.match_date::text
  and (confirmation.match_time is null or confirmation.match_location is null);

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
    match_time,
    match_location,
    player_id,
    withdrawal_code_hash,
    attendance_status
  )
  values (
    target_season_id,
    target_match_date,
    nullif(next_match_value->>'time', '')::time,
    nullif(next_match_value->>'location', ''),
    target_player_id,
    crypt(target_withdrawal_code, gen_salt('bf')),
    'awaiting'
  );
end;
$$;

