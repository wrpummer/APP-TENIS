create or replace function public.refresh_season_derived_data(target_season_id uuid)
returns void
language plpgsql
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
    case when slot.team = m.winner_team then 3 else 1 end as points
  from public.matches m
  join lateral (
    values
      (m.team_a_player_1_id, 'A'),
      (m.team_a_player_2_id, 'A'),
      (m.team_b_player_1_id, 'B'),
      (m.team_b_player_2_id, 'B')
  ) as slot(player_id, team) on true
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
    row_number() over (
      order by
        sa.points desc,
        sa.wins desc,
        round((sa.wins::numeric / nullif(sa.matches_played, 0)) * 100, 2) desc,
        (sa.sets_won - sa.sets_lost) desc,
        (sa.games_won - sa.games_lost) desc,
        sa.player_id
    )::integer as ranking_position
  from season_aggregate sa;

  create temporary table tmp_ranked_monthly on commit drop as
  with month_series as (
    select distinct extract(month from match_date)::smallint as scope_month
    from public.matches
    where season_id = target_season_id
  ),
  cumulative_player_months as (
    select
      pmr.season_id,
      months.scope_month,
      pmr.player_id,
      count(*) filter (where pmr.scope_month <= months.scope_month)::integer as matches_played,
      coalesce(sum(pmr.is_win) filter (where pmr.scope_month <= months.scope_month), 0)::integer as wins,
      coalesce(sum(case when pmr.is_win = 0 then 1 else 0 end) filter (where pmr.scope_month <= months.scope_month), 0)::integer as losses,
      coalesce(sum(pmr.points) filter (where pmr.scope_month <= months.scope_month), 0)::integer as points
    from month_series months
    join tmp_player_match_rows pmr on pmr.scope_month <= months.scope_month
    group by pmr.season_id, months.scope_month, pmr.player_id
  ),
  cumulative_set_months as (
    select
      msr.season_id,
      months.scope_month,
      msr.player_id,
      coalesce(sum(msr.sets_won) filter (where msr.scope_month <= months.scope_month), 0)::integer as sets_won,
      coalesce(sum(msr.sets_lost) filter (where msr.scope_month <= months.scope_month), 0)::integer as sets_lost,
      coalesce(sum(msr.games_won) filter (where msr.scope_month <= months.scope_month), 0)::integer as games_won,
      coalesce(sum(msr.games_lost) filter (where msr.scope_month <= months.scope_month), 0)::integer as games_lost
    from month_series months
    join tmp_match_set_rows msr on msr.scope_month <= months.scope_month
    group by msr.season_id, months.scope_month, msr.player_id
  )
  select
    cpm.season_id,
    cpm.scope_month,
    cpm.player_id,
    cpm.points,
    cpm.matches_played,
    cpm.wins,
    cpm.losses,
    round((cpm.wins::numeric / nullif(cpm.matches_played, 0)) * 100, 2) as win_rate,
    coalesce(csm.sets_won, 0)::integer as sets_won,
    coalesce(csm.sets_lost, 0)::integer as sets_lost,
    coalesce(csm.games_won, 0)::integer as games_won,
    coalesce(csm.games_lost, 0)::integer as games_lost,
    row_number() over (
      partition by cpm.scope_month
      order by
        cpm.points desc,
        cpm.wins desc,
        round((cpm.wins::numeric / nullif(cpm.matches_played, 0)) * 100, 2) desc,
        (coalesce(csm.sets_won, 0) - coalesce(csm.sets_lost, 0)) desc,
        (coalesce(csm.games_won, 0) - coalesce(csm.games_lost, 0)) desc,
        cpm.player_id
    )::integer as ranking_position
  from cumulative_player_months cpm
  left join cumulative_set_months csm
    on csm.season_id = cpm.season_id
   and csm.scope_month = cpm.scope_month
   and csm.player_id = cpm.player_id;

  insert into public.season_rankings (
    season_id, player_id, scope, scope_month, ranking_position, points, matches_played,
    wins, losses, win_rate, sets_won, sets_lost, games_won, games_lost
  )
  select
    season_id, player_id, 'season', null, ranking_position, points, matches_played,
    wins, losses, win_rate, sets_won, sets_lost, games_won, games_lost
  from tmp_ranked_season
  union all
  select
    season_id, player_id, 'monthly', scope_month, ranking_position, points, matches_played,
    wins, losses, win_rate, sets_won, sets_lost, games_won, games_lost
  from tmp_ranked_monthly;

  insert into public.player_partners (season_id, player_id, partner_id, matches_played, wins, losses, win_rate)
  select
    x.season_id,
    x.player_id,
    x.partner_id,
    count(*)::integer as matches_played,
    sum(x.is_win)::integer as wins,
    sum(case when x.is_win = 0 then 1 else 0 end)::integer as losses,
    round((sum(x.is_win)::numeric / nullif(count(*), 0)) * 100, 2) as win_rate
  from (
    select m.season_id, m.team_a_player_1_id as player_id, m.team_a_player_2_id as partner_id,
      case when m.winner_team = 'A' then 1 else 0 end as is_win
    from public.matches m where m.season_id = target_season_id
    union all
    select m.season_id, m.team_a_player_2_id, m.team_a_player_1_id,
      case when m.winner_team = 'A' then 1 else 0 end
    from public.matches m where m.season_id = target_season_id
    union all
    select m.season_id, m.team_b_player_1_id, m.team_b_player_2_id,
      case when m.winner_team = 'B' then 1 else 0 end
    from public.matches m where m.season_id = target_season_id
    union all
    select m.season_id, m.team_b_player_2_id, m.team_b_player_1_id,
      case when m.winner_team = 'B' then 1 else 0 end
    from public.matches m where m.season_id = target_season_id
  ) x
  group by x.season_id, x.player_id, x.partner_id;

  insert into public.player_rivals (season_id, player_id, rival_id, matches_played, wins, losses, win_rate)
  select
    x.season_id,
    x.player_id,
    x.rival_id,
    count(*)::integer as matches_played,
    sum(x.is_win)::integer as wins,
    sum(case when x.is_win = 0 then 1 else 0 end)::integer as losses,
    round((sum(x.is_win)::numeric / nullif(count(*), 0)) * 100, 2) as win_rate
  from (
    select m.season_id, m.team_a_player_1_id as player_id, m.team_b_player_1_id as rival_id,
      case when m.winner_team = 'A' then 1 else 0 end as is_win
    from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_a_player_1_id, m.team_b_player_2_id,
      case when m.winner_team = 'A' then 1 else 0 end from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_a_player_2_id, m.team_b_player_1_id,
      case when m.winner_team = 'A' then 1 else 0 end from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_a_player_2_id, m.team_b_player_2_id,
      case when m.winner_team = 'A' then 1 else 0 end from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_b_player_1_id, m.team_a_player_1_id,
      case when m.winner_team = 'B' then 1 else 0 end from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_b_player_1_id, m.team_a_player_2_id,
      case when m.winner_team = 'B' then 1 else 0 end from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_b_player_2_id, m.team_a_player_1_id,
      case when m.winner_team = 'B' then 1 else 0 end from public.matches m where m.season_id = target_season_id
    union all select m.season_id, m.team_b_player_2_id, m.team_a_player_2_id,
      case when m.winner_team = 'B' then 1 else 0 end from public.matches m where m.season_id = target_season_id
  ) x
  group by x.season_id, x.player_id, x.rival_id;

  insert into public.player_statistics (
    player_id,
    season_id,
    matches_played,
    wins,
    losses,
    points,
    sets_won,
    sets_lost,
    games_won,
    games_lost,
    best_win_streak,
    worst_loss_streak,
    best_month,
    favorite_partner_id,
    best_partner_id,
    most_faced_rival_id,
    hardest_rival_id,
    updated_at
  )
  with streak_rows as (
    select
      pmr.player_id,
      pmr.match_date,
      pmr.match_id,
      pmr.is_win,
      row_number() over (partition by pmr.player_id order by pmr.match_date, pmr.match_id) as rn_all,
      row_number() over (partition by pmr.player_id, pmr.is_win order by pmr.match_date, pmr.match_id) as rn_by_result
    from tmp_player_match_rows pmr
  ),
  win_streaks as (
    select player_id, max(streak_size) as best_win_streak
    from (
      select player_id, count(*)::integer as streak_size
      from streak_rows
      where is_win = 1
      group by player_id, (rn_all - rn_by_result)
    ) grouped
    group by player_id
  ),
  loss_streaks as (
    select player_id, max(streak_size) as worst_loss_streak
    from (
      select player_id, count(*)::integer as streak_size
      from streak_rows
      where is_win = 0
      group by player_id, (rn_all - rn_by_result)
    ) grouped
    group by player_id
  ),
  best_months as (
    select player_id, scope_month as best_month
    from (
      select
        rm.player_id,
        rm.scope_month,
        row_number() over (
          partition by rm.player_id
          order by rm.points desc, rm.wins desc, rm.scope_month desc
        ) as rn
      from tmp_ranked_monthly rm
    ) ranked
    where rn = 1
  ),
  favorite_partners as (
    select player_id, partner_id
    from (
      select
        pp.player_id,
        pp.partner_id,
        row_number() over (
          partition by pp.player_id
          order by pp.matches_played desc, pp.wins desc, pp.win_rate desc, pp.partner_id
        ) as rn
      from public.player_partners pp
      where pp.season_id = target_season_id
    ) ranked
    where rn = 1
  ),
  best_partners as (
    select player_id, partner_id
    from (
      select
        pp.player_id,
        pp.partner_id,
        row_number() over (
          partition by pp.player_id
          order by pp.win_rate desc, pp.wins desc, pp.matches_played desc, pp.partner_id
        ) as rn
      from public.player_partners pp
      where pp.season_id = target_season_id
        and pp.matches_played > 0
    ) ranked
    where rn = 1
  ),
  most_faced_rivals as (
    select player_id, rival_id
    from (
      select
        pr.player_id,
        pr.rival_id,
        row_number() over (
          partition by pr.player_id
          order by pr.matches_played desc, pr.losses desc, pr.rival_id
        ) as rn
      from public.player_rivals pr
      where pr.season_id = target_season_id
    ) ranked
    where rn = 1
  ),
  hardest_rivals as (
    select player_id, rival_id
    from (
      select
        pr.player_id,
        pr.rival_id,
        row_number() over (
          partition by pr.player_id
          order by pr.win_rate asc, pr.losses desc, pr.matches_played desc, pr.rival_id
        ) as rn
      from public.player_rivals pr
      where pr.season_id = target_season_id
        and pr.matches_played > 0
    ) ranked
    where rn = 1
  )
  select
    rs.player_id,
    rs.season_id,
    rs.matches_played,
    rs.wins,
    rs.losses,
    rs.points,
    rs.sets_won,
    rs.sets_lost,
    rs.games_won,
    rs.games_lost,
    coalesce(ws.best_win_streak, 0),
    coalesce(ls.worst_loss_streak, 0),
    bm.best_month,
    fp.partner_id,
    bp.partner_id,
    mr.rival_id,
    hr.rival_id,
    timezone('utc', now())
  from tmp_ranked_season rs
  left join win_streaks ws on ws.player_id = rs.player_id
  left join loss_streaks ls on ls.player_id = rs.player_id
  left join best_months bm on bm.player_id = rs.player_id
  left join favorite_partners fp on fp.player_id = rs.player_id
  left join best_partners bp on bp.player_id = rs.player_id
  left join most_faced_rivals mr on mr.player_id = rs.player_id
  left join hardest_rivals hr on hr.player_id = rs.player_id;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'champion', player_id, points
  from tmp_ranked_season
  where ranking_position = 1
  limit 1;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'most_wins', player_id, wins
  from tmp_ranked_season
  order by wins desc, points desc, player_id
  limit 1;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'best_win_rate', player_id, win_rate
  from tmp_ranked_season
  where matches_played > 0
  order by win_rate desc, wins desc, points desc, player_id
  limit 1;

  insert into public.hall_of_fame (season_id, category, player_id, value_number)
  select target_season_id, 'most_active', player_id, matches_played
  from tmp_ranked_season
  order by matches_played desc, points desc, player_id
  limit 1;
end;
$$;
