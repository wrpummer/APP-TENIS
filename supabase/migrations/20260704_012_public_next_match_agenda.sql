create or replace function public.save_public_next_match(
  target_season_id uuid,
  target_date date,
  target_time time,
  target_location text,
  target_comment text default ''
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  scheduled_local timestamp;
begin
  if not exists (select 1 from public.seasons where id = target_season_id) then
    raise exception 'Temporada não encontrada.';
  end if;

  if target_date is null or target_time is null then
    raise exception 'Informe a data e o horário do jogo.';
  end if;

  scheduled_local := target_date + target_time;
  if scheduled_local <= (now() at time zone 'America/Sao_Paulo') then
    raise exception 'Escolha uma data e um horário que ainda não passaram.';
  end if;

  if char_length(trim(coalesce(target_location, ''))) < 2 then
    raise exception 'Informe o local do jogo.';
  end if;

  if char_length(target_location) > 150 then
    raise exception 'O local deve ter no máximo 150 caracteres.';
  end if;

  if char_length(coalesce(target_comment, '')) > 1000 then
    raise exception 'O comentário deve ter no máximo 1000 caracteres.';
  end if;

  insert into public.system_settings (key, value, description)
  values (
    'next-match:' || target_season_id::text,
    jsonb_build_object(
      'date', target_date::text,
      'time', to_char(target_time, 'HH24:MI'),
      'location', trim(target_location),
      'comment', trim(coalesce(target_comment, '')),
      'status', 'confirmed'
    ),
    'Próximo jogo da temporada ' || target_season_id::text
  )
  on conflict (key) do update
  set
    value = excluded.value,
    description = excluded.description,
    updated_at = timezone('utc', now());
end;
$$;

revoke all on function public.save_public_next_match(uuid, date, time, text, text) from public;
grant execute on function public.save_public_next_match(uuid, date, time, text, text) to anon, authenticated;

