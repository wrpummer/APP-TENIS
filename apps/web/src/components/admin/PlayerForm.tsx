import CloudUploadRoundedIcon from "@mui/icons-material/CloudUploadRounded";
import PersonAddAltRoundedIcon from "@mui/icons-material/PersonAddAltRounded";
import PhotoCameraRoundedIcon from "@mui/icons-material/PhotoCameraRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import { Alert, Avatar, Box, Button, MenuItem, Paper, Stack, TextField, Typography } from "@mui/material";
import { useEffect, useRef, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { AlertSlot } from "@/components/common/AlertSlot";
import { savePlayer, uploadPlayerPhoto } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Player } from "@/types/domain";

interface PlayerFormProps {
  editingPlayer?: Player | null;
  onSaved?: () => void;
  onCancelEdit?: () => void;
}

function toDateInput(value?: string | null) {
  return value ? value.slice(0, 10) : "";
}

export function PlayerForm({ editingPlayer, onSaved, onCancelEdit }: PlayerFormProps) {
  const queryClient = useQueryClient();
  const cameraInputRef = useRef<HTMLInputElement | null>(null);
  const uploadInputRef = useRef<HTMLInputElement | null>(null);
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");
  const [status, setStatus] = useState("");
  const [registeredAt, setRegisteredAt] = useState("");
  const [photoUrl, setPhotoUrl] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (!editingPlayer) {
      setFullName("");
      setPhone("");
      setStatus("");
      setRegisteredAt("");
      setPhotoUrl(null);
      return;
    }

    setFullName(editingPlayer.fullName);
    setPhone(editingPlayer.phone ?? "");
    setStatus(editingPlayer.status);
    setRegisteredAt(toDateInput(editingPlayer.registeredAt));
    setPhotoUrl(editingPlayer.photoUrl ?? null);
  }, [editingPlayer]);

  async function handlePhotoSelected(file: File | null) {
    if (!file) {
      return;
    }

    if (!file.type.startsWith("image/")) {
      setError("Selecione uma imagem valida.");
      return;
    }

    if (file.size > 1024 * 1024) {
      setError("A foto deve ter no maximo 1 MB para caber no plano gratuito.");
      return;
    }

    if (!fullName.trim()) {
      setError("Informe o nome do jogador antes de enviar a foto.");
      return;
    }

    try {
      const publicUrl = await uploadPlayerPhoto(file, fullName.trim());
      setPhotoUrl(publicUrl);
      setError(null);
      setMessage("Foto carregada com sucesso.");
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : "Nao foi possivel enviar a foto.");
    }
  }

  async function handleSubmit() {
    if (!fullName.trim()) {
      setError("Informe o nome do jogador.");
      return;
    }

    if (!registeredAt) {
      setError("Informe a data em 'Jogador desde'.");
      return;
    }

    if (!status) {
      setError("Selecione o status do jogador.");
      return;
    }

    try {
      setIsSaving(true);
      await savePlayer({
        id: editingPlayer?.id,
        fullName: fullName.trim(),
        displayName: fullName.trim(),
        phone: phone.trim(),
        photoUrl,
        registeredAt: new Date(`${registeredAt}T00:00:00`).toISOString(),
        status: status as "active" | "inactive"
      });

      await queryClient.invalidateQueries({ queryKey: queryKeys.players });
      setError(null);
      setMessage(editingPlayer ? "Jogador atualizado com sucesso." : "Jogador salvo com sucesso.");
      setFullName("");
      setPhone("");
      setStatus("");
      setRegisteredAt("");
      setPhotoUrl(null);
      if (cameraInputRef.current) {
        cameraInputRef.current.value = "";
      }
      if (uploadInputRef.current) {
        uploadInputRef.current.value = "";
      }
      onSaved?.();
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : "Nao foi possivel salvar o jogador.");
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)" }}>
      <Stack spacing={2}>
        <Typography variant="h6">{editingPlayer ? "Editar jogador" : "Cadastrar jogador"}</Typography>
        <AlertSlot
          severity={error ? "error" : "success"}
          message={error ?? message}
          minHeight={88}
        />
        <TextField label="Nome completo" value={fullName} onChange={(event) => setFullName(event.target.value)} />
        <TextField label="Telefone" value={phone} onChange={(event) => setPhone(event.target.value)} />
        <TextField
          label="Jogador desde"
          type="date"
          value={registeredAt}
          onChange={(event) => setRegisteredAt(event.target.value)}
          InputLabelProps={{ shrink: true }}
        />
        <TextField select label="Status" value={status} onChange={(event) => setStatus(event.target.value)}>
          <MenuItem value="">Selecione</MenuItem>
          <MenuItem value="active">Ativo</MenuItem>
          <MenuItem value="inactive">Inativo</MenuItem>
        </TextField>

        <Stack spacing={1}>
          <Typography variant="subtitle2">Foto do jogador</Typography>
          <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
            <Avatar src={photoUrl ?? undefined} sx={{ width: 72, height: 72 }}>
              {fullName.trim().slice(0, 1).toUpperCase() || "?"}
            </Avatar>
            <Box>
              <Stack direction={{ xs: "column", sm: "row" }} spacing={1} flexWrap="wrap">
                <Button
                  variant="outlined"
                  startIcon={<PhotoCameraRoundedIcon />}
                  onClick={() => cameraInputRef.current?.click()}
                >
                  Tirar foto
                </Button>
                <Button
                  variant="outlined"
                  startIcon={<CloudUploadRoundedIcon />}
                  onClick={() => uploadInputRef.current?.click()}
                >
                  Enviar foto
                </Button>
              </Stack>
              <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
                No celular, `Tirar foto` abre a camera. Limite: 1 MB.
              </Typography>
            </Box>
          </Stack>
          <input
            ref={cameraInputRef}
            hidden
            type="file"
            accept="image/*"
            capture="environment"
            onChange={(event) => void handlePhotoSelected(event.target.files?.[0] ?? null)}
          />
          <input
            ref={uploadInputRef}
            hidden
            type="file"
            accept="image/*"
            onChange={(event) => void handlePhotoSelected(event.target.files?.[0] ?? null)}
          />
        </Stack>

        <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
          <Button
            variant="contained"
            startIcon={editingPlayer ? <EditRoundedIcon /> : <PersonAddAltRoundedIcon />}
            onClick={handleSubmit}
            disabled={isSaving}
            fullWidth
          >
            {editingPlayer ? "Salvar alteracoes" : "Salvar jogador"}
          </Button>
          {editingPlayer && (
            <Button variant="outlined" color="inherit" onClick={onCancelEdit} fullWidth>
              Cancelar edicao
            </Button>
          )}
        </Stack>
      </Stack>
    </Paper>
  );
}
