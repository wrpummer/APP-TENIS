-- Gerado automaticamente por scripts/import_match_json.py
-- Origem: C:\Users\wesle\Downloads\gemini-code-1781465633875.json
begin;

insert into public.seasons (year, starts_at, ends_at, is_active)
values (2026, '2026-01-01', '2026-12-31', true)
on conflict (year) do nothing;

with source_players(display_name, full_name, normalized_name) as (
  values
    ('Ailson', 'Ailson', 'ailson'),
    ('Daniel', 'Daniel', 'daniel'),
    ('Marcos', 'Marcos', 'marcos'),
    ('Denny', 'Denny', 'denny'),
    ('Cleber', 'Cleber', 'cleber'),
    ('Marcelo', 'Marcelo', 'marcelo'),
    ('Rodrigo', 'Rodrigo', 'rodrigo'),
    ('Arthur', 'Arthur', 'arthur')
)
insert into public.players (display_name, full_name, normalized_name, status)
select sp.display_name, sp.full_name, sp.normalized_name, 'active'
from source_players sp
where not exists (
  select 1
  from public.players p
  where upper(trim(p.display_name)) = upper(trim(sp.display_name))
     or upper(trim(p.full_name)) = upper(trim(sp.full_name))
);

-- Partida 1
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
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
    season_ref.id,
    '2026-01-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '3-6 / 6-4',
    'legacy_import',
    'Importado do arquivo JSON gemini-code-1781465633875.json.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.season_id = season_ref.id
        and m.match_date = '2026-01-05'
        and m.result_summary = '3-6 / 6-4'
        and m.team_a_player_1_id = player_refs.team_a_player_1_id
        and m.team_a_player_2_id = player_refs.team_a_player_2_id
        and m.team_b_player_1_id = player_refs.team_b_player_1_id
        and m.team_b_player_2_id = player_refs.team_b_player_2_id
    )
  returning id
)
insert into public.match_sets (match_id, set_order, team_a_games, team_b_games, is_tiebreak)
select inserted_match.id, set_rows.set_order, set_rows.team_a_games, set_rows.team_b_games, false
from inserted_match
cross join (
  values
    (1, 3, 6),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida 2
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
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
    season_ref.id,
    '2026-01-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2',
    'legacy_import',
    'Importado do arquivo JSON gemini-code-1781465633875.json.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.season_id = season_ref.id
        and m.match_date = '2026-01-05'
        and m.result_summary = '6-2'
        and m.team_a_player_1_id = player_refs.team_a_player_1_id
        and m.team_a_player_2_id = player_refs.team_a_player_2_id
        and m.team_b_player_1_id = player_refs.team_b_player_1_id
        and m.team_b_player_2_id = player_refs.team_b_player_2_id
    )
  returning id
)
insert into public.match_sets (match_id, set_order, team_a_games, team_b_games, is_tiebreak)
select inserted_match.id, set_rows.set_order, set_rows.team_a_games, set_rows.team_b_games, false
from inserted_match
cross join (
  values
    (1, 6, 2)
) as set_rows(set_order, team_a_games, team_b_games);

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
