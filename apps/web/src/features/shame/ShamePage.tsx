import CalendarMonthRoundedIcon from "@mui/icons-material/CalendarMonthRounded";
import DeleteOutlineRoundedIcon from "@mui/icons-material/DeleteOutlineRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import LocationOnRoundedIcon from "@mui/icons-material/LocationOnRounded";
import PersonRoundedIcon from "@mui/icons-material/PersonRounded";
import SendRoundedIcon from "@mui/icons-material/SendRounded";
import {
  Alert,
  Box,
  Button,
  Grid,
  IconButton,
  Paper,
  Snackbar,
  Stack,
  TextField,
  Tooltip,
  Typography
} from "@mui/material";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useRef, useState } from "react";
import { LoadingState } from "@/components/common/LoadingState";
import { useFunnyStories } from "@/hooks/useFunnyStories";
import { deleteFunnyStory, saveFunnyStory } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { FunnyStory } from "@/types/domain";
import { formatDateOnlyBR } from "@/utils/tennis";

interface StoryFormState {
  id?: string;
  authorName: string;
  eventDate: string;
  location: string;
  content: string;
}

const emptyForm: StoryFormState = {
  authorName: "",
  eventDate: "",
  location: "",
  content: ""
};

export function ShamePage() {
  const queryClient = useQueryClient();
  const formRef = useRef<HTMLDivElement | null>(null);
  const { data: stories = [], isLoading, error } = useFunnyStories();
  const [form, setForm] = useState<StoryFormState>(emptyForm);
  const [feedback, setFeedback] = useState<{ severity: "success" | "error"; message: string } | null>(null);
  const [toastOpen, setToastOpen] = useState(false);
  const isEditing = Boolean(form.id);
  const formValid = form.authorName.trim().length >= 2
    && Boolean(form.eventDate)
    && form.location.trim().length >= 2
    && form.content.trim().length >= 3;

  const saveMutation = useMutation({
    mutationFn: saveFunnyStory,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: queryKeys.funnyStories });
      setFeedback({ severity: "success", message: isEditing ? "História atualizada com sucesso." : "História publicada com sucesso!" });
      setToastOpen(true);
      setForm(emptyForm);
    },
    onError: (caughtError) => {
      setFeedback({
        severity: "error",
        message: caughtError instanceof Error ? caughtError.message : "Não foi possível salvar a história."
      });
    }
  });

  const deleteMutation = useMutation({
    mutationFn: deleteFunnyStory,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: queryKeys.funnyStories });
      setFeedback({ severity: "success", message: "História apagada." });
      setToastOpen(true);
      setForm(emptyForm);
    },
    onError: (caughtError) => {
      setFeedback({
        severity: "error",
        message: caughtError instanceof Error ? caughtError.message : "Não foi possível apagar a história."
      });
    }
  });

  function handleEdit(story: FunnyStory) {
    setForm({
      id: story.id,
      authorName: story.authorName,
      eventDate: story.eventDate,
      location: story.location,
      content: story.content
    });
    setFeedback(null);
    requestAnimationFrame(() => {
      const top = (formRef.current?.getBoundingClientRect().top ?? 0) + window.scrollY - 96;
      window.scrollTo({ top: Math.max(0, top), behavior: "smooth" });
    });
  }

  function handleDelete(story: FunnyStory) {
    const confirmed = window.confirm(`Apagar a história publicada por ${story.authorName}?`);
    if (confirmed) {
      deleteMutation.mutate(story.id);
    }
  }

  if (isLoading) {
    return <LoadingState />;
  }

  return (
    <Stack spacing={3}>
      <Paper
        sx={{
          overflow: "hidden",
          borderRadius: 5,
          color: "#fff8df",
          background: "linear-gradient(120deg, #24113f 0%, #53153d 52%, #9d251f 100%)",
          boxShadow: "0 24px 70px rgba(76,20,48,0.24)"
        }}
      >
        <Grid container alignItems="stretch">
          <Grid size={{ xs: 12, md: 7 }}>
            <Stack spacing={2} sx={{ p: { xs: 3, sm: 4, md: 5 } }}>
              <Typography variant="overline" fontWeight={900} color="#ffd447">Mural aberto do tênis</Typography>
              <Typography variant="h2" sx={{ fontSize: { xs: "2.35rem", md: "4rem" }, lineHeight: 0.95 }}>
                Dick Vigarista
              </Typography>
              <Typography variant="h6" sx={{ color: "rgba(255,248,223,0.86)", maxWidth: 650 }}>
                Escreva aqui o seu relato para deixar registrado no painel.
              </Typography>
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 5 }}>
            <Box component="img" src="/dick-vigarista.jpg" alt="Dick Vigarista" sx={{ width: "100%", height: { xs: 250, md: "100%" }, minHeight: { md: 350 }, objectFit: "cover", display: "block" }} />
          </Grid>
        </Grid>
      </Paper>

      <Paper ref={formRef} sx={{ p: { xs: 2, sm: 3 }, borderRadius: 4, border: "1px solid rgba(83,21,61,0.14)" }}>
        <Stack spacing={2}>
          <Box>
            <Typography variant="h5" fontWeight={900}>{isEditing ? "Editar história" : "Conte uma história"}</Typography>
            <Typography color="text.secondary">Preencha os quatro campos abaixo. Todos são obrigatórios.</Typography>
          </Box>

          {feedback && <Alert severity={feedback.severity}>{feedback.message}</Alert>}
          {error && <Alert severity="error">{error instanceof Error ? error.message : "Não foi possível carregar as histórias."}</Alert>}

          <Grid container spacing={2}>
            <Grid size={{ xs: 12, md: 4 }}>
              <TextField label="Seu nome" value={form.authorName} onChange={(event) => setForm((current) => ({ ...current, authorName: event.target.value }))} helperText="Nome de quem está escrevendo" inputProps={{ maxLength: 80 }} fullWidth />
            </Grid>
            <Grid size={{ xs: 12, sm: 6, md: 4 }}>
              <TextField label="Data do jogo" type="date" value={form.eventDate} onChange={(event) => setForm((current) => ({ ...current, eventDate: event.target.value }))} slotProps={{ inputLabel: { shrink: true } }} fullWidth />
            </Grid>
            <Grid size={{ xs: 12, sm: 6, md: 4 }}>
              <TextField label="Local do jogo" value={form.location} onChange={(event) => setForm((current) => ({ ...current, location: event.target.value }))} placeholder="Ex.: Quadra coberta" inputProps={{ maxLength: 120 }} fullWidth />
            </Grid>
            <Grid size={{ xs: 12 }}>
              <TextField label="O que aconteceu?" value={form.content} onChange={(event) => setForm((current) => ({ ...current, content: event.target.value }))} placeholder="Conte aqui o fato engraçado..." multiline minRows={4} inputProps={{ maxLength: 2000 }} helperText={`${form.content.length}/2000 caracteres`} fullWidth />
            </Grid>
          </Grid>

          <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
            <Button variant="contained" startIcon={<SendRoundedIcon />} disabled={!formValid || saveMutation.isPending} onClick={() => saveMutation.mutate(form)}>
              {saveMutation.isPending ? "Salvando..." : isEditing ? "Salvar alteração" : "Publicar história"}
            </Button>
            {isEditing && (
              <Button color="inherit" variant="outlined" onClick={() => { setForm(emptyForm); setFeedback(null); }}>
                Cancelar edição
              </Button>
            )}
          </Stack>
        </Stack>
      </Paper>

      <Box>
        <Typography variant="h5" fontWeight={900}>Histórias da turma</Typography>
        <Typography color="text.secondary">As mais recentes aparecem primeiro.</Typography>
      </Box>

      {!error && stories.length === 0 ? (
        <Paper sx={{ p: 4, textAlign: "center", borderRadius: 4, border: "1px dashed rgba(83,21,61,0.25)" }}>
          <Typography variant="h6" fontWeight={850}>O mural ainda está comportado demais.</Typography>
          <Typography color="text.secondary">Use o formulário acima para publicar o primeiro causo.</Typography>
        </Paper>
      ) : (
        <Grid container spacing={2}>
          {stories.map((story) => (
            <Grid key={story.id} size={{ xs: 12, md: 6 }}>
              <Paper sx={{ p: { xs: 2, sm: 3 }, borderRadius: 4, height: "100%", border: "1px solid rgba(83,21,61,0.12)", bgcolor: "#fffdf7" }}>
                <Stack spacing={2} height="100%">
                  <Stack direction="row" justifyContent="space-between" alignItems="flex-start" gap={1}>
                    <Stack spacing={0.75}>
                      <Stack direction="row" spacing={0.75} alignItems="center">
                        <PersonRoundedIcon sx={{ color: "#53153d", fontSize: 20 }} />
                        <Typography fontWeight={900}>{story.authorName}</Typography>
                      </Stack>
                      <Stack direction={{ xs: "column", sm: "row" }} spacing={{ xs: 0.5, sm: 1.5 }}>
                        <Stack direction="row" spacing={0.5} alignItems="center">
                          <CalendarMonthRoundedIcon sx={{ color: "#9d251f", fontSize: 18 }} />
                          <Typography variant="body2">{formatDateOnlyBR(story.eventDate)}</Typography>
                        </Stack>
                        <Stack direction="row" spacing={0.5} alignItems="center">
                          <LocationOnRoundedIcon sx={{ color: "#9d251f", fontSize: 18 }} />
                          <Typography variant="body2">{story.location}</Typography>
                        </Stack>
                      </Stack>
                    </Stack>
                    <Stack direction="row" spacing={0.25}>
                      <Tooltip title="Editar">
                        <IconButton size="small" aria-label={`Editar história de ${story.authorName}`} onClick={() => handleEdit(story)}>
                          <EditRoundedIcon fontSize="small" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Apagar">
                        <IconButton size="small" color="error" aria-label={`Apagar história de ${story.authorName}`} onClick={() => handleDelete(story)} disabled={deleteMutation.isPending}>
                          <DeleteOutlineRoundedIcon fontSize="small" />
                        </IconButton>
                      </Tooltip>
                    </Stack>
                  </Stack>
                  <Typography sx={{ whiteSpace: "pre-line", lineHeight: 1.7, flex: 1 }}>{story.content}</Typography>
                </Stack>
              </Paper>
            </Grid>
          ))}
        </Grid>
      )}

      <Snackbar open={toastOpen} autoHideDuration={3500} onClose={() => setToastOpen(false)} anchorOrigin={{ vertical: "top", horizontal: "right" }}>
        <Alert severity="success" variant="filled" onClose={() => setToastOpen(false)}>{feedback?.message ?? "Concluído."}</Alert>
      </Snackbar>
    </Stack>
  );
}
