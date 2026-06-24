import { Box, Chip, Grid, Paper, Stack, Typography } from "@mui/material";
import { NextMatchCard } from "@/components/dashboard/NextMatchCard";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { StatCard } from "@/components/common/StatCard";
import { ColoredScore } from "@/components/matches/ColoredScore";
import { usePlayers } from "@/hooks/usePlayers";
import { useDashboardData } from "@/hooks/useDashboardData";
import type { Match, Player } from "@/types/domain";

function getTeamLabel(match: Match, players: Player[], team: "A" | "B") {
  const ids = team === "A"
    ? [match.teamAPlayer1Id, match.teamAPlayer2Id]
    : [match.teamBPlayer1Id, match.teamBPlayer2Id];

  return ids
    .map((id) => players.find((player) => player.id === id)?.displayName ?? "Jogador")
    .join(" + ");
}

function formatShortDate(value: string) {
  const [year, month, day] = value.slice(0, 10).split("-");
  return `${day}/${month}/${year}`;
}

function getLastThreeItems<T>(items: T[]) {
  return items.slice(-3);
}

interface MonthlyHighlightPanelProps {
  title: string;
  subtitle: string;
  rows: Array<{
    label: string;
    playerNames?: string[];
    mainValue: string;
    detail?: string;
  }>;
  accent: string;
}

function LeaderNames({ names }: { names?: string[] }) {
  if (!names?.length) {
    return <Typography fontWeight={800}>Sem dados</Typography>;
  }

  return (
    <Stack spacing={0.25}>
      {names.map((name) => (
        <Typography key={name} fontWeight={850} noWrap>
          {name}
        </Typography>
      ))}
    </Stack>
  );
}

function MonthlyHighlightPanel({ title, subtitle, rows, accent }: MonthlyHighlightPanelProps) {
  const current = rows.at(-1);
  const previousRows = rows.slice(0, -1);

  return (
    <Paper sx={{ p: 3, height: "100%", border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4 }}>
      <Stack spacing={2.5}>
        <Box>
          <Typography variant="h6">{title}</Typography>
          <Typography variant="body2" color="text.secondary">{subtitle}</Typography>
        </Box>

        {current && (
          <Paper
            elevation={0}
            sx={{
              p: 2,
              pl: { xs: 3.5, sm: 4 },
              borderRadius: 4,
              color: "text.primary",
              bgcolor: "rgba(255,255,255,0.72)",
              border: `1px solid ${accent}33`,
              boxShadow: `inset 4px 0 0 ${accent}`
            }}
          >
            <Typography variant="caption" color="text.secondary">Mês atual - {current.label}</Typography>
            {current.playerNames !== undefined && <LeaderNames names={current.playerNames} />}
            <Typography variant="h5" fontWeight={850} color={accent}>{current.mainValue}</Typography>
            {current.detail && <Typography variant="body2" color="text.secondary">{current.detail}</Typography>}
          </Paper>
        )}

        <Stack spacing={1}>
          {previousRows.map((row) => (
            <Paper
              key={`${title}-${row.label}`}
              variant="outlined"
              sx={{ p: 1.5, borderRadius: 3, bgcolor: "rgba(10,77,60,0.03)" }}
            >
              <Stack direction="row" alignItems="center" justifyContent="space-between" gap={1}>
                <Box minWidth={0}>
                  <Typography variant="caption" color="text.secondary">{row.label}</Typography>
                  {row.playerNames !== undefined && <LeaderNames names={row.playerNames} />}
                  {row.detail && <Typography variant="body2" color="text.secondary">{row.detail}</Typography>}
                </Box>
                <Typography fontWeight={900} color={accent} textAlign="right">{row.mainValue}</Typography>
              </Stack>
            </Paper>
          ))}
        </Stack>
      </Stack>
    </Paper>
  );
}

export function DashboardPage() {
  const { data, isLoading } = useDashboardData();
  const { data: players, isLoading: playersLoading } = usePlayers();

  if (isLoading || playersLoading || !data || !players) {
    return <LoadingState />;
  }

  const monthlyChampions = getLastThreeItems(data.monthlyChampions);
  const monthlyMostActive = getLastThreeItems(data.monthlyMostActive);
  const matchesPerMonth = getLastThreeItems(data.matchesPerMonth);

  return (
    <Stack spacing={4}>
      <SectionHeader
        title={`Temporada ${data.activeSeason.year}`}
        subtitle="Visão geral da temporada atual, próximos jogos e destaques mensais do grupo."
      />

      <NextMatchCard nextMatch={data.nextMatch} season={data.activeSeason} />

      <Grid container spacing={2}>
        {data.quickStats.map((stat) => (
          <Grid key={stat.label} size={{ xs: 12, sm: 6, lg: 4 }}>
            <StatCard {...stat} />
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={2}>
        <Grid size={{ xs: 12, xl: 6 }}>
          <Paper sx={{ p: 3, height: "100%", border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4 }}>
            <Typography variant="h6" mb={2}>Partidas recentes</Typography>
            <Stack spacing={2}>
              {data.recentMatches.map((match) => (
                <Paper key={match.id} variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                  <Stack direction={{ xs: "column", sm: "row" }} spacing={1} alignItems={{ xs: "flex-start", sm: "center" }} flexWrap="wrap">
                    <Chip
                      label={getTeamLabel(match, players, "A")}
                      sx={{
                        bgcolor: match.winnerTeam === "A" ? "rgba(10,77,60,0.12)" : "rgba(10,77,60,0.06)",
                        color: match.winnerTeam === "A" ? "#0a4d3c" : "text.primary",
                        fontWeight: match.winnerTeam === "A" ? 700 : 500
                      }}
                    />
                    <Typography color="text.secondary">x</Typography>
                    <Chip
                      label={getTeamLabel(match, players, "B")}
                      sx={{
                        bgcolor: match.winnerTeam === "B" ? "rgba(245,159,0,0.16)" : "rgba(245,159,0,0.08)",
                        color: match.winnerTeam === "B" ? "#9a6700" : "text.primary",
                        fontWeight: match.winnerTeam === "B" ? 700 : 500
                      }}
                    />
                  </Stack>
                  <Box sx={{ mt: 1 }}>
                    <ColoredScore match={match} />
                  </Box>
                  <Typography color="text.secondary">{formatShortDate(match.matchDate)}</Typography>
                </Paper>
              ))}
            </Stack>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, xl: 6 }}>
          <MonthlyHighlightPanel
            title="Maior Pontuação"
            subtitle="Líderes por pontos dos últimos 3 meses. O mês atual aparece em destaque."
            accent="#0a4d3c"
            rows={monthlyChampions.map((row) => ({
              label: row.label,
              playerNames: row.leaders,
              mainValue: `${row.points} pts`,
              detail: row.points > 0 ? "Maior pontuação do mês" : "Sem dados no mês"
            }))}
          />
        </Grid>

        <Grid size={{ xs: 12, lg: 6 }}>
          <MonthlyHighlightPanel
            title="Jogador mais frequente"
            subtitle="Mais jogos no mês. Em caso de empate, vence quem tiver mais pontos."
            accent="#118ab2"
            rows={monthlyMostActive.map((row) => ({
              label: row.label,
              playerNames: row.leaders,
              mainValue: `${row.matches} jogos`,
              detail: row.matches > 0 ? `${row.points} pontos no mês` : "Sem dados no mês"
            }))}
          />
        </Grid>

        <Grid size={{ xs: 12, lg: 6 }}>
          <MonthlyHighlightPanel
            title="Qtde SETS do mês"
            subtitle="Quantidade de sets registrados nos últimos 3 meses."
            accent="#7a5c00"
            rows={matchesPerMonth.map((row) => ({
              label: row.label,
              mainValue: `${row.sets} sets`,
              detail: row.sets > 0 ? "Sets registrados no mês" : "Sem sets no mês"
            }))}
          />
        </Grid>
      </Grid>
    </Stack>
  );
}
