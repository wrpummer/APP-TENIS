import SwapHorizRoundedIcon from "@mui/icons-material/SwapHorizRounded";
import { MenuItem, Paper, Stack, TextField, Typography } from "@mui/material";
import { useMemo, useState } from "react";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { useMatches } from "@/hooks/useMatches";
import { usePlayers } from "@/hooks/usePlayers";

export function HeadToHeadPage() {
  const { data: players, isLoading: playersLoading } = usePlayers();
  const { data: matches, isLoading: matchesLoading } = useMatches();
  const [playerA, setPlayerA] = useState("");
  const [playerB, setPlayerB] = useState("");

  const comparison = useMemo(() => {
    if (!players || !matches || !playerA || !playerB) {
      return null;
    }

    const relevantMatches = matches.filter((match) => {
      const ids = [match.teamAPlayer1Id, match.teamAPlayer2Id, match.teamBPlayer1Id, match.teamBPlayer2Id];
      return ids.includes(playerA) && ids.includes(playerB);
    });

    const playerAWins = relevantMatches.filter((match) => {
      const playerAOnTeamA = [match.teamAPlayer1Id, match.teamAPlayer2Id].includes(playerA);
      return (playerAOnTeamA && match.winnerTeam === "A") || (!playerAOnTeamA && match.winnerTeam === "B");
    }).length;

    return {
      matchesPlayed: relevantMatches.length,
      playerAWins,
      playerBWins: relevantMatches.length - playerAWins
    };
  }, [matches, playerA, playerB, players]);

  if (playersLoading || matchesLoading || !players || !matches) {
    return <LoadingState />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Confronto direto"
        subtitle="Compare rapidamente dois jogadores e veja quem leva vantagem nas partidas registradas."
      />
      <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)" }}>
        <Stack spacing={2}>
          <Stack direction={{ xs: "column", md: "row" }} spacing={2}>
            <TextField select fullWidth label="Jogador A" value={playerA} onChange={(event) => setPlayerA(event.target.value)}>
              {players.map((player) => (
                <MenuItem key={player.id} value={player.id}>
                  {player.displayName}
                </MenuItem>
              ))}
            </TextField>
            <TextField select fullWidth label="Jogador B" value={playerB} onChange={(event) => setPlayerB(event.target.value)}>
              {players.map((player) => (
                <MenuItem key={player.id} value={player.id}>
                  {player.displayName}
                </MenuItem>
              ))}
            </TextField>
          </Stack>

          {comparison && (
            <Paper sx={{ p: 3, bgcolor: "rgba(194,255,61,0.16)" }}>
              <Stack direction="row" spacing={2} alignItems="center">
                <SwapHorizRoundedIcon />
                <div>
                  <Typography variant="h6">{comparison.matchesPlayed} partidas em comum</Typography>
                  <Typography>
                    Jogador A venceu {comparison.playerAWins} e Jogador B venceu {comparison.playerBWins}.
                  </Typography>
                </div>
              </Stack>
            </Paper>
          )}
        </Stack>
      </Paper>
    </Stack>
  );
}
