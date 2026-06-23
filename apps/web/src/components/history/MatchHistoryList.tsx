import { Chip, Paper, Stack, Typography } from "@mui/material";
import { format } from "date-fns";
import { ptBR } from "date-fns/locale";
import { ColoredScore } from "@/components/matches/ColoredScore";
import type { Match, Player } from "@/types/domain";

function resolveTeam(match: Match, players: Player[], side: "A" | "B") {
  const ids = side === "A"
    ? [match.teamAPlayer1Id, match.teamAPlayer2Id]
    : [match.teamBPlayer1Id, match.teamBPlayer2Id];

  return ids
    .map((id) => players.find((player) => player.id === id)?.displayName ?? "Jogador")
    .join(" + ");
}

interface MatchHistoryListProps {
  matches: Match[];
  players: Player[];
}

export function MatchHistoryList({ matches, players }: MatchHistoryListProps) {
  if (matches.length === 0) {
    return (
      <Paper sx={{ p: 4, border: "1px solid rgba(10,77,60,0.08)" }}>
        <Typography variant="h6">Nenhuma partida encontrada</Typography>
        <Typography color="text.secondary">
          Ajuste os filtros de jogador ou data para visualizar outros lançamentos.
        </Typography>
      </Paper>
    );
  }

  return (
    <Stack gap={2}>
      {matches.map((match) => (
        <Paper key={match.id} sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)" }}>
          <Stack direction={{ xs: "column", md: "row" }} justifyContent="space-between" gap={2}>
            <div>
              <Stack direction={{ xs: "column", sm: "row" }} spacing={1} alignItems={{ xs: "flex-start", sm: "center" }} flexWrap="wrap">
                <Chip
                  label={resolveTeam(match, players, "A")}
                  sx={{
                    bgcolor: match.winnerTeam === "A" ? "rgba(10,77,60,0.12)" : "rgba(10,77,60,0.06)",
                    color: match.winnerTeam === "A" ? "#0a4d3c" : "text.primary",
                    fontWeight: match.winnerTeam === "A" ? 700 : 500
                  }}
                />
                <Typography color="text.secondary">x</Typography>
                <Chip
                  label={resolveTeam(match, players, "B")}
                  sx={{
                    bgcolor: match.winnerTeam === "B" ? "rgba(245,159,0,0.16)" : "rgba(245,159,0,0.08)",
                    color: match.winnerTeam === "B" ? "#9a6700" : "text.primary",
                    fontWeight: match.winnerTeam === "B" ? 700 : 500
                  }}
                />
              </Stack>
              <Typography color="text.secondary" sx={{ mt: 1 }}>
                <Typography
                  component="span"
                  color="text.secondary"
                >
                  {format(new Date(match.matchDate), "dd 'de' MMMM 'de' yyyy", { locale: ptBR })}
                </Typography>
              </Typography>
            </div>
            <div>
              <ColoredScore match={match} />
              <Typography color="text.secondary">
                Vencedor: Dupla {match.winnerTeam}
              </Typography>
            </div>
          </Stack>
        </Paper>
      ))}
    </Stack>
  );
}
