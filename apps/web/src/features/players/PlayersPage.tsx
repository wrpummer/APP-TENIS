import { Avatar, Chip, Grid, Paper, Stack, Typography } from "@mui/material";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { usePlayerStatistics, usePlayers } from "@/hooks/usePlayers";
import { formatPercentage } from "@/utils/tennis";

function formatDate(value?: string | null) {
  if (!value) {
    return "Não informado";
  }

  const [year, month, day] = value.slice(0, 10).split("-");
  return `${day}/${month}/${year}`;
}

export function PlayersPage() {
  const { data: players, isLoading: playersLoading } = usePlayers();
  const { data: statistics, isLoading: statisticsLoading } = usePlayerStatistics();

  if (playersLoading || statisticsLoading || !players || !statistics) {
    return <LoadingState />;
  }

  const statisticsByPlayerId = new Map(statistics.map((item) => [item.playerId, item]));

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Jogadores"
        subtitle="Lista completa de todos os jogadores cadastrados, inclusive novos registros feitos pelo painel administrativo."
      />
      <Grid container spacing={2}>
        {players.map((player) => {
          const playerStatistics = statisticsByPlayerId.get(player.id);

          return (
            <Grid key={player.id} size={{ xs: 12, md: 6 }}>
              <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4, height: "100%" }}>
                <Stack spacing={2}>
                  <Stack direction="row" spacing={2} alignItems="center">
                    <Avatar src={player.photoUrl ?? undefined} sx={{ width: 64, height: 64 }}>
                      {player.displayName.slice(0, 1).toUpperCase()}
                    </Avatar>
                    <Stack spacing={0.5} sx={{ flex: 1 }}>
                      <Typography variant="h5">{player.displayName}</Typography>
                      <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap">
                        <Chip
                          size="small"
                          label={player.status === "active" ? "Ativo" : "Inativo"}
                          color={player.status === "active" ? "success" : "default"}
                        />
                        <Typography color="text.secondary">Jogador desde: {formatDate(player.registeredAt)}</Typography>
                      </Stack>
                    </Stack>
                  </Stack>

                  <Typography color="text.secondary">
                    Telefone: {player.phone?.trim() ? player.phone : "Não informado"}
                  </Typography>

                  {playerStatistics ? (
                    <Stack spacing={1}>
                      <Typography color="text.secondary">
                        {playerStatistics.matchesPlayed} jogos | {playerStatistics.wins} vitórias | {formatPercentage(playerStatistics.winRate)}
                      </Typography>
                      <Typography>Parceiro favorito: {playerStatistics.favoritePartner ?? "A definir"}</Typography>
                      <Typography>Melhor parceiro: {playerStatistics.bestPartner ?? "A definir"}</Typography>
                      <Typography>Rival mais enfrentado: {playerStatistics.mostFacedRival ?? "A definir"}</Typography>
                      <Typography>Rival mais difícil: {playerStatistics.hardestRival ?? "A definir"}</Typography>
                      <Typography>Maior sequência de vitórias: {playerStatistics.bestWinStreak}</Typography>
                      <Typography>Maior sequência de derrotas: {playerStatistics.worstLossStreak}</Typography>
                      <Typography>Melhor mês: {playerStatistics.bestMonth ?? "Sem dados"}</Typography>
                    </Stack>
                  ) : (
                    <Paper sx={{ p: 2, bgcolor: "rgba(194,255,61,0.14)", borderRadius: 3 }}>
                      <Typography fontWeight={700}>Ainda sem partidas registradas</Typography>
                      <Typography color="text.secondary">
                        Este jogador já está cadastrado e aparecerá nas estatísticas assim que tiver partidas lançadas.
                      </Typography>
                    </Paper>
                  )}
                </Stack>
              </Paper>
            </Grid>
          );
        })}
      </Grid>
    </Stack>
  );
}
