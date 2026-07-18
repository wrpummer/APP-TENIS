revoke insert, update, delete on table public.next_match_confirmations from anon, authenticated;

grant select (
  id,
  season_id,
  match_date,
  match_time,
  match_location,
  player_id,
  confirmed_at
) on table public.next_match_confirmations to anon, authenticated;

