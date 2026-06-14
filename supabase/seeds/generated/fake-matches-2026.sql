-- Gerado automaticamente por scripts/generate_fake_matches_2026.py
-- Importa 60 partidas ficticias para teste visual do aplicativo
begin;

insert into public.seasons (year, starts_at, ends_at, is_active)
values (2026, '2026-01-01', '2026-12-31', true)
on conflict (year) do nothing;

with source_players(display_name, full_name, normalized_name) as (
  values
    ('Carlos Eduardo', 'Carlos Eduardo', 'carlos-eduardo'),
    ('Ailson', 'Ailson', 'ailson'),
    ('Hellinton', 'Hellinton', 'hellinton'),
    ('Milton', 'Milton', 'milton'),
    ('Marcos', 'Marcos', 'marcos'),
    ('Daniel', 'Daniel', 'daniel'),
    ('Denny', 'Denny', 'denny'),
    ('Cleber', 'Cleber', 'cleber'),
    ('Marcelo', 'Marcelo', 'marcelo'),
    ('Rodrigo', 'Rodrigo', 'rodrigo'),
    ('Arthur', 'Arthur', 'arthur'),
    ('Wesley R Pummer', 'Wesley R Pummer', 'wesley-r-pummer')
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

-- Partida ficticia 1
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
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
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 01/60.'
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
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 2
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
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
    '2026-01-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 02/60.'
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
        and m.match_date = '2026-01-09'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 3
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
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
    '2026-01-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 03/60.'
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
        and m.match_date = '2026-01-13'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 4
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
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
    '2026-01-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 04/60.'
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
        and m.match_date = '2026-01-19'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 5
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
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
    '2026-01-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 05/60.'
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
        and m.match_date = '2026-01-25'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 6
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
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
    '2026-02-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 06/60.'
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
        and m.match_date = '2026-02-05'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 7
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
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
    '2026-02-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 07/60.'
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
        and m.match_date = '2026-02-09'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 8
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
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
    '2026-02-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 08/60.'
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
        and m.match_date = '2026-02-13'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 9
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
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
    '2026-02-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 09/60.'
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
        and m.match_date = '2026-02-19'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 10
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
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
    '2026-02-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 10/60.'
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
        and m.match_date = '2026-02-25'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 11
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
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
    '2026-03-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 11/60.'
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
        and m.match_date = '2026-03-05'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 12
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
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
    '2026-03-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 12/60.'
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
        and m.match_date = '2026-03-09'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 13
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
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
    '2026-03-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 13/60.'
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
        and m.match_date = '2026-03-13'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 14
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
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
    '2026-03-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 14/60.'
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
        and m.match_date = '2026-03-19'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 15
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
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
    '2026-03-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 15/60.'
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
        and m.match_date = '2026-03-25'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 16
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
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
    '2026-04-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 16/60.'
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
        and m.match_date = '2026-04-05'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 17
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
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
    '2026-04-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 17/60.'
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
        and m.match_date = '2026-04-09'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 18
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
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
    '2026-04-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 18/60.'
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
        and m.match_date = '2026-04-13'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 19
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
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
    '2026-04-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 19/60.'
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
        and m.match_date = '2026-04-19'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 20
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
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
    '2026-04-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 20/60.'
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
        and m.match_date = '2026-04-25'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 21
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
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
    '2026-05-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 21/60.'
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
        and m.match_date = '2026-05-05'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 22
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
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
    '2026-05-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 22/60.'
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
        and m.match_date = '2026-05-09'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 23
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
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
    '2026-05-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 23/60.'
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
        and m.match_date = '2026-05-13'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 24
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
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
    '2026-05-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 24/60.'
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
        and m.match_date = '2026-05-19'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 25
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
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
    '2026-05-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 25/60.'
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
        and m.match_date = '2026-05-25'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 26
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
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
    '2026-06-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 26/60.'
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
        and m.match_date = '2026-06-05'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 27
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
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
    '2026-06-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 27/60.'
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
        and m.match_date = '2026-06-09'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 28
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
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
    '2026-06-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 28/60.'
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
        and m.match_date = '2026-06-13'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 29
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
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
    '2026-06-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 29/60.'
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
        and m.match_date = '2026-06-19'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 30
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
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
    '2026-06-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 30/60.'
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
        and m.match_date = '2026-06-25'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 31
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
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
    '2026-07-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 31/60.'
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
        and m.match_date = '2026-07-05'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 32
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
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
    '2026-07-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 32/60.'
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
        and m.match_date = '2026-07-09'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 33
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
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
    '2026-07-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 33/60.'
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
        and m.match_date = '2026-07-13'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 34
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
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
    '2026-07-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 34/60.'
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
        and m.match_date = '2026-07-19'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 35
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
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
    '2026-07-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 35/60.'
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
        and m.match_date = '2026-07-25'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 36
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
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
    '2026-08-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 36/60.'
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
        and m.match_date = '2026-08-05'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 37
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
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
    '2026-08-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 37/60.'
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
        and m.match_date = '2026-08-09'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 38
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
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
    '2026-08-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 38/60.'
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
        and m.match_date = '2026-08-13'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 39
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
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
    '2026-08-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 39/60.'
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
        and m.match_date = '2026-08-19'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 40
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
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
    '2026-08-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 40/60.'
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
        and m.match_date = '2026-08-25'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 41
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
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
    '2026-09-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 41/60.'
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
        and m.match_date = '2026-09-05'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 42
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
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
    '2026-09-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 42/60.'
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
        and m.match_date = '2026-09-09'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 43
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_2_id
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
    '2026-09-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 43/60.'
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
        and m.match_date = '2026-09-13'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 44
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
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
    '2026-09-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 44/60.'
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
        and m.match_date = '2026-09-19'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 45
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
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
    '2026-09-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 45/60.'
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
        and m.match_date = '2026-09-25'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 46
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
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
    '2026-10-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 46/60.'
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
        and m.match_date = '2026-10-05'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 47
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
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
    '2026-10-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 47/60.'
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
        and m.match_date = '2026-10-09'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 48
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_2_id
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
    '2026-10-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 48/60.'
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
        and m.match_date = '2026-10-13'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 49
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
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
    '2026-10-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 49/60.'
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
        and m.match_date = '2026-10-19'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 50
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
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
    '2026-10-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 50/60.'
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
        and m.match_date = '2026-10-25'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 51
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_2_id
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
    '2026-11-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 51/60.'
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
        and m.match_date = '2026-11-05'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 52
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_1_id,
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
    '2026-11-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 52/60.'
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
        and m.match_date = '2026-11-09'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 53
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_2_id
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
    '2026-11-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 53/60.'
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
        and m.match_date = '2026-11-13'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 54
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_1_id,
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
    '2026-11-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 54/60.'
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
        and m.match_date = '2026-11-19'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 55
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_2_id
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
    '2026-11-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 55/60.'
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
        and m.match_date = '2026-11-25'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 56
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_b_player_2_id
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
    '2026-12-05',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '7-5 / 3-6 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 56/60.'
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
        and m.match_date = '2026-12-05'
        and m.result_summary = '7-5 / 3-6 / 6-4'
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
    (1, 7, 5),
    (2, 3, 6),
    (3, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 57
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Hellinton')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_b_player_2_id
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
    '2026-12-09',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-2 / 6-1',
    'manual',
    'Lote ficticio de teste 2026 - partida 57/60.'
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
        and m.match_date = '2026-12-09'
        and m.result_summary = '6-2 / 6-1'
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
    (1, 6, 2),
    (2, 6, 1)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 58
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcos')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Daniel')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Wesley R Pummer')) limit 1) as team_b_player_2_id
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
    '2026-12-13',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-4 / 5-7 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 58/60.'
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
        and m.match_date = '2026-12-13'
        and m.result_summary = '6-4 / 5-7 / 6-3'
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
    (1, 6, 4),
    (2, 5, 7),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 59
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Denny')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Cleber')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Arthur')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Ailson')) limit 1) as team_b_player_2_id
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
    '2026-12-19',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '6-3 / 6-4',
    'manual',
    'Lote ficticio de teste 2026 - partida 59/60.'
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
        and m.match_date = '2026-12-19'
        and m.result_summary = '6-3 / 6-4'
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
    (1, 6, 3),
    (2, 6, 4)
) as set_rows(set_order, team_a_games, team_b_games);

-- Partida ficticia 60
with season_ref as (
  select id from public.seasons where year = 2026 limit 1
),
player_refs as (
  select
    (select id from public.players where upper(trim(display_name)) = upper(trim('Marcelo')) limit 1) as team_a_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Rodrigo')) limit 1) as team_a_player_2_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Carlos Eduardo')) limit 1) as team_b_player_1_id,
    (select id from public.players where upper(trim(display_name)) = upper(trim('Milton')) limit 1) as team_b_player_2_id
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
    '2026-12-25',
    player_refs.team_a_player_1_id,
    player_refs.team_a_player_2_id,
    player_refs.team_b_player_1_id,
    player_refs.team_b_player_2_id,
    'A',
    '4-6 / 6-2 / 6-3',
    'manual',
    'Lote ficticio de teste 2026 - partida 60/60.'
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
        and m.match_date = '2026-12-25'
        and m.result_summary = '4-6 / 6-2 / 6-3'
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
    (1, 4, 6),
    (2, 6, 2),
    (3, 6, 3)
) as set_rows(set_order, team_a_games, team_b_games);

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
