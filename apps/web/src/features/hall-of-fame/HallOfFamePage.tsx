import EmojiEventsRoundedIcon from "@mui/icons-material/EmojiEventsRounded";
import { Alert, Avatar, Grid, Paper, Stack, Typography } from "@mui/material";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { useDashboardData } from "@/hooks/useDashboardData";

function formatHallValue(valueNumber?: number | null, valueText?: string | null) {
  if (typeof valueNumber === "number") {
    return Number.isInteger(valueNumber) ? String(valueNumber) : `${valueNumber.toFixed(2).replace(".", ",")}%`;
  }

  return valueText ?? "Sem dado";
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
        subtitle="Destaques permanentes da temporada com campeão, mais ativo, mais vitórias e melhor aproveitamento."
      />

      {data.hallOfFame.length === 0 ? (
        <Alert severity="info">
          Ainda não há partidas suficientes nesta temporada para preencher o Hall da Fama.
        </Alert>
      ) : (
        <Grid container spacing={2}>
          {data.hallOfFame.map((entry) => (
            <Grid key={entry.category} size={{ xs: 12, md: 6 }}>
              <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4 }}>
                <Stack direction="row" spacing={2} alignItems="center">
                  <Avatar
                    src={entry.photoUrl ?? undefined}
                    sx={{ width: 64, height: 64, bgcolor: "secondary.main", color: "secondary.contrastText" }}
                  >
                    {entry.playerName.slice(0, 1).toUpperCase()}
                  </Avatar>
                  <Stack spacing={0.5} sx={{ flex: 1 }}>
                    <Typography variant="h6">{entry.category}</Typography>
                    <Typography fontWeight={700}>{entry.playerName}</Typography>
                    <Typography color="text.secondary">
                      {formatHallValue(entry.valueNumber, entry.valueText)}
                    </Typography>
                  </Stack>
                  <EmojiEventsRoundedIcon color="secondary" sx={{ fontSize: 32 }} />
                </Stack>
              </Paper>
            </Grid>
          ))}
        </Grid>
      )}
    </Stack>
  );
}
