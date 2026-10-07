import domToImage from "dom-to-image-more";
import { jsPDF } from "jspdf/dist/jspdf.umd.min.js";
import type { Match, Player } from "@/types/domain";
import { formatDateOnlyBR, formatLongDateOnlyBR } from "@/utils/tennis";

export async function exportElementAsPng(element: HTMLElement, fileName: string) {
  const dataUrl = await domToImage.toPng(element, {
    bgcolor: "#f2f5ee",
    quality: 1,
    cacheBust: true
  });

  const link = document.createElement("a");
  link.download = `${fileName}.png`;
  link.href = dataUrl;
  link.click();
}

interface ExportPdfOptions {
  title: string;
  subtitle?: string;
}

async function imageUrlToDataUrl(url?: string | null): Promise<{ dataUrl: string; format: "PNG" | "JPEG" } | null> {
  if (!url) return null;

  try {
    const response = await fetch(url, { mode: "cors" });
    if (!response.ok) return null;
    const blob = await response.blob();
    return await new Promise<{ dataUrl: string; format: "PNG" | "JPEG" } | null>((resolve) => {
      const reader = new FileReader();
      reader.onload = () => {
        if (typeof reader.result !== "string") {
          resolve(null);
          return;
        }
        resolve({ dataUrl: reader.result, format: blob.type === "image/png" ? "PNG" : "JPEG" });
      };
      reader.onerror = () => resolve(null);
      reader.readAsDataURL(blob);
    });
  } catch {
    return null;
  }
}

function drawPlayer(pdf: jsPDF, player: Player | undefined, x: number, y: number, color: [number, number, number]) {
  const photo = (player as Player & { pdfPhoto?: { dataUrl: string; format: "PNG" | "JPEG" } | null } | undefined)?.pdfPhoto;
  if (photo) {
    pdf.addImage(photo.dataUrl, photo.format, x, y - 4.5, 9, 9, undefined, "FAST");
  } else {
    pdf.setFillColor(...color);
    pdf.circle(x + 4.5, y, 4.5, "F");
    pdf.setTextColor(255, 255, 255);
    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(8);
    pdf.text((player?.displayName?.[0] ?? "?").toUpperCase(), x + 4.5, y + 2.8, { align: "center" });
  }

  pdf.setTextColor(35, 48, 43);
  pdf.setFont("helvetica", "normal");
  pdf.setFontSize(13);
  pdf.text(player?.displayName ?? "Jogador", x + 12, y + 2.8);
}

export async function exportMatchesAsPdf(
  matches: Match[],
  players: Player[],
  options: { startDate?: string; endDate?: string }
) {
  const pdf = new jsPDF({ orientation: "portrait", unit: "mm", format: "a4" });
  const pageWidth = pdf.internal.pageSize.getWidth();
  const pageHeight = pdf.internal.pageSize.getHeight();
  const margin = 12;
  const playerById = new Map(players.map((player) => [player.id, player]));

  await Promise.all(players.map(async (player) => {
    const photo = await imageUrlToDataUrl(player.photoUrl);
    (player as Player & { pdfPhoto?: { dataUrl: string; format: "PNG" | "JPEG" } | null }).pdfPhoto = photo;
  }));

  const dateRange = options.startDate || options.endDate
    ? `${options.startDate ? formatLongDateOnlyBR(options.startDate) : "início"} até ${options.endDate ? formatLongDateOnlyBR(options.endDate) : "hoje"}`
    : "Todas as datas";

  const drawHeader = () => {
    pdf.setFillColor(10, 77, 60);
    pdf.rect(0, 0, pageWidth, 25, "F");
    pdf.setTextColor(255, 255, 255);
    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(20);
    pdf.text("Ranking Tennis", margin, 11);
    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(11);
    pdf.text("Extrato de partidas", margin, 18);
    pdf.text(dateRange, pageWidth - margin, 18, { align: "right" });
    pdf.setTextColor(35, 48, 43);
  };

  const drawFooter = () => {
    pdf.setDrawColor(220, 226, 221);
    pdf.line(margin, pageHeight - 12, pageWidth - margin, pageHeight - 12);
    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(10);
    pdf.setTextColor(105, 115, 109);
    pdf.text(`${matches.length} partida${matches.length === 1 ? "" : "s"}`, margin, pageHeight - 6);
    pdf.text(`Página ${pdf.getNumberOfPages()}`, pageWidth - margin, pageHeight - 6, { align: "right" });
  };

  const columns = [
    { label: "DATA / LOCAL", width: 30 },
    { label: "DUPLA A", width: 58 },
    { label: "DUPLA B", width: 58 },
    { label: "PLACAR", width: 40 }
  ];

  const drawTableHeader = () => {
    let x = margin;
    pdf.setFillColor(226, 236, 229);
    pdf.setDrawColor(190, 207, 197);
    pdf.rect(margin, 31, pageWidth - margin * 2, 9, "FD");
    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(8);
    pdf.setTextColor(10, 77, 60);
    columns.forEach((column) => {
      pdf.text(column.label, x + 3, 37);
      x += column.width;
      if (x < pageWidth - margin) pdf.line(x, 31, x, 40);
    });
  };

  const drawTablePlayer = (player: Player | undefined, x: number, y: number, color: [number, number, number]) => {
    const photo = (player as Player & { pdfPhoto?: { dataUrl: string; format: "PNG" | "JPEG" } | null } | undefined)?.pdfPhoto;
    if (photo) {
      pdf.addImage(photo.dataUrl, photo.format, x, y - 3.5, 6, 6, undefined, "FAST");
    } else {
      pdf.setFillColor(...color);
      pdf.circle(x + 3, y - 0.5, 3, "F");
      pdf.setTextColor(255, 255, 255);
      pdf.setFont("helvetica", "bold");
      pdf.setFontSize(5.5);
      pdf.text((player?.displayName?.[0] ?? "?").toUpperCase(), x + 3, y + 1.2, { align: "center" });
    }

    pdf.setTextColor(35, 48, 43);
    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(8.2);
    pdf.text(player?.displayName ?? "Jogador", x + 8, y + 1.2, { maxWidth: 47 });
  };

  drawHeader();
  drawTableHeader();
  let y = 40;
  if (matches.length === 0) {
    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(11);
    pdf.text("Nenhuma partida encontrada para este período.", margin, y + 12);
  }

  matches.forEach((match, index) => {
    const rowHeight = match.notes?.trim() ? 26 : 20;
    if (y + rowHeight > pageHeight - 17) {
      drawFooter();
      pdf.addPage();
      drawHeader();
      drawTableHeader();
      y = 40;
    }

    pdf.setFillColor(index % 2 === 0 ? 249 : 255, 251, index % 2 === 0 ? 249 : 255);
    pdf.setDrawColor(215, 225, 218);
    pdf.rect(margin, y, pageWidth - margin * 2, rowHeight, "FD");
    let columnX = margin;
    columns.slice(0, -1).forEach((column) => {
      columnX += column.width;
      pdf.line(columnX, y, columnX, y + rowHeight);
    });

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(8.5);
    pdf.setTextColor(10, 77, 60);
    pdf.text(formatDateOnlyBR(match.matchDate), margin + 3, y + 7);
    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(6.8);
    pdf.setTextColor(105, 115, 109);
    pdf.text(match.courtName?.trim() || "Local não informado", margin + 3, y + 14, { maxWidth: 25 });

    const teamAX = margin + columns[0].width + 3;
    const teamBX = margin + columns[0].width + columns[1].width + 3;
    const teamA = [match.teamAPlayer1Id, match.teamAPlayer2Id].map((id) => playerById.get(id));
    const teamB = [match.teamBPlayer1Id, match.teamBPlayer2Id].map((id) => playerById.get(id));
    drawTablePlayer(teamA[0], teamAX, y + 6, [10, 77, 60]);
    drawTablePlayer(teamA[1], teamAX, y + 14, [10, 77, 60]);
    drawTablePlayer(teamB[0], teamBX, y + 6, [154, 103, 0]);
    drawTablePlayer(teamB[1], teamBX, y + 14, [154, 103, 0]);

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(13);
    pdf.setTextColor(match.winnerTeam === "A" ? 10 : 154, match.winnerTeam === "A" ? 77 : 103, match.winnerTeam === "A" ? 60 : 0);
    pdf.text(match.resultSummary || "-", pageWidth - margin - 5, y + 9, { align: "right" });
    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(7.5);
    pdf.setTextColor(105, 115, 109);
    pdf.text(`Vencedor: dupla ${match.winnerTeam}`, pageWidth - margin - 5, y + 15, { align: "right" });
    if (match.notes?.trim()) {
      pdf.setFontSize(7);
      pdf.text(`Obs.: ${pdf.splitTextToSize(match.notes.trim(), pageWidth - margin * 2 - 8).slice(0, 1).join(" ")}`, margin + 3, y + rowHeight - 4);
    }
    y += rowHeight;
  });

  drawFooter();
  pdf.save(`extrato-partidas-ranking-tennis.pdf`);
}

export async function exportElementAsPdf(element: HTMLElement, fileName: string, options: ExportPdfOptions) {
  const dataUrl = await domToImage.toPng(element, {
    bgcolor: "#f2f5ee",
    quality: 1,
    cacheBust: true
  });

  const image = new Image();
  image.src = dataUrl;

  await new Promise<void>((resolve, reject) => {
    image.onload = () => resolve();
    image.onerror = () => reject(new Error("Nao foi possivel carregar a imagem para o PDF."));
  });

  const pdf = new jsPDF({
    orientation: "portrait",
    unit: "mm",
    format: "a4"
  });

  const pageWidth = pdf.internal.pageSize.getWidth();
  const pageHeight = pdf.internal.pageSize.getHeight();
  const margin = 10;
  const headerHeight = 20;
  const usableWidth = pageWidth - margin * 2;
  const usableHeight = pageHeight - margin * 2 - headerHeight;
  const imageHeight = (image.height * usableWidth) / image.width;
  const titleY = margin + 6;
  const subtitleY = margin + 13;

  pdf.setFont("helvetica", "bold");
  pdf.setFontSize(16);
  pdf.text(options.title, margin, titleY);

  pdf.setFont("helvetica", "normal");
  pdf.setFontSize(10);
  if (options.subtitle) {
    pdf.text(options.subtitle, margin, subtitleY);
  }

  if (imageHeight <= usableHeight) {
    pdf.addImage(dataUrl, "PNG", margin, margin + headerHeight, usableWidth, imageHeight, undefined, "FAST");
  } else {
    let renderedHeight = 0;
    let pageIndex = 0;

    while (renderedHeight < imageHeight) {
      if (pageIndex > 0) {
        pdf.addPage();
      }

      const remainingHeight = imageHeight - renderedHeight;
      const currentSliceHeight = Math.min(usableHeight, remainingHeight);
      const sourceY = (renderedHeight / imageHeight) * image.height;
      const sourceHeight = (currentSliceHeight / imageHeight) * image.height;
      const canvas = document.createElement("canvas");
      canvas.width = image.width;
      canvas.height = Math.ceil(sourceHeight);
      const context = canvas.getContext("2d");

      if (!context) {
        throw new Error("Nao foi possivel preparar o PDF.");
      }

      context.fillStyle = "#f2f5ee";
      context.fillRect(0, 0, canvas.width, canvas.height);
      context.drawImage(
        image,
        0,
        sourceY,
        image.width,
        sourceHeight,
        0,
        0,
        image.width,
        sourceHeight
      );

      pdf.addImage(canvas.toDataURL("image/png"), "PNG", margin, margin + headerHeight, usableWidth, currentSliceHeight, undefined, "FAST");

      renderedHeight += currentSliceHeight;
      pageIndex += 1;
    }
  }

  pdf.save(`${fileName}.pdf`);
}
