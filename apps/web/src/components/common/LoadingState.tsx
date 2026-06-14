import { Box, CircularProgress, Typography } from "@mui/material";

export function LoadingState() {
  return (
    <Box display="grid" gap={2} justifyItems="center" py={8}>
      <CircularProgress color="primary" />
      <Typography color="text.secondary">Carregando ranking e estatísticas...</Typography>
    </Box>
  );
}
