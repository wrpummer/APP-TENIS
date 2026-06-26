import CloudUploadRoundedIcon from "@mui/icons-material/CloudUploadRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import PersonAddAltRoundedIcon from "@mui/icons-material/PersonAddAltRounded";
import PhotoCameraRoundedIcon from "@mui/icons-material/PhotoCameraRounded";
import { Avatar, Box, Button, MenuItem, Paper, Stack, TextField, Typography } from "@mui/material";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useRef, useState } from "react";
import { AlertSlot } from "@/components/common/AlertSlot";
import { savePlayer, uploadPlayerPhoto } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";
import type { Player } from "@/types/domain";

interface PlayerFormProps {
  editingPlayer?: Player | null;
  onSaved?: () => void;
  onCancelEdit?: () => void;
}

const PHOTO_TARGET_BYTES = 850 * 1024;

function toDateInput(value?: string | null) {
  return value ? value.slice(0, 10) : "";
}

async function compressImageFile(file: File, maxBytes: number) {
  if (file.size <= maxBytes) {
    return file;
  }

  const imageUrl = URL.createObjectURL(file);

  try {
    const image = await new Promise<HTMLImageElement>((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error("Não foi possível carregar a foto selecionada."));
      img.src = imageUrl;
    });

    const canvas = document.createElement("canvas");
    const context = canvas.getContext("2d");
    if (!context) {
      throw new Error("Não foi possível preparar a foto para envio.");
    }

    const maxDimension = 1600;
    const scale = Math.min(1, maxDimension / Math.max(image.width, image.height));
    canvas.width = Math.max(1, Math.round(image.width * scale));
    canvas.height = Math.max(1, Math.round(image.height * scale));
    context.drawImage(image, 0, 0, canvas.width, canvas.height);

    for (const quality of [0.82, 0.72, 0.62, 0.5, 0.4, 0.32, 0.24]) {
      const blob = await new Promise<Blob | null>((resolve) => {
        canvas.toBlob(resolve, "image/jpeg", quality);
      });

      if (blob && blob.size <= maxBytes) {
        return new File([blob], `${file.name.replace(/\.[^.]+$/, "") || "foto-jogador"}.jpg`, {
          type: "image/jpeg"
        });
      }
    }

    throw new Error("A foto ficou grande demais mesmo após redução. Tente uma imagem mais leve.");
  } finally {
    URL.revokeObjectURL(imageUrl);
  }
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
  const [isUploadingPhoto, setIsUploadingPhoto] = useState(false);

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
      setError("Selecione uma imagem válida.");
      return;
    }

    if (!fullName.trim()) {
      setError("Informe o nome do jogador antes de enviar a foto.");
      return;
    }

    try {
      setIsUploadingPhoto(true);
      setError(null);
      setMessage(file.size > PHOTO_TARGET_BYTES ? "Reduzindo a foto para caber no limite gratuito..." : "Enviando foto...");
      const processedFile = await compressImageFile(file, PHOTO_TARGET_BYTES);
      const publicUrl = await uploadPlayerPhoto(processedFile, fullName.trim());
      setPhotoUrl(publicUrl);
      setMessage("Foto carregada com sucesso.");
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : "Não foi possível enviar a foto.");
      setMessage(null);
    } finally {
      setIsUploadingPhoto(false);
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
        registeredAt: `${registeredAt}T12:00:00.000Z`,
        status: status as "active" | "inactive"
      });

      await Promise.all([
        queryClient.invalidateQueries({ queryKey: queryKeys.players }),
        queryClient.invalidateQueries({ queryKey: queryKeys.dashboard }),
        queryClient.invalidateQueries({ queryKey: ["player-statistics"] }),
        queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "ranking" }),
        queryClient.invalidateQueries({ predicate: (query) => Array.isArray(query.queryKey) && query.queryKey[0] === "hall-of-fame" })
      ]);

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
      setError(caughtError instanceof Error ? caughtError.message : "Não foi possível salvar o jogador.");
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)" }}>
      <Stack spacing={2}>
        <Typography variant="h6">{editingPlayer ? "Editar jogador" : "Cadastrar jogador"}</Typography>
        <AlertSlot severity={error ? "error" : "success"} message={error ?? message} minHeight={88} />

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
                  disabled={isUploadingPhoto || isSaving}
                >
                  Tirar foto
                </Button>
                <Button
                  variant="outlined"
                  startIcon={<CloudUploadRoundedIcon />}
                  onClick={() => uploadInputRef.current?.click()}
                  disabled={isUploadingPhoto || isSaving}
                >
                  Enviar foto
                </Button>
              </Stack>
              <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
                No celular, `Tirar foto` abre a câmera. Se a imagem vier grande, o sistema reduz antes do envio.
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
            disabled={isSaving || isUploadingPhoto}
            fullWidth
          >
            {editingPlayer ? "Salvar alterações" : "Salvar jogador"}
          </Button>

          {editingPlayer && (
            <Button variant="outlined" color="inherit" onClick={onCancelEdit} disabled={isSaving || isUploadingPhoto} fullWidth>
              Cancelar edição
            </Button>
          )}
        </Stack>
      </Stack>
    </Paper>
  );
}
