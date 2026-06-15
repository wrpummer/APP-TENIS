import DeleteOutlineRoundedIcon from "@mui/icons-material/DeleteOutlineRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import {
  Accordion,
  AccordionDetails,
  AccordionSummary,
  Box,
  Button,
  Chip,
  Paper,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography
} from "@mui/material";
import { useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { AlertSlot } from "@/components/common/AlertSlot";
import { deleteMatch } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Match, Player } from "@/types/domain";

interface RecentMatchesAdminTableProps {
  matches: Match[];
  players: Player[];
  onEditMatch: (match: Match) => void;
}

function resolveTeam(match: Match, players: Player[], side: "A" | "B") {
  const ids = side === "A"
    ? [match.teamAPlayer1Id, match.teamAPlayer2Id]
    : [match.teamBPlayer1Id, match.teamBPlayer2Id];

  return ids.map((id) => players.find((player) => player.id === id)?.displayName ?? "Jogador").join(" + ");
}

function formatDate(value: string) {
  return value.split("-").reverse().join("/");
}

export function RecentMatchesAdminTable({ matches, players, onEditMatch }: RecentMatchesAdminTableProps) {
  const queryClient = useQueryClient();
  const [feedback, setFeedback] = useState<{ type: "success" | "error"; message: string } | null>(null);
  const [expanded, setExpanded] = useState(true);

  async function refreshMatches() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: queryKeys.recentMatches }),
      queryClient.invalidateQueries({ queryKey: queryKeys.history("active") }),
      queryClient.invalidateQueries({ queryKey: queryKeys.dashboard })
    ]);
  }

  async function handleDelete(match: Match) {
    const confirmed = window.confirm(`Deseja excluir a partida de ${formatDate(match.matchDate)} com placar ${match.resultSummary}?`);
    if (!confirmed) {
      return;
    }

    try {
      await deleteMatch(match.id);
      await refreshMatches();
      setFeedback({ type: "success", message: "Lançamento excluído com sucesso." });
    } catch (caughtError) {
      setFeedback({
        type: "error",
        message: caughtError instanceof Error ? caughtError.message : "Não foi possível excluir o lançamento."
      });
    }
  }

  return (
    <Paper sx={{ overflow: "hidden", border: "1px solid rgba(10,77,60,0.08)" }}>
      <Accordion
        expanded={expanded}
        onChange={(_, isExpanded) => setExpanded(isExpanded)}
        disableGutters
        elevation={0}
        sx={{ "&:before": { display: "none" } }}
      >
        <AccordionSummary expandIcon={<ExpandMoreRoundedIcon />}>
          <Stack spacing={0.5} sx={{ width: "100%" }}>
            <Stack direction="row" spacing={1} alignItems="center" justifyContent="space-between" sx={{ pr: 1 }}>
              <Typography variant="h6">Últimos 10 lançamentos</Typography>
              <Chip size="small" label={`${Math.min(matches.length, 10)} partida${Math.min(matches.length, 10) === 1 ? "" : "s"}`} color="primary" variant="outlined" />
            </Stack>
            <AlertSlot severity={feedback?.type ?? "info"} message={feedback?.message ?? null} />
          </Stack>
        </AccordionSummary>

        <AccordionDetails sx={{ px: 0, pt: 0, pb: 0 }}>
          <Stack spacing={1.5} sx={{ display: { xs: "flex", md: "none" }, px: 2, pb: 2 }}>
            {matches.slice(0, 10).map((match) => (
              <Paper key={match.id} variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                <Stack spacing={1.5}>
                  <Stack direction="row" justifyContent="space-between" gap={1}>
                    <Typography fontWeight={700}>{formatDate(match.matchDate)}</Typography>
                    <Chip size="small" label={match.resultSummary} color="secondary" />
                  </Stack>
                  <Typography variant="body2" sx={{ wordBreak: "break-word" }}>
                    <strong>Dupla A:</strong> {resolveTeam(match, players, "A")}
                  </Typography>
                  <Typography variant="body2" sx={{ wordBreak: "break-word" }}>
                    <strong>Dupla B:</strong> {resolveTeam(match, players, "B")}
                  </Typography>
                  <Stack direction="row" spacing={1} useFlexGap flexWrap="wrap">
                    <Button size="small" variant="outlined" startIcon={<EditRoundedIcon />} onClick={() => onEditMatch(match)}>
                      Editar
                    </Button>
                    <Button size="small" variant="outlined" color="error" startIcon={<DeleteOutlineRoundedIcon />} onClick={() => void handleDelete(match)}>
                      Excluir
                    </Button>
                  </Stack>
                </Stack>
              </Paper>
            ))}
          </Stack>

          <Box sx={{ display: { xs: "none", md: "block" }, overflowX: "auto" }}>
            <Table sx={{ minWidth: 860 }}>
              <TableHead>
                <TableRow>
                  <TableCell>Data</TableCell>
                  <TableCell>Dupla A</TableCell>
                  <TableCell>Dupla B</TableCell>
                  <TableCell>Placar</TableCell>
                  <TableCell align="right">Ações</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {matches.slice(0, 10).map((match) => (
                  <TableRow key={match.id} hover>
                    <TableCell>{formatDate(match.matchDate)}</TableCell>
                    <TableCell>{resolveTeam(match, players, "A")}</TableCell>
                    <TableCell>{resolveTeam(match, players, "B")}</TableCell>
                    <TableCell>{match.resultSummary}</TableCell>
                    <TableCell align="right">
                      <Stack direction={{ xs: "column", lg: "row" }} spacing={1} justifyContent="flex-end">
                        <Button size="small" variant="outlined" startIcon={<EditRoundedIcon />} onClick={() => onEditMatch(match)}>
                          Editar
                        </Button>
                        <Button size="small" variant="outlined" color="error" startIcon={<DeleteOutlineRoundedIcon />} onClick={() => void handleDelete(match)}>
                          Excluir
                        </Button>
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Box>
        </AccordionDetails>
      </Accordion>
    </Paper>
  );
}
