import type {
  DashboardData,
  HallOfFameEntry,
  Match,
  Player,
  PlayerStatistics,
  RankingRow,
  Season
} from "@/types/domain";

export const mockSeason: Season = {
  id: "season-2026",
  year: 2026,
  startsAt: "2026-01-01",
  endsAt: "2026-12-31",
  isActive: true
};

export const mockPlayers: Player[] = [
  "Carlos Eduardo",
  "Ailson",
  "Hellinton",
  "Milton",
  "Marcos",
  "Daniel",
  "Henrique",
  "Mario",
  "Giuliano",
  "Denny"
].map((name, index) => ({
  id: `player-${index + 1}`,
  fullName: name,
  displayName: name,
  normalizedName: name.toUpperCase(),
  status: "active",
  registeredAt: "2026-01-01T00:00:00.000Z",
  phone: null,
  photoUrl: null
}));

const mockRankingSource: [number, string, number, number, number, number, number, number, number, number, number][] = [
  [1, "Carlos Eduardo", 274, 122, 64, 58, 52.46, 41, 28, 297, 241],
  [2, "Hellinton", 177, 85, 46, 39, 54.12, 33, 26, 244, 219],
  [3, "Ailson", 173, 116, 42, 74, 36.21, 32, 34, 266, 280],
  [4, "Milton", 64, 38, 17, 21, 44.74, 14, 18, 115, 129],
  [5, "Marcos", 56, 30, 15, 15, 50, 12, 13, 91, 95]
];

export const mockRanking: RankingRow[] = mockRankingSource.map(([position, name, points, matchesPlayed, wins, losses, winRate, setsWon, setsLost, gamesWon, gamesLost]) => ({
  playerId: mockPlayers.find((player) => player.displayName === name)?.id ?? name,
  seasonId: mockSeason.id,
  rankingPosition: position,
  playerName: name,
  points,
  matchesPlayed,
  wins,
  losses,
  winRate,
  setsWon,
  setsLost,
  gamesWon,
  gamesLost,
  photoUrl: null,
  importedFromLegacy: true
}));

export const mockMatches: Match[] = [
  {
    id: "match-1",
    seasonId: mockSeason.id,
    matchDate: "2026-05-23",
    teamAPlayer1Id: mockPlayers[1].id,
    teamAPlayer2Id: mockPlayers[6].id,
    teamBPlayer1Id: mockPlayers[5].id,
    teamBPlayer2Id: mockPlayers[7].id,
    winnerTeam: "B",
    resultSummary: "6-3 / 6-2",
    source: "legacy_import",
    sets: [
      { setOrder: 1, teamAGames: 3, teamBGames: 6, isTiebreak: false },
      { setOrder: 2, teamAGames: 2, teamBGames: 6, isTiebreak: false }
    ]
  },
  {
    id: "match-2",
    seasonId: mockSeason.id,
    matchDate: "2026-05-31",
    teamAPlayer1Id: mockPlayers[1].id,
    teamAPlayer2Id: mockPlayers[2].id,
    teamBPlayer1Id: mockPlayers[0].id,
    teamBPlayer2Id: mockPlayers[9].id,
    winnerTeam: "B",
    resultSummary: "6-3 / 7-5",
    source: "legacy_import",
    sets: [
      { setOrder: 1, teamAGames: 3, teamBGames: 6, isTiebreak: false },
      { setOrder: 2, teamAGames: 5, teamBGames: 7, isTiebreak: false }
    ]
  },
  {
    id: "match-3",
    seasonId: mockSeason.id,
    matchDate: "2026-04-25",
    teamAPlayer1Id: mockPlayers[0].id,
    teamAPlayer2Id: mockPlayers[2].id,
    teamBPlayer1Id: mockPlayers[7].id,
    teamBPlayer2Id: mockPlayers[5].id,
    winnerTeam: "A",
    resultSummary: "6-4 / 6-1",
    source: "legacy_import",
    sets: [
      { setOrder: 1, teamAGames: 6, teamBGames: 4, isTiebreak: false },
      { setOrder: 2, teamAGames: 6, teamBGames: 1, isTiebreak: false }
    ]
  }
];

export const mockHallOfFame: HallOfFameEntry[] = [
  { category: "Campeão da temporada", playerId: mockPlayers[0].id, playerName: "Carlos Eduardo", photoUrl: null, valueNumber: 274 },
  { category: "Mais vitórias", playerId: mockPlayers[0].id, playerName: "Carlos Eduardo", photoUrl: null, valueNumber: 64 },
  { category: "Melhor aproveitamento", playerId: mockPlayers[2].id, playerName: "Hellinton", photoUrl: null, valueNumber: 54.12 },
  { category: "Jogador mais ativo", playerId: mockPlayers[0].id, playerName: "Carlos Eduardo", photoUrl: null, valueNumber: 122 }
];

export const mockPlayerStatistics: PlayerStatistics[] = mockRanking.map((row, index) => ({
  ...row,
  favoritePartner: ["Ailson", "Carlos Eduardo", "Carlos Eduardo", "Hellinton", "Milton"][index] ?? null,
  bestPartner: ["Hellinton", "Henrique", "Carlos Eduardo", "Marcos", "Daniel"][index] ?? null,
  mostFacedRival: ["Hellinton", "Carlos Eduardo", "Carlos Eduardo", "Ailson", "Carlos Eduardo"][index] ?? null,
  hardestRival: ["Hellinton", "Carlos Eduardo", "Marcos", "Carlos Eduardo", "Hellinton"][index] ?? null,
  bestWinStreak: [6, 4, 4, 3, 3][index] ?? 0,
  worstLossStreak: [3, 3, 5, 4, 4][index] ?? 0,
  bestMonth: ["Janeiro", "Abril", "Maio", "Abril", "Maio"][index] ?? null
}));

export const mockDashboard: DashboardData = {
  activeSeason: mockSeason,
  ranking: mockRanking,
  recentMatches: mockMatches,
  hallOfFame: mockHallOfFame,
  nextMatch: {
    seasonId: mockSeason.id,
    date: "2026-06-21",
    time: "08:30",
    location: "Quadra Coberta",
    status: "confirmed"
  },
  quickStats: [
    { label: "Partidas registradas", value: "98", detail: "temporada atual" },
    { label: "Jogadores ativos", value: "18", detail: "com pelo menos 1 jogo" },
    { label: "Média mensal", value: "19,6", detail: "partidas por mês com jogos" }
  ],
  matchesPerMonth: [
    { month: "Jan", matches: 29, sets: 64 },
    { month: "Fev", matches: 23, sets: 51 },
    { month: "Mar", matches: 20, sets: 44 },
    { month: "Abr", matches: 19, sets: 43 },
    { month: "Mai", matches: 26, sets: 59 }
  ],
  monthlyChampions: [
    { month: "Jan", playerName: "Carlos Eduardo", points: 69 },
    { month: "Fev", playerName: "Carlos Eduardo", points: 122 },
    { month: "Mar", playerName: "Carlos Eduardo", points: 166 },
    { month: "Abr", playerName: "Hellinton", points: 137 },
    { month: "Mai", playerName: "Carlos Eduardo", points: 274 }
  ],
  monthlyMostActive: [
    { month: "Jan", playerName: "Carlos Eduardo", matches: 12 },
    { month: "Fev", playerName: "Ailson", matches: 10 },
    { month: "Mar", playerName: "Hellinton", matches: 9 },
    { month: "Abr", playerName: "Carlos Eduardo", matches: 8 },
    { month: "Mai", playerName: "Ailson", matches: 11 }
  ],
  monthlyBestGamesBalance: [
    { month: "Jan", year: 2026, label: "Jan/2026", playerName: "Carlos Eduardo", balance: 18 },
    { month: "Fev", year: 2026, label: "Fev/2026", playerName: "Hellinton", balance: 14 },
    { month: "Mar", year: 2026, label: "Mar/2026", playerName: "Carlos Eduardo", balance: 12 },
    { month: "Abr", year: 2026, label: "Abr/2026", playerName: "Hellinton", balance: 17 },
    { month: "Mai", year: 2026, label: "Mai/2026", playerName: "Carlos Eduardo", balance: 21 }
  ]
};
