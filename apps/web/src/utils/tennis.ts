import type { MatchFormValues, MatchSet, TeamSide } from "@/types/domain";

export const monthLabels = [
  "Janeiro",
  "Fevereiro",
  "Março",
  "Abril",
  "Maio",
  "Junho",
  "Julho",
  "Agosto",
  "Setembro",
  "Outubro",
  "Novembro",
  "Dezembro"
];

export const shortMonthLabels = monthLabels.map((month) => month.slice(0, 3));

export function formatDateOnlyBR(value?: string | null): string {
  if (!value) {
    return "Não informado";
  }

  const [year, month, day] = value.slice(0, 10).split("-");
  if (!year || !month || !day) {
    return "Não informado";
  }

  return `${day}/${month}/${year}`;
}

export function formatLongDateOnlyBR(value: string): string {
  const [year, month, day] = value.slice(0, 10).split("-").map(Number);
  if (!year || !month || !day) {
    return "Data não informada";
  }

  return `${String(day).padStart(2, "0")} de ${monthLabels[month - 1]?.toLowerCase() ?? "mês"} de ${year}`;
}

export function summarizeSets(sets: MatchSet[]): string {
  return sets
    .filter((set) => set.isEnabled !== false && Number.isFinite(set.teamAGames) && Number.isFinite(set.teamBGames) && !(set.teamAGames === 0 && set.teamBGames === 0))
    .map((set) => {
      const base = `${set.teamAGames}-${set.teamBGames}`;
      if (set.isTiebreak && Number.isFinite(set.tiebreakPointsA) && Number.isFinite(set.tiebreakPointsB)) {
        return `${base} (${set.tiebreakPointsA}-${set.tiebreakPointsB} TB)`;
      }

      return base;
    })
    .join(" / ");
}

export function inferWinnerTeam(sets: MatchSet[]): TeamSide {
  const activeSets = sets.filter((set) => set.isEnabled !== false && !(set.teamAGames === 0 && set.teamBGames === 0));
  const teamAWins = activeSets.filter((set) => set.teamAGames > set.teamBGames).length;
  const teamBWins = activeSets.filter((set) => set.teamBGames > set.teamAGames).length;
  return teamAWins >= teamBWins ? "A" : "B";
}

function isRegularSetScoreValid(set: MatchSet) {
  const a = set.teamAGames;
  const b = set.teamBGames;
  const max = Math.max(a, b);
  const min = Math.min(a, b);

  if (a < 0 || b < 0 || a > 7 || b > 7) {
    return false;
  }

  if (max === 6) {
    return min <= 4;
  }

  if (max === 7) {
    return min === 5 || min === 6;
  }

  return false;
}

function isSuperTiebreakSetScoreValid(set: MatchSet) {
  const a = set.teamAGames;
  const b = set.teamBGames;
  return (a === 1 && b === 0) || (a === 0 && b === 1);
}

function isTiebreakPointsValid(pointsA: number | null | undefined, pointsB: number | null | undefined, superTiebreak: boolean) {
  if (!Number.isFinite(pointsA) || !Number.isFinite(pointsB)) {
    return false;
  }

  const a = Number(pointsA);
  const b = Number(pointsB);
  const target = superTiebreak ? 10 : 7;
  const max = Math.max(a, b);
  const min = Math.min(a, b);

  return max >= target && max - min >= 2;
}

export function validateMatch(values: MatchFormValues): string[] {
  const issues: string[] = [];
  const players = [
    values.teamAPlayer1Id,
    values.teamAPlayer2Id,
    values.teamBPlayer1Id,
    values.teamBPlayer2Id
  ];

  if (new Set(players).size !== players.length) {
    issues.push("Cada partida deve ter quatro jogadores diferentes.");
  }

  const activeSets = values.sets.filter((set) => set.isEnabled !== false);
  const completedSets = activeSets.filter((set) => Number.isFinite(set.teamAGames) && Number.isFinite(set.teamBGames) && !(set.teamAGames === 0 && set.teamBGames === 0));

  if (completedSets.length < 1) {
    issues.push("Informe pelo menos um set válido.");
  }

  for (const set of completedSets) {
    if (set.teamAGames === set.teamBGames) {
      issues.push(`O set ${set.setOrder} nao pode terminar empatado.`);
    }

    if (set.isSuperTiebreak) {
      if (set.setOrder !== 3) {
        issues.push("Super tiebreak só deve ser usado no 3º set.");
      }

      if (!isSuperTiebreakSetScoreValid(set)) {
        issues.push("No super tiebreak, o placar do set deve ser 1-0 ou 0-1.");
      }
    } else if (!isRegularSetScoreValid(set)) {
      issues.push(`O placar do set ${set.setOrder} não segue uma combinação válida de tênis.`);
    }

    if (set.isTiebreak && !isTiebreakPointsValid(set.tiebreakPointsA, set.tiebreakPointsB, Boolean(set.isSuperTiebreak))) {
      issues.push(`O placar do tiebreak no set ${set.setOrder} está inválido.`);
    }

    if (!set.isTiebreak && (set.tiebreakPointsA != null || set.tiebreakPointsB != null)) {
      issues.push(`Remova os pontos de tiebreak do set ${set.setOrder} ou marque que houve tiebreak.`);
    }
  }

  return issues;
}

export function formatPercentage(value: number): string {
  return `${value.toFixed(2).replace(".", ",")}%`;
}

export function slugifyName(input: string): string {
  return input
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-zA-Z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
}



