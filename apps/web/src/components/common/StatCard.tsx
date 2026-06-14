import { Paper, Stack, Typography } from "@mui/material";

interface StatCardProps {
  label: string;
  value: string;
  detail: string;
}

export function StatCard({ label, value, detail }: StatCardProps) {
  return (
    <Paper
      sx={{
        p: 3,
        border: "1px solid rgba(10,77,60,0.08)",
        background: "linear-gradient(160deg, rgba(255,255,255,0.95), rgba(225,239,228,0.95))"
      }}
    >
      <Stack gap={1}>
        <Typography variant="body2" color="text.secondary">
          {label}
        </Typography>
        <Typography variant="h3">{value}</Typography>
        <Typography variant="body2" color="text.secondary">
          {detail}
        </Typography>
      </Stack>
    </Paper>
  );
}
