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
  TextField,
  Typography
} from "@mui/material";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useMemo, useState } from "react";
import { AlertSlot } from "@/components/common/AlertSlot";
import { ColoredScore } from "@/components/matches/ColoredScore";
import { deleteMatch } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Match, Player } from "@/types/domain";
import { formatDateOnlyBR } from "@/utils/tennis";

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

export function RecentMatchesAdminTable({ matches, players, onEditMatch }: RecentMatchesAdminTableProps) {
  const queryClient = useQueryClient();
  const [feedback, setFeedback] = useState<{ type: "success" | "error"; message: string } | null>(null);
  const [expanded, setExpanded] = useState(false);
  const [search, setSearch] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [visibleCount, setVisibleCount] = useState(20);

  async function refreshMatches() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: queryKeys.recentMatches }),
      queryClient.invalidateQueries({ queryKey: queryKeys.dashboard }),
      queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "history" }),
      queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "ranking" }),
      queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "hall-of-fame" }),
      queryClient.invalidateQueries({ queryKey: ["player-statistics"] })
    ]);
  }

  async function handleDelete(match: Match) {
    const confirmed = window.confirm(`Deseja excluir a partida de ${formatDateOnlyBR(match.matchDate)} com placar ${match.resultSummary}?`);
    if (!confirmed) {
      return;
    }

    try {
      await deleteMatch(match.id);
      await refreshMatches();
      setFeedback({ type: "success", message: "Lancamento excluido com sucesso." });
    } catch (caughtError) {
      setFeedback({
        type: "error",
        message: caughtError instanceof Error ? caughtError.message : "Nao foi possivel excluir o lancamento."
      });
    }
  }

  const filteredMatches = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();

    return matches.filter((match) => {
      if (startDate && match.matchDate < startDate) {
        return false;
      }

      if (endDate && match.matchDate > endDate) {
        return false;
      }

      if (!normalizedSearch) {
        return true;
      }

      const searchableText = [
        formatDateOnlyBR(match.matchDate),
        match.matchDate,
        match.resultSummary,
        match.notes,
        resolveTeam(match, players, "A"),
        resolveTeam(match, players, "B"),
        match.isWalkover ? "wo w.o. walkover" : ""
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase();

      return searchableText.includes(normalizedSearch);
    });
  }, [endDate, matches, players, search, startDate]);

  const visibleMatches = filteredMatches.slice(0, visibleCount);
  const hasFilters = Boolean(search.trim() || startDate || endDate);

  useEffect(() => {
    setVisibleCount(20);
  }, [search, startDate, endDate]);

  function clearFilters() {
    setSearch("");
    setStartDate("");
    setEndDate("");
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
              <Typography variant="h6">Partidas cadastradas</Typography>
              <Chip
                size="small"
                label={`${visibleMatches.length} de ${filteredMatches.length} partida${filteredMatches.length === 1 ? "" : "s"}`}
                color="primary"
                variant="outlined"
              />
            </Stack>
            <AlertSlot severity={feedback?.type ?? "info"} message={feedback?.message ?? null} />
          </Stack>
        </AccordionSummary>

        <AccordionDetails sx={{ px: 0, pt: 0, pb: 0 }}>
          <Stack spacing={1.5} sx={{ px: 2, pb: 2 }}>
            <Typography variant="body2" color="text.secondary">
              Use a busca para encontrar qualquer partida por jogador, placar, data, observacao ou W.O.
            </Typography>
            <Stack direction={{ xs: "column", md: "row" }} spacing={1.25}>
              <TextField
                label="Buscar partida"
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                placeholder="Ex.: Ailson, 20/07/2026, W.O."
                fullWidth
              />
              <TextField
                label="De"
                type="date"
                value={startDate}
                onChange={(event) => setStartDate(event.target.value)}
                slotProps={{ inputLabel: { shrink: true } }}
                sx={{ minWidth: { md: 170 } }}
              />
              <TextField
                label="Ate"
                type="date"
                value={endDate}
                onChange={(event) => setEndDate(event.target.value)}
                slotProps={{ inputLabel: { shrink: true } }}
                sx={{ minWidth: { md: 170 } }}
              />
              {hasFilters && (
                <Button variant="outlined" color="inherit" onClick={clearFilters} sx={{ minWidth: 130 }}>
                  Limpar
                </Button>
              )}
            </Stack>
          </Stack>

          <Stack spacing={1.5} sx={{ display: { xs: "flex", md: "none" }, px: 2, pb: 2 }}>
            {visibleMatches.length === 0 ? (
              <Typography color="text.secondary">Nenhuma partida encontrada com estes filtros.</Typography>
            ) : visibleMatches.map((match) => (
              <Paper key={match.id} variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                <Stack spacing={1.5}>
                  <Stack direction="row" justifyContent="space-between" gap={1}>
                    <Typography fontWeight={700}>{formatDateOnlyBR(match.matchDate)}</Typography>
                    <ColoredScore match={match} size="small" />
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
                  <TableCell align="right">Acoes</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {visibleMatches.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5}>
                      <Typography color="text.secondary">Nenhuma partida encontrada com estes filtros.</Typography>
                    </TableCell>
                  </TableRow>
                ) : visibleMatches.map((match) => (
                  <TableRow key={match.id} hover>
                    <TableCell>{formatDateOnlyBR(match.matchDate)}</TableCell>
                    <TableCell>{resolveTeam(match, players, "A")}</TableCell>
                    <TableCell>{resolveTeam(match, players, "B")}</TableCell>
                    <TableCell>
                      <ColoredScore match={match} size="small" />
                    </TableCell>
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

          {visibleMatches.length < filteredMatches.length && (
            <Stack alignItems="center" sx={{ px: 2, py: 2 }}>
              <Button variant="outlined" onClick={() => setVisibleCount((current) => current + 20)}>
                Mostrar mais partidas
              </Button>
            </Stack>
          )}
        </AccordionDetails>
      </Accordion>
    </Paper>
  );
}
