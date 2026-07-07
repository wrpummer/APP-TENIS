import PictureAsPdfRoundedIcon from "@mui/icons-material/PictureAsPdfRounded";
import { Alert, Box, Button, Grid, MenuItem, Paper, Stack, TextField, Typography } from "@mui/material";
import { useState } from "react";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { RankingTable } from "@/components/ranking/RankingTable";
import { useRanking } from "@/hooks/useRanking";
import { useSeasons } from "@/hooks/useSeasons";
import { exportElementAsPdf } from "@/utils/share";
import { monthLabels } from "@/utils/tennis";

export function RankingPage() {
  const currentYear = new Date().getFullYear();
  const [selectedYear, setSelectedYear] = useState(currentYear);
  const [selectedMonth, setSelectedMonth] = useState(0);
  const [isExporting, setIsExporting] = useState(false);
  const { data: seasons, isLoading: seasonsLoading } = useSeasons();
  const orderedSeasons = [...(seasons ?? [])].sort((a, b) => b.year - a.year);
  const selectedSeason = orderedSeasons.find((season) => season.year === selectedYear) ?? orderedSeasons[0];
  const { data, isLoading } = useRanking(selectedSeason?.id, selectedMonth || undefined);
  const periodLabel = selectedMonth
    ? `${monthLabels[selectedMonth - 1]} de ${selectedSeason?.year ?? selectedYear}`
    : `Ano inteiro de ${selectedSeason?.year ?? selectedYear}`;

  if (isLoading || seasonsLoading || !data || !seasons) {
    return <LoadingState />;
  }

  const handleExportPdf = async () => {
    const element = document.getElementById("ranking-pdf-export");
    if (!element) {
      return;
    }

    try {
      setIsExporting(true);
      await exportElementAsPdf(element, "ranking-tennis", {
        title: "Ranking Tennis",
        subtitle: `Classificação - ${periodLabel}`
      });
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Ranking geral"
        subtitle="Classificação atual: 3 pontos por vitória e 1 ponto por derrota em cada partida."
        action={
          <Button
            variant="contained"
            startIcon={<PictureAsPdfRoundedIcon />}
            onClick={handleExportPdf}
            disabled={isExporting}
          >
            {isExporting ? "Gerando PDF..." : "Baixar PDF"}
          </Button>
        }
      />
      <Paper sx={{ p: 2, borderRadius: 4, border: "1px solid rgba(10,77,60,0.1)" }}>
        <Stack spacing={1.5}>
          <Box>
            <Typography fontWeight={850}>Filtrar classificação</Typography>
            <Typography variant="body2" color="text.secondary">Escolha o ano e o mês para recalcular as posições.</Typography>
          </Box>
          <Grid container spacing={2}>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                select
                label="Ano"
                value={selectedSeason?.year ?? selectedYear}
                onChange={(event) => setSelectedYear(Number(event.target.value))}
                fullWidth
              >
                {orderedSeasons.map((season) => (
                  <MenuItem key={season.id} value={season.year}>{season.year}</MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                select
                label="Mês"
                value={selectedMonth}
                onChange={(event) => setSelectedMonth(Number(event.target.value))}
                fullWidth
              >
                <MenuItem value={0}>Ano inteiro</MenuItem>
                {monthLabels.map((month, index) => (
                  <MenuItem key={month} value={index + 1}>{month}</MenuItem>
                ))}
              </TextField>
            </Grid>
          </Grid>
        </Stack>
      </Paper>
      <Box id="ranking-pdf-export">
        <Typography variant="h6" mb={2}>{periodLabel}</Typography>
        {data.length > 0 ? (
          <RankingTable rows={data} />
        ) : (
          <Alert severity="info">Não há partidas registradas neste período.</Alert>
        )}
      </Box>
    </Stack>
  );
}
