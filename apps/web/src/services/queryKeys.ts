export const queryKeys = {
  dashboard: ["dashboard"] as const,
  nextMatchConfirmations: (seasonId: string, matchDate: string) =>
    ["next-match-confirmations", seasonId, matchDate] as const,
  adminSession: ["admin-session"] as const,
  seasons: ["seasons"] as const,
  ranking: (seasonId: string) => ["ranking", seasonId] as const,
  players: ["players"] as const,
  player: (playerId: string) => ["player", playerId] as const,
  history: (seasonId: string) => ["history", seasonId] as const,
  recentMatches: ["recent-matches"] as const,
  hallOfFame: (seasonId: string) => ["hall-of-fame", seasonId] as const
};
