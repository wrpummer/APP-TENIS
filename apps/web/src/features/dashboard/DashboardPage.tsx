import { Chip, Grid, Paper, Stack, Typography } from "@mui/material";
import { Bar, BarChart, CartesianGrid, Cell, LabelList, Legend, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { NextMatchCard } from "@/components/dashboard/NextMatchCard";
import { ChartPanel } from "@/components/charts/ChartPanel";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { StatCard } from "@/components/common/StatCard";
import { usePlayers } from "@/hooks/usePlayers";
import { useDashboardData } from "@/hooks/useDashboardData";
import type { Match, Player } from "@/types/domain";

const chartPalette = ["#0a4d3c", "#7cb518", "#f59f00", "#118ab2", "#ef476f", "#f25c54"];

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

export function DashboardPage() {
  const { data, isLoading } = useDashboardData();
  const { data: players, isLoading: playersLoading } = usePlayers();

  if (isLoading || playersLoading || !data || !players) {
    return <LoadingState />;
  }

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
          <Paper sx={{ p: 3, height: "100%", border: "1px solid rgba(10,77,60,0.08)" }}>
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
                  <Typography fontWeight={700} sx={{ mt: 1 }}>{match.resultSummary}</Typography>
                  <Typography color="text.secondary">{formatShortDate(match.matchDate)}</Typography>
                </Paper>
              ))}
            </Stack>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, xl: 6 }}>
          <ChartPanel title="Pontos do campeão de cada mês">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.monthlyChampions}>
                <CartesianGrid vertical={false} strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip formatter={(value, _, item) => [`${value} pontos`, item.payload.playerName]} />
                <Bar dataKey="points" radius={[8, 8, 0, 0]}>
                  {data.monthlyChampions.map((entry, index) => (
                    <Cell key={`${entry.month}-${entry.playerName}`} fill={chartPalette[index % chartPalette.length]} />
                  ))}
                  <LabelList dataKey="playerName" position="top" fontSize={11} />
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </ChartPanel>
        </Grid>

        <Grid size={{ xs: 12, lg: 6 }}>
          <ChartPanel title="Jogador frequente do mês">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.monthlyMostActive}>
                <CartesianGrid vertical={false} strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis allowDecimals={false} />
                <Tooltip formatter={(value, _, item) => [`${value} jogos`, item.payload.playerName]} />
                <Line type="monotone" dataKey="matches" stroke="#0a4d3c" strokeWidth={3} dot={{ r: 5 }} />
              </LineChart>
            </ResponsiveContainer>
          </ChartPanel>
        </Grid>

        <Grid size={{ xs: 12, lg: 6 }}>
          <ChartPanel title="Partidas e sets por mês">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.matchesPerMonth}>
                <CartesianGrid vertical={false} strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="matches" name="Partidas" fill="#0a4d3c" radius={[8, 8, 0, 0]} />
                <Bar dataKey="sets" name="Sets" fill="#c2ff3d" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </ChartPanel>
        </Grid>

        <Grid size={{ xs: 12 }}>
          <ChartPanel title="Maior saldo de games por mês">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.monthlyBestGamesBalance}>
                <CartesianGrid vertical={false} strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip formatter={(value, _, item) => [`${value} de saldo`, item.payload.playerName]} />
                <Bar dataKey="balance" fill="#118ab2" radius={[8, 8, 0, 0]}>
                  <LabelList dataKey="playerName" position="top" fontSize={11} />
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </ChartPanel>
        </Grid>
      </Grid>
    </Stack>
  );
}
