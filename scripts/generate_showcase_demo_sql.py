from __future__ import annotations

import calendar
from dataclasses import dataclass
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = PROJECT_ROOT / "supabase" / "seeds" / "generated"
IMPORT_FILE = OUTPUT_DIR / "showcase-demo-2026.sql"
CLEANUP_FILE = OUTPUT_DIR / "cleanup-showcase-demo-2026.sql"
NOTE_MARKER = "Showcase app demo 2026"


@dataclass(frozen=True)
class PlayerSeed:
    name: str
    phone: str
    registered_at: str
    status: str = "active"


PLAYERS = [
    PlayerSeed("Carlos Eduardo", "(11) 98811-2001", "2024-01-10"),
    PlayerSeed("Ailson", "(11) 98811-2002", "2024-02-14"),
    PlayerSeed("Hellinton", "(11) 98811-2003", "2024-03-09"),
    PlayerSeed("Milton", "(11) 98811-2004", "2024-04-12"),
    PlayerSeed("Marcos", "(11) 98811-2005", "2024-05-18"),
    PlayerSeed("Daniel", "(11) 98811-2006", "2024-06-03"),
    PlayerSeed("Denny", "(11) 98811-2007", "2024-06-21"),
    PlayerSeed("Cleber", "(11) 98811-2008", "2024-07-07"),
    PlayerSeed("Marcelo", "(11) 98811-2009", "2024-07-28"),
    PlayerSeed("Rodrigo", "(11) 98811-2010", "2024-08-15"),
    PlayerSeed("Arthur", "(11) 98811-2011", "2024-08-29"),
    PlayerSeed("Wesley R Pummer", "(11) 98811-2012", "2024-09-10"),
    PlayerSeed("Giuliano", "(11) 98811-2013", "2024-09-22"),
    PlayerSeed("Henrique", "(11) 98811-2014", "2024-10-11"),
    PlayerSeed("Mario", "(11) 98811-2015", "2024-10-30"),
    PlayerSeed("Renato", "(11) 98811-2016", "2024-11-12"),
    PlayerSeed("Bruno", "(11) 98811-2017", "2024-11-26", "inactive"),
    PlayerSeed("Fabio", "(11) 98811-2018", "2024-12-05", "inactive"),
]

COURTS = ["Quadra 1", "Quadra 2", "Quadra 3", "Trianon Coberta"]
SET_PATTERNS = [
    [(6, 2), (6, 4)],
    [(6, 4), (3, 6), (6, 3)],
    [(7, 5), (6, 4)],
    [(6, 3), (4, 6), (10, 8)],
    [(6, 1), (6, 2)],
    [(4, 6), (7, 5), (10, 7)],
    [(7, 6), (6, 3)],
    [(6, 4), (5, 7), (7, 6)],
]


def escape_sql(value: str) -> str:
    return value.replace("'", "''")


def slugify(value: str) -> str:
    return (
        value.encode("ascii", "ignore")
        .decode("ascii")
        .replace(" ", "-")
        .replace("/", "-")
        .lower()
    )


def choose_players(month: int, slot: int) -> tuple[str, str, str, str]:
    active_names = [player.name for player in PLAYERS if player.status == "active"]
    base_index = (month * 5 + slot * 3) % len(active_names)
    selected = [active_names[(base_index + offset) % len(active_names)] for offset in [0, 2, 5, 9]]
    return selected[0], selected[1], selected[2], selected[3]


def normalize_sets(raw_sets: list[tuple[int, int]]) -> tuple[list[tuple[int, int]], list[dict[str, object]]]:
    score_rows: list[tuple[int, int]] = []
    set_meta: list[dict[str, object]] = []
    for games_a, games_b in raw_sets:
        if games_a >= 10 or games_b >= 10:
            winner_a = games_a > games_b
            score_rows.append((1, 0) if winner_a else (0, 1))
            set_meta.append({
                "is_tiebreak": True,
                "is_super_tiebreak": True,
                "tiebreak_points_a": games_a,
                "tiebreak_points_b": games_b,
            })
        elif max(games_a, games_b) == 7 and min(games_a, games_b) == 6:
            score_rows.append((games_a, games_b))
            set_meta.append({
                "is_tiebreak": True,
                "is_super_tiebreak": False,
                "tiebreak_points_a": 7 if games_a > games_b else 4,
                "tiebreak_points_b": 4 if games_a > games_b else 7,
            })
        else:
            score_rows.append((games_a, games_b))
            set_meta.append({
                "is_tiebreak": False,
                "is_super_tiebreak": False,
                "tiebreak_points_a": None,
                "tiebreak_points_b": None,
            })
    return score_rows, set_meta


def infer_winner(sets: list[tuple[int, int]]) -> str:
    team_a_wins = sum(1 for games_a, games_b in sets if games_a > games_b)
    team_b_wins = sum(1 for games_a, games_b in sets if games_b > games_a)
    return "A" if team_a_wins >= team_b_wins else "B"


def summarize_sets(sets: list[tuple[int, int]]) -> str:
    return " / ".join(f"{games_a}-{games_b}" for games_a, games_b in sets)


def safe_match_day(year: int, month: int, preferred_day: int) -> int:
    return min(preferred_day, calendar.monthrange(year, month)[1])


def build_import_sql() -> str:
    lines: list[str] = [
        "-- Gerado automaticamente por scripts/generate_showcase_demo_sql.py",
        "-- Base de demonstracao para explorar dashboard, historico, ranking, estatisticas e hall da fama",
        "begin;",
        "",
        "insert into public.seasons (year, starts_at, ends_at, is_active)",
        "values (2026, '2026-01-01', '2026-12-31', true)",
        "on conflict (year) do update",
        "set starts_at = excluded.starts_at,",
        "    ends_at = excluded.ends_at,",
        "    is_active = excluded.is_active;",
        "",
        "with source_players(display_name, full_name, normalized_name, phone, registered_at, status) as (",
        "  values",
    ]

    for index, player in enumerate(PLAYERS):
        suffix = "," if index < len(PLAYERS) - 1 else ""
        lines.append(
            f"    ('{escape_sql(player.name)}', '{escape_sql(player.name)}', '{escape_sql(slugify(player.name))}', '{escape_sql(player.phone)}', '{player.registered_at}T00:00:00Z', '{player.status}'){suffix}"
        )

    lines.extend([
        ")",
        "insert into public.players (display_name, full_name, normalized_name, phone, registered_at, status)",
        "select sp.display_name, sp.full_name, sp.normalized_name, sp.phone, sp.registered_at::timestamptz, sp.status",
        "from source_players sp",
        "where not exists (",
        "  select 1",
        "  from public.players p",
        "  where upper(trim(p.display_name)) = upper(trim(sp.display_name))",
        "     or upper(trim(p.full_name)) = upper(trim(sp.full_name))",
        ");",
        "",
    ])

    match_counter = 0
    for month in range(1, 13):
      for slot, day in enumerate([4, 8, 12, 16, 20, 24, 27, 29], start=1):
        match_counter += 1
        team_a_1, team_a_2, team_b_1, team_b_2 = choose_players(month, slot)
        base_sets = SET_PATTERNS[(month + slot) % len(SET_PATTERNS)]
        scoreboard_sets, set_meta = normalize_sets(base_sets)
        winner_team = infer_winner(scoreboard_sets)
        result_summary = summarize_sets(scoreboard_sets)
        match_day = safe_match_day(2026, month, day)
        match_date = f"2026-{month:02d}-{match_day:02d}"
        court_name = COURTS[(month + slot) % len(COURTS)]
        note = f"{NOTE_MARKER} - partida {match_counter:03d}/96."

        lines.extend([
            f"-- Partida showcase {match_counter}",
            "with season_ref as (",
            "  select id from public.seasons where year = 2026 limit 1",
            "),",
            "player_refs as (",
            "  select",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(team_a_1)}')) limit 1) as team_a_player_1_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(team_a_2)}')) limit 1) as team_a_player_2_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(team_b_1)}')) limit 1) as team_b_player_1_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(team_b_2)}')) limit 1) as team_b_player_2_id",
            "),",
            "inserted_match as (",
            "  insert into public.matches (",
            "    season_id,",
            "    match_date,",
            "    court_name,",
            "    team_a_player_1_id,",
            "    team_a_player_2_id,",
            "    team_b_player_1_id,",
            "    team_b_player_2_id,",
            "    winner_team,",
            "    result_summary,",
            "    source,",
            "    notes",
            "  )",
            "  select",
            "    season_ref.id,",
            f"    '{match_date}',",
            f"    '{escape_sql(court_name)}',",
            "    player_refs.team_a_player_1_id,",
            "    player_refs.team_a_player_2_id,",
            "    player_refs.team_b_player_1_id,",
            "    player_refs.team_b_player_2_id,",
            f"    '{winner_team}',",
            f"    '{result_summary}',",
            "    'manual',",
            f"    '{escape_sql(note)}'",
            "  from season_ref",
            "  cross join player_refs",
            "  where player_refs.team_a_player_1_id is not null",
            "    and player_refs.team_a_player_2_id is not null",
            "    and player_refs.team_b_player_1_id is not null",
            "    and player_refs.team_b_player_2_id is not null",
            "    and not exists (",
            "      select 1",
            "      from public.matches m",
            "      where m.notes = " + f"'{escape_sql(note)}'",
            "    )",
            "  returning id",
            ")",
            "insert into public.match_sets (",
            "  match_id, set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes",
            ")",
            "select",
            "  inserted_match.id,",
            "  set_rows.set_order::smallint,",
            "  set_rows.team_a_games::smallint,",
            "  set_rows.team_b_games::smallint,",
            "  set_rows.is_tiebreak::boolean,",
            "  set_rows.is_super_tiebreak::boolean,",
            "  set_rows.tiebreak_points_a::smallint,",
            "  set_rows.tiebreak_points_b::smallint,",
            "  set_rows.deuces_count::smallint,",
            "  set_rows.set_notes::text",
            "from inserted_match",
            "cross join (",
            "  values",
        ])

        for set_index, ((games_a, games_b), meta) in enumerate(zip(scoreboard_sets, set_meta), start=1):
            suffix = "," if set_index < len(scoreboard_sets) else ""
            set_note = "Super tiebreak" if meta["is_super_tiebreak"] else ("Set decidido no tiebreak" if meta["is_tiebreak"] else "")
            deuces = (month + slot + set_index) % 5
            lines.append(
                "    (" +
                f"{set_index}, {games_a}, {games_b}, "
                f"{str(meta['is_tiebreak']).lower()}, {str(meta['is_super_tiebreak']).lower()}, "
                f"{'null' if meta['tiebreak_points_a'] is None else meta['tiebreak_points_a']}, "
                f"{'null' if meta['tiebreak_points_b'] is None else meta['tiebreak_points_b']}, "
                f"{deuces}, "
                f"{'null' if not set_note else chr(39) + escape_sql(set_note) + chr(39)}"
                f"){suffix}"
            )

        lines.extend([
            ") as set_rows(set_order, team_a_games, team_b_games, is_tiebreak, is_super_tiebreak, tiebreak_points_a, tiebreak_points_b, deuces_count, set_notes);",
            "",
        ])

    lines.extend([
        "select public.refresh_season_derived_data(id)",
        "from public.seasons",
        "where year = 2026;",
        "",
        "commit;",
        "",
    ])
    return "\n".join(lines)


def build_cleanup_sql() -> str:
    return "\n".join([
        "-- Remove a base showcase de demonstracao",
        "begin;",
        "",
        "delete from public.matches",
        f"where notes like '{NOTE_MARKER}%';",
        "",
        "select public.refresh_season_derived_data(id)",
        "from public.seasons",
        "where year = 2026;",
        "",
        "commit;",
        "",
    ])


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    IMPORT_FILE.write_text(build_import_sql(), encoding="utf-8")
    CLEANUP_FILE.write_text(build_cleanup_sql(), encoding="utf-8")
    print(f"Arquivo SQL gerado: {IMPORT_FILE}")
    print(f"Arquivo de limpeza gerado: {CLEANUP_FILE}")
    print("Partidas showcase preparadas: 96")


if __name__ == "__main__":
    main()
