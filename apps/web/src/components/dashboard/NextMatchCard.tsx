import CheckCircleRoundedIcon from "@mui/icons-material/CheckCircleRounded";
import EventAvailableRoundedIcon from "@mui/icons-material/EventAvailableRounded";
import HowToRegRoundedIcon from "@mui/icons-material/HowToRegRounded";
import PlaceRoundedIcon from "@mui/icons-material/PlaceRounded";
import ScheduleRoundedIcon from "@mui/icons-material/ScheduleRounded";
import {
  Alert,
  Autocomplete,
  Avatar,
  Box,
  Button,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Grid,
  Paper,
  Stack,
  TextField,
  Typography
} from "@mui/material";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useMemo, useState } from "react";
import {
  confirmNextMatchPresence,
  getAdminSessionStatus,
  getNextMatchConfirmations,
  saveNextMatch
} from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { NextMatchInfo, NextMatchStatus, Player, Season } from "@/types/domain";

interface NextMatchCardProps {
  nextMatch: NextMatchInfo | null;
  season: Season;
  players: Player[];
}

const statusOptions: Array<{
  value: NextMatchStatus;
  label: string;
  color: "success" | "warning" | "error";
}> = [
  { value: "confirmed", label: "Confirmado", color: "success" },
  { value: "pending", label: "Confirmação pendente", color: "warning" },
  { value: "cancelled", label: "Cancelado", color: "error" }
];

function formatDate(date: string) {
  if (!date) {
    return "A definir";
  }

  const [year, month, day] = date.split("-");
  return `${day}/${month}/${year}`;
}

function getInitials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase();
}

export function NextMatchCard({ nextMatch, season, players }: NextMatchCardProps) {
  const queryClient = useQueryClient();
  const [date, setDate] = useState(nextMatch?.date ?? "");
  const [time, setTime] = useState(nextMatch?.time ?? "");
  const [location, setLocation] = useState(nextMatch?.location ?? "");
  const [status, setStatus] = useState<NextMatchStatus>(nextMatch?.status ?? "pending");
  const [feedback, setFeedback] = useState<string | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [confirmationOpen, setConfirmationOpen] = useState(false);
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  const [confirmationFeedback, setConfirmationFeedback] = useState<string | null>(null);

  const publishedDate = nextMatch?.date ?? "";
  const publishedStatus = nextMatch?.status ?? "pending";
  const confirmationQueryKey = queryKeys.nextMatchConfirmations(season.id, publishedDate);
  const activePlayers = useMemo(
    () => players.filter((player) => player.status === "active"),
    [players]
  );

  useEffect(() => {
    setDate(nextMatch?.date ?? "");
    setTime(nextMatch?.time ?? "");
    setLocation(nextMatch?.location ?? "");
    setStatus(nextMatch?.status ?? "pending");
    setFeedback(null);
    setIsEditing(false);
    setConfirmationOpen(false);
    setSelectedPlayer(null);
    setConfirmationFeedback(null);
  }, [nextMatch]);

  const { data: canEdit } = useQuery({
    queryKey: queryKeys.adminSession,
    queryFn: getAdminSessionStatus
  });

  const {
    data: confirmations = [],
    isLoading: confirmationsLoading,
    error: confirmationsError
  } = useQuery({
    queryKey: confirmationQueryKey,
    queryFn: () => getNextMatchConfirmations(season.id, publishedDate),
    enabled: Boolean(publishedDate)
  });

  const confirmedPlayerIds = useMemo(
    () => new Set(confirmations.map((confirmation) => confirmation.playerId)),
    [confirmations]
  );

  const saveMutation = useMutation({
    mutationFn: saveNextMatch,
    onSuccess: () => {
      setFeedback("Próximo jogo salvo com sucesso.");
      setIsEditing(false);
      queryClient.invalidateQueries({ queryKey: queryKeys.dashboard });
    },
    onError: (error) => {
      setFeedback(error instanceof Error ? error.message : "Não foi possível salvar o próximo jogo.");
    }
  });

  const confirmationMutation = useMutation({
    mutationFn: confirmNextMatchPresence,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: confirmationQueryKey });
      setConfirmationFeedback("Presença confirmada com sucesso!");
      setSelectedPlayer(null);
      setConfirmationOpen(false);
    },
    onError: (error) => {
      setConfirmationFeedback(error instanceof Error ? error.message : "Não foi possível confirmar a presença.");
    }
  });

  function resetForm() {
    setDate(nextMatch?.date ?? "");
    setTime(nextMatch?.time ?? "");
    setLocation(nextMatch?.location ?? "");
    setStatus(nextMatch?.status ?? "pending");
    setFeedback(null);
  }

  function handleStartEditing() {
    resetForm();
    setIsEditing(true);
  }

  function handleCancelEditing() {
    resetForm();
    setIsEditing(false);
  }

  function handleOpenConfirmation() {
    setSelectedPlayer(null);
    setConfirmationFeedback(null);
    setConfirmationOpen(true);
  }

  function handleConfirmPresence() {
    if (!selectedPlayer || !publishedDate) {
      return;
    }

    confirmationMutation.mutate({
      seasonId: season.id,
      matchDate: publishedDate,
      playerId: selectedPlayer.id
    });
  }

  const activeStatus = statusOptions.find((option) => option.value === status) ?? statusOptions[1];
  const confirmationDisabled = !publishedDate || publishedStatus === "cancelled";

  return (
    <Paper sx={{ p: { xs: 2, sm: 3 }, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4 }}>
      <Stack spacing={2.5}>
        <Stack direction={{ xs: "column", md: "row" }} justifyContent="space-between" gap={2}>
          <div>
            <Typography variant="h5">Próximo jogo</Typography>
            <Typography color="text.secondary">Temporada {season.year}</Typography>
          </div>
          <Chip label={activeStatus.label} color={activeStatus.color} sx={{ fontWeight: 700, alignSelf: "flex-start" }} />
        </Stack>

        <Grid container spacing={2}>
          <Grid size={{ xs: 12, md: 4 }}>
            <Stack direction="row" spacing={1.5} alignItems="center">
              <EventAvailableRoundedIcon color="primary" />
              <div>
                <Typography color="text.secondary">Data</Typography>
                <Typography fontWeight={700}>{formatDate(date)}</Typography>
              </div>
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 4 }}>
            <Stack direction="row" spacing={1.5} alignItems="center">
              <ScheduleRoundedIcon color="primary" />
              <div>
                <Typography color="text.secondary">Horário</Typography>
                <Typography fontWeight={700}>{time || "A definir"}</Typography>
              </div>
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 4 }}>
            <Stack direction="row" spacing={1.5} alignItems="center">
              <PlaceRoundedIcon color="primary" />
              <div>
                <Typography color="text.secondary">Local</Typography>
                <Typography fontWeight={700}>{location || "A definir"}</Typography>
              </div>
            </Stack>
          </Grid>
        </Grid>

        <Paper
          variant="outlined"
          sx={{ p: 2, borderRadius: 3, bgcolor: "rgba(10,77,60,0.035)", borderColor: "rgba(10,77,60,0.12)" }}
        >
          <Stack spacing={1.5}>
            <Stack direction={{ xs: "column", sm: "row" }} justifyContent="space-between" alignItems={{ xs: "stretch", sm: "center" }} gap={1.5}>
              <Box>
                <Typography fontWeight={800}>Presenças confirmadas ({confirmations.length})</Typography>
                <Typography variant="body2" color="text.secondary">Selecione seu nome para entrar na lista.</Typography>
              </Box>
              <Button
                variant="contained"
                startIcon={<HowToRegRoundedIcon />}
                onClick={handleOpenConfirmation}
                disabled={confirmationDisabled}
              >
                Confirmar presença
              </Button>
            </Stack>

            {confirmationFeedback && <Alert severity="success">{confirmationFeedback}</Alert>}
            {confirmationsError && (
              <Alert severity="error">
                {confirmationsError instanceof Error ? confirmationsError.message : "Não foi possível carregar as confirmações."}
              </Alert>
            )}

            {!publishedDate ? (
              <Typography variant="body2" color="text.secondary">A confirmação será liberada quando a data for definida.</Typography>
            ) : publishedStatus === "cancelled" ? (
              <Typography variant="body2" color="error.main">As confirmações estão fechadas porque o jogo foi cancelado.</Typography>
            ) : confirmationsLoading ? (
              <Typography variant="body2" color="text.secondary">Carregando confirmações...</Typography>
            ) : confirmations.length === 0 ? (
              <Typography variant="body2" color="text.secondary">Ainda não há jogadores confirmados.</Typography>
            ) : (
              <Stack direction="row" gap={1} flexWrap="wrap">
                {confirmations.map((confirmation) => (
                  <Chip
                    key={confirmation.id}
                    avatar={
                      <Avatar src={confirmation.photoUrl ?? undefined} alt={confirmation.playerName}>
                        {getInitials(confirmation.playerName)}
                      </Avatar>
                    }
                    label={confirmation.playerName}
                    color="success"
                    variant="outlined"
                    icon={<CheckCircleRoundedIcon />}
                    sx={{ fontWeight: 700 }}
                  />
                ))}
              </Stack>
            )}
          </Stack>
        </Paper>

        {canEdit && (
          isEditing ? (
            <Stack spacing={2}>
              <Grid container spacing={2}>
                <Grid size={{ xs: 12, md: 4 }}>
                  <TextField label="Data" type="date" value={date} onChange={(event) => setDate(event.target.value)} slotProps={{ inputLabel: { shrink: true } }} fullWidth />
                </Grid>
                <Grid size={{ xs: 12, md: 4 }}>
                  <TextField label="Horário" type="time" value={time} onChange={(event) => setTime(event.target.value)} slotProps={{ inputLabel: { shrink: true } }} fullWidth />
                </Grid>
                <Grid size={{ xs: 12, md: 4 }}>
                  <TextField label="Local" value={location} onChange={(event) => setLocation(event.target.value)} placeholder="Ex.: Quadra coberta" fullWidth />
                </Grid>
              </Grid>

              <Stack direction={{ xs: "column", md: "row" }} spacing={1} alignItems={{ xs: "stretch", md: "center" }}>
                {statusOptions.map((option) => (
                  <Chip
                    key={option.value}
                    label={option.label}
                    color={status === option.value ? option.color : "default"}
                    variant={status === option.value ? "filled" : "outlined"}
                    onClick={() => setStatus(option.value)}
                    sx={{ fontWeight: 700 }}
                  />
                ))}
              </Stack>

              {feedback && <Alert severity={saveMutation.isError ? "error" : "success"}>{feedback}</Alert>}

              <Stack direction={{ xs: "column", sm: "row" }} spacing={1} sx={{ alignSelf: "flex-start" }}>
                <Button
                  variant="contained"
                  onClick={() => saveMutation.mutate({ seasonId: season.id, date, time, location, status })}
                  disabled={saveMutation.isPending}
                >
                  {saveMutation.isPending ? "Salvando..." : "Salvar próximo jogo"}
                </Button>
                <Button variant="outlined" color="inherit" onClick={handleCancelEditing} disabled={saveMutation.isPending}>
                  Cancelar
                </Button>
              </Stack>
            </Stack>
          ) : (
            <Stack spacing={2} alignItems="flex-start">
              {feedback && <Alert severity="success" sx={{ width: "100%" }}>{feedback}</Alert>}
              <Button variant="outlined" onClick={handleStartEditing}>Editar próximo jogo</Button>
            </Stack>
          )
        )}
      </Stack>

      <Dialog open={confirmationOpen} onClose={() => !confirmationMutation.isPending && setConfirmationOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle>Confirmar presença</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ pt: 1 }}>
            <Typography color="text.secondary">Pesquise e selecione o seu nome na lista de jogadores.</Typography>
            <Autocomplete
              options={activePlayers}
              value={selectedPlayer}
              onChange={(_, value) => setSelectedPlayer(value)}
              getOptionLabel={(option) => option.displayName}
              getOptionDisabled={(option) => confirmedPlayerIds.has(option.id)}
              isOptionEqualToValue={(option, value) => option.id === value.id}
              noOptionsText="Nenhum jogador encontrado"
              renderInput={(params) => (
                <TextField {...params} label="Buscar jogador" placeholder="Digite seu nome" autoFocus />
              )}
              renderOption={(props, option) => (
                <Box component="li" {...props} sx={{ display: "flex", gap: 1.5 }}>
                  <Avatar src={option.photoUrl ?? undefined} sx={{ width: 34, height: 34 }}>
                    {getInitials(option.displayName)}
                  </Avatar>
                  <Box>
                    <Typography fontWeight={700}>{option.displayName}</Typography>
                    {confirmedPlayerIds.has(option.id) && (
                      <Typography variant="caption" color="success.main">Presença já confirmada</Typography>
                    )}
                  </Box>
                </Box>
              )}
            />
            {confirmationMutation.isError && confirmationFeedback && <Alert severity="error">{confirmationFeedback}</Alert>}
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button color="inherit" onClick={() => setConfirmationOpen(false)} disabled={confirmationMutation.isPending}>Cancelar</Button>
          <Button variant="contained" onClick={handleConfirmPresence} disabled={!selectedPlayer || confirmationMutation.isPending}>
            {confirmationMutation.isPending ? "Confirmando..." : "Confirmar meu nome"}
          </Button>
        </DialogActions>
      </Dialog>
    </Paper>
  );
}
