import AddRoundedIcon from "@mui/icons-material/AddRounded";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import RemoveCircleOutlineRoundedIcon from "@mui/icons-material/RemoveCircleOutlineRounded";
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
import { useEffect, useMemo, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { AlertSlot } from "@/components/common/AlertSlot";
import { saveMatch } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Match, MatchSet, Player, Season } from "@/types/domain";
import { inferWinnerTeam, summarizeSets, validateMatch } from "@/utils/tennis";

interface MatchFormProps {
  players: Player[];
  seasons: Season[];
  editingMatch?: Match | null;
  onSaved?: () => void;
  onCancelEdit?: () => void;
}

type MatchFormSetState = Omit<MatchSet, "teamAGames" | "teamBGames"> & {
  teamAGames: number | null;
  teamBGames: number | null;
  isEnabled: boolean;
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
  notes: string;
  sets: MatchFormSetState[];
}

const createInitialSets = (): MatchFormSetState[] => [
  { setOrder: 1, teamAGames: null, teamBGames: null, isTiebreak: false, isSuperTiebreak: false, tiebreakPointsA: null, tiebreakPointsB: null, deucesCount: null, notes: "", isEnabled: true },
  { setOrder: 2, teamAGames: null, teamBGames: null, isTiebreak: false, isSuperTiebreak: false, tiebreakPointsA: null, tiebreakPointsB: null, deucesCount: null, notes: "", isEnabled: false },
  { setOrder: 3, teamAGames: null, teamBGames: null, isTiebreak: false, isSuperTiebreak: false, tiebreakPointsA: null, tiebreakPointsB: null, deucesCount: null, notes: "", isEnabled: false }
];

function createInitialForm(seasonId: string): MatchFormState {
  return {
    id: undefined as string | undefined,
    seasonId,
    matchDate: "",
    teamAPlayer1Id: "",
    teamAPlayer2Id: "",
    teamBPlayer1Id: "",
    teamBPlayer2Id: "",
    notes: "",
    sets: createInitialSets()
  };
}

function buildMatchPayload(form: MatchFormState) {
  return {
    ...form,
    sets: form.sets.map((set) => ({
      ...set,
      teamAGames: set.teamAGames ?? 0,
      teamBGames: set.teamBGames ?? 0
    }))
  };
}

function validateMatchDraft(form: MatchFormState) {
  const issues: string[] = [];

  if (!form.seasonId) {
    issues.push("Selecione a temporada.");
  }

  if (!form.matchDate) {
    issues.push("Informe a data da partida.");
  }

  const selectedPlayers = [form.teamAPlayer1Id, form.teamAPlayer2Id, form.teamBPlayer1Id, form.teamBPlayer2Id];
  if (selectedPlayers.some((playerId) => !playerId)) {
    issues.push("Selecione os quatro jogadores da partida.");
  } else if (new Set(selectedPlayers).size !== selectedPlayers.length) {
    issues.push("Cada partida deve ter quatro jogadores diferentes.");
  }

  for (const set of form.sets.filter((item) => item.isEnabled)) {
    if (set.teamAGames == null || set.teamBGames == null) {
      issues.push(`Preencha o placar do set ${set.setOrder}.`);
    }
  }

  if (issues.length > 0) {
    return issues;
  }

  return validateMatch(buildMatchPayload(form));
}

export function MatchForm({ players, seasons, editingMatch, onSaved, onCancelEdit }: MatchFormProps) {
  const queryClient = useQueryClient();
  const activePlayers = players.filter((player) => player.status === "active");
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [form, setForm] = useState(createInitialForm(""));
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [successToastOpen, setSuccessToastOpen] = useState(false);
  const validationIssues = useMemo(() => validateMatchDraft(form), [form]);

  useEffect(() => {
    if (!editingMatch) {
      return;
    }

    setForm({
      id: editingMatch.id,
      seasonId: editingMatch.seasonId,
      matchDate: editingMatch.matchDate,
      teamAPlayer1Id: editingMatch.teamAPlayer1Id,
      teamAPlayer2Id: editingMatch.teamAPlayer2Id,
      teamBPlayer1Id: editingMatch.teamBPlayer1Id,
      teamBPlayer2Id: editingMatch.teamBPlayer2Id,
      notes: editingMatch.notes ?? "",
      sets: createInitialSets().map((defaultSet) => {
        const existing = editingMatch.sets.find((item) => item.setOrder === defaultSet.setOrder);
        return existing ? { ...defaultSet, ...existing, notes: existing.notes ?? "", isEnabled: true } : defaultSet;
      })
    });
    setShowAdvanced(Boolean(editingMatch.sets.some((set) => set.isTiebreak || set.deucesCount || set.notes)));
    setMessage(null);
    setError(null);
  }, [editingMatch]);

  function resetForm() {
    setForm(createInitialForm(""));
    setShowAdvanced(false);
  }

  function updateSet(setOrder: number, patch: Partial<MatchFormSetState>) {
    setForm((current) => ({
      ...current,
      sets: current.sets.map((currentSet) =>
        currentSet.setOrder === setOrder
          ? { ...currentSet, ...patch, notes: patch.notes ?? currentSet.notes }
          : currentSet
      )
    }));
  }

  function clearSet(setOrder: number, currentSet: MatchFormSetState): MatchFormSetState {
    return {
      ...currentSet,
      isEnabled: false,
      teamAGames: null,
      teamBGames: null,
      isTiebreak: false,
      isSuperTiebreak: false,
      tiebreakPointsA: null,
      tiebreakPointsB: null,
      deucesCount: null,
      notes: ""
    };
  }

  function removeSet(setOrder: number) {
    setForm((current) => ({
      ...current,
      sets: current.sets.map((currentSet) => {
        if (currentSet.setOrder === setOrder || (setOrder === 2 && currentSet.setOrder === 3)) {
          return clearSet(currentSet.setOrder, currentSet);
        }

        return currentSet;
      })
    }));
  }

  async function handleSave() {
    if (validationIssues.length > 0) {
      return;
    }

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
          : `Partida salva com sucesso. Vencedor: Dupla ${inferWinnerTeam(payload.sets)} | ${summarizeSets(payload.sets)}`
      );
      setSuccessToastOpen(true);
      resetForm();
      onSaved?.();
    } catch (caughtError) {
      setMessage(null);
      setError(
        caughtError instanceof Error
          ? caughtError.message
          : "Nao foi possivel salvar a partida. Verifique os dados e tente novamente."
      );
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)" }}>
      <Stack spacing={2}>
        <Typography variant="h6">{form.id ? "Editar partida" : "Registrar partida"}</Typography>
        <Typography color="text.secondary">
          Lance rapidamente os sets e, se quiser, abra os detalhes avancados para tiebreak, super tiebreak e deuces.
        </Typography>
        <AlertSlot
          severity={validationIssues.length > 0 ? "warning" : error ? "error" : "success"}
          message={validationIssues.length > 0 ? validationIssues.join(" ") : error ?? message}
          minHeight={88}
        />
        <Grid container spacing={2}>
          <Grid size={{ xs: 12, md: 3 }}>
            <TextField
              select
              fullWidth
              label="Temporada"
              value={form.seasonId}
              onChange={(event) => setForm((current) => ({ ...current, seasonId: event.target.value }))}
            >
              <MenuItem value="">Selecione</MenuItem>
              {seasons.map((season) => (
                <MenuItem key={season.id} value={season.id}>
                  {season.year}
                </MenuItem>
              ))}
            </TextField>
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <TextField
              fullWidth
              type="date"
              label="Data"
              value={form.matchDate}
              onChange={(event) => setForm((current) => ({ ...current, matchDate: event.target.value }))}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          {[
            ["teamAPlayer1Id", "Dupla A - Jogador 1"],
            ["teamAPlayer2Id", "Dupla A - Jogador 2"],
            ["teamBPlayer1Id", "Dupla B - Jogador 1"],
            ["teamBPlayer2Id", "Dupla B - Jogador 2"]
          ].map(([field, label]) => (
            <Grid key={field} size={{ xs: 12, md: 3 }}>
              <TextField
                select
                fullWidth
                label={label}
                value={form[field as keyof typeof form] as string}
                onChange={(event) => setForm((current) => ({ ...current, [field]: event.target.value }))}
              >
                <MenuItem value="">Selecione</MenuItem>
                {activePlayers.map((player) => (
                  <MenuItem key={player.id} value={player.id}>
                    {player.displayName}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
          ))}

          <Grid size={{ xs: 12 }}>
            <Divider />
          </Grid>

          {form.sets.filter((set) => set.isEnabled).map((set) => (
            <Grid key={set.setOrder} size={{ xs: 12 }}>
              <Paper variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                <Stack spacing={2}>
                  <Stack direction={{ xs: "column", md: "row" }} spacing={2} justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }}>
                    <Typography variant="subtitle1" fontWeight={700}>
                      Set {set.setOrder}
                    </Typography>
                    {set.setOrder > 1 && (
                      <Button
                        size="small"
                        color="inherit"
                        startIcon={<RemoveCircleOutlineRoundedIcon />}
                        onClick={() => removeSet(set.setOrder)}
                      >
                        Remover set
                      </Button>
                    )}
                  </Stack>

                  <Grid container spacing={2}>
                    <Grid size={{ xs: 12, md: 3 }}>
                      <TextField
                        fullWidth
                        label="Games dupla A"
                        type="number"
                        value={set.teamAGames ?? ""}
                        inputProps={{ min: 0, max: set.isSuperTiebreak ? 1 : 7 }}
                        helperText={set.isSuperTiebreak ? "Use 1-0 ou 0-1 no 3Âº set." : "Set normal: 0 a 7."}
                        onChange={(event) => updateSet(set.setOrder, { teamAGames: event.target.value === "" ? null : Number(event.target.value) })}
                      />
                    </Grid>
                    <Grid size={{ xs: 12, md: 3 }}>
                      <TextField
                        fullWidth
                        label="Games dupla B"
                        type="number"
                        value={set.teamBGames ?? ""}
                        inputProps={{ min: 0, max: set.isSuperTiebreak ? 1 : 7 }}
                        helperText={set.isSuperTiebreak ? "Use 1-0 ou 0-1 no 3Âº set." : "Set normal: 0 a 7."}
                        onChange={(event) => updateSet(set.setOrder, { teamBGames: event.target.value === "" ? null : Number(event.target.value) })}
                      />
                    </Grid>
                    {showAdvanced && (
                      <>
                        <Grid size={{ xs: 12, md: 3 }}>
                          <TextField
                            fullWidth
                            label="Deuces no set"
                            type="number"
                            value={set.deucesCount ?? ""}
                            onChange={(event) => updateSet(set.setOrder, { deucesCount: event.target.value === "" ? null : Number(event.target.value) })}
                          />
                        </Grid>
                        <Grid size={{ xs: 12, md: 3 }}>
                          <TextField
                            fullWidth
                            label="Observacao do set"
                            value={set.notes ?? ""}
                            onChange={(event) => updateSet(set.setOrder, { notes: event.target.value })}
                          />
                        </Grid>
                      </>
                    )}
                    <Grid size={{ xs: 12 }}>
                      <Stack direction={{ xs: "column", md: "row" }} spacing={2}>
                        <FormControlLabel
                          control={
                            <Checkbox
                              checked={set.isTiebreak}
                              onChange={(event) =>
                                updateSet(set.setOrder, {
                                  isTiebreak: event.target.checked,
                                  tiebreakPointsA: event.target.checked ? set.tiebreakPointsA : null,
                                  tiebreakPointsB: event.target.checked ? set.tiebreakPointsB : null,
                                  isSuperTiebreak: event.target.checked ? set.isSuperTiebreak : false
                                })
                              }
                            />
                          }
                          label="Houve tiebreak no set"
                        />
                        {showAdvanced && (
                          <FormControlLabel
                            control={
                              <Checkbox
                                checked={Boolean(set.isSuperTiebreak)}
                                disabled={!set.isTiebreak || set.setOrder !== 3}
                                onChange={(event) =>
                                  updateSet(set.setOrder, {
                                    isSuperTiebreak: event.target.checked,
                                    teamAGames: event.target.checked ? 1 : set.teamAGames,
                                    teamBGames: event.target.checked ? 0 : set.teamBGames
                                  })
                                }
                              />
                            }
                            label="3Âº set foi super tiebreak"
                          />
                        )}
                        {set.isSuperTiebreak && (
                          <Alert severity="info" sx={{ alignItems: "center" }}>
                            No super tiebreak, registre o set como 1-0 ou 0-1 e informe abaixo o placar real, por exemplo 10-8.
                          </Alert>
                        )}
                        {set.setOrder < 3 && set.isSuperTiebreak && (
                          <Alert severity="warning">
                            Super tiebreak deve ser usado somente no 3Âº set.
                          </Alert>
                        )}
                        {showAdvanced && set.setOrder === 3 && !set.isTiebreak && (
                          <FormControlLabel
                            control={
                              <Checkbox
                                checked={Boolean(set.isSuperTiebreak)}
                                onChange={(event) =>
                                  updateSet(set.setOrder, {
                                    isSuperTiebreak: event.target.checked,
                                    isTiebreak: event.target.checked,
                                    teamAGames: event.target.checked ? 1 : set.teamAGames,
                                    teamBGames: event.target.checked ? 0 : set.teamBGames
                                  })
                                }
                              />
                            }
                            label="Usar super tiebreak no 3Âº set"
                          />
                        )}
                      </Stack>
                    </Grid>

                    {set.isTiebreak && (
                      <>
                        <Grid size={{ xs: 12, md: 3 }}>
                          <TextField
                            fullWidth
                            label="Pontos tiebreak A"
                            type="number"
                            value={set.tiebreakPointsA ?? ""}
                            inputProps={{ min: 0, max: 30 }}
                            helperText={set.isSuperTiebreak ? "Ex.: 10" : "Ex.: 7"}
                            onChange={(event) => updateSet(set.setOrder, { tiebreakPointsA: event.target.value === "" ? null : Number(event.target.value) })}
                          />
                        </Grid>
                        <Grid size={{ xs: 12, md: 3 }}>
                          <TextField
                            fullWidth
                            label="Pontos tiebreak B"
                            type="number"
                            value={set.tiebreakPointsB ?? ""}
                            inputProps={{ min: 0, max: 30 }}
                            helperText={set.isSuperTiebreak ? "Ex.: 8" : "Ex.: 4"}
                            onChange={(event) => updateSet(set.setOrder, { tiebreakPointsB: event.target.value === "" ? null : Number(event.target.value) })}
                          />
                        </Grid>
                      </>
                    )}
                  </Grid>
                </Stack>
              </Paper>
            </Grid>
          ))}
          {!form.sets[1].isEnabled && (
            <Grid size={{ xs: 12 }}>
              <Button
                variant="outlined"
                startIcon={<AddRoundedIcon />}
                onClick={() => updateSet(2, { isEnabled: true })}
              >
                Adicionar 2Âº set
              </Button>
            </Grid>
          )}

          {form.sets[1].isEnabled && !form.sets[2].isEnabled && (
            <Grid size={{ xs: 12 }}>
              <Button
                variant="outlined"
                startIcon={<AddRoundedIcon />}
                onClick={() => updateSet(3, { isEnabled: true })}
              >
                Adicionar 3Âº set
              </Button>
            </Grid>
          )}

          <Grid size={{ xs: 12 }}>
            <Button
              variant="text"
              color="inherit"
              startIcon={<ExpandMoreRoundedIcon />}
              onClick={() => setShowAdvanced((current) => !current)}
            >
              {showAdvanced ? "Ocultar detalhes avancados" : "Mostrar detalhes avancados"}
            </Button>
          </Grid>

          <Grid size={{ xs: 12 }}>
            <Collapse in={showAdvanced}>
              <Alert severity="info">
                Use os detalhes avancados apenas quando quiser enriquecer a estatistica. O cadastro rapido continua funcionando so com os sets.
              </Alert>
            </Collapse>
          </Grid>

          <Grid size={{ xs: 12 }}>
            <TextField
              fullWidth
              multiline
              minRows={3}
              label="Observacoes"
              value={form.notes}
              onChange={(event) => setForm((current) => ({ ...current, notes: event.target.value }))}
            />
          </Grid>
        </Grid>
        <Alert severity="success">
          Resumo automatico: {validationIssues.length > 0 ? "preencha os campos para visualizar o resultado." : `vencedor da partida = Dupla ${inferWinnerTeam(buildMatchPayload(form).sets.filter((set) => set.isEnabled !== false))} | ${summarizeSets(buildMatchPayload(form).sets)}`}
        </Alert>
        <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
          <Button variant="contained" startIcon={<SaveRoundedIcon />} onClick={handleSave} fullWidth disabled={isSaving}>
            {form.id ? "Salvar alteracoes" : "Salvar partida"}
          </Button>
          {form.id && (
            <Button
              variant="outlined"
              color="inherit"
              onClick={() => {
                resetForm();
                setMessage(null);
                setError(null);
                onCancelEdit?.();
              }}
              fullWidth
            >
              Cancelar edicao
            </Button>
          )}
        </Stack>
      </Stack>
      <Snackbar
        open={successToastOpen}
        autoHideDuration={3500}
        onClose={(_, reason) => {
          if (reason === "clickaway") {
            return;
          }

          setSuccessToastOpen(false);
        }}
        anchorOrigin={{ vertical: "top", horizontal: "right" }}
      >
        <Alert
          severity="success"
          variant="filled"
          onClose={() => setSuccessToastOpen(false)}
          sx={{ width: "100%" }}
        >
          {message ?? "Partida salva com sucesso."}
        </Alert>
      </Snackbar>
    </Paper>
  );
}



