begin;

drop table if exists sets_to_split;

create temporary table sets_to_split as
select
  match_set.id as set_id,
  gen_random_uuid() as new_match_id,
  match_row.id as original_match_id,
  match_row.season_id,
  match_row.match_date,
  match_row.start_time,
  match_row.court_name,
  match_row.team_a_player_1_id,
  match_row.team_a_player_2_id,
  match_row.team_b_player_1_id,
  match_row.team_b_player_2_id,
  match_row.source,
  match_row.notes,
  match_row.created_by,
  match_row.created_at,
  match_set.team_a_games,
  match_set.team_b_games,
  match_set.is_tiebreak,
  match_set.tiebreak_points_a,
  match_set.tiebreak_points_b
from public.match_sets as match_set
join public.matches as match_row on match_row.id = match_set.match_id
where match_set.set_order > 1;

insert into public.matches (
  id,
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
  notes,
  created_by,
  created_at,
  updated_at
)
select
  new_match_id,
  season_id,
  match_date,
  start_time,
  court_name,
  team_a_player_1_id,
  team_a_player_2_id,
  team_b_player_1_id,
  team_b_player_2_id,
  case when team_a_games > team_b_games then 'A' else 'B' end,
  team_a_games::text || '-' || team_b_games::text
    || case
      when is_tiebreak and tiebreak_points_a is not null and tiebreak_points_b is not null
        then ' (' || tiebreak_points_a::text || '-' || tiebreak_points_b::text || ' TB)'
      else ''
    end,
  source,
  notes,
  created_by,
  created_at,
  timezone('utc', now())
from sets_to_split;

update public.match_sets as match_set
set
  match_id = split.new_match_id,
  set_order = 1
from sets_to_split as split
where match_set.id = split.set_id;

update public.matches as match_row
set
  winner_team = case when match_set.team_a_games > match_set.team_b_games then 'A' else 'B' end,
  result_summary = match_set.team_a_games::text || '-' || match_set.team_b_games::text
    || case
      when match_set.is_tiebreak and match_set.tiebreak_points_a is not null and match_set.tiebreak_points_b is not null
        then ' (' || match_set.tiebreak_points_a::text || '-' || match_set.tiebreak_points_b::text || ' TB)'
      else ''
    end
from public.match_sets as match_set
where match_set.match_id = match_row.id
  and match_set.set_order = 1;

create unique index if not exists idx_match_sets_one_per_match
  on public.match_sets (match_id);

drop table sets_to_split;

commit;
