-- Gerado automaticamente por scripts/generate_showcase_demo_sql.py
-- Base de demonstracao para explorar dashboard, historico, ranking, estatisticas e hall da fama
begin;

insert into public.seasons (year, starts_at, ends_at, is_active)
values (2026, '2026-01-01', '2026-12-31', true)
on conflict (year) do update
set starts_at = excluded.starts_at,
    ends_at = excluded.ends_at,
    is_active = excluded.is_active;

with source_players(display_name, full_name, normalized_name, phone, registered_at, status) as (
  values
    ('Carlos Eduardo', 'Carlos Eduardo', 'carlos-eduardo', '(11) 98811-2001', '2024-01-10T00:00:00Z', 'active'),
    ('Ailson', 'Ailson', 'ailson', '(11) 98811-2002', '2024-02-14T00:00:00Z', 'active'),
    ('Hellinton', 'Hellinton', 'hellinton', '(11) 98811-2003', '2024-03-09T00:00:00Z', 'active'),
    ('Milton', 'Milton', 'milton', '(11) 98811-2004', '2024-04-12T00:00:00Z', 'active'),
    ('Marcos', 'Marcos', 'marcos', '(11) 98811-2005', '2024-05-18T00:00:00Z', 'active'),
    ('Daniel', 'Daniel', 'daniel', '(11) 98811-2006', '2024-06-03T00:00:00Z', 'active'),
    ('Denny', 'Denny', 'denny', '(11) 98811-2007', '2024-06-21T00:00:00Z', 'active'),
    ('Cleber', 'Cleber', 'cleber', '(11) 98811-2008', '2024-07-07T00:00:00Z', 'active'),
    ('Marcelo', 'Marcelo', 'marcelo', '(11) 98811-2009', '2024-07-28T00:00:00Z', 'active'),
    ('Rodrigo', 'Rodrigo', 'rodrigo', '(11) 98811-2010', '2024-08-15T00:00:00Z', 'active'),
    ('Arthur', 'Arthur', 'arthur', '(11) 98811-2011', '2024-08-29T00:00:00Z', 'active'),
    ('Wesley R Pummer', 'Wesley R Pummer', 'wesley-r-pummer', '(11) 98811-2012', '2024-09-10T00:00:00Z', 'active'),
    ('Giuliano', 'Giuliano', 'giuliano', '(11) 98811-2013', '2024-09-22T00:00:00Z', 'active'),
    ('Henrique', 'Henrique', 'henrique', '(11) 98811-2014', '2024-10-11T00:00:00Z', 'active'),
    ('Mario', 'Mario', 'mario', '(11) 98811-2015', '2024-10-30T00:00:00Z', 'active'),
    ('Renato', 'Renato', 'renato', '(11) 98811-2016', '2024-11-12T00:00:00Z', 'active'),
    ('Bruno', 'Bruno', 'bruno', '(11) 98811-2017', '2024-11-26T00:00:00Z', 'inactive'),
    ('Fabio', 'Fabio', 'fabio', '(11) 98811-2018', '2024-12-05T00:00:00Z', 'inactive')
)
insert into public.players (display_name, full_name, normalized_name, phone, registered_at, status)
select sp.display_name, sp.full_name, sp.normalized_name, sp.phone, sp.registered_at::timestamptz, sp.status
from source_players sp
where not exists (
  select 1
  from public.players p
  where upper(trim(p.display_name)) = upper(trim(sp.display_name))
     or upper(trim(p.full_name)) = upper(trim(sp.full_name))
);

-- Partida showcase 1
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-04',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 001/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 001/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 3, null),
    (2, 6, 4, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 2
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-08',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 002/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 002/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 4, null),
    (2, 4, 6, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 8, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 3
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-12',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 003/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 003/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 0, null),
    (2, 6, 2, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 4
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-16',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 004/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 004/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 1, null),
    (2, 7, 5, false, false, null, null, 2, null),
    (3, 1, 0, true, true, 10, 7, 3, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 5
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-20',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 005/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 005/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 2, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 6
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-24',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 006/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 006/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 5, 7, false, false, null, null, 4, null),
    (3, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 7
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-27',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 007/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 007/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 8
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-01-29',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 008/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 008/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 9
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-04',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 009/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 009/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 4, null),
    (2, 4, 6, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 8, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 10
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-08',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 010/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 010/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 0, null),
    (2, 6, 2, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 11
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-12',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 011/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 011/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 1, null),
    (2, 7, 5, false, false, null, null, 2, null),
    (3, 1, 0, true, true, 10, 7, 3, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 12
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-16',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 012/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 012/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 2, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 13
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-20',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 013/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 013/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 5, 7, false, false, null, null, 4, null),
    (3, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 14
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-24',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 014/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 014/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 15
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-27',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 015/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 015/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 16
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-02-28',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 016/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 016/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 17
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-04',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 017/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 017/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 0, null),
    (2, 6, 2, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 18
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-08',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 018/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 018/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 1, null),
    (2, 7, 5, false, false, null, null, 2, null),
    (3, 1, 0, true, true, 10, 7, 3, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 19
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-12',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 019/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 019/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 2, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 20
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-16',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 020/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 020/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 5, 7, false, false, null, null, 4, null),
    (3, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 21
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-20',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 021/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 021/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 22
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-24',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 022/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 022/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 23
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-27',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 023/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 023/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 24
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-03-29',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 024/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 024/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 25
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-04',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 025/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 025/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 1, null),
    (2, 7, 5, false, false, null, null, 2, null),
    (3, 1, 0, true, true, 10, 7, 3, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 26
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-08',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 026/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 026/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 2, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 27
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-12',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 027/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 027/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 5, 7, false, false, null, null, 4, null),
    (3, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 28
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-16',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 028/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 028/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 29
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-20',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 029/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 029/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 30
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-24',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 030/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 030/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 31
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-27',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 031/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 031/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 32
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-04-29',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 032/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 032/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 33
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-04',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 033/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 033/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 2, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 34
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-08',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 034/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 034/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 5, 7, false, false, null, null, 4, null),
    (3, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 35
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-12',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 035/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 035/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 36
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-16',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 036/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 036/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 37
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-20',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 037/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 037/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 38
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-24',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 038/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 038/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 39
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-27',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 039/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 039/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 40
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-05-29',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 040/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 040/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 41
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-04',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 041/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 041/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 5, 7, false, false, null, null, 4, null),
    (3, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 42
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-08',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 042/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 042/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 43
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-12',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 043/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 043/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 44
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-16',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 044/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 044/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 45
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-20',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 045/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 045/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 46
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-24',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 046/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 046/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 47
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-27',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 047/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 047/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 48
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-06-29',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 048/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 048/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 49
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-04',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 049/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 049/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 50
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-08',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 050/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 050/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 51
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-12',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 051/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 051/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 52
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-16',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 052/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 052/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 53
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-20',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 053/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 053/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 54
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-24',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 054/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 054/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 55
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-27',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 055/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 055/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 56
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-07-29',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 056/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 056/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 1, null),
    (2, 5, 7, false, false, null, null, 2, null),
    (3, 7, 6, true, false, 7, 4, 3, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 57
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-04',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 057/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 057/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 0, null),
    (2, 3, 6, false, false, null, null, 1, null),
    (3, 6, 3, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 58
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-08',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 058/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 058/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 59
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-12',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 059/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 059/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 60
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-16',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 060/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 060/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 61
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-20',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 061/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 061/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 62
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-24',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 062/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 062/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 63
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-27',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 063/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 063/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 1, null),
    (2, 5, 7, false, false, null, null, 2, null),
    (3, 7, 6, true, false, 7, 4, 3, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 64
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-08-29',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 064/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 064/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 2, null),
    (2, 6, 4, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 65
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-04',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 065/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 065/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 1, null),
    (2, 6, 4, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 66
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-08',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 066/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 066/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 67
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-12',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 067/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 067/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 68
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-16',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 068/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 068/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 69
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-20',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 069/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 069/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 70
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-24',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 070/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 070/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 1, null),
    (2, 5, 7, false, false, null, null, 2, null),
    (3, 7, 6, true, false, 7, 4, 3, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 71
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-27',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 071/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 071/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 2, null),
    (2, 6, 4, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 72
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-09-29',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 072/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 072/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 3, 6, false, false, null, null, 4, null),
    (3, 6, 3, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 73
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-04',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 073/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 073/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 2, null),
    (2, 4, 6, false, false, null, null, 3, null),
    (3, 1, 0, true, true, 10, 8, 4, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 74
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-08',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 074/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 074/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 75
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-12',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 075/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 075/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 76
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-16',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 076/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 076/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 77
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-20',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 077/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 077/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 1, null),
    (2, 5, 7, false, false, null, null, 2, null),
    (3, 7, 6, true, false, 7, 4, 3, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 78
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-24',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 078/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 078/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 2, null),
    (2, 6, 4, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 79
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-27',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 079/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 079/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 3, 6, false, false, null, null, 4, null),
    (3, 6, 3, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 80
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-10-29',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 080/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 080/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 81
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-04',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 081/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 081/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 3, null),
    (2, 6, 2, false, false, null, null, 4, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 82
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-08',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 082/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 082/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 83
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-12',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 083/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 083/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 84
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-16',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 084/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 084/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 1, null),
    (2, 5, 7, false, false, null, null, 2, null),
    (3, 7, 6, true, false, 7, 4, 3, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 85
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-20',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 085/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 085/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 2, null),
    (2, 6, 4, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 86
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-24',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 086/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 086/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 3, 6, false, false, null, null, 4, null),
    (3, 6, 3, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 87
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Giuliano')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-27',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 087/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 087/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 88
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-11-29',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 088/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 088/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 0, null),
    (2, 4, 6, false, false, null, null, 1, null),
    (3, 1, 0, true, true, 10, 8, 2, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 89
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Renato')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-04',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 7-5 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 089/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 089/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 4, 6, false, false, null, null, 4, null),
    (2, 7, 5, false, false, null, null, 0, null),
    (3, 1, 0, true, true, 10, 7, 1, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 90
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-08',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 090/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 090/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 6, true, false, 7, 4, 0, 'Set decidido no tiebreak'),
    (2, 6, 3, false, false, null, null, 1, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 91
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-12',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 7-6',
    'manual',
    'Showcase app demo 2026 - partida 091/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 091/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 1, null),
    (2, 5, 7, false, false, null, null, 2, null),
    (3, 7, 6, true, false, 7, 4, 3, 'Set decidido no tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 92
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-16',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 092/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 092/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 2, false, false, null, null, 2, null),
    (2, 6, 4, false, false, null, null, 3, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 93
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-20',
    'Quadra 2',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 3-6 / 6-3',
    'manual',
    'Showcase app demo 2026 - partida 093/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 093/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 4, false, false, null, null, 3, null),
    (2, 3, 6, false, false, null, null, 4, null),
    (3, 6, 3, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 94
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Mario')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-24',
    'Quadra 3',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 6-4',
    'manual',
    'Showcase app demo 2026 - partida 094/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 094/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 7, 5, false, false, null, null, 4, null),
    (2, 6, 4, false, false, null, null, 0, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 95
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-27',
    'Trianon Coberta',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 4-6 / 1-0',
    'manual',
    'Showcase app demo 2026 - partida 095/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 095/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 3, false, false, null, null, 0, null),
    (2, 4, 6, false, false, null, null, 1, null),
    (3, 1, 0, true, true, 10, 8, 2, 'Super tiebreak')
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

-- Partida showcase 96
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Henrique')) limit 1) as team_b_player_2_id
),
inserted_match as (
  insert into public.matches (
    season_id,
    match_date,
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
    season_ref.id,
    '2026-12-29',
    'Quadra 1',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-1 / 6-2',
    'manual',
    'Showcase app demo 2026 - partida 096/96.'
  from season_ref
  cross join player_refs
  where player_refs.team_a_player_1_id is not null
    and player_refs.team_a_player_2_id is not null
    and player_refs.team_b_player_1_id is not null
    and player_refs.team_b_player_2_id is not null
    and not exists (
      select 1
      from public.matches m
      where m.notes = 'Showcase app demo 2026 - partida 096/96.'
    )
  returning id
)
insert into public.match_sets (
  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes
)
select
  inserted_match.id,
  set_rows.set_order::smallint,
  set_rows.team_a_games::smallint,
  set_rows.team_b_games::smallint,
  set_rows.is_tiebreak::boolean,
  set_rows.is_super_tiebreak::boolean,
  set_rows.tiebreak_points_a::smallint,
  set_rows.tiebreak_points_b::smallint,
  set_rows.deuces_count::smallint,
  set_rows.set_notes::text
from inserted_match
cross join (
  values
    (1, 6, 1, false, false, null, null, 1, null),
    (2, 6, 2, false, false, null, null, 2, null)
) as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
