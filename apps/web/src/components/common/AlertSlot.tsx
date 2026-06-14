import { Alert, Box } from "@mui/material";

interface AlertSlotProps {
  severity: "success" | "info" | "warning" | "error";
  message?: string | null;
  minHeight?: number;
}

export function AlertSlot({ severity, message, minHeight = 72 }: AlertSlotProps) {
  return (
    <Box sx={{ minHeight, display: "flex", alignItems: "stretch" }}>
      {message ? (
        <Alert severity={severity} sx={{ width: "100%" }}>
          {message}
        </Alert>
      ) : (
        <Box sx={{ width: "100%" }} />
      )}
    </Box>
  );
}
