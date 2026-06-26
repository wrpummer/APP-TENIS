import EventAvailableRoundedIcon from "@mui/icons-material/EventAvailableRounded";
import HowToRegRoundedIcon from "@mui/icons-material/HowToRegRounded";
import PlaceRoundedIcon from "@mui/icons-material/PlaceRounded";
import ScheduleRoundedIcon from "@mui/icons-material/ScheduleRounded";
import UndoRoundedIcon from "@mui/icons-material/UndoRounded";
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
  FormControl,
  Grid,
  InputLabel,
  MenuItem,
  Paper,
  Select,
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
  removeNextMatchConfirmationAsAdmin,
  saveNextMatch,
  updateNextMatchAttendanceStatus,
  withdrawNextMatchPresence
} from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type {
  NextMatchAttendanceStatus,
  NextMatchConfirmation,
  NextMatchInfo,
  NextMatchStatus,
  Player,
  Season
} from "@/types/domain";

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

const attendanceOptions: Array<{
  value: NextMatchAttendanceStatus;
  label: string;
  color: "default" | "success" | "error" | "info";
}> = [
  { value: "awaiting", label: "Aguardando", color: "default" },
  { value: "played", label: "Jogou", color: "success" },
  { value: "absent", label: "Faltou", color: "error" },
  { value: "justified", label: "Justificado", color: "info" }
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

function isWithinWithdrawalLimit(date: string, time: string) {
  if (!date || !time) {
    return false;
  }

  const scheduledAt = new Date(`${date}T${time}:00`);
  return scheduledAt.getTime() - Date.now() <= 10 * 60 * 60 * 1000;
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
  const [confirmationCode, setConfirmationCode] = useState("");
  const [confirmationFeedback, setConfirmationFeedback] = useState<string | null>(null);
  const [withdrawalTarget, setWithdrawalTarget] = useState<NextMatchConfirmation | null>(null);
  const [withdrawalCode, setWithdrawalCode] = useState("");

  const publishedDate = nextMatch?.date ?? "";
  const publishedTime = nextMatch?.time ?? "";
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
    setConfirmationCode("");
    setConfirmationFeedback(null);
    setWithdrawalTarget(null);
    setWithdrawalCode("");
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
      setConfirmationCode("");
      setConfirmationOpen(false);
    },
    onError: (error) => {
      setConfirmationFeedback(error instanceof Error ? error.message : "Não foi possível confirmar a presença.");
    }
  });

  const withdrawalMutation = useMutation({
    mutationFn: withdrawNextMatchPresence,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: confirmationQueryKey });
      setConfirmationFeedback("Seu nome foi retirado da lista de presença.");
      setWithdrawalTarget(null);
      setWithdrawalCode("");
    },
    onError: (error) => {
      setConfirmationFeedback(error instanceof Error ? error.message : "Não foi possível retirar a confirmação.");
    }
  });

  const attendanceMutation = useMutation({
    mutationFn: updateNextMatchAttendanceStatus,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: confirmationQueryKey });
      setConfirmationFeedback("Status do jogador atualizado.");
    },
    onError: (error) => {
      setConfirmationFeedback(error instanceof Error ? error.message : "Não foi possível atualizar o status.");
    }
  });

  const adminRemovalMutation = useMutation({
    mutationFn: removeNextMatchConfirmationAsAdmin,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: confirmationQueryKey });
      setConfirmationFeedback("Jogador removido da lista de presença.");
      setWithdrawalTarget(null);
      setWithdrawalCode("");
    },
    onError: (error) => {
      setConfirmationFeedback(error instanceof Error ? error.message : "Não foi possível remover o jogador.");
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
    setConfirmationCode("");
    setConfirmationFeedback(null);
    setConfirmationOpen(true);
  }

  function handleConfirmPresence() {
    if (!selectedPlayer || !publishedDate || confirmationCode.length !== 4) {
      return;
    }

    confirmationMutation.mutate({
      seasonId: season.id,
      matchDate: publishedDate,
      playerId: selectedPlayer.id,
      withdrawalCode: confirmationCode
    });
  }

  function handleOpenWithdrawal(confirmation: NextMatchConfirmation) {
    setConfirmationFeedback(null);
    setWithdrawalCode("");
    setWithdrawalTarget(confirmation);
  }

  function handleWithdrawPresence() {
    if (!withdrawalTarget) {
      return;
    }

    if (canEdit) {
      adminRemovalMutation.mutate(withdrawalTarget.id);
      return;
    }

    if (withdrawalCode.length !== 4) {
      return;
    }

    withdrawalMutation.mutate({
      confirmationId: withdrawalTarget.id,
      withdrawalCode
    });
  }

  const activeStatus = statusOptions.find((option) => option.value === status) ?? statusOptions[1];
  const confirmationDisabled = !publishedDate || publishedStatus === "cancelled";
  const withdrawalLocked = isWithinWithdrawalLimit(publishedDate, publishedTime);
  const presenceFeedbackIsError = confirmationMutation.isError
    || withdrawalMutation.isError
    || attendanceMutation.isError
    || adminRemovalMutation.isError;

  return (
    <Paper sx={{ p: { xs: 2, sm: 3 }, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4 }}>
      <Stack spacing={2.5}>
        <Box>
          <Stack direction="row" spacing={1.25} alignItems="center" flexWrap="wrap" useFlexGap>
            <Typography variant="h5">Próximo jogo</Typography>
            <Chip label={activeStatus.label} color={activeStatus.color} sx={{ fontWeight: 700 }} />
          </Stack>
          <Typography color="text.secondary">Temporada {season.year}</Typography>
        </Box>

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
                <Typography variant="body2" color="text.secondary">
                  Confirme seu nome e crie um código de 4 números. Guarde o código caso precise desistir.
                </Typography>
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

            {confirmationFeedback && <Alert severity={presenceFeedbackIsError ? "error" : "success"}>{confirmationFeedback}</Alert>}
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
              <Stack spacing={1}>
                {confirmations.map((confirmation) => (
                  <Paper
                    key={confirmation.id}
                    variant="outlined"
                    sx={{ p: 1.25, borderRadius: 2.5, bgcolor: "background.paper" }}
                  >
                    <Stack
                      direction={{ xs: "column", sm: "row" }}
                      alignItems={{ xs: "stretch", sm: "center" }}
                      justifyContent="space-between"
                      gap={1.25}
                    >
                      <Stack direction="row" alignItems="center" spacing={1.25}>
                      <Avatar src={confirmation.photoUrl ?? undefined} alt={confirmation.playerName}>
                        {getInitials(confirmation.playerName)}
                      </Avatar>
                        <Box>
                          <Typography fontWeight={800}>{confirmation.playerName}</Typography>
                          {!canEdit && (
                            <Chip
                              size="small"
                              label={attendanceOptions.find((option) => option.value === confirmation.attendanceStatus)?.label ?? "Aguardando"}
                              color={attendanceOptions.find((option) => option.value === confirmation.attendanceStatus)?.color ?? "default"}
                            />
                          )}
                        </Box>
                      </Stack>

                      <Stack direction={{ xs: "column", sm: "row" }} spacing={1} alignItems={{ xs: "stretch", sm: "center" }}>
                        {canEdit ? (
                          <FormControl size="small" sx={{ minWidth: 150 }}>
                            <InputLabel>Status</InputLabel>
                            <Select
                              label="Status"
                              value={confirmation.attendanceStatus}
                              disabled={attendanceMutation.isPending}
                              onChange={(event) => {
                                setConfirmationFeedback(null);
                                attendanceMutation.mutate({
                                  confirmationId: confirmation.id,
                                  attendanceStatus: event.target.value as NextMatchAttendanceStatus
                                });
                              }}
                            >
                              {attendanceOptions.map((option) => (
                                <MenuItem key={option.value} value={option.value}>{option.label}</MenuItem>
                              ))}
                            </Select>
                          </FormControl>
                        ) : null}

                        {(confirmation.attendanceStatus === "awaiting" || canEdit) && (
                          <Button
                            size="small"
                            color="error"
                            variant="outlined"
                            startIcon={<UndoRoundedIcon />}
                            onClick={() => handleOpenWithdrawal(confirmation)}
                            disabled={!canEdit && withdrawalLocked}
                          >
                            {canEdit ? "Remover" : "Desistir"}
                          </Button>
                        )}
                      </Stack>
                    </Stack>
                  </Paper>
                ))}
              </Stack>
            )}

            {publishedDate && publishedStatus !== "cancelled" && (
              <Alert severity={withdrawalLocked ? "warning" : "info"}>
                {withdrawalLocked
                  ? "O prazo para desistir terminou. Não é possível retirar a confirmação nas 10 horas anteriores ao jogo."
                  : publishedTime
                    ? "Se precisar desistir, faça isso até 10 horas antes do horário do jogo e informe seu código de 4 números."
                    : "Enquanto o horário não estiver definido, a desistência permanece disponível."}
              </Alert>
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
            <Alert severity="info">
              São apenas dois passos: escolha seu nome e crie um código de 4 números. Anote ou memorize esse código, pois ele será necessário se você desistir.
            </Alert>
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
            <TextField
              label="Crie seu código de 4 números"
              value={confirmationCode}
              onChange={(event) => setConfirmationCode(event.target.value.replace(/\D/g, "").slice(0, 4))}
              type="password"
              helperText="Exemplo: 2580. Não use a senha do seu celular ou banco."
              slotProps={{ htmlInput: { inputMode: "numeric", maxLength: 4 } }}
              fullWidth
            />
            {confirmationMutation.isError && confirmationFeedback && <Alert severity="error">{confirmationFeedback}</Alert>}
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button color="inherit" onClick={() => setConfirmationOpen(false)} disabled={confirmationMutation.isPending}>Cancelar</Button>
          <Button variant="contained" onClick={handleConfirmPresence} disabled={!selectedPlayer || confirmationCode.length !== 4 || confirmationMutation.isPending}>
            {confirmationMutation.isPending ? "Confirmando..." : "Confirmar meu nome"}
          </Button>
        </DialogActions>
      </Dialog>

      <Dialog
        open={Boolean(withdrawalTarget)}
        onClose={() => !withdrawalMutation.isPending && !adminRemovalMutation.isPending && setWithdrawalTarget(null)}
        fullWidth
        maxWidth="xs"
      >
        <DialogTitle>{canEdit ? "Remover jogador" : "Desistir do jogo"}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ pt: 1 }}>
            <Typography>Retirar <strong>{withdrawalTarget?.playerName}</strong> da lista de presença?</Typography>
            {canEdit ? (
              <Alert severity="warning">Como administrador, você pode remover este nome sem informar o código.</Alert>
            ) : (
              <>
                <Alert severity="info">Digite o mesmo código de 4 números criado quando este nome foi confirmado.</Alert>
                <TextField
                  label="Código de 4 números"
                  value={withdrawalCode}
                  onChange={(event) => setWithdrawalCode(event.target.value.replace(/\D/g, "").slice(0, 4))}
                  type="password"
                  slotProps={{ htmlInput: { inputMode: "numeric", maxLength: 4 } }}
                  error={withdrawalMutation.isError}
                  fullWidth
                  autoFocus
                />
              </>
            )}
            {(withdrawalMutation.isError || adminRemovalMutation.isError) && confirmationFeedback && <Alert severity="error">{confirmationFeedback}</Alert>}
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button color="inherit" onClick={() => setWithdrawalTarget(null)} disabled={withdrawalMutation.isPending || adminRemovalMutation.isPending}>Voltar</Button>
          <Button
            color="error"
            variant="contained"
            onClick={handleWithdrawPresence}
            disabled={(!canEdit && withdrawalCode.length !== 4) || withdrawalMutation.isPending || adminRemovalMutation.isPending}
          >
            {withdrawalMutation.isPending || adminRemovalMutation.isPending
              ? "Retirando..."
              : canEdit ? "Remover da lista" : "Sim, quero desistir"}
          </Button>
        </DialogActions>
      </Dialog>
    </Paper>
  );
}
