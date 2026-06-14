insert into public.players (full_name, display_name, normalized_name, status)
values
  ('Carlos Eduardo', 'Carlos Eduardo', 'CARLOS EDUARDO', 'active'),
  ('Ailson', 'Ailson', 'AILSON', 'active'),
  ('Hellinton', 'Hellinton', 'HELLINTON', 'active'),
  ('Milton', 'Milton', 'MILTON', 'active'),
  ('Marcos', 'Marcos', 'MARCOS', 'active'),
  ('Daniel', 'Daniel', 'DANIEL', 'active')
on conflict (normalized_name) do update
set display_name = excluded.display_name,
    full_name = excluded.full_name,
    status = excluded.status;

with season_2026 as (
  select id from public.seasons where year = 2026
),
player_refs as (
  select normalized_name, id from public.players
  where normalized_name in ('CARLOS EDUARDO', 'AILSON', 'HELLINTON', 'MILTON', 'MARCOS', 'DANIEL')
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
    team_a_player_1_id,
    team_a_player_2_id,
    team_b_player_1_id,
    team_b_player_2_id,
    winner_team,
    result_summary,
    source,
    notes
  )
  select
    season_2026.id,
    '2026-05-23',
    pa1.id,
    pa2.id,
    pb1.id,
    pb2.id,
    'A',
    '6-4 / 6-3',
    'manual',
    'Partida de exemplo para validacao inicial.'
  from season_2026
  join player_refs pa1 on pa1.normalized_name = 'CARLOS EDUARDO'
  join player_refs pa2 on pa2.normalized_name = 'AILSON'
  join player_refs pb1 on pb1.normalized_name = 'HELLINTON'
  join player_refs pb2 on pb2.normalized_name = 'MILTON'
  where not exists (
    select 1 from public.matches
    where season_id = season_2026.id
      and match_date = '2026-05-23'
      and result_summary = '6-4 / 6-3'
  )
  returning id
)
insert into public.match_sets (match_id, set_order, team_a_games, team_b_games, is_tiebreak)
select inserted_match.id, x.set_order, x.team_a_games, x.team_b_games, false
from inserted_match
cross join (
  values
    (1, 6, 4),
    (2, 6, 3)
) as x(set_order, team_a_games, team_b_games);
