update public.next_match_confirmations
set attendance_status = 'awaiting'
where attendance_status <> 'awaiting';

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

    if scheduled_local - (now() at time zone 'America/Sao_Paulo') <= interval '6 hours' then
      raise exception 'Não é possível desistir nas 6 horas anteriores ao início do jogo.';
    end if;
  end if;

  delete from public.next_match_confirmations
  where id = target_confirmation_id;
end;
$$;

revoke all on function public.withdraw_next_match_presence(uuid, text) from public;
grant execute on function public.withdraw_next_match_presence(uuid, text) to anon, authenticated;

