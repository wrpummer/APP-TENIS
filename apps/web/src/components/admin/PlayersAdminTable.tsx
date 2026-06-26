import DeleteOutlineRoundedIcon from "@mui/icons-material/DeleteOutlineRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import PersonOffRoundedIcon from "@mui/icons-material/PersonOffRounded";
import RestartAltRoundedIcon from "@mui/icons-material/RestartAltRounded";
import {
  Accordion,
  AccordionDetails,
  AccordionSummary,
  Avatar,
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
import { deletePlayer, updatePlayerStatus } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Player } from "@/types/domain";
import { formatDateOnlyBR } from "@/utils/tennis";

interface PlayersAdminTableProps {
  players: Player[];
  onEditPlayer: (player: Player) => void;
}

export function PlayersAdminTable({ players, onEditPlayer }: PlayersAdminTableProps) {
  const queryClient = useQueryClient();
  const [feedback, setFeedback] = useState<{ type: "success" | "error"; message: string } | null>(null);
  const [expanded, setExpanded] = useState(false);

  async function refreshPlayers() {
    await queryClient.invalidateQueries({ queryKey: queryKeys.players });
  }

  async function handleToggleStatus(player: Player) {
    const nextStatus = player.status === "active" ? "inactive" : "active";
    try {
      await updatePlayerStatus(player.id, nextStatus);
      await refreshPlayers();
      setFeedback({
        type: "success",
        message: `${player.displayName} agora está ${nextStatus === "active" ? "ativo" : "inativo"}.`
      });
    } catch (caughtError) {
      setFeedback({
        type: "error",
        message: caughtError instanceof Error ? caughtError.message : "Não foi possível alterar o status do jogador."
      });
    }
  }

  async function handleDelete(player: Player) {
    const confirmed = window.confirm(`Deseja realmente excluir ${player.displayName}?`);
    if (!confirmed) {
      return;
    }

    try {
      await deletePlayer(player.id);
      await refreshPlayers();
      setFeedback({
        type: "success",
        message: `${player.displayName} foi excluído com sucesso.`
      });
    } catch (caughtError) {
      setFeedback({
        type: "error",
        message: caughtError instanceof Error ? caughtError.message : "Não foi possível excluir o jogador."
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
              <Typography variant="h6">Jogadores cadastrados</Typography>
              <Chip size="small" label={`${players.length} jogador${players.length === 1 ? "" : "es"}`} color="primary" variant="outlined" />
            </Stack>
            <AlertSlot severity={feedback?.type ?? "info"} message={feedback?.message ?? null} />
          </Stack>
        </AccordionSummary>

        <AccordionDetails sx={{ px: 0, pt: 0, pb: 0 }}>
          <Stack spacing={1.5} sx={{ display: { xs: "flex", md: "none" }, px: 2, pb: 2 }}>
            {players.map((player) => (
              <Paper key={player.id} variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                <Stack spacing={2}>
                  <Stack direction="row" spacing={1.5} alignItems="center">
                    <Avatar src={player.photoUrl ?? undefined}>
                      {player.displayName.slice(0, 1).toUpperCase()}
                    </Avatar>
                    <Box sx={{ minWidth: 0, flex: 1 }}>
                      <Typography fontWeight={700} sx={{ wordBreak: "break-word" }}>
                        {player.displayName}
                      </Typography>
                      <Typography color="text.secondary" variant="body2">
                        Desde: {formatDateOnlyBR(player.registeredAt)}
                      </Typography>
                    </Box>
                    <Chip
                      size="small"
                      label={player.status === "active" ? "Ativo" : "Inativo"}
                      color={player.status === "active" ? "success" : "default"}
                    />
                  </Stack>

                  <Typography color="text.secondary" variant="body2">
                    Telefone: {player.phone || "Não informado"}
                  </Typography>

                  <Stack direction="row" spacing={1} useFlexGap flexWrap="wrap">
                    <Button size="small" variant="outlined" startIcon={<EditRoundedIcon />} onClick={() => onEditPlayer(player)}>
                      Editar
                    </Button>
                    <Button
                      size="small"
                      variant="outlined"
                      color={player.status === "active" ? "warning" : "success"}
                      startIcon={player.status === "active" ? <PersonOffRoundedIcon /> : <RestartAltRoundedIcon />}
                      onClick={() => void handleToggleStatus(player)}
                    >
                      {player.status === "active" ? "Inativar" : "Ativar"}
                    </Button>
                    <Button
                      size="small"
                      variant="outlined"
                      color="error"
                      startIcon={<DeleteOutlineRoundedIcon />}
                      onClick={() => void handleDelete(player)}
                    >
                      Excluir
                    </Button>
                  </Stack>
                </Stack>
              </Paper>
            ))}
          </Stack>

          <Box sx={{ display: { xs: "none", md: "block" }, overflowX: "auto" }}>
            <Table sx={{ minWidth: 760 }}>
              <TableHead>
                <TableRow>
                  <TableCell>Foto</TableCell>
                  <TableCell>Nome</TableCell>
                  <TableCell>Telefone</TableCell>
                  <TableCell>Jogador desde</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="right">Ações</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {players.map((player) => (
                  <TableRow key={player.id} hover>
                    <TableCell>
                      <Avatar src={player.photoUrl ?? undefined}>
                        {player.displayName.slice(0, 1).toUpperCase()}
                      </Avatar>
                    </TableCell>
                    <TableCell>{player.displayName}</TableCell>
                    <TableCell>{player.phone || "Não informado"}</TableCell>
                    <TableCell>{formatDateOnlyBR(player.registeredAt)}</TableCell>
                    <TableCell>
                      <Chip
                        size="small"
                        label={player.status === "active" ? "Ativo" : "Inativo"}
                        color={player.status === "active" ? "success" : "default"}
                      />
                    </TableCell>
                    <TableCell align="right">
                      <Stack direction={{ xs: "column", lg: "row" }} spacing={1} justifyContent="flex-end">
                        <Button size="small" variant="outlined" startIcon={<EditRoundedIcon />} onClick={() => onEditPlayer(player)}>
                          Editar
                        </Button>
                        <Button
                          size="small"
                          variant="outlined"
                          color={player.status === "active" ? "warning" : "success"}
                          startIcon={player.status === "active" ? <PersonOffRoundedIcon /> : <RestartAltRoundedIcon />}
                          onClick={() => void handleToggleStatus(player)}
                        >
                          {player.status === "active" ? "Inativar" : "Ativar"}
                        </Button>
                        <Button size="small" variant="outlined" color="error" startIcon={<DeleteOutlineRoundedIcon />} onClick={() => void handleDelete(player)}>
                          Excluir
                        </Button>
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Box>

          <Stack sx={{ px: 3, pb: 3, pt: 1 }}>
            <Typography variant="body2" color="text.secondary">
              Jogadores com partidas já lançadas não podem ser excluídos para preservar o histórico. Nesses casos, use "Inativar".
            </Typography>
          </Stack>
        </AccordionDetails>
      </Accordion>
    </Paper>
  );
}
