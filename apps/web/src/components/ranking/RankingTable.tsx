import MilitaryTechRoundedIcon from "@mui/icons-material/MilitaryTechRounded";
import {
  Avatar,
  Box,
  Button,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Paper,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography
} from "@mui/material";
import { useState } from "react";
import type { RankingRow } from "@/types/domain";
import { formatPercentage } from "@/utils/tennis";

interface RankingTableProps {
  rows: RankingRow[];
}

function StatPill({ label, value }: { label: string; value: string | number }) {
  return (
    <Box
      sx={{
        px: 1.5,
        py: 1,
        borderRadius: 3,
        bgcolor: "rgba(10,77,60,0.06)",
        minWidth: 92
      }}
    >
      <Typography variant="caption" color="text.secondary" sx={{ display: "block" }}>
        {label}
      </Typography>
      <Typography fontWeight={700}>{value}</Typography>
    </Box>
  );
}

function formatShortDate(value: string) {
  const [year, month, day] = value.slice(0, 10).split("-");
  return `${day}/${month}/${year}`;
}

export function RankingTable({ rows }: RankingTableProps) {
  const [selectedObservation, setSelectedObservation] = useState<RankingRow | null>(null);
  const pointCounts = new Map<number, number>();
  for (const row of rows) {
    pointCounts.set(row.points, (pointCounts.get(row.points) ?? 0) + 1);
  }

  return (
    <>
      <Stack spacing={2} sx={{ display: { xs: "flex", md: "none" } }}>
        {rows.map((row) => (
          <Paper
            key={row.playerId}
            sx={{
              p: 2,
              border: "1px solid rgba(10,77,60,0.08)",
              borderRadius: 4
            }}
          >
            <Stack spacing={2}>
              <Stack direction="row" spacing={1.5} alignItems="center">
                <Avatar src={row.photoUrl ?? undefined} sx={{ width: 52, height: 52 }}>
                  {row.playerName.slice(0, 1)}
                </Avatar>
                <Box sx={{ minWidth: 0, flex: 1 }}>
                  <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap">
                    {row.rankingPosition <= 3 && <MilitaryTechRoundedIcon color="secondary" fontSize="small" />}
                    <Typography fontWeight={800}>#{row.rankingPosition}</Typography>
                    {(pointCounts.get(row.points) ?? 0) > 1 && <Chip size="small" label="Empate" color="primary" variant="outlined" />}
                    {row.importedFromLegacy && <Chip size="small" label="Legado" color="secondary" />}
                  </Stack>
                  <Typography fontWeight={700} sx={{ mt: 0.5, wordBreak: "break-word" }}>
                    {row.playerName}
                  </Typography>
                  {(row.matchNotes?.length ?? 0) > 0 && (
                    <Button size="small" variant="outlined" sx={{ mt: 1 }} onClick={() => setSelectedObservation(row)}>
                      Observações
                    </Button>
                  )}
                </Box>
              </Stack>

              <Stack direction="row" spacing={1} useFlexGap flexWrap="wrap">
                <StatPill label="Pontos" value={row.points} />
                <StatPill label="Jogos" value={row.matchesPlayed} />
                <StatPill label="Vitórias" value={row.wins} />
                <StatPill label="Derrotas" value={row.losses} />
                <StatPill label="Aproveitamento" value={formatPercentage(row.winRate)} />
                <StatPill label="Saldo sets" value={row.setsWon - row.setsLost} />
              </Stack>
            </Stack>
          </Paper>
        ))}
      </Stack>

      <Paper sx={{ display: { xs: "none", md: "block" }, overflow: "hidden", border: "1px solid rgba(10,77,60,0.08)" }}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Pos.</TableCell>
              <TableCell>Jogador</TableCell>
              <TableCell align="right">Pontos</TableCell>
              <TableCell align="right">Jogos</TableCell>
              <TableCell align="right">Vitórias</TableCell>
              <TableCell align="right">Derrotas</TableCell>
              <TableCell align="right">Aproveitamento</TableCell>
              <TableCell align="right">Saldo sets</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.map((row) => (
              <TableRow key={row.playerId} hover>
                <TableCell>
                  <Stack direction="row" spacing={1} alignItems="center">
                    {row.rankingPosition <= 3 && <MilitaryTechRoundedIcon color="secondary" fontSize="small" />}
                    <Typography fontWeight={700}>{row.rankingPosition}</Typography>
                    {(pointCounts.get(row.points) ?? 0) > 1 && <Chip size="small" label="Empate" color="primary" variant="outlined" />}
                  </Stack>
                </TableCell>
                <TableCell>
                  <Stack direction="row" spacing={2} alignItems="center">
                    <Avatar src={row.photoUrl ?? undefined}>{row.playerName.slice(0, 1)}</Avatar>
                    <div>
                      <Typography fontWeight={700}>{row.playerName}</Typography>
                      {row.importedFromLegacy && <Chip size="small" label="Legado" color="secondary" />}
                      {(row.matchNotes?.length ?? 0) > 0 && (
                        <Button size="small" variant="outlined" sx={{ mt: 0.75 }} onClick={() => setSelectedObservation(row)}>
                          Observações
                        </Button>
                      )}
                    </div>
                  </Stack>
                </TableCell>
                <TableCell align="right">{row.points}</TableCell>
                <TableCell align="right">{row.matchesPlayed}</TableCell>
                <TableCell align="right">{row.wins}</TableCell>
                <TableCell align="right">{row.losses}</TableCell>
                <TableCell align="right">{formatPercentage(row.winRate)}</TableCell>
                <TableCell align="right">{row.setsWon - row.setsLost}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Paper>

      <Dialog open={Boolean(selectedObservation)} onClose={() => setSelectedObservation(null)} fullWidth maxWidth="sm">
        <DialogTitle>Observações das partidas de {selectedObservation?.playerName}</DialogTitle>
        <DialogContent>
          <Stack spacing={1.5} sx={{ pt: 0.5 }}>
            {(selectedObservation?.matchNotes ?? []).map((item) => (
              <Paper key={`${item.matchId}-${item.note}`} variant="outlined" sx={{ p: 1.5, borderRadius: 3 }}>
                <Typography fontWeight={800}>{formatShortDate(item.matchDate)} - {item.resultSummary}</Typography>
                <Typography sx={{ whiteSpace: "pre-line" }}>{item.note}</Typography>
              </Paper>
            ))}
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setSelectedObservation(null)}>Fechar</Button>
        </DialogActions>
      </Dialog>
    </>
  );
}
