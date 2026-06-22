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

async function seasonHasMatches(seasonId: string) {
  if (!hasSupabaseEnv) {
    return mockMatches.length > 0;
  }

  const client = requireSupabase();
  const { count, error } = await client
    .from("matches")
    .select("id", { count: "exact", head: true })
    .eq("season_id", seasonId);

  if (error) {
    throw error;
  }

  return (count ?? 0) > 0;
}

async function refreshSeasonDerivedData(seasonId: string) {
  if (!hasSupabaseEnv) {
    return;
  }

  const client = requireSupabase();
  const { error } = await client.rpc("refresh_season_derived_data", {
    target_season_id: seasonId
  });

  if (error) {
    throw new Error(getErrorMessage(error, "Não foi possível recalcular ranking e estatísticas da temporada."));
  }
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

function formatMonthKey(year: number, monthIndex: number) {
  return `${year}-${String(monthIndex + 1).padStart(2, "0")}`;
}

function buildLastTwelveMonthsWindow() {
  const now = new Date();
  const months: Array<{ key: string; label: string; month: string; year: number; monthIndex: number }> = [];

  for (let offset = 11; offset >= 0; offset -= 1) {
    const date = new Date(now.getFullYear(), now.getMonth() - offset, 1);
    const year = date.getFullYear();
    const monthIndex = date.getMonth();
    const month = monthLabels[monthIndex]?.slice(0, 3) ?? `M${monthIndex + 1}`;
    months.push({
      key: formatMonthKey(year, monthIndex),
      label: `${month}/${year}`,
      month,
      year,
      monthIndex
    });
  }

  return {
    months,
    startDate: `${months[0].year}-${String(months[0].monthIndex + 1).padStart(2, "0")}-01`
  };
}

type PlayerAggregate = {
  seasonId: string;
  playerId: string;
  playerName: string;
  photoUrl?: string | null;
  points: number;
  matchesPlayed: number;
  wins: number;
  losses: number;
  setsWon: number;
  setsLost: number;
  gamesWon: number;
  gamesLost: number;
};

function createPlayerAggregate(player: Player, seasonId: string): PlayerAggregate {
  return {
    seasonId,
    playerId: player.id,
    playerName: player.displayName,
    photoUrl: player.photoUrl,
    points: 0,
    matchesPlayed: 0,
    wins: 0,
    losses: 0,
    setsWon: 0,
    setsLost: 0,
    gamesWon: 0,
    gamesLost: 0
  };
}

function getTeamPlayers(match: Match, team: "A" | "B") {
  return team === "A"
    ? [match.teamAPlayer1Id, match.teamAPlayer2Id]
    : [match.teamBPlayer1Id, match.teamBPlayer2Id];
}

function buildRankingFromMatches(matches: Match[], players: Player[], seasonId: string): RankingRow[] {
  if (matches.length === 0) {
    return [];
  }

  const playersById = new Map(players.map((player) => [player.id, player]));
  const aggregates = new Map<string, PlayerAggregate>();

  const ensureAggregate = (playerId: string) => {
    const player = playersById.get(playerId);
    if (!player) {
      return null;
    }

    const existing = aggregates.get(playerId);
    if (existing) {
      return existing;
    }

    const created = createPlayerAggregate(player, seasonId);
    aggregates.set(playerId, created);
    return created;
  };

  for (const match of matches) {
    const teamAPlayers = getTeamPlayers(match, "A");
    const teamBPlayers = getTeamPlayers(match, "B");
    const allSlots: Array<{ playerId: string; team: "A" | "B" }> = [
      ...teamAPlayers.map((playerId) => ({ playerId, team: "A" as const })),
      ...teamBPlayers.map((playerId) => ({ playerId, team: "B" as const }))
    ];

    for (const slot of allSlots) {
      const aggregate = ensureAggregate(slot.playerId);
      if (!aggregate) {
        continue;
      }

      const isWinner = slot.team === match.winnerTeam;
      aggregate.matchesPlayed += 1;
      aggregate.wins += isWinner ? 1 : 0;
      aggregate.losses += isWinner ? 0 : 1;
      aggregate.points += isWinner ? 3 : 1;

      for (const set of match.sets) {
        const ownGames = slot.team === "A" ? set.teamAGames : set.teamBGames;
        const opponentGames = slot.team === "A" ? set.teamBGames : set.teamAGames;
        aggregate.gamesWon += ownGames;
        aggregate.gamesLost += opponentGames;

        if (ownGames > opponentGames) {
          aggregate.setsWon += 1;
        } else if (ownGames < opponentGames) {
          aggregate.setsLost += 1;
        }
      }
    }
  }

  return Array.from(aggregates.values())
    .map((aggregate) => ({
      ...aggregate,
      rankingPosition: 0,
      winRate: aggregate.matchesPlayed > 0
        ? Number(((aggregate.wins / aggregate.matchesPlayed) * 100).toFixed(2))
        : 0,
      importedFromLegacy: false
    }))
    .sort((a, b) =>
      b.points - a.points
      || b.wins - a.wins
      || b.winRate - a.winRate
      || (b.setsWon - b.setsLost) - (a.setsWon - a.setsLost)
      || (b.gamesWon - b.gamesLost) - (a.gamesWon - a.gamesLost)
      || a.playerName.localeCompare(b.playerName)
    )
    .map((row, index) => ({ ...row, rankingPosition: index + 1 }));
}

function buildPlayerStatisticsFromMatches(matches: Match[], players: Player[], seasonId: string): PlayerStatistics[] {
  const ranking = buildRankingFromMatches(matches, players, seasonId);
  if (ranking.length === 0) {
    return [];
  }

  const playersById = new Map(players.map((player) => [player.id, player]));
  const partnerRows = new Map<string, Map<string, { matches: number; wins: number }>>();
  const rivalRows = new Map<string, Map<string, { matches: number; wins: number; losses: number }>>();
  const monthlyRows = new Map<string, Map<number, { points: number; wins: number }>>();
  const streakRows = new Map<string, Array<{ date: string; matchId: string; isWin: boolean }>>();

  const addPartner = (playerId: string, partnerId: string, isWin: boolean) => {
    const playerMap = partnerRows.get(playerId) ?? new Map<string, { matches: number; wins: number }>();
    const row = playerMap.get(partnerId) ?? { matches: 0, wins: 0 };
    row.matches += 1;
    row.wins += isWin ? 1 : 0;
    playerMap.set(partnerId, row);
    partnerRows.set(playerId, playerMap);
  };

  const addRival = (playerId: string, rivalId: string, isWin: boolean) => {
    const playerMap = rivalRows.get(playerId) ?? new Map<string, { matches: number; wins: number; losses: number }>();
    const row = playerMap.get(rivalId) ?? { matches: 0, wins: 0, losses: 0 };
    row.matches += 1;
    row.wins += isWin ? 1 : 0;
    row.losses += isWin ? 0 : 1;
    playerMap.set(rivalId, row);
    rivalRows.set(playerId, playerMap);
  };

  for (const match of matches) {
    const month = Number(match.matchDate.slice(5, 7));
    const teamAPlayers = getTeamPlayers(match, "A");
    const teamBPlayers = getTeamPlayers(match, "B");
    const teams = [
      { side: "A" as const, players: teamAPlayers, rivals: teamBPlayers },
      { side: "B" as const, players: teamBPlayers, rivals: teamAPlayers }
    ];

    for (const team of teams) {
      const isWin = team.side === match.winnerTeam;
      for (const playerId of team.players) {
        const monthMap = monthlyRows.get(playerId) ?? new Map<number, { points: number; wins: number }>();
        const monthRow = monthMap.get(month) ?? { points: 0, wins: 0 };
        monthRow.points += isWin ? 3 : 1;
        monthRow.wins += isWin ? 1 : 0;
        monthMap.set(month, monthRow);
        monthlyRows.set(playerId, monthMap);

        const playerStreaks = streakRows.get(playerId) ?? [];
        playerStreaks.push({ date: match.matchDate, matchId: match.id, isWin });
        streakRows.set(playerId, playerStreaks);

        for (const partnerId of team.players.filter((candidate) => candidate !== playerId)) {
          addPartner(playerId, partnerId, isWin);
        }

        for (const rivalId of team.rivals) {
          addRival(playerId, rivalId, isWin);
        }
      }
    }
  }

  const getBestStreaks = (playerId: string) => {
    const rows = (streakRows.get(playerId) ?? []).sort((a, b) => a.date.localeCompare(b.date) || a.matchId.localeCompare(b.matchId));
    let currentWin = 0;
    let currentLoss = 0;
    let bestWin = 0;
    let worstLoss = 0;

    for (const row of rows) {
      if (row.isWin) {
        currentWin += 1;
        currentLoss = 0;
      } else {
        currentLoss += 1;
        currentWin = 0;
      }

      bestWin = Math.max(bestWin, currentWin);
      worstLoss = Math.max(worstLoss, currentLoss);
    }

    return { bestWin, worstLoss };
  };

  const getFavoritePartner = (playerId: string) => {
    const rows = Array.from(partnerRows.get(playerId)?.entries() ?? []);
    const best = rows.sort((a, b) =>
      b[1].matches - a[1].matches
      || b[1].wins - a[1].wins
      || a[0].localeCompare(b[0])
    )[0];
    return best ? playersById.get(best[0])?.displayName ?? null : null;
  };

  const getBestPartner = (playerId: string) => {
    const rows = Array.from(partnerRows.get(playerId)?.entries() ?? []);
    const best = rows.sort((a, b) => {
      const rateA = a[1].matches > 0 ? a[1].wins / a[1].matches : 0;
      const rateB = b[1].matches > 0 ? b[1].wins / b[1].matches : 0;
      return rateB - rateA || b[1].wins - a[1].wins || b[1].matches - a[1].matches || a[0].localeCompare(b[0]);
    })[0];
    return best ? playersById.get(best[0])?.displayName ?? null : null;
  };

  const getMostFacedRival = (playerId: string) => {
    const rows = Array.from(rivalRows.get(playerId)?.entries() ?? []);
    const best = rows.sort((a, b) =>
      b[1].matches - a[1].matches
      || b[1].losses - a[1].losses
      || a[0].localeCompare(b[0])
    )[0];
    return best ? playersById.get(best[0])?.displayName ?? null : null;
  };

  const getHardestRival = (playerId: string) => {
    const rows = Array.from(rivalRows.get(playerId)?.entries() ?? []);
    const best = rows.sort((a, b) => {
      const rateA = a[1].matches > 0 ? a[1].wins / a[1].matches : 0;
      const rateB = b[1].matches > 0 ? b[1].wins / b[1].matches : 0;
      return rateA - rateB || b[1].losses - a[1].losses || b[1].matches - a[1].matches || a[0].localeCompare(b[0]);
    })[0];
    return best ? playersById.get(best[0])?.displayName ?? null : null;
  };

  const getBestMonth = (playerId: string) => {
    const rows = Array.from(monthlyRows.get(playerId)?.entries() ?? []);
    const best = rows.sort((a, b) => b[1].points - a[1].points || b[1].wins - a[1].wins || b[0] - a[0])[0];
    return best ? monthLabels[best[0] - 1] ?? null : null;
  };

  return ranking.map((row) => {
    const streaks = getBestStreaks(row.playerId);
    return {
      ...row,
      favoritePartner: getFavoritePartner(row.playerId),
      bestPartner: getBestPartner(row.playerId),
      mostFacedRival: getMostFacedRival(row.playerId),
      hardestRival: getHardestRival(row.playerId),
      bestWinStreak: streaks.bestWin,
      worstLossStreak: streaks.worstLoss,
      bestMonth: getBestMonth(row.playerId)
    };
  });
}

function buildHallOfFameFromRanking(ranking: RankingRow[]): HallOfFameEntry[] {
  if (ranking.length === 0) {
    return [];
  }

  const champion = ranking[0];
  const mostWins = [...ranking].sort((a, b) => b.wins - a.wins || b.points - a.points || a.playerName.localeCompare(b.playerName))[0];
  const bestWinRate = [...ranking].sort((a, b) =>
    b.winRate - a.winRate
    || b.wins - a.wins
    || b.points - a.points
    || a.playerName.localeCompare(b.playerName)
  )[0];
  const mostActive = [...ranking].sort((a, b) =>
    b.matchesPlayed - a.matchesPlayed
    || b.points - a.points
    || a.playerName.localeCompare(b.playerName)
  )[0];

  return [
    { category: "Campeão da temporada", playerId: champion.playerId, playerName: champion.playerName, photoUrl: champion.photoUrl, valueNumber: champion.points },
    { category: "Mais vitórias", playerId: mostWins.playerId, playerName: mostWins.playerName, photoUrl: mostWins.photoUrl, valueNumber: mostWins.wins },
    { category: "Melhor aproveitamento", playerId: bestWinRate.playerId, playerName: bestWinRate.playerName, photoUrl: bestWinRate.photoUrl, valueNumber: bestWinRate.winRate },
    { category: "Jogador mais ativo", playerId: mostActive.playerId, playerName: mostActive.playerName, photoUrl: mostActive.photoUrl, valueNumber: mostActive.matchesPlayed }
  ];
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
  const lastTwelveMonths = buildLastTwelveMonthsWindow();
  const client = requireSupabase();
  const [players, ranking, hallOfFame, allSeasonMatches, chartMatchesResponse, nextMatchRow] = await Promise.all([
    getPlayers(),
    getRanking(activeSeason.id),
    getHallOfFame(activeSeason.id),
    client
      .from("matches")
      .select("*, match_sets(*)")
      .eq("season_id", activeSeason.id)
      .order("match_date", { ascending: false }),
    client
      .from("matches")
      .select("*, match_sets(*)")
      .gte("match_date", lastTwelveMonths.startDate)
      .order("match_date", { ascending: false }),
    client
      .from("system_settings")
      .select("value")
      .eq("key", buildNextMatchKey(activeSeason.id))
      .maybeSingle()
  ]);

  if (allSeasonMatches.error) {
    throw allSeasonMatches.error;
  }

  if (chartMatchesResponse.error) {
    throw chartMatchesResponse.error;
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

  const chartMatches: Match[] = (chartMatchesResponse.data ?? []).map((row) => ({
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
  const safeRanking = matches.length === 0 ? [] : ranking;
  const safeHallOfFame = matches.length === 0 ? [] : hallOfFame;

  const quickStats = [
    { label: "Partidas registradas", value: String(matches.length), detail: "temporada atual" },
    { label: "Jogadores ativos", value: String(activePlayersCount), detail: `${playersWithMatchesCount} com pelo menos 1 jogo` },
    { label: "Média mensal", value: matches.length > 0 ? formatDecimal(averagePerMonth, 1) : "0,0", detail: "partidas por mês com jogos" }
  ];

  const matchesPerMonthMap = new Map<string, { month: string; matches: number; sets: number }>();
  const monthlyPlayerAppearances = new Map<string, Map<string, number>>();
  const monthlyGamesBalance = new Map<string, Map<string, number>>();
  const monthlyPlayerPoints = new Map<string, Map<string, number>>();
  for (const match of chartMatches) {
    const date = new Date(`${match.matchDate}T00:00:00`);
    const key = formatMonthKey(date.getFullYear(), date.getMonth());
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

    const pointsRow = monthlyPlayerPoints.get(key) ?? new Map<string, number>();
    const teamAPlayers = [match.teamAPlayer1Id, match.teamAPlayer2Id];
    const teamBPlayers = [match.teamBPlayer1Id, match.teamBPlayer2Id];
    const winners = match.winnerTeam === "A" ? teamAPlayers : teamBPlayers;
    const losers = match.winnerTeam === "A" ? teamBPlayers : teamAPlayers;

    for (const playerId of winners) {
      pointsRow.set(playerId, (pointsRow.get(playerId) ?? 0) + 3);
    }

    for (const playerId of losers) {
      pointsRow.set(playerId, (pointsRow.get(playerId) ?? 0) + 1);
    }

    monthlyPlayerPoints.set(key, pointsRow);
  }

  const monthKeys = lastTwelveMonths.months.map((item) => item.key);
  const matchesPerMonth = lastTwelveMonths.months.map((item) => {
    const row = matchesPerMonthMap.get(item.key);
    return {
      month: item.month,
      year: item.year,
      label: item.label,
      matches: row?.matches ?? 0,
      sets: row?.sets ?? 0
    };
  });
  const playersById = new Map(players.map((player) => [player.id, player]));
  const monthlyChampions = lastTwelveMonths.months.map((item) => {
    const points = monthlyPlayerPoints.get(item.key) ?? new Map<string, number>();
    const winnerEntry = Array.from(points.entries()).sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))[0];
    return {
      month: item.month,
      year: item.year,
      label: item.label,
      playerName: winnerEntry ? (playersById.get(winnerEntry[0])?.displayName ?? "Jogador") : "Sem dados",
      points: winnerEntry?.[1] ?? 0
    };
  });

  const monthlyMostActive = lastTwelveMonths.months.map((item) => {
    const counts = monthlyPlayerAppearances.get(item.key) ?? new Map<string, number>();
    const points = monthlyPlayerPoints.get(item.key) ?? new Map<string, number>();
    const winnerEntry = Array.from(counts.entries()).sort((a, b) =>
      b[1] - a[1]
      || (points.get(b[0]) ?? 0) - (points.get(a[0]) ?? 0)
      || a[0].localeCompare(b[0])
    )[0];
    return {
      month: item.month,
      year: item.year,
      label: item.label,
      playerName: winnerEntry ? (playersById.get(winnerEntry[0])?.displayName ?? "Jogador") : "Sem dados",
      matches: winnerEntry?.[1] ?? 0,
      points: winnerEntry ? points.get(winnerEntry[0]) ?? 0 : 0
    };
  });

  const monthlyBestGamesBalance = lastTwelveMonths.months.map((item) => {
    const balances = monthlyGamesBalance.get(item.key) ?? new Map<string, number>();
    const winnerEntry = Array.from(balances.entries()).sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))[0];
    return {
      month: item.month,
      year: item.year,
      label: item.label,
      playerName: winnerEntry ? (playersById.get(winnerEntry[0])?.displayName ?? "Jogador") : "Sem dados",
      balance: winnerEntry?.[1] ?? 0
    };
  });

  return {
    activeSeason,
    ranking: safeRanking,
    recentMatches,
    hallOfFame: safeHallOfFame,
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

  const resolvedSeasonId = seasonId ?? getDashboardSeason(await getSeasons()).id;
  const [players, matches] = await Promise.all([getPlayers(), getMatchesBySeason(resolvedSeasonId)]);
  return buildRankingFromMatches(matches, players, resolvedSeasonId);
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

  const activeSeason = getDashboardSeason(await getSeasons());
  const [players, matches] = await Promise.all([getPlayers(), getMatchesBySeason(activeSeason.id)]);
  return buildPlayerStatisticsFromMatches(matches, players, activeSeason.id);
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

async function getMatchesBySeason(seasonId: string): Promise<Match[]> {
  if (!hasSupabaseEnv) {
    return mockMatches.filter((match) => match.seasonId === seasonId);
  }

  const client = requireSupabase();
  const { data, error } = await client
    .from("matches")
    .select("*, match_sets(*)")
    .eq("season_id", seasonId)
    .order("match_date", { ascending: false });

  if (error) {
    throw error;
  }

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

  const resolvedSeasonId = seasonId ?? getDashboardSeason(await getSeasons()).id;
  const ranking = await getRanking(resolvedSeasonId);
  return buildHallOfFameFromRanking(ranking);
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
    const message = getErrorMessage(error, "Não foi possível enviar a foto.");
    if (/1\s*mb|too large|file size|exceeded/i.test(message)) {
      throw new Error("A foto ainda ficou acima do limite do Supabase. Tente tirar uma foto mais leve ou com menos resolução.");
    }
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

  await refreshSeasonDerivedData(values.seasonId);

  return data;
}

export async function deleteMatch(matchId: string) {
  if (!hasSupabaseEnv) {
    return { id: matchId };
  }

  const client = requireSupabase();
  const { data: matchRow, error: fetchError } = await client
    .from("matches")
    .select("season_id")
    .eq("id", matchId)
    .single();

  if (fetchError) {
    throw fetchError;
  }

  const { error } = await client.from("matches").delete().eq("id", matchId);
  if (error) throw error;

  await refreshSeasonDerivedData(String(matchRow.season_id));
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
