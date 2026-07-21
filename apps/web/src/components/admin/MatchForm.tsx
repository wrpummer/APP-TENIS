import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import SaveRoundedIcon from "@mui/icons-material/SaveRounded";
import {
  Alert,
  Button,
  Checkbox,
  Collapse,
  Divider,
  FormControlLabel,
  Grid,
  MenuItem,
  Paper,
  Snackbar,
  Stack,
  TextField,
  Typography
} from "@mui/material";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useMemo, useState } from "react";
import { AlertSlot } from "@/components/common/AlertSlot";
import { saveMatch } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Match, MatchSet, Player, Season, TeamSide } from "@/types/domain";
import { inferWinnerTeam, summarizeSets, validateMatch } from "@/utils/tennis";

interface MatchFormProps {
  players: Player[];
  seasons: Season[];
  editingMatch?: Match | null;
  onSaved?: () => void;
  onCancelEdit?: () => void;
}

type MatchScoreState = Omit<MatchSet, "teamAGames" | "teamBGames"> & {
  teamAGames: number | null;
  teamBGames: number | null;
  isEnabled: true;
  notes: string;
};

interface MatchFormState {
  id?: string;
  seasonId: string;
  matchDate: string;
  teamAPlayer1Id: string;
  teamAPlayer2Id: string;
  teamBPlayer1Id: string;
  teamBPlayer2Id: string;
  isWalkover: boolean;
  walkoverTeam: TeamSide | null;
  notes: string;
  sets: [MatchScoreState];
}

const LAST_MATCH_FORM_KEY = "ranking-tennis:last-match-form";

function createInitialScore(): MatchScoreState {
  return {
    setOrder: 1,
    teamAGames: null,
    teamBGames: null,
    isTiebreak: false,
    isSuperTiebreak: false,
    tiebreakPointsA: null,
    tiebreakPointsB: null,
    deucesCount: null,
    notes: "",
    isEnabled: true
  };
}

function createInitialForm(): MatchFormState {
  return {
    id: undefined,
    seasonId: "",
    matchDate: "",
    teamAPlayer1Id: "",
    teamAPlayer2Id: "",
    teamBPlayer1Id: "",
    teamBPlayer2Id: "",
    isWalkover: false,
    walkoverTeam: null,
    notes: "",
    sets: [createInitialScore()]
  };
}

function createRepeatForm(form: MatchFormState): MatchFormState {
  return {
    ...form,
    id: undefined,
    sets: [{ ...form.sets[0], id: undefined }]
  };
}

function buildMatchPayload(form: MatchFormState) {
  return {
    ...form,
    sets: [{
      ...form.sets[0],
      setOrder: 1,
      teamAGames: form.sets[0].teamAGames ?? 0,
      teamBGames: form.sets[0].teamBGames ?? 0
    }]
  };
}

function validateMatchDraft(form: MatchFormState) {
  const issues: string[] = [];
  const score = form.sets[0];

  if (!form.seasonId) issues.push("Selecione a temporada.");
  if (!form.matchDate) issues.push("Informe a data da partida.");

  const selectedPlayers = [form.teamAPlayer1Id, form.teamAPlayer2Id, form.teamBPlayer1Id, form.teamBPlayer2Id];
  if (selectedPlayers.some((playerId) => !playerId)) {
    issues.push("Selecione os quatro jogadores da partida.");
  } else if (new Set(selectedPlayers).size !== selectedPlayers.length) {
    issues.push("Cada partida deve ter quatro jogadores diferentes.");
  }

  if (score.teamAGames == null || score.teamBGames == null) {
    issues.push("Preencha o placar da partida.");
  }

  if (form.isWalkover && !form.walkoverTeam) {
    issues.push("Selecione a dupla que desistiu por W.O.");
  }

  return issues.length > 0 ? issues : validateMatch(buildMatchPayload(form));
}

export function MatchForm({ players, seasons, editingMatch, onSaved, onCancelEdit }: MatchFormProps) {
  const queryClient = useQueryClient();
  const activePlayers = players.filter((player) => player.status === "active");
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [form, setForm] = useState<MatchFormState>(createInitialForm());
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [successToastOpen, setSuccessToastOpen] = useState(false);
  const validationIssues = useMemo(() => validateMatchDraft(form), [form]);
  const score = form.sets[0];

  useEffect(() => {
    if (!editingMatch) {
      const savedForm = window.localStorage.getItem(LAST_MATCH_FORM_KEY);
      if (!savedForm) return;

      try {
        setForm(createRepeatForm(JSON.parse(savedForm) as MatchFormState));
      } catch {
        window.localStorage.removeItem(LAST_MATCH_FORM_KEY);
      }
      return;
    }

    const existingScore = editingMatch.sets[0];
    setForm({
      id: editingMatch.id,
      seasonId: editingMatch.seasonId,
      matchDate: editingMatch.matchDate,
      teamAPlayer1Id: editingMatch.teamAPlayer1Id,
      teamAPlayer2Id: editingMatch.teamAPlayer2Id,
      teamBPlayer1Id: editingMatch.teamBPlayer1Id,
      teamBPlayer2Id: editingMatch.teamBPlayer2Id,
      isWalkover: editingMatch.isWalkover,
      walkoverTeam: editingMatch.walkoverTeam ?? null,
      notes: editingMatch.notes ?? "",
      sets: [{
        ...createInitialScore(),
        ...existingScore,
        setOrder: 1,
        notes: existingScore?.notes ?? "",
        isEnabled: true
      }]
    });
    setShowAdvanced(Boolean(existingScore?.isTiebreak || existingScore?.deucesCount || existingScore?.notes));
    setMessage(null);
    setError(null);
  }, [editingMatch]);

  function resetForm() {
    setForm(createInitialForm());
    setShowAdvanced(false);
  }

  function updateScore(patch: Partial<MatchScoreState>) {
    setForm((current) => ({
      ...current,
      sets: [{ ...current.sets[0], ...patch, notes: patch.notes ?? current.sets[0].notes }]
    }));
  }

  async function handleSave() {
    if (validationIssues.length > 0) return;

    try {
      setIsSaving(true);
      const payload = buildMatchPayload(form);
      await saveMatch(payload);
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: queryKeys.recentMatches }),
        queryClient.invalidateQueries({ queryKey: queryKeys.dashboard }),
        queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "history" }),
        queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "ranking" }),
        queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "hall-of-fame" }),
        queryClient.invalidateQueries({ queryKey: ["player-statistics"] })
      ]);
      setError(null);
      setMessage(
        form.id
          ? "Partida atualizada com sucesso."
          : form.isWalkover && form.walkoverTeam
            ? `Partida salva com sucesso. W.O. da Dupla ${form.walkoverTeam}; vitória da Dupla ${form.walkoverTeam === "A" ? "B" : "A"}.`
            : `Partida salva com sucesso. Vencedor: Dupla ${inferWinnerTeam(payload.sets)} | Placar: ${summarizeSets(payload.sets)}`
      );
      setSuccessToastOpen(true);
      const repeatForm = createRepeatForm(form);
      window.localStorage.setItem(LAST_MATCH_FORM_KEY, JSON.stringify(repeatForm));
      setForm(repeatForm);
      onSaved?.();
    } catch (caughtError) {
      setMessage(null);
      setError(caughtError instanceof Error ? caughtError.message : "Não foi possível salvar a partida.");
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Paper sx={{ p: { xs: 2, sm: 3 }, border: "1px solid rgba(10,77,60,0.08)" }}>
      <Stack spacing={2}>
        <Typography variant="h6">{form.id ? "Editar partida" : "Registrar partida"}</Typography>
        <Alert severity="info">
          Cada lançamento corresponde a uma partida. Informe apenas um placar; não existe segundo ou terceiro set neste cadastro.
        </Alert>
        <AlertSlot
          severity={validationIssues.length > 0 ? "warning" : error ? "error" : "success"}
          message={validationIssues.length > 0 ? validationIssues.join(" ") : error ?? message}
          minHeight={88}
        />

        <Grid container spacing={2}>
          <Grid size={{ xs: 12, md: 3 }}>
            <TextField select fullWidth label="Temporada" value={form.seasonId} onChange={(event) => setForm((current) => ({ ...current, seasonId: event.target.value }))}>
              <MenuItem value="">Selecione</MenuItem>
              {seasons.map((season) => <MenuItem key={season.id} value={season.id}>{season.year}</MenuItem>)}
            </TextField>
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <TextField fullWidth type="date" label="Data" value={form.matchDate} onChange={(event) => setForm((current) => ({ ...current, matchDate: event.target.value }))} slotProps={{ inputLabel: { shrink: true } }} />
          </Grid>
          {[
            ["teamAPlayer1Id", "Dupla A - Jogador 1"],
            ["teamAPlayer2Id", "Dupla A - Jogador 2"],
            ["teamBPlayer1Id", "Dupla B - Jogador 1"],
            ["teamBPlayer2Id", "Dupla B - Jogador 2"]
          ].map(([field, label]) => (
            <Grid key={field} size={{ xs: 12, md: 3 }}>
              <TextField select fullWidth label={label} value={form[field as keyof MatchFormState] as string} onChange={(event) => setForm((current) => ({ ...current, [field]: event.target.value }))}>
                <MenuItem value="">Selecione</MenuItem>
                {activePlayers.map((player) => <MenuItem key={player.id} value={player.id}>{player.displayName}</MenuItem>)}
              </TextField>
            </Grid>
          ))}

          <Grid size={{ xs: 12 }}>
            <Paper variant="outlined" sx={{ p: 2, borderRadius: 3, bgcolor: form.isWalkover ? "rgba(211,47,47,0.04)" : "transparent" }}>
              <Stack spacing={1.5}>
                <FormControlLabel
                  control={
                    <Checkbox
                      checked={form.isWalkover}
                      onChange={(event) => setForm((current) => ({
                        ...current,
                        isWalkover: event.target.checked,
                        walkoverTeam: event.target.checked ? current.walkoverTeam : null,
                        sets: event.target.checked
                          ? [{ ...current.sets[0], isTiebreak: false, isSuperTiebreak: false, tiebreakPointsA: null, tiebreakPointsB: null }]
                          : current.sets
                      }))}
                    />
                  }
                  label="Partida encerrada por W.O."
                />
                {form.isWalkover && (
                  <Grid container spacing={2} alignItems="center">
                    <Grid size={{ xs: 12, sm: 5 }}>
                      <TextField
                        select
                        label="Dupla que desistiu"
                        value={form.walkoverTeam ?? ""}
                        onChange={(event) => setForm((current) => ({ ...current, walkoverTeam: event.target.value as TeamSide }))}
                        helperText="Selecione quem não conseguiu continuar"
                        fullWidth
                      >
                        <MenuItem value="">Selecione</MenuItem>
                        <MenuItem value="A">Dupla A</MenuItem>
                        <MenuItem value="B">Dupla B</MenuItem>
                      </TextField>
                    </Grid>
                    <Grid size={{ xs: 12, sm: 7 }}>
                      <Alert severity="warning">
                        O placar será congelado. A outra dupla vencerá por W.O.; vencedores receberão 3 pontos e desistentes receberão 1 ponto.
                      </Alert>
                    </Grid>
                  </Grid>
                )}
              </Stack>
            </Paper>
          </Grid>

          <Grid size={{ xs: 12 }}><Divider /></Grid>

          <Grid size={{ xs: 12 }}>
            <Paper variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
              <Stack spacing={2}>
                <Typography variant="subtitle1" fontWeight={800}>Placar da partida</Typography>
                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                    <TextField fullWidth label="Games da dupla A" type="number" value={score.teamAGames ?? ""} slotProps={{ htmlInput: { min: 0, max: score.isSuperTiebreak ? 1 : 7 } }} helperText={score.isSuperTiebreak ? "Use 1-0 ou 0-1." : "Placar normal: 0 a 7."} onChange={(event) => updateScore({ teamAGames: event.target.value === "" ? null : Number(event.target.value) })} />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                    <TextField fullWidth label="Games da dupla B" type="number" value={score.teamBGames ?? ""} slotProps={{ htmlInput: { min: 0, max: score.isSuperTiebreak ? 1 : 7 } }} helperText={score.isSuperTiebreak ? "Use 1-0 ou 0-1." : "Placar normal: 0 a 7."} onChange={(event) => updateScore({ teamBGames: event.target.value === "" ? null : Number(event.target.value) })} />
                  </Grid>
                  {!form.isWalkover && <Grid size={{ xs: 12 }}>
                    <FormControlLabel
                      control={<Checkbox checked={score.isTiebreak} onChange={(event) => updateScore({ isTiebreak: event.target.checked, isSuperTiebreak: event.target.checked ? score.isSuperTiebreak : false, tiebreakPointsA: event.target.checked ? score.tiebreakPointsA : null, tiebreakPointsB: event.target.checked ? score.tiebreakPointsB : null })} />}
                      label="Houve tiebreak na partida"
                    />
                  </Grid>}
                  {!form.isWalkover && score.isTiebreak && (
                    <>
                      <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                        <TextField fullWidth label="Pontos tiebreak A" type="number" value={score.tiebreakPointsA ?? ""} slotProps={{ htmlInput: { min: 0, max: 30 } }} onChange={(event) => updateScore({ tiebreakPointsA: event.target.value === "" ? null : Number(event.target.value) })} />
                      </Grid>
                      <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                        <TextField fullWidth label="Pontos tiebreak B" type="number" value={score.tiebreakPointsB ?? ""} slotProps={{ htmlInput: { min: 0, max: 30 } }} onChange={(event) => updateScore({ tiebreakPointsB: event.target.value === "" ? null : Number(event.target.value) })} />
                      </Grid>
                    </>
                  )}
                </Grid>
              </Stack>
            </Paper>
          </Grid>

          {!form.isWalkover && <Grid size={{ xs: 12 }}>
            <Button variant="text" color="inherit" startIcon={<ExpandMoreRoundedIcon />} onClick={() => setShowAdvanced((current) => !current)}>
              {showAdvanced ? "Ocultar detalhes avançados" : "Mostrar detalhes avançados"}
            </Button>
          </Grid>}
          {!form.isWalkover && <Grid size={{ xs: 12 }}>
            <Collapse in={showAdvanced}>
              <Paper variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                <Grid container spacing={2}>
                  <Grid size={{ xs: 12 }}>
                    <FormControlLabel
                      control={<Checkbox checked={Boolean(score.isSuperTiebreak)} onChange={(event) => updateScore({ isSuperTiebreak: event.target.checked, isTiebreak: event.target.checked || score.isTiebreak, teamAGames: event.target.checked ? 1 : score.teamAGames, teamBGames: event.target.checked ? 0 : score.teamBGames })} />}
                      label="A partida foi decidida por super tiebreak"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, md: 4 }}>
                    <TextField fullWidth label="Quantidade de deuces" type="number" value={score.deucesCount ?? ""} onChange={(event) => updateScore({ deucesCount: event.target.value === "" ? null : Number(event.target.value) })} />
                  </Grid>
                  <Grid size={{ xs: 12, md: 8 }}>
                    <TextField fullWidth label="Observação do placar" value={score.notes} onChange={(event) => updateScore({ notes: event.target.value })} />
                  </Grid>
                </Grid>
              </Paper>
            </Collapse>
          </Grid>}

          <Grid size={{ xs: 12 }}>
            <TextField fullWidth multiline minRows={3} label="Observações da partida" value={form.notes} onChange={(event) => setForm((current) => ({ ...current, notes: event.target.value }))} />
          </Grid>
        </Grid>

        <Alert severity="success">
          Resumo automático: {validationIssues.length > 0
            ? "preencha os campos para visualizar o resultado."
            : form.isWalkover && form.walkoverTeam
              ? `W.O. da Dupla ${form.walkoverTeam} | vencedora = Dupla ${form.walkoverTeam === "A" ? "B" : "A"} | placar congelado ${summarizeSets(buildMatchPayload(form).sets) || "0-0"}`
              : `vencedor = Dupla ${inferWinnerTeam(buildMatchPayload(form).sets)} | placar ${summarizeSets(buildMatchPayload(form).sets)}`}
        </Alert>
        <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
          <Button variant="contained" startIcon={<SaveRoundedIcon />} onClick={handleSave} fullWidth disabled={isSaving}>
            {form.id ? "Salvar alterações" : "Salvar partida"}
          </Button>
          {form.id && (
            <Button variant="outlined" color="inherit" onClick={() => { resetForm(); setMessage(null); setError(null); onCancelEdit?.(); }} fullWidth>
              Cancelar edição
            </Button>
          )}
        </Stack>
      </Stack>

      <Snackbar open={successToastOpen} autoHideDuration={3500} onClose={(_, reason) => reason !== "clickaway" && setSuccessToastOpen(false)} anchorOrigin={{ vertical: "top", horizontal: "right" }}>
        <Alert severity="success" variant="filled" onClose={() => setSuccessToastOpen(false)} sx={{ width: "100%" }}>
          {message ?? "Partida salva com sucesso."}
        </Alert>
      </Snackbar>
    </Paper>
  );
}
