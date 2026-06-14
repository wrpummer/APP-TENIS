import { mockDashboard, mockHallOfFame, mockMatches, mockPlayerStatistics, mockPlayers, mockRanking, mockSeason } from "@/lib/mock-data";
import { hasSupabaseEnv, supabase } from "@/lib/supabase";
import type {
  AdminCredentials,
  AdminLoginResult,
  DashboardData,
  HallOfFameEntry,
  Match,
  MatchFormValues,
  NextMatchInfo,
  NextMatchStatus,
  Player,
  PlayerStatistics,
  RankingRow,
  Season
} from "@/types/domain";
import { inferWinnerTeam, monthLabels, slugifyName, summarizeSets } from "@/utils/tennis";

function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof Error && error.message) {
    return error.message;
  }

  if (typeof error === "object" && error !== null) {
    const candidate = "message" in error ? error.message : null;
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate;
    }
  }

  return fallback;
}

function requireSupabase() {
  if (!supabase) {
    throw new Error("Supabase nao configurado. Defina VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY.");
  }

  return supabase;
}

function formatDecimal(value: number, digits = 1) {
  return value.toFixed(digits).replace(".", ",");
}

function formatPercentageLabel(value: number) {
  return `${value.toFixed(2).replace(".", ",")}%`;
}

function translateHallOfFameCategory(category: string) {
  switch (category) {
    case "champion":
      return "Campeão da temporada";
    case "most_wins":
      return "Mais vitórias";
    case "best_win_rate":
      return "Melhor aproveitamento";
    case "most_active":
      return "Jogador mais ativo";
    default:
      return category;
  }
}

function getDashboardSeason(seasons: Season[]) {
  const currentYear = new Date().getFullYear();
  return seasons.find((season) => season.year === currentYear)
    ?? seasons.find((season) => season.isActive)
    ?? seasons[0];
}

function buildNextMatchKey(seasonId: string) {
  return `next-match:${seasonId}`;
}

function normalizeNextMatchValue(value: unknown, seasonId: string): NextMatchInfo | null {
  if (!value || typeof value !== "object") {
    return null;
  }

  const candidate = value as Record<string, unknown>;
  return {
    seasonId,
    date: typeof candidate.date === "string" ? candidate.date : "",
    time: typeof candidate.time === "string" ? candidate.time : "",
    location: typeof candidate.location === "string" ? candidate.location : "",
    status: (candidate.status === "confirmed" || candidate.status === "cancelled" || candidate.status === "pending")
      ? candidate.status
      : "pending"
  };
}

export async function getSeasons(): Promise<Season[]> {
  if (!hasSupabaseEnv) {
    return [mockSeason];
  }

  const client = requireSupabase();
  const { data, error } = await client.from("seasons").select("*").order("year", { ascending: false });
  if (error) throw error;

  return (data ?? []).map((row) => ({
    id: row.id,
    year: row.year,
    startsAt: row.starts_at,
    endsAt: row.ends_at,
    isActive: row.is_active
  }));
}

export async function ensureSeasonsRange(startYear: number, endYear: number): Promise<Season[]> {
  if (!hasSupabaseEnv) {
    return Array.from({ length: endYear - startYear + 1 }, (_, index) => ({
      id: `season-${startYear + index}`,
      year: startYear + index,
      startsAt: `${startYear + index}-01-01`,
      endsAt: `${startYear + index}-12-31`,
      isActive: startYear + index === mockSeason.year
    }));
  }

  const client = requireSupabase();
  const existingSeasons = await getSeasons();
  const existingYears = new Set(existingSeasons.map((season) => season.year));
  const missingYears: number[] = [];

  for (let year = startYear; year <= endYear; year += 1) {
    if (!existingYears.has(year)) {
      missingYears.push(year);
    }
  }

  if (missingYears.length > 0) {
    const { error } = await client.from("seasons").insert(
      missingYears.map((year) => ({
        year,
        starts_at: `${year}-01-01`,
        ends_at: `${year}-12-31`,
        is_active: false
      }))
    );

    if (error) {
      throw new Error(getErrorMessage(error, "Nao foi possivel preparar as temporadas futuras no banco."));
    }
  }

  return getSeasons();
}

export async function getDashboard(): Promise<DashboardData> {
  if (!hasSupabaseEnv) {
    return mockDashboard;
  }

  const seasons = await getSeasons();
  const activeSeason = getDashboardSeason(seasons);
  const client = requireSupabase();
  const [players, ranking, hallOfFame, allSeasonMatches, monthlyRankingRows, nextMatchRow] = await Promise.all([
    getPlayers(),
    getRanking(activeSeason.id),
    getHallOfFame(activeSeason.id),
    client
      .from("matches")
      .select("*, match_sets(*)")
      .eq("season_id", activeSeason.id)
      .order("match_date", { ascending: false }),
    client
      .from("season_rankings")
      .select("scope_month, ranking_position, points, player_id, wins, players!inner(display_name)")
      .eq("season_id", activeSeason.id)
      .eq("scope", "monthly")
      .order("scope_month", { ascending: true })
      .order("ranking_position", { ascending: true }),
    client
      .from("system_settings")
      .select("value")
      .eq("key", buildNextMatchKey(activeSeason.id))
      .maybeSingle()
  ]);

  if (allSeasonMatches.error) {
    throw allSeasonMatches.error;
  }

  if (monthlyRankingRows.error) {
    throw monthlyRankingRows.error;
  }

  if (nextMatchRow.error) {
    throw nextMatchRow.error;
  }

  const matches: Match[] = (allSeasonMatches.data ?? []).map((row) => ({
    id: row.id,
    seasonId: row.season_id,
    matchDate: row.match_date,
    courtName: row.court_name,
    teamAPlayer1Id: row.team_a_player_1_id,
    teamAPlayer2Id: row.team_a_player_2_id,
    teamBPlayer1Id: row.team_b_player_1_id,
    teamBPlayer2Id: row.team_b_player_2_id,
    winnerTeam: row.winner_team,
    resultSummary: row.result_summary,
    source: row.source,
    notes: row.notes,
    sets: (row.match_sets ?? []).map((setRow: Record<string, unknown>) => ({
      id: String(setRow.id),
      setOrder: Number(setRow.set_order),
      teamAGames: Number(setRow.team_a_games),
      teamBGames: Number(setRow.team_b_games),
      isTiebreak: Boolean(setRow.is_tiebreak),
      isSuperTiebreak: Boolean(setRow.is_super_tiebreak),
      tiebreakPointsA: setRow.tiebreak_points_a == null ? null : Number(setRow.tiebreak_points_a),
      tiebreakPointsB: setRow.tiebreak_points_b == null ? null : Number(setRow.tiebreak_points_b),
      deucesCount: setRow.deuces_count == null ? null : Number(setRow.deuces_count),
      notes: setRow.set_notes == null ? null : String(setRow.set_notes)
    }))
  }));

  const recentMatches = matches.slice(0, 10);
  const activePlayersCount = players.filter((player) => player.status === "active").length;
  const playersWithMatchesCount = ranking.filter((row) => row.matchesPlayed > 0).length;
  const averagePerMonth = matches.length > 0 ? matches.length / new Set(matches.map((match) => match.matchDate.slice(0, 7))).size : 0;
  const nextMatch = normalizeNextMatchValue(nextMatchRow.data?.value, activeSeason.id);

  const quickStats = [
    { label: "Partidas registradas", value: String(matches.length), detail: "temporada atual" },
    { label: "Jogadores ativos", value: String(activePlayersCount), detail: `${playersWithMatchesCount} com pelo menos 1 jogo` },
    { label: "Média mensal", value: matches.length > 0 ? formatDecimal(averagePerMonth, 1) : "0,0", detail: "partidas por mês com jogos" }
  ];

  const matchesPerMonthMap = new Map<string, { month: string; matches: number; sets: number }>();
  const monthlyPlayerAppearances = new Map<string, Map<string, number>>();
  const monthlyGamesBalance = new Map<string, Map<string, number>>();
  for (const match of matches) {
    const date = new Date(`${match.matchDate}T00:00:00`);
    const key = `${date.getFullYear()}-${date.getMonth()}`;
    const label = monthLabels[date.getMonth()]?.slice(0, 3) ?? `M${date.getMonth() + 1}`;
    const current = matchesPerMonthMap.get(key) ?? { month: label, matches: 0, sets: 0 };
    current.matches += 1;
    current.sets += match.sets.length;
    matchesPerMonthMap.set(key, current);
    const playerIds = [match.teamAPlayer1Id, match.teamAPlayer2Id, match.teamBPlayer1Id, match.teamBPlayer2Id];
    const appearanceRow = monthlyPlayerAppearances.get(key) ?? new Map<string, number>();
    for (const playerId of playerIds) {
      appearanceRow.set(playerId, (appearanceRow.get(playerId) ?? 0) + 1);
    }
    monthlyPlayerAppearances.set(key, appearanceRow);

    const balanceRow = monthlyGamesBalance.get(key) ?? new Map<string, number>();
    const teamAGames = match.sets.reduce((sum, set) => sum + set.teamAGames, 0);
    const teamBGames = match.sets.reduce((sum, set) => sum + set.teamBGames, 0);
    const teamABalance = teamAGames - teamBGames;
    const teamBBalance = teamBGames - teamAGames;

    for (const playerId of [match.teamAPlayer1Id, match.teamAPlayer2Id]) {
      balanceRow.set(playerId, (balanceRow.get(playerId) ?? 0) + teamABalance);
    }
    for (const playerId of [match.teamBPlayer1Id, match.teamBPlayer2Id]) {
      balanceRow.set(playerId, (balanceRow.get(playerId) ?? 0) + teamBBalance);
    }
    monthlyGamesBalance.set(key, balanceRow);
  }

  const monthKeys = Array.from(matchesPerMonthMap.keys()).sort();
  const matchesPerMonth = monthKeys.map((key) => matchesPerMonthMap.get(key)!).reverse();
  const playersById = new Map(players.map((player) => [player.id, player]));
  const monthlyRows = (monthlyRankingRows.data ?? []).map((row) => {
    const player = Array.isArray(row.players) ? row.players[0] : row.players;
    return {
      scopeMonth: Number(row.scope_month),
      rankingPosition: Number(row.ranking_position),
      points: Number(row.points),
      wins: Number(row.wins),
      playerId: String(row.player_id),
      playerName: player?.display_name ?? ""
    };
  });

  const monthlyChampions = Array.from(new Set(monthlyRows.map((row) => row.scopeMonth))).sort((a, b) => a - b).map((month) => {
    const row = monthlyRows.find((entry) => entry.scopeMonth === month && entry.rankingPosition === 1);
    return {
      month: monthLabels[month - 1]?.slice(0, 3) ?? `M${month}`,
      playerName: row?.playerName ?? "Sem dados",
      points: row?.points ?? 0
    };
  });

  const monthlyMostActive = monthKeys.map((key) => {
    const counts = monthlyPlayerAppearances.get(key) ?? new Map<string, number>();
    const winnerEntry = Array.from(counts.entries()).sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))[0];
    const monthIndex = Number(key.split("-")[1]);
    return {
      month: monthLabels[monthIndex]?.slice(0, 3) ?? `M${monthIndex + 1}`,
      playerName: winnerEntry ? (playersById.get(winnerEntry[0])?.displayName ?? "Jogador") : "Sem dados",
      matches: winnerEntry?.[1] ?? 0
    };
  });

  const monthlyBestGamesBalance = monthKeys.map((key) => {
    const balances = monthlyGamesBalance.get(key) ?? new Map<string, number>();
    const winnerEntry = Array.from(balances.entries()).sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))[0];
    const monthIndex = Number(key.split("-")[1]);
    return {
      month: monthLabels[monthIndex]?.slice(0, 3) ?? `M${monthIndex + 1}`,
      playerName: winnerEntry ? (playersById.get(winnerEntry[0])?.displayName ?? "Jogador") : "Sem dados",
      balance: winnerEntry?.[1] ?? 0
    };
  });

  return {
    activeSeason,
    ranking,
    recentMatches,
    hallOfFame,
    nextMatch,
    quickStats,
    matchesPerMonth,
    monthlyChampions,
    monthlyMostActive,
    monthlyBestGamesBalance
  };
}

export async function getRanking(seasonId?: string): Promise<RankingRow[]> {
  if (!hasSupabaseEnv) {
    return mockRanking;
  }

  const client = requireSupabase();
  let query = client
    .from("season_rankings")
    .select("season_id, player_id, ranking_position, points, matches_played, wins, losses, win_rate, sets_won, sets_lost, games_won, games_lost, imported_from_legacy, players!inner(display_name, photo_url)")
    .eq("scope", "season")
    .order("ranking_position", { ascending: true });

  if (seasonId) {
    query = query.eq("season_id", seasonId);
  }

  const { data, error } = await query;
  if (error) throw error;

  return (data ?? []).map((row) => {
    const player = Array.isArray(row.players) ? row.players[0] : row.players;

    return ({
    seasonId: row.season_id,
    playerId: row.player_id,
    rankingPosition: row.ranking_position,
    playerName: player?.display_name ?? "",
    photoUrl: player?.photo_url ?? null,
    points: row.points,
    matchesPlayed: row.matches_played,
    wins: row.wins,
    losses: row.losses,
    winRate: row.win_rate,
    setsWon: row.sets_won,
    setsLost: row.sets_lost,
    gamesWon: row.games_won,
    gamesLost: row.games_lost,
    importedFromLegacy: row.imported_from_legacy
    });
  });
}

export async function getPlayers(): Promise<Player[]> {
  if (!hasSupabaseEnv) {
    return mockPlayers;
  }

  const client = requireSupabase();
  const { data, error } = await client.from("players").select("*").order("display_name");
  if (error) throw error;

  return (data ?? []).map((row) => ({
    id: row.id,
    legacyCode: row.legacy_code,
    fullName: row.full_name,
    displayName: row.display_name,
    normalizedName: row.normalized_name,
    phone: row.phone,
    photoUrl: row.photo_url,
    status: row.status,
    registeredAt: row.registered_at,
    notes: row.notes
  }));
}

export async function getPlayerStatistics(): Promise<PlayerStatistics[]> {
  if (!hasSupabaseEnv) {
    return mockPlayerStatistics;
  }

  const client = requireSupabase();
  const { data, error } = await client
    .from("player_statistics")
    .select(`
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
      players!player_statistics_player_id_fkey(display_name, photo_url),
      favorite_partner:players!player_statistics_favorite_partner_id_fkey(display_name),
      best_partner:players!player_statistics_best_partner_id_fkey(display_name),
      most_faced_rival:players!player_statistics_most_faced_rival_id_fkey(display_name),
      hardest_rival:players!player_statistics_hardest_rival_id_fkey(display_name)
    `)
    .order("points", { ascending: false });
  if (error) throw error;

  return (data ?? []).map((row) => {
    const player = Array.isArray(row.players) ? row.players[0] : row.players;
    const favoritePartner = Array.isArray(row.favorite_partner) ? row.favorite_partner[0] : row.favorite_partner;
    const bestPartner = Array.isArray(row.best_partner) ? row.best_partner[0] : row.best_partner;
    const mostFacedRival = Array.isArray(row.most_faced_rival) ? row.most_faced_rival[0] : row.most_faced_rival;
    const hardestRival = Array.isArray(row.hardest_rival) ? row.hardest_rival[0] : row.hardest_rival;

    return {
      playerId: row.player_id,
      seasonId: row.season_id,
      rankingPosition: 0,
      playerName: player?.display_name ?? "",
      photoUrl: player?.photo_url ?? null,
      points: row.points,
      matchesPlayed: row.matches_played,
      wins: row.wins,
      losses: row.losses,
      winRate: row.matches_played > 0 ? Number(((row.wins / row.matches_played) * 100).toFixed(2)) : 0,
      setsWon: row.sets_won,
      setsLost: row.sets_lost,
      gamesWon: row.games_won,
      gamesLost: row.games_lost,
      favoritePartner: favoritePartner?.display_name ?? null,
      bestPartner: bestPartner?.display_name ?? null,
      mostFacedRival: mostFacedRival?.display_name ?? null,
      hardestRival: hardestRival?.display_name ?? null,
      bestWinStreak: row.best_win_streak,
      worstLossStreak: row.worst_loss_streak,
      bestMonth: row.best_month == null ? null : monthLabels[Number(row.best_month) - 1] ?? null
    };
  });
}

function mapMatchRows(rows: Record<string, unknown>[]): Match[] {
  return rows.map((row) => ({
    id: String(row.id),
    seasonId: String(row.season_id),
    matchDate: String(row.match_date),
    courtName: row.court_name == null ? null : String(row.court_name),
    teamAPlayer1Id: String(row.team_a_player_1_id),
    teamAPlayer2Id: String(row.team_a_player_2_id),
    teamBPlayer1Id: String(row.team_b_player_1_id),
    teamBPlayer2Id: String(row.team_b_player_2_id),
    winnerTeam: row.winner_team as "A" | "B",
    resultSummary: String(row.result_summary),
    source: row.source as "manual" | "legacy_import",
    notes: row.notes == null ? null : String(row.notes),
    sets: ((row.match_sets ?? []) as Record<string, unknown>[]).map((setRow) => ({
      id: String(setRow.id),
      setOrder: Number(setRow.set_order),
      teamAGames: Number(setRow.team_a_games),
      teamBGames: Number(setRow.team_b_games),
      isTiebreak: Boolean(setRow.is_tiebreak),
      isSuperTiebreak: Boolean(setRow.is_super_tiebreak),
      tiebreakPointsA: setRow.tiebreak_points_a == null ? null : Number(setRow.tiebreak_points_a),
      tiebreakPointsB: setRow.tiebreak_points_b == null ? null : Number(setRow.tiebreak_points_b),
      deucesCount: setRow.deuces_count == null ? null : Number(setRow.deuces_count),
      notes: setRow.set_notes == null ? null : String(setRow.set_notes)
    }))
  }));
}

export async function getMatches(): Promise<Match[]> {
  if (!hasSupabaseEnv) {
    return mockMatches;
  }

  const client = requireSupabase();
  const { data, error } = await client
    .from("matches")
    .select("*, match_sets(*)")
    .order("match_date", { ascending: false });
  if (error) throw error;

  return mapMatchRows((data ?? []) as Record<string, unknown>[]);
}

export async function getRecentMatches(): Promise<Match[]> {
  if (!hasSupabaseEnv) {
    return mockMatches;
  }

  const client = requireSupabase();
  const { data, error } = await client
    .from("matches")
    .select("*, match_sets(*)")
    .order("match_date", { ascending: false })
    .limit(12);
  if (error) throw error;

  return mapMatchRows((data ?? []) as Record<string, unknown>[]);
}

export async function getHallOfFame(seasonId?: string): Promise<HallOfFameEntry[]> {
  if (!hasSupabaseEnv) {
    return mockHallOfFame;
  }

  const client = requireSupabase();
  let query = client
    .from("hall_of_fame")
    .select("category, value_text, value_number, player_id, players!inner(display_name, photo_url)");

  if (seasonId) {
    query = query.eq("season_id", seasonId);
  }

  const { data, error } = await query;
  if (error) throw error;

  return (data ?? []).map((row) => {
    const player = Array.isArray(row.players) ? row.players[0] : row.players;

    return ({
      category: translateHallOfFameCategory(row.category),
      playerId: row.player_id,
      playerName: player?.display_name ?? "",
      photoUrl: player?.photo_url ?? null,
      valueText: row.value_text,
      valueNumber: row.value_number
    });
  });
}

export async function getAdminSessionStatus() {
  if (!hasSupabaseEnv) {
    return true;
  }

  const client = requireSupabase();
  const { data: sessionData, error: sessionError } = await client.auth.getSession();
  if (sessionError) {
    throw sessionError;
  }

  const authUserId = sessionData.session?.user?.id;
  if (!authUserId) {
    return false;
  }

  const { data, error } = await client
    .from("admin_access")
    .select("id, is_active")
    .eq("auth_user_id", authUserId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return Boolean(data?.is_active);
}

export async function saveNextMatch(nextMatch: NextMatchInfo) {
  if (!hasSupabaseEnv) {
    return nextMatch;
  }

  const client = requireSupabase();
  const { error } = await client.from("system_settings").upsert({
    key: buildNextMatchKey(nextMatch.seasonId),
    value: {
      date: nextMatch.date,
      time: nextMatch.time,
      location: nextMatch.location,
      status: nextMatch.status
    },
    description: `Próximo jogo da temporada ${nextMatch.seasonId}`
  }, {
    onConflict: "key"
  });

  if (error) {
    throw error;
  }

  return nextMatch;
}

export async function savePlayer(player: Partial<Player>) {
  const payload = {
    full_name: player.fullName,
    display_name: player.displayName,
    normalized_name: slugifyName(player.displayName ?? player.fullName ?? ""),
    phone: player.phone ?? null,
    photo_url: player.photoUrl ?? null,
    status: player.status ?? "active",
    notes: player.notes ?? null,
    registered_at: player.registeredAt ?? new Date().toISOString()
  };

  if (!hasSupabaseEnv) {
    return payload;
  }

  const client = requireSupabase();
  const { error } = player.id
    ? await client.from("players").update(payload).eq("id", player.id)
    : await client.from("players").insert(payload);
  if (error) throw error;
}

export async function uploadPlayerPhoto(file: File, playerName: string) {
  if (!hasSupabaseEnv) {
    return URL.createObjectURL(file);
  }

  const client = requireSupabase();
  const extension = file.name.split(".").pop()?.toLowerCase() ?? "jpg";
  const filePath = `${slugifyName(playerName || "jogador")}-${Date.now()}.${extension}`;

  const { error } = await client.storage.from("player-photos").upload(filePath, file, {
    cacheControl: "3600",
    upsert: true
  });

  if (error) {
    throw error;
  }

  const { data } = client.storage.from("player-photos").getPublicUrl(filePath);
  return data.publicUrl;
}

export async function updatePlayerStatus(playerId: string, status: "active" | "inactive") {
  if (!hasSupabaseEnv) {
    return { id: playerId, status };
  }

  const client = requireSupabase();
  const { error } = await client.from("players").update({ status }).eq("id", playerId);
  if (error) throw error;
}

export async function countPlayerMatches(playerId: string) {
  if (!hasSupabaseEnv) {
    return 0;
  }

  const client = requireSupabase();
  const { count, error } = await client
    .from("matches")
    .select("id", { count: "exact", head: true })
    .or(
      `team_a_player_1_id.eq.${playerId},team_a_player_2_id.eq.${playerId},team_b_player_1_id.eq.${playerId},team_b_player_2_id.eq.${playerId}`
    );

  if (error) {
    throw new Error(getErrorMessage(error, "Nao foi possivel verificar as partidas vinculadas deste jogador."));
  }

  return count ?? 0;
}

export async function deletePlayer(playerId: string) {
  if (!hasSupabaseEnv) {
    return { id: playerId };
  }

  const linkedMatches = await countPlayerMatches(playerId);
  if (linkedMatches > 0) {
    throw new Error(
      linkedMatches === 1
        ? "Este jogador ja possui 1 partida vinculada. Inative em vez de excluir."
        : `Este jogador ja possui ${linkedMatches} partidas vinculadas. Inative em vez de excluir.`
    );
  }

  const client = requireSupabase();
  const { error } = await client.from("players").delete().eq("id", playerId);
  if (error) {
    if (error.code === "23503") {
      throw new Error("Este jogador ja possui partidas vinculadas. Inative em vez de excluir.");
    }

    throw error;
  }
}

export async function saveMatch(values: MatchFormValues) {
  const persistedSets = values.sets.filter((set) => set.isEnabled !== false && !(set.teamAGames === 0 && set.teamBGames === 0));
  const winnerTeam = inferWinnerTeam(persistedSets);
  const resultSummary = summarizeSets(persistedSets);

  if (!hasSupabaseEnv) {
    return { winnerTeam, resultSummary };
  }

  const client = requireSupabase();
  const payload = {
    season_id: values.seasonId,
    match_date: values.matchDate,
    team_a_player_1_id: values.teamAPlayer1Id,
    team_a_player_2_id: values.teamAPlayer2Id,
    team_b_player_1_id: values.teamBPlayer1Id,
    team_b_player_2_id: values.teamBPlayer2Id,
    winner_team: winnerTeam,
    result_summary: resultSummary,
    notes: values.notes ?? null
  };

  const { data, error } = values.id
    ? await client.from("matches").update(payload).eq("id", values.id).select("id").single()
    : await client.from("matches").insert(payload).select("id").single();

  if (error) {
    throw new Error(
      getErrorMessage(
        error,
        values.id ? "Nao foi possivel atualizar a partida." : "Nao foi possivel criar a partida."
      )
    );
  }

  if (values.id) {
    const { error: deleteSetsError } = await client.from("match_sets").delete().eq("match_id", values.id);
    if (deleteSetsError) {
      throw new Error(getErrorMessage(deleteSetsError, "Nao foi possivel atualizar os sets existentes da partida."));
    }
  }

  const insertRows = persistedSets.map((set) => ({
    match_id: data.id,
    set_order: set.setOrder,
    team_a_games: set.teamAGames,
    team_b_games: set.teamBGames,
    is_tiebreak: set.isTiebreak,
    tiebreak_points_a: set.isTiebreak ? set.tiebreakPointsA ?? null : null,
    tiebreak_points_b: set.isTiebreak ? set.tiebreakPointsB ?? null : null,
    ...(set.isSuperTiebreak ? { is_super_tiebreak: true } : {}),
    ...(set.deucesCount != null ? { deuces_count: set.deucesCount } : {}),
    ...(set.notes?.trim() ? { set_notes: set.notes.trim() } : {})
  }));

  const { error: setsError } = await client.from("match_sets").insert(insertRows);

  if (setsError) {
    throw new Error(
      getErrorMessage(
        setsError,
        "Nao foi possivel salvar os sets da partida."
      )
    );
  }

  return data;
}

export async function deleteMatch(matchId: string) {
  if (!hasSupabaseEnv) {
    return { id: matchId };
  }

  const client = requireSupabase();
  const { error } = await client.from("matches").delete().eq("id", matchId);
  if (error) throw error;
}

export async function loginAdmin(credentials: AdminCredentials): Promise<AdminLoginResult> {
  const normalizedEmail = credentials.email.trim().toLowerCase();

  if (!hasSupabaseEnv) {
    return {
      ok: normalizedEmail === "admin@trianon.local" && credentials.password.length >= 4,
      message: "Modo local sem Supabase."
    };
  }

  const client = requireSupabase();
  const { data: authData, error: authError } = await client.auth.signInWithPassword({
    email: normalizedEmail,
    password: credentials.password
  });
  if (authError) {
    return {
      ok: false,
      message: authError.message === "Invalid login credentials"
        ? "O Supabase rejeitou o email/senha. Confira se o email foi criado em Authentication e se a senha esta correta."
        : authError.message
    };
  }

  const { data, error } = await client
    .from("admin_access")
    .select("id, is_active")
    .eq("auth_user_id", authData.user.id)
    .maybeSingle();
  if (error) {
    throw error;
  }

  if (!data?.is_active) {
    return {
      ok: false,
      message: "Login autenticado, mas este usuario nao esta liberado na tabela admin_access."
    };
  }

  return {
    ok: true
  };
}
