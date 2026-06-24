-- Corrige erro de RLS ao recalcular tabelas derivadas depois de salvar partidas.
-- Rode este arquivo no SQL Editor do Supabase.

create or replace function public.refresh_season_derived_data(target_season_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.season_rankings where season_id = target_season_id;
  delete from public.player_statistics where season_id = target_season_id;
  delete from public.player_partners where season_id = target_season_id;
  delete from public.player_rivals where season_id = target_season_id;
  delete from public.hall_of_fame where season_id = target_season_id;

  drop table if exists tmp_player_match_rows;
  drop table if exists tmp_match_set_rows;
  drop table if exists tmp_ranked_season;
  drop table if exists tmp_ranked_monthly;

  create temporary table tmp_player_match_rows on commit drop as
  select
    m.id as match_id,
    m.season_id,
    m.match_date,
    extract(month from m.match_date)::smallint as scope_month,
    slot.player_id,
    slot.team,
    case when slot.team = m.winner_team then 1 else 0 end as is_win,
    coalesce(set_points.points, 0)::integer as points
  from public.matches m
  join lateral (
    values
      (m.team_a_player_1_id, 'A'),
      (m.team_a_player_2_id, 'A'),
      (m.team_b_player_1_id, 'B'),
      (m.team_b_player_2_id, 'B')
  ) as slot(player_id, team) on true
  left join lateral (
    select
      sum(
        case
          when (slot.team = 'A' and ms.team_a_games > ms.team_b_games)
            or (slot.team = 'B' and ms.team_b_games > ms.team_a_games) then 3
          else 1
        end
      )::integer as points
    from public.match_sets ms
    where ms.match_id = m.id
      and ms.team_a_games <> ms.team_b_games
  ) as set_points on true
  where m.season_id = target_season_id;

  create temporary table tmp_match_set_rows on commit drop as
  select
    m.id as match_id,
    m.season_id,
    m.match_date,
    extract(month from m.match_date)::smallint as scope_month,
    slot.player_id,
    sum(case when slot.team = 'A' then ms.team_a_games else ms.team_b_games end)::integer as games_won,
    sum(case when slot.team = 'A' then ms.team_b_games else ms.team_a_games end)::integer as games_lost,
    sum(
      case
        when (slot.team = 'A' and ms.team_a_games > ms.team_b_games)
          or (slot.team = 'B' and ms.team_b_games > ms.team_a_games) then 1
        else 0
      end
    )::integer as sets_won,
    sum(
      case
        when (slot.team = 'A' and ms.team_a_games < ms.team_b_games)
          or (slot.team = 'B' and ms.team_b_games < ms.team_a_games) then 1
        else 0
      end
    )::integer as sets_lost
  from public.matches m
  join public.match_sets ms on ms.match_id = m.id
  join lateral (
    values
      (m.team_a_player_1_id, 'A'),
      (m.team_a_player_2_id, 'A'),
      (m.team_b_player_1_id, 'B'),
      (m.team_b_player_2_id, 'B')
  ) as slot(player_id, team) on true
  where m.season_id = target_season_id
  group by m.id, m.season_id, m.match_date, extract(month from m.match_date)::smallint, slot.player_id;

  create temporary table tmp_ranked_season on commit drop as
  with season_aggregate as (
    select
      pmr.season_id,
      pmr.player_id,
      count(*)::integer as matches_played,
      sum(pmr.is_win)::integer as wins,
      sum(case when pmr.is_win = 0 then 1 else 0 end)::integer as losses,
      sum(pmr.points)::integer as points,
      coalesce(sum(msr.sets_won), 0)::integer as sets_won,
      coalesce(sum(msr.sets_lost), 0)::integer as sets_lost,
      coalesce(sum(msr.games_won), 0)::integer as games_won,
      coalesce(sum(msr.games_lost), 0)::integer as games_lost
    from tmp_player_match_rows pmr
    left join tmp_match_set_rows msr
      on msr.match_id = pmr.match_id
     and msr.player_id = pmr.player_id
    group by pmr.season_id, pmr.player_id
  )
  select
    sa.*,
    round((sa.wins::numeric / nullif(sa.matches_played, 0)) * 100, 2) as win_rate,
    dense_rank() over (
      order by
        sa.points desc,
        sa.wins desc,
        round((sa.wins::numeric / nullif(sa.matches_played, 0)) * 100, 2) desc,
        (sa.sets_won - sa.sets_lost) desc,
        sa.player_id
    )::integer as ranking_position
  from season_aggregate sa;

  insert into public.season_rankings (
    season_id, player_id, scope, scope_month, ranking_position, points, matches_played,
    wins, losses, win_rate, sets_won, sets_lost, games_won, games_lost
  )
  select
    season_id, player_id, 'season', null, ranking_position, points, matches_played,
    wins, losses, win_rate, sets_won, sets_lost, games_won, games_lost
  from tmp_ranked_season;

  insert into public.player_statistics (
    player_id, season_id, matches_played, wins, losses, points, sets_won, sets_lost,
    games_won, games_lost, updated_at
  )
  select
    player_id, season_id, matches_played, wins, losses, points, sets_won, sets_lost,
    games_won, games_lost, timezone('utc', now())
  from tmp_ranked_season;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'champion', player_id, points
  from tmp_ranked_season
  order by points desc, player_id
  limit 1;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'most_wins', player_id, wins
  from tmp_ranked_season
  order by wins desc, points desc, player_id
  limit 1;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'best_win_rate', player_id, win_rate
  from tmp_ranked_season
  order by win_rate desc, wins desc, points desc, player_id
  limit 1;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'most_active', player_id, matches_played
  from tmp_ranked_season
  order by matches_played desc, points desc, player_id
  limit 1;
end;
$$;

grant execute on function public.refresh_season_derived_data(uuid) to authenticated;
