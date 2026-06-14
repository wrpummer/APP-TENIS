import LoginRoundedIcon from "@mui/icons-material/LoginRounded";
import { Alert, Button, Paper, Stack, TextField, Typography } from "@mui/material";
import { useState } from "react";
import { loginAdmin } from "@/services/api";

interface AdminLoginCardProps {
  onAuthenticated: () => void;
}

export function AdminLoginCard({ onAuthenticated }: AdminLoginCardProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit() {
    try {
      const result = await loginAdmin({ email, password });
      if (!result.ok) {
        setError(result.message ?? "Credenciais inválidas.");
        return;
      }

      setError(null);
      onAuthenticated();
    } catch (caughtError) {
      const message = caughtError instanceof Error ? caughtError.message : "Falha inesperada ao validar o acesso administrativo.";
      setError(message);
    }
  }

  return (
    <Paper sx={{ p: 4, maxWidth: 460, mx: "auto", border: "1px solid rgba(10,77,60,0.08)" }}>
      <Stack spacing={2}>
        <Typography variant="h4">Área administrativa</Typography>
        <Typography color="text.secondary">
          Use o mesmo e-mail e senha cadastrados em Authentication no Supabase para registrar partidas, atualizar jogadores e ajustar configurações.
        </Typography>
        {error && <Alert severity="error">{error}</Alert>}
        <TextField
          label="E-mail"
          placeholder="seu-email@exemplo.com"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          helperText="Digite o e-mail real criado no Supabase Auth."
        />
        <TextField label="Senha" type="password" value={password} onChange={(event) => setPassword(event.target.value)} />
        <Alert severity="info">
          Se a senha não entrar, redefina ou altere a senha do usuário diretamente no painel do Supabase em Authentication.
        </Alert>
        <Button variant="contained" startIcon={<LoginRoundedIcon />} onClick={handleSubmit}>
          Entrar
        </Button>
      </Stack>
    </Paper>
  );
}
