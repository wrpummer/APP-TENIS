from __future__ import annotations

import json
import random
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_JSON = PROJECT_ROOT / "supabase" / "seeds" / "generated" / "legacy-ranking-2026.json"
OUTPUT_SQL = PROJECT_ROOT / "supabase" / "seeds" / "generated" / "trimmed-ranking-2026.sql"
RANDOM_SEED = 20260614


def fix_mojibake(value: str) -> str:
    if "Ã" not in value and "�" not in value:
        return value
    try:
        return value.encode("latin1").decode("utf-8")
    except (UnicodeEncodeError, UnicodeDecodeError):
        return value


def normalize_name(value: str) -> str:
    return " ".join(fix_mojibake(value).strip().upper().split())


def sql_string(value: str | None) -> str:
    if value is None:
        return "null"
    return "'" + value.replace("'", "''") + "'"


def build_matches(players: list[str]) -> list[dict[str, object]]:
    round_one = players[:]
    round_two = players[:]
    random.Random(RANDOM_SEED).shuffle(round_one)
    random.Random(RANDOM_SEED + 1).shuffle(round_two)

    pairings = [
        *[round_one[index:index + 4] for index in range(0, len(round_one), 4)],
        *[round_two[index:index + 4] for index in range(0, len(round_two), 4)],
    ]

    templates = [
        {
            "match_date": "2026-01-10",
            "start_time": "08:00",
            "court_name": "Quadra 1",
            "winner_team": "B",
            "sets": [(1, 4, 6, False, None, None), (2, 3, 6, False, None, None)],
        },
        {
            "match_date": "2026-02-14",
            "start_time": "08:30",
            "court_name": "Quadra 2",
            "winner_team": "A",
            "sets": [(1, 6, 4, False, None, None), (2, 7, 6, True, 7, 4)],
        },
        {
            "match_date": "2026-03-07",
            "start_time": "09:00",
            "court_name": "Quadra 1",
            "winner_team": "A",
            "sets": [(1, 6, 2, False, None, None), (2, 4, 6, False, None, None), (3, 6, 3, False, None, None)],
        },
        {
            "match_date": "2026-04-18",
            "start_time": "08:00",
            "court_name": "Quadra 3",
            "winner_team": "B",
            "sets": [(1, 3, 6, False, None, None), (2, 6, 4, False, None, None), (3, 4, 6, False, None, None)],
        },
        {
            "match_date": "2026-05-23",
            "start_time": "09:15",
            "court_name": "Quadra 2",
            "winner_team": "A",
            "sets": [(1, 6, 1, False, None, None), (2, 6, 2, False, None, None)],
        },
        {
            "match_date": "2026-06-13",
            "start_time": "08:45",
            "court_name": "Quadra 1",
            "winner_team": "A",
            "sets": [(1, 7, 6, True, 7, 5), (2, 6, 4, False, None, None)],
        },
        {
            "match_date": "2026-07-11",
            "start_time": "08:00",
            "court_name": "Quadra 2",
            "winner_team": "B",
            "sets": [(1, 5, 7, False, None, None), (2, 2, 6, False, None, None)],
        },
        {
            "match_date": "2026-08-15",
            "start_time": "09:00",
            "court_name": "Quadra 3",
            "winner_team": "B",
            "sets": [(1, 4, 6, False, None, None), (2, 6, 3, False, None, None), (3, 3, 6, False, None, None)],
        },
        {
            "match_date": "2026-09-19",
            "start_time": "08:30",
            "court_name": "Quadra 1",
            "winner_team": "A",
            "sets": [(1, 6, 4, False, None, None), (2, 7, 5, False, None, None)],
        },
        {
            "match_date": "2026-10-17",
            "start_time": "09:15",
            "court_name": "Quadra 2",
            "winner_team": "B",
            "sets": [(1, 6, 7, True, 4, 7), (2, 6, 4, False, None, None), (3, 2, 6, False, None, None)],
        },
    ]

    matches: list[dict[str, object]] = []
    for index, players_group in enumerate(pairings[:10]):
        team_a_player_1, team_a_player_2, team_b_player_1, team_b_player_2 = players_group
        template = templates[index]
        rendered_sets = template["sets"]
        result_summary = " / ".join(f"{team_a}-{team_b}" for _, team_a, team_b, _, _, _ in rendered_sets)
        matches.append(
            {
                "match_date": template["match_date"],
                "start_time": template["start_time"],
                "court_name": template["court_name"],
                "winner_team": template["winner_team"],
                "result_summary": result_summary,
                "team_a_player_1": team_a_player_1,
                "team_a_player_2": team_a_player_2,
                "team_b_player_1": team_b_player_1,
                "team_b_player_2": team_b_player_2,
                "sets": rendered_sets,
            }
        )
    return matches


def build_sql(players: list[str], matches: list[dict[str, object]]) -> str:
    player_rows = []
    for index, player_name in enumerate(players, start=1):
        registered_at = f"2026-01-{min(index, 28):02d} 12:00:00+00"
        player_rows.append(
            f"  ({sql_string(player_name)}, {sql_string(player_name)}, {sql_string(normalize_name(player_name))}, 'active', {sql_string(registered_at)})"
        )

    match_rows = []
    set_rows = []
    for match in matches:
        match_rows.append(
            "  ("
            + ", ".join(
                [
                    sql_string(str(match["match_date"])),
                    sql_string(str(match["start_time"])),
                    sql_string(str(match["court_name"])),
                    sql_string(str(match["winner_team"])),
                    sql_string(str(match["result_summary"])),
                    sql_string(normalize_name(str(match["team_a_player_1"]))),
                    sql_string(normalize_name(str(match["team_a_player_2"]))),
                    sql_string(normalize_name(str(match["team_b_player_1"]))),
                    sql_string(normalize_name(str(match["team_b_player_2"]))),
                ]
            )
            + ")"
        )

        for set_order, team_a_games, team_b_games, is_tiebreak, tiebreak_points_a, tiebreak_points_b in match["sets"]:
            set_rows.append(
                "  ("
                + ", ".join(
                    [
                        sql_string(str(match["match_date"])),
                        sql_string(str(match["result_summary"])),
                        str(set_order),
                        str(team_a_games),
                        str(team_b_games),
                        "true" if is_tiebreak else "false",
                        "false",
                        "null" if tiebreak_points_a is None else str(tiebreak_points_a),
                        "null" if tiebreak_points_b is None else str(tiebreak_points_b),
                        "null",
                        "null",
                    ]
                )
                + ")"
            )

    return f"""begin;

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
{",\n".join(player_rows)};

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
{",\n".join(match_rows)}
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
{",\n".join(set_rows)}
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
  seed_sets.set_order::smallint,
  seed_sets.team_a_games::smallint,
  seed_sets.team_b_games::smallint,
  seed_sets.is_tiebreak,
  seed_sets.is_super_tiebreak,
  seed_sets.tiebreak_points_a::smallint,
  seed_sets.tiebreak_points_b::smallint,
  seed_sets.deuces_count::smallint,
  seed_sets.set_notes
from inserted_matches
join seed_sets
  on seed_sets.match_date::date = inserted_matches.match_date
 and seed_sets.result_summary = inserted_matches.result_summary;

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
"""


def main() -> None:
    payload = json.loads(SOURCE_JSON.read_text(encoding="utf-8"))
    players = [fix_mojibake(player["display_name"]).strip() for player in payload["players"]]
    matches = build_matches(players)
    sql = build_sql(players, matches)
    OUTPUT_SQL.write_text(sql, encoding="utf-8")
    print(f"Arquivo gerado: {OUTPUT_SQL}")
    print(f"Jogadores únicos: {len(players)}")
    print(f"Partidas geradas: {len(matches)}")


if __name__ == "__main__":
    main()
