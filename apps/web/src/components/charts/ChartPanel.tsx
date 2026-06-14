import { Paper, Typography } from "@mui/material";
import type { ReactNode } from "react";

interface ChartPanelProps {
  title: string;
  children: ReactNode;
}

export function ChartPanel({ title, children }: ChartPanelProps) {
  return (
    <Paper sx={{ p: 3, height: 380, border: "1px solid rgba(10,77,60,0.08)" }}>
      <Typography variant="h6" mb={2}>
        {title}
      </Typography>
      {children}
    </Paper>
  );
}
