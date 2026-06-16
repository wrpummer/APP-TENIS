import EventAvailableRoundedIcon from "@mui/icons-material/EventAvailableRounded";
import PlaceRoundedIcon from "@mui/icons-material/PlaceRounded";
import ScheduleRoundedIcon from "@mui/icons-material/ScheduleRounded";
import { Alert, Button, Chip, Grid, Paper, Stack, TextField, Typography } from "@mui/material";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { getAdminSessionStatus, saveNextMatch } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { NextMatchInfo, NextMatchStatus, Season } from "@/types/domain";

interface NextMatchCardProps {
  nextMatch: NextMatchInfo | null;
  season: Season;
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

export function NextMatchCard({ nextMatch, season }: NextMatchCardProps) {
  const queryClient = useQueryClient();
  const [date, setDate] = useState(nextMatch?.date ?? "");
  const [time, setTime] = useState(nextMatch?.time ?? "");
  const [location, setLocation] = useState(nextMatch?.location ?? "");
  const [status, setStatus] = useState<NextMatchStatus>(nextMatch?.status ?? "pending");
  const [feedback, setFeedback] = useState<string | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    setDate(nextMatch?.date ?? "");
    setTime(nextMatch?.time ?? "");
    setLocation(nextMatch?.location ?? "");
    setStatus(nextMatch?.status ?? "pending");
    setFeedback(null);
    setIsEditing(false);
  }, [nextMatch]);

  const { data: canEdit } = useQuery({
    queryKey: queryKeys.adminSession,
    queryFn: getAdminSessionStatus
  });

  const mutation = useMutation({
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

  const activeStatus = statusOptions.find((option) => option.value === status) ?? statusOptions[1];

  return (
    <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4 }}>
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

        {canEdit ? (
          isEditing ? (
            <Stack spacing={2}>
              <Grid container spacing={2}>
                <Grid size={{ xs: 12, md: 4 }}>
                  <TextField
                    label="Data"
                    type="date"
                    value={date}
                    onChange={(event) => setDate(event.target.value)}
                    InputLabelProps={{ shrink: true }}
                    fullWidth
                  />
                </Grid>
                <Grid size={{ xs: 12, md: 4 }}>
                  <TextField
                    label="Horário"
                    type="time"
                    value={time}
                    onChange={(event) => setTime(event.target.value)}
                    InputLabelProps={{ shrink: true }}
                    fullWidth
                  />
                </Grid>
                <Grid size={{ xs: 12, md: 4 }}>
                  <TextField
                    label="Local"
                    value={location}
                    onChange={(event) => setLocation(event.target.value)}
                    placeholder="Ex.: Trianon Coberta"
                    fullWidth
                  />
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

              {feedback && (
                <Alert severity={mutation.isError ? "error" : "success"}>
                  {feedback}
                </Alert>
              )}

              <Stack direction={{ xs: "column", sm: "row" }} spacing={1} sx={{ alignSelf: "flex-start" }}>
                <Button
                  variant="contained"
                  onClick={() => mutation.mutate({
                    seasonId: season.id,
                    date,
                    time,
                    location,
                    status
                  })}
                  disabled={mutation.isPending}
                >
                  {mutation.isPending ? "Salvando..." : "Salvar próximo jogo"}
                </Button>
                <Button variant="outlined" color="inherit" onClick={handleCancelEditing} disabled={mutation.isPending}>
                  Cancelar
                </Button>
              </Stack>
            </Stack>
          ) : (
            <Stack spacing={2} alignItems="flex-start">
              {feedback && (
                <Alert severity="success" sx={{ width: "100%" }}>
                  {feedback}
                </Alert>
              )}
              <Button variant="outlined" onClick={handleStartEditing}>
                Editar próximo jogo
              </Button>
            </Stack>
          )
        ) : (
          <Alert severity="info">
            Entre na área administrativa para inserir ou editar os dados do próximo jogo diretamente neste card.
          </Alert>
        )}
      </Stack>
    </Paper>
  );
}
