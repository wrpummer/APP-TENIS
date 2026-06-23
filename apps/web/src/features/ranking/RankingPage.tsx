import PictureAsPdfRoundedIcon from "@mui/icons-material/PictureAsPdfRounded";
import { Box, Button, Stack } from "@mui/material";
import { useState } from "react";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { RankingTable } from "@/components/ranking/RankingTable";
import { useRanking } from "@/hooks/useRanking";
import { exportElementAsPdf } from "@/utils/share";

export function RankingPage() {
  const { data, isLoading } = useRanking();
  const [isExporting, setIsExporting] = useState(false);

  if (isLoading || !data) {
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
        subtitle: "Classificação geral da temporada"
      });
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Ranking geral"
        subtitle="Classificação atual com pontos por set: 3 pontos para cada set vencido e 1 ponto para cada set perdido."
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
      <Box id="ranking-pdf-export">
        <RankingTable rows={data} />
      </Box>
    </Stack>
  );
}
