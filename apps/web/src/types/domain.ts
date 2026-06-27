export type EntityStatus = "active" | "inactive";

export type TeamSide = "A" | "B";

export interface Season {
  id: string;
  year: number;
  startsAt: string;
  endsAt: string;
  isActive: boolean;
}

export interface Player {
  id: string;
  legacyCode?: string | null;
  fullName: string;
  displayName: string;
  normalizedName: string;
  phone?: string | null;
  photoUrl?: string | null;
  status: EntityStatus;
  registeredAt: string;
  notes?: string | null;
}

export interface MatchSet {
  id?: string;
  setOrder: number;
  teamAGames: number;
  teamBGames: number;
  isTiebreak: boolean;
  isSuperTiebreak?: boolean;
  tiebreakPointsA?: number | null;
  tiebreakPointsB?: number | null;
  deucesCount?: number | null;
  notes?: string | null;
  isEnabled?: boolean;
}

export interface Match {
  id: string;
  seasonId: string;
  matchDate: string;
  courtName?: string | null;
  teamAPlayer1Id: string;
  teamAPlayer2Id: string;
  teamBPlayer1Id: string;
  teamBPlayer2Id: string;
  winnerTeam: TeamSide;
  resultSummary: string;
  source: "manual" | "legacy_import";
  notes?: string | null;
  sets: MatchSet[];
}

export interface RankingRow {
  playerId: string;
  seasonId: string;
  rankingPosition: number;
  playerName: string;
  photoUrl?: string | null;
  points: number;
  matchesPlayed: number;
  wins: number;
  losses: number;
  winRate: number;
  setsWon: number;
  setsLost: number;
  gamesWon: number;
  gamesLost: number;
  matchNotes?: Array<{
    matchId: string;
    matchDate: string;
    resultSummary: string;
    note: string;
  }>;
  importedFromLegacy?: boolean;
}

export interface PlayerStatistics extends RankingRow {
  favoritePartner?: string | null;
  bestPartner?: string | null;
  mostFacedRival?: string | null;
  hardestRival?: string | null;
  bestWinStreak: number;
  worstLossStreak: number;
  bestMonth?: string | null;
}

export interface HallOfFameEntry {
  category: string;
  playerId: string;
  playerName: string;
  photoUrl?: string | null;
  players?: Array<{
    playerId: string;
    playerName: string;
    photoUrl?: string | null;
  }>;
  valueText?: string | null;
  valueNumber?: number | null;
}

export interface HeadToHeadRecord {
  playerAId: string;
  playerBId: string;
  playerAName: string;
  playerBName: string;
  matchesPlayed: number;
  playerAWins: number;
  playerBWins: number;
  winRateA: number;
  recentMatches: Match[];
}

export type NextMatchStatus = "confirmed" | "pending" | "cancelled";

export interface NextMatchInfo {
  seasonId: string;
  date: string;
  time: string;
  location: string;
  status: NextMatchStatus;
}

export type NextMatchAttendanceStatus = "awaiting" | "played" | "absent" | "justified";

export interface NextMatchConfirmation {
  id: string;
  seasonId: string;
  matchDate: string;
  playerId: string;
  playerName: string;
  photoUrl?: string | null;
  attendanceStatus: NextMatchAttendanceStatus;
  confirmedAt: string;
}

export interface ShameEntry {
  id: string;
  playerId: string;
  playerName: string;
  photoUrl?: string | null;
  matchDate: string;
  matchTime?: string | null;
  matchLocation?: string | null;
}

export interface DashboardData {
  activeSeason: Season;
  ranking: RankingRow[];
  recentMatches: Match[];
  hallOfFame: HallOfFameEntry[];
  nextMatch: NextMatchInfo | null;
  quickStats: Array<{ label: string; value: string; detail: string }>;
  matchesPerMonth: Array<{ month: string; year: number; label: string; matches: number }>;
  monthlyChampions: Array<{ month: string; year: number; label: string; playerName: string; points: number; leaders: string[] }>;
  monthlyMostActive: Array<{ month: string; year: number; label: string; playerName: string; matches: number; points: number; leaders: string[] }>;
}

export interface AdminCredentials {
  email: string;
  password: string;
}

export interface AdminLoginResult {
  ok: boolean;
  message?: string;
}

export interface MatchFormValues {
  id?: string;
  seasonId: string;
  matchDate: string;
  teamAPlayer1Id: string;
  teamAPlayer2Id: string;
  teamBPlayer1Id: string;
  teamBPlayer2Id: string;
  sets: MatchSet[];
  notes?: string;
}
