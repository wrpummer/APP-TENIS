from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = PROJECT_ROOT / "supabase" / "seeds" / "generated"
IMPORT_FILE = OUTPUT_DIR / "fake-matches-2026.sql"
CLEANUP_FILE = OUTPUT_DIR / "cleanup-fake-matches-2026.sql"
PLAYER_NAMES = [
    "Carlos Eduardo",
    "Ailson",
    "Hellinton",
    "Milton",
    "Marcos",
    "Daniel",
    "Denny",
    "Cleber",
    "Marcelo",
    "Rodrigo",
    "Arthur",
    "Wesley R Pummer",
]
MONTH_DAYS = [5, 9, 13, 19, 25]
SET_PATTERNS = [
    [(6, 3), (6, 4)],
    [(4, 6), (6, 2), (6, 3)],
    [(7, 5), (3, 6), (6, 4)],
    [(6, 2), (6, 1)],
    [(6, 4), (5, 7), (6, 3)],
]
NOTES_MARKER = "Lote ficticio de teste 2026"


@dataclass
class MatchSeed:
    match_date: str
    team_a: tuple[str, str]
    team_b: tuple[str, str]
    sets: list[tuple[int, int]]


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


def build_matches() -> list[MatchSeed]:
    matches: list[MatchSeed] = []
    total_players = len(PLAYER_NAMES)

    for month in range(1, 13):
        for slot, day in enumerate(MONTH_DAYS):
            base_index = (month * 3 + slot * 2) % total_players
            selected = [PLAYER_NAMES[(base_index + offset) % total_players] for offset in [0, 1, 4, 7]]
            team_a = (selected[0], selected[1])
            team_b = (selected[2], selected[3])
            pattern = SET_PATTERNS[(month + slot) % len(SET_PATTERNS)]
            match_date = f"2026-{month:02d}-{day:02d}"
            matches.append(MatchSeed(match_date=match_date, team_a=team_a, team_b=team_b, sets=pattern))

    return matches


def infer_winner(sets: list[tuple[int, int]]) -> str:
    team_a_wins = sum(1 for games_a, games_b in sets if games_a > games_b)
    team_b_wins = sum(1 for games_a, games_b in sets if games_b > games_a)
    return "A" if team_a_wins >= team_b_wins else "B"


def summarize_sets(sets: list[tuple[int, int]]) -> str:
    return " / ".join(f"{games_a}-{games_b}" for games_a, games_b in sets)


def build_import_sql(matches: list[MatchSeed]) -> str:
    lines: list[str] = [
        "-- Gerado automaticamente por scripts/generate_fake_matches_2026.py",
        "-- Importa 60 partidas ficticias para teste visual do aplicativo",
        "begin;",
        "",
        "insert into public.seasons (year, starts_at, ends_at, is_active)",
        "values (2026, '2026-01-01', '2026-12-31', true)",
        "on conflict (year) do nothing;",
        "",
        "with source_players(display_name, full_name, normalized_name) as (",
        "  values",
    ]

    for index, player_name in enumerate(PLAYER_NAMES):
        suffix = "," if index < len(PLAYER_NAMES) - 1 else ""
        lines.append(
            f"    ('{escape_sql(player_name)}', '{escape_sql(player_name)}', '{escape_sql(slugify(player_name))}'){suffix}"
        )

    lines.extend([
        ")",
        "insert into public.players (display_name, full_name, normalized_name, status)",
        "select sp.display_name, sp.full_name, sp.normalized_name, 'active'",
        "from source_players sp",
        "where not exists (",
        "  select 1",
        "  from public.players p",
        "  where upper(trim(p.display_name)) = upper(trim(sp.display_name))",
        "     or upper(trim(p.full_name)) = upper(trim(sp.full_name))",
        ");",
        "",
    ])

    for match_index, match in enumerate(matches, start=1):
        result_summary = summarize_sets(match.sets)
        winner_team = infer_winner(match.sets)
        notes = f"{NOTES_MARKER} - partida {match_index:02d}/60."
        lines.extend([
            f"-- Partida ficticia {match_index}",
            "with season_ref as (",
            "  select id from public.seasons where year = 2026 limit 1",
            "),",
            "player_refs as (",
            "  select",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.team_a[0])}')) limit 1) as team_a_player_1_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.team_a[1])}')) limit 1) as team_a_player_2_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.team_b[0])}')) limit 1) as team_b_player_1_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.team_b[1])}')) limit 1) as team_b_player_2_id",
            "),",
            "inserted_match as (",
            "  insert into public.matches (",
            "    season_id,",
            "    match_date,",
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
            f"    '{match.match_date}',",
            "    player_refs.team_a_player_1_id,",
            "    player_refs.team_a_player_2_id,",
            "    player_refs.team_b_player_1_id,",
            "    player_refs.team_b_player_2_id,",
            f"    '{winner_team}',",
            f"    '{result_summary}',",
            "    'manual',",
            f"    '{escape_sql(notes)}'",
            "  from season_ref",
            "  cross join player_refs",
            "  where player_refs.team_a_player_1_id is not null",
            "    and player_refs.team_a_player_2_id is not null",
            "    and player_refs.team_b_player_1_id is not null",
            "    and player_refs.team_b_player_2_id is not null",
            "    and not exists (",
            "      select 1",
            "      from public.matches m",
            "      where m.season_id = season_ref.id",
            f"        and m.match_date = '{match.match_date}'",
            f"        and m.result_summary = '{result_summary}'",
            "        and m.team_a_player_1_id = player_refs.team_a_player_1_id",
            "        and m.team_a_player_2_id = player_refs.team_a_player_2_id",
            "        and m.team_b_player_1_id = player_refs.team_b_player_1_id",
            "        and m.team_b_player_2_id = player_refs.team_b_player_2_id",
            "    )",
            "  returning id",
            ")",
            "insert into public.match_sets (match_id, set_order, team_a_games, team_b_games, is_tiebreak)",
            "select inserted_match.id, set_rows.set_order, set_rows.team_a_games, set_rows.team_b_games, false",
            "from inserted_match",
            "cross join (",
            "  values",
        ])

        for set_index, (games_a, games_b) in enumerate(match.sets, start=1):
            suffix = "," if set_index < len(match.sets) else ""
            lines.append(f"    ({set_index}, {games_a}, {games_b}){suffix}")

        lines.extend([
            ") as set_rows(set_order, team_a_games, team_b_games);",
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
    return "\n".join(
        [
            "-- Remove o lote ficticio gerado para testes",
            "begin;",
            "",
            "delete from public.matches",
            f"where notes like '{NOTES_MARKER}%';",
            "",
            "select public.refresh_season_derived_data(id)",
            "from public.seasons",
            "where year = 2026;",
            "",
            "commit;",
            "",
        ]
    )


def main() -> None:
    matches = build_matches()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    IMPORT_FILE.write_text(build_import_sql(matches), encoding="utf-8")
    CLEANUP_FILE.write_text(build_cleanup_sql(), encoding="utf-8")
    print(f"Arquivo SQL gerado: {IMPORT_FILE}")
    print(f"Arquivo de limpeza gerado: {CLEANUP_FILE}")
    print(f"Partidas ficticias preparadas: {len(matches)}")


if __name__ == "__main__":
    main()
