import EmojiEventsRoundedIcon from "@mui/icons-material/EmojiEventsRounded";
import { Alert, Avatar, Box, Chip, Grid, Paper, Stack, Typography } from "@mui/material";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { useDashboardData } from "@/hooks/useDashboardData";

function formatHallValue(category: string, valueNumber?: number | null, valueText?: string | null) {
  if (typeof valueNumber === "number") {
    if (category === "Melhor aproveitamento") {
      return `${valueNumber.toFixed(2).replace(".", ",")}%`;
    }

    return Number.isInteger(valueNumber) ? String(valueNumber) : valueNumber.toFixed(2).replace(".", ",");
  }

  return valueText ?? "Sem dado";
}

function getValueLabel(category: string) {
  switch (category) {
    case "Campeão da temporada":
      return "pontos";
    case "Mais vitórias":
      return "vitórias";
    case "Melhor aproveitamento":
      return "aproveitamento";
    case "Jogador mais ativo":
      return "partidas";
    default:
      return "resultado";
  }
}

export function HallOfFamePage() {
  const { data, isLoading } = useDashboardData();

  if (isLoading || !data) {
    return <LoadingState />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Hall da Fama"
        subtitle="Destaques da temporada. Quando houver empate, todos os jogadores empatados aparecem juntos."
      />

      {data.hallOfFame.length === 0 ? (
        <Alert severity="info">
          Ainda não há partidas suficientes nesta temporada para preencher o Hall da Fama.
        </Alert>
      ) : (
        <Grid container spacing={2}>
          {data.hallOfFame.map((entry) => {
            const winners = entry.players?.length
              ? entry.players
              : [{ playerId: entry.playerId, playerName: entry.playerName, photoUrl: entry.photoUrl }];

            return (
              <Grid key={entry.category} size={{ xs: 12, md: 6 }}>
                <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4, height: "100%" }}>
                  <Stack spacing={2}>
                    <Stack direction="row" spacing={1.5} alignItems="center" justifyContent="space-between">
                      <Box>
                        <Typography variant="h6">{entry.category}</Typography>
                        <Typography color="text.secondary">
                          {formatHallValue(entry.category, entry.valueNumber, entry.valueText)} {getValueLabel(entry.category)}
                        </Typography>
                      </Box>
                      <EmojiEventsRoundedIcon color="secondary" sx={{ fontSize: 32 }} />
                    </Stack>

                    {winners.length > 1 && (
                      <Chip
                        label={`${winners.length} jogadores empatados`}
                        color="secondary"
                        variant="outlined"
                        sx={{ alignSelf: "flex-start", fontWeight: 700 }}
                      />
                    )}

                    <Stack spacing={1.25}>
                      {winners.map((winner) => (
                        <Stack key={`${entry.category}-${winner.playerId}`} direction="row" spacing={1.5} alignItems="center">
                          <Avatar
                            src={winner.photoUrl ?? undefined}
                            sx={{ width: 48, height: 48, bgcolor: "secondary.main", color: "secondary.contrastText" }}
                          >
                            {winner.playerName.slice(0, 1).toUpperCase()}
                          </Avatar>
                          <Typography fontWeight={800}>{winner.playerName}</Typography>
                        </Stack>
                      ))}
                    </Stack>
                  </Stack>
                </Paper>
              </Grid>
            );
          })}
        </Grid>
      )}
    </Stack>
  );
}
