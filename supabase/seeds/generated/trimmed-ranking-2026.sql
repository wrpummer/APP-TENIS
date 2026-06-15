begin;

insert into public.seasons (year, starts_at, ends_at, is_active)
values
  (2026, '2026-01-01', '2026-12-31', true)
on conflict (year) do update
set starts_at = excluded.starts_at,
    ends_at = excluded.ends_at,
    is_active = excluded.is_active,
    updated_at = timezone('utc', now());

update public.seasons
set is_active = (year = 2026),
    updated_at = timezone('utc', now())
where year in (2025, 2026);

delete from public.matches;
delete from public.hall_of_fame;
delete from public.player_rivals;
delete from public.player_partners;
delete from public.player_statistics;
delete from public.season_rankings;
delete from public.legacy_import_rows;
delete from public.players;

insert into public.players (
  full_name,
  display_name,
  normalized_name,
  status,
  registered_at
)
values
  ('Carlos Eduardo', 'Carlos Eduardo', 'CARLOS EDUARDO', 'active', '2026-01-01 12:00:00+00'),
  ('Ailson', 'Ailson', 'AILSON', 'active', '2026-01-02 12:00:00+00'),
  ('Hellinton', 'Hellinton', 'HELLINTON', 'active', '2026-01-03 12:00:00+00'),
  ('Chicão', 'Chicão', 'CHICÃO', 'active', '2026-01-04 12:00:00+00'),
  ('Giuliano', 'Giuliano', 'GIULIANO', 'active', '2026-01-05 12:00:00+00'),
  ('Mario', 'Mario', 'MARIO', 'active', '2026-01-06 12:00:00+00'),
  ('Daniel', 'Daniel', 'DANIEL', 'active', '2026-01-07 12:00:00+00'),
  ('José', 'José', 'JOSÉ', 'active', '2026-01-08 12:00:00+00'),
  ('João Paulo', 'João Paulo', 'JOÃO PAULO', 'active', '2026-01-09 12:00:00+00'),
  ('Denny', 'Denny', 'DENNY', 'active', '2026-01-10 12:00:00+00'),
  ('Rogério', 'Rogério', 'ROGÉRIO', 'active', '2026-01-11 12:00:00+00'),
  ('Samuel', 'Samuel', 'SAMUEL', 'active', '2026-01-12 12:00:00+00'),
  ('Marcos', 'Marcos', 'MARCOS', 'active', '2026-01-13 12:00:00+00'),
  ('Milton', 'Milton', 'MILTON', 'active', '2026-01-14 12:00:00+00'),
  ('Henrique', 'Henrique', 'HENRIQUE', 'active', '2026-01-15 12:00:00+00'),
  ('Luis', 'Luis', 'LUIS', 'active', '2026-01-16 12:00:00+00'),
  ('Patrício', 'Patrício', 'PATRÍCIO', 'active', '2026-01-17 12:00:00+00'),
  ('Tico', 'Tico', 'TICO', 'active', '2026-01-18 12:00:00+00'),
  ('Rafael', 'Rafael', 'RAFAEL', 'active', '2026-01-19 12:00:00+00'),
  ('Beto', 'Beto', 'BETO', 'active', '2026-01-20 12:00:00+00');

with season_2026 as (
  select id
  from public.seasons
  where year = 2026
),
seed_matches (
  match_date,
  start_time,
  court_name,
  winner_team,
  result_summary,
  team_a_player_1_name,
  team_a_player_2_name,
  team_b_player_1_name,
  team_b_player_2_name
) as (
  values
  ('2026-01-10', '08:00', 'Quadra 1', 'B', '4-6 / 3-6', 'PATRÍCIO', 'CHICÃO', 'CARLOS EDUARDO', 'TICO'),
  ('2026-02-14', '08:30', 'Quadra 2', 'A', '6-4 / 7-6', 'ROGÉRIO', 'LUIS', 'AILSON', 'MILTON'),
  ('2026-03-07', '09:00', 'Quadra 1', 'A', '6-2 / 4-6 / 6-3', 'DENNY', 'HENRIQUE', 'GIULIANO', 'DANIEL'),
  ('2026-04-18', '08:00', 'Quadra 3', 'B', '3-6 / 6-4 / 4-6', 'JOSÉ', 'MARCOS', 'HELLINTON', 'SAMUEL'),
  ('2026-05-23', '09:15', 'Quadra 2', 'A', '6-1 / 6-2', 'JOÃO PAULO', 'BETO', 'RAFAEL', 'MARIO'),
  ('2026-06-13', '08:45', 'Quadra 1', 'A', '7-6 / 6-4', 'JOSÉ', 'CARLOS EDUARDO', 'MARIO', 'RAFAEL'),
  ('2026-07-11', '08:00', 'Quadra 2', 'B', '5-7 / 2-6', 'LUIS', 'PATRÍCIO', 'SAMUEL', 'AILSON'),
  ('2026-08-15', '09:00', 'Quadra 3', 'B', '4-6 / 6-3 / 3-6', 'BETO', 'CHICÃO', 'TICO', 'HELLINTON'),
  ('2026-09-19', '08:30', 'Quadra 1', 'A', '6-4 / 7-5', 'ROGÉRIO', 'JOÃO PAULO', 'GIULIANO', 'DANIEL'),
  ('2026-10-17', '09:15', 'Quadra 2', 'B', '6-7 / 6-4 / 2-6', 'MARCOS', 'DENNY', 'MILTON', 'HENRIQUE')
),
inserted_matches as (
  insert into public.matches (
    season_id,
    match_date,
    start_time,
    court_name,
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
    seed_matches.match_date::date,
    seed_matches.start_time::time,
    seed_matches.court_name,
    pa1.id,
    pa2.id,
    pb1.id,
    pb2.id,
    seed_matches.winner_team,
    seed_matches.result_summary,
    'manual',
    'Seed enxuto gerado a partir da planilha Ranking Tennis 2026.'
  from seed_matches
  cross join season_2026
  join public.players pa1 on pa1.normalized_name = seed_matches.team_a_player_1_name
  join public.players pa2 on pa2.normalized_name = seed_matches.team_a_player_2_name
  join public.players pb1 on pb1.normalized_name = seed_matches.team_b_player_1_name
  join public.players pb2 on pb2.normalized_name = seed_matches.team_b_player_2_name
  returning id, match_date, result_summary
),
seed_sets (
  match_date,
  result_summary,
  set_order,
  team_a_games,
  team_b_games,
  is_tiebreak,
  is_super_tiebreak,
  tiebreak_points_a,
  tiebreak_points_b,
  deuces_count,
  set_notes
) as (
  values
  ('2026-01-10', '4-6 / 3-6', 1, 4, 6, false, false, null, null, null, null),
  ('2026-01-10', '4-6 / 3-6', 2, 3, 6, false, false, null, null, null, null),
  ('2026-02-14', '6-4 / 7-6', 1, 6, 4, false, false, null, null, null, null),
  ('2026-02-14', '6-4 / 7-6', 2, 7, 6, true, false, 7, 4, null, null),
  ('2026-03-07', '6-2 / 4-6 / 6-3', 1, 6, 2, false, false, null, null, null, null),
  ('2026-03-07', '6-2 / 4-6 / 6-3', 2, 4, 6, false, false, null, null, null, null),
  ('2026-03-07', '6-2 / 4-6 / 6-3', 3, 6, 3, false, false, null, null, null, null),
  ('2026-04-18', '3-6 / 6-4 / 4-6', 1, 3, 6, false, false, null, null, null, null),
  ('2026-04-18', '3-6 / 6-4 / 4-6', 2, 6, 4, false, false, null, null, null, null),
  ('2026-04-18', '3-6 / 6-4 / 4-6', 3, 4, 6, false, false, null, null, null, null),
  ('2026-05-23', '6-1 / 6-2', 1, 6, 1, false, false, null, null, null, null),
  ('2026-05-23', '6-1 / 6-2', 2, 6, 2, false, false, null, null, null, null),
  ('2026-06-13', '7-6 / 6-4', 1, 7, 6, true, false, 7, 5, null, null),
  ('2026-06-13', '7-6 / 6-4', 2, 6, 4, false, false, null, null, null, null),
  ('2026-07-11', '5-7 / 2-6', 1, 5, 7, false, false, null, null, null, null),
  ('2026-07-11', '5-7 / 2-6', 2, 2, 6, false, false, null, null, null, null),
  ('2026-08-15', '4-6 / 6-3 / 3-6', 1, 4, 6, false, false, null, null, null, null),
  ('2026-08-15', '4-6 / 6-3 / 3-6', 2, 6, 3, false, false, null, null, null, null),
  ('2026-08-15', '4-6 / 6-3 / 3-6', 3, 3, 6, false, false, null, null, null, null),
  ('2026-09-19', '6-4 / 7-5', 1, 6, 4, false, false, null, null, null, null),
  ('2026-09-19', '6-4 / 7-5', 2, 7, 5, false, false, null, null, null, null),
  ('2026-10-17', '6-7 / 6-4 / 2-6', 1, 6, 7, true, false, 4, 7, null, null),
  ('2026-10-17', '6-7 / 6-4 / 2-6', 2, 6, 4, false, false, null, null, null, null),
  ('2026-10-17', '6-7 / 6-4 / 2-6', 3, 2, 6, false, false, null, null, null, null)
)
insert into public.match_sets (
  match_id,
  set_order,
  team_a_games,
  team_b_games,
  is_tiebreak,
  is_super_tiebreak,
  tiebreak_points_a,
  tiebreak_points_b,
  deuces_count,
  set_notes
)
select
  inserted_matches.id,
  seed_sets.set_order,
  seed_sets.team_a_games,
  seed_sets.team_b_games,
  seed_sets.is_tiebreak,
  seed_sets.is_super_tiebreak,
  seed_sets.tiebreak_points_a,
  seed_sets.tiebreak_points_b,
  seed_sets.deuces_count,
  seed_sets.set_notes
from inserted_matches
join seed_sets
  on seed_sets.match_date::date = inserted_matches.match_date
 and seed_sets.result_summary = inserted_matches.result_summary;

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
