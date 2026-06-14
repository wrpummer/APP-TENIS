import DeleteOutlineRoundedIcon from "@mui/icons-material/DeleteOutlineRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import PersonOffRoundedIcon from "@mui/icons-material/PersonOffRounded";
import RestartAltRoundedIcon from "@mui/icons-material/RestartAltRounded";
import { Avatar, Button, Chip, Paper, Stack, Table, TableBody, TableCell, TableHead, TableRow, Typography } from "@mui/material";
import { useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { AlertSlot } from "@/components/common/AlertSlot";
import { deletePlayer, updatePlayerStatus } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Player } from "@/types/domain";

interface PlayersAdminTableProps {
  players: Player[];
  onEditPlayer: (player: Player) => void;
}

function formatDate(value?: string | null) {
  if (!value) {
    return "Nao informado";
  }

  const [year, month, day] = value.slice(0, 10).split("-");
  return `${day}/${month}/${year}`;
}

export function PlayersAdminTable({ players, onEditPlayer }: PlayersAdminTableProps) {
  const queryClient = useQueryClient();
  const [feedback, setFeedback] = useState<{ type: "success" | "error"; message: string } | null>(null);

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
        message: `${player.displayName} agora esta ${nextStatus === "active" ? "ativo" : "inativo"}.`
      });
    } catch (caughtError) {
      setFeedback({
        type: "error",
        message: caughtError instanceof Error ? caughtError.message : "Nao foi possivel alterar o status do jogador."
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
        message: `${player.displayName} foi excluido com sucesso.`
      });
    } catch (caughtError) {
      setFeedback({
        type: "error",
        message: caughtError instanceof Error ? caughtError.message : "Nao foi possivel excluir o jogador."
      });
    }
  }

  return (
    <Paper sx={{ overflow: "hidden", border: "1px solid rgba(10,77,60,0.08)" }}>
      <Stack spacing={1} sx={{ px: 3, pt: 3, pb: 1 }}>
        <Typography variant="h6">Jogadores cadastrados</Typography>
        <AlertSlot severity={feedback?.type ?? "info"} message={feedback?.message ?? null} />
      </Stack>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Foto</TableCell>
            <TableCell>Nome</TableCell>
            <TableCell>Telefone</TableCell>
            <TableCell>Jogador desde</TableCell>
            <TableCell>Status</TableCell>
            <TableCell align="right">Acoes</TableCell>
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
              <TableCell>{player.phone || "Nao informado"}</TableCell>
              <TableCell>{formatDate(player.registeredAt)}</TableCell>
              <TableCell>
                <Chip
                  size="small"
                  label={player.status === "active" ? "Ativo" : "Inativo"}
                  color={player.status === "active" ? "success" : "default"}
                />
              </TableCell>
              <TableCell align="right">
                <Stack direction={{ xs: "column", md: "row" }} spacing={1} justifyContent="flex-end">
                  <Button
                    size="small"
                    variant="outlined"
                    startIcon={<EditRoundedIcon />}
                    onClick={() => onEditPlayer(player)}
                  >
                    Editar
                  </Button>
                  <Button
                    size="small"
                    variant="outlined"
                    color={player.status === "active" ? "warning" : "success"}
                    startIcon={player.status === "active" ? <PersonOffRoundedIcon /> : <RestartAltRoundedIcon />}
                    onClick={() => handleToggleStatus(player)}
                  >
                    {player.status === "active" ? "Inativar" : "Ativar"}
                  </Button>
                  <Button
                    size="small"
                    variant="outlined"
                    color="error"
                    startIcon={<DeleteOutlineRoundedIcon />}
                    onClick={() => handleDelete(player)}
                  >
                    Excluir
                  </Button>
                </Stack>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <Stack sx={{ px: 3, pb: 3, pt: 1 }}>
        <Typography variant="body2" color="text.secondary">
          Jogadores com partidas ja lancadas nao podem ser excluidos para preservar o historico. Nesses casos, use "Inativar".
        </Typography>
      </Stack>
    </Paper>
  );
}
