from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = PROJECT_ROOT / "supabase" / "seeds" / "generated"
DEFAULT_INPUT = Path(r"C:\Users\wesle\Downloads\gemini-code-1781465633875.json")
NAME_ALIASES = {
    "AIL": "Ailson",
}


@dataclass
class TeamPayload:
    jogador_1: str
    jogador_2: str
    pontos_sets: list[int]


@dataclass
class MatchPayload:
    data: str
    dupla_a: TeamPayload
    dupla_b: TeamPayload


def normalize_space(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def slugify(value: str) -> str:
    compact = normalize_space(value)
    compact = compact.encode("ascii", "ignore").decode("ascii")
    compact = re.sub(r"[^a-zA-Z0-9]+", "-", compact)
    return compact.strip("-").lower()


def canonical_name(raw_name: str) -> str:
    compact = normalize_space(raw_name)
    alias_key = compact.upper()
    return NAME_ALIASES.get(alias_key, compact).title()


def escape_sql(value: str) -> str:
    return value.replace("'", "''")


def parse_payload(payload: list[dict]) -> list[MatchPayload]:
    matches: list[MatchPayload] = []
    for item in payload:
        team_a = TeamPayload(
            jogador_1=canonical_name(item["dupla_a"]["jogador_1"]),
            jogador_2=canonical_name(item["dupla_a"]["jogador_2"]),
            pontos_sets=[int(value) for value in item["dupla_a"]["pontos_sets"]],
        )
        team_b = TeamPayload(
            jogador_1=canonical_name(item["dupla_b"]["jogador_1"]),
            jogador_2=canonical_name(item["dupla_b"]["jogador_2"]),
            pontos_sets=[int(value) for value in item["dupla_b"]["pontos_sets"]],
        )

        if len(team_a.pontos_sets) != len(team_b.pontos_sets):
            raise ValueError(f"Quantidade de sets diferente na partida de {item['data']}.")

        matches.append(
            MatchPayload(
                data=item["data"],
                dupla_a=team_a,
                dupla_b=team_b,
            )
        )

    return matches


def infer_winner(team_a_sets: list[int], team_b_sets: list[int]) -> str:
    team_a_wins = sum(1 for a, b in zip(team_a_sets, team_b_sets) if a > b)
    team_b_wins = sum(1 for a, b in zip(team_a_sets, team_b_sets) if b > a)
    return "A" if team_a_wins >= team_b_wins else "B"


def summarize_sets(team_a_sets: list[int], team_b_sets: list[int]) -> str:
    return " / ".join(f"{a}-{b}" for a, b in zip(team_a_sets, team_b_sets))


def build_sql(matches: list[MatchPayload], source_file: Path) -> str:
    player_names: list[str] = []
    seen_players: set[str] = set()
    for match in matches:
        for name in [
            match.dupla_a.jogador_1,
            match.dupla_a.jogador_2,
            match.dupla_b.jogador_1,
            match.dupla_b.jogador_2,
        ]:
            if name not in seen_players:
                seen_players.add(name)
                player_names.append(name)

    lines: list[str] = [
        "-- Gerado automaticamente por scripts/import_match_json.py",
        f"-- Origem: {source_file}",
        "begin;",
        "",
        "insert into public.seasons (year, starts_at, ends_at, is_active)",
        "values (2026, '2026-01-01', '2026-12-31', true)",
        "on conflict (year) do nothing;",
        "",
        "with source_players(display_name, full_name, normalized_name) as (",
        "  values",
    ]

    for index, player_name in enumerate(player_names):
        suffix = "," if index < len(player_names) - 1 else ""
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
        result_summary = summarize_sets(match.dupla_a.pontos_sets, match.dupla_b.pontos_sets)
        winner_team = infer_winner(match.dupla_a.pontos_sets, match.dupla_b.pontos_sets)
        notes = f"Importado do arquivo JSON {source_file.name}."
        lines.extend([
            f"-- Partida {match_index}",
            "with season_ref as (",
            "  select id from public.seasons where year = 2026 limit 1",
            "),",
            "player_refs as (",
            "  select",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.dupla_a.jogador_1)}')) limit 1) as team_a_player_1_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.dupla_a.jogador_2)}')) limit 1) as team_a_player_2_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.dupla_b.jogador_1)}')) limit 1) as team_b_player_1_id,",
            f"    (select id from public.players where upper(trim(display_name)) = upper(trim('{escape_sql(match.dupla_b.jogador_2)}')) limit 1) as team_b_player_2_id",
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
            f"    '{match.data}',",
            "    player_refs.team_a_player_1_id,",
            "    player_refs.team_a_player_2_id,",
            "    player_refs.team_b_player_1_id,",
            "    player_refs.team_b_player_2_id,",
            f"    '{winner_team}',",
            f"    '{result_summary}',",
            "    'legacy_import',",
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
            f"        and m.match_date = '{match.data}'",
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

        for set_index, (games_a, games_b) in enumerate(zip(match.dupla_a.pontos_sets, match.dupla_b.pontos_sets), start=1):
            suffix = "," if set_index < len(match.dupla_a.pontos_sets) else ""
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


def main() -> None:
    input_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_INPUT
    payload = json.loads(input_path.read_text(encoding="utf-8"))
    matches = parse_payload(payload)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / f"{input_path.stem}.sql"
    output_path.write_text(build_sql(matches, input_path), encoding="utf-8")
    print(f"Arquivo SQL gerado: {output_path}")
    print(f"Partidas preparadas: {len(matches)}")


if __name__ == "__main__":
    main()
