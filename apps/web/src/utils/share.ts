import domToImage from "dom-to-image-more";
import { jsPDF } from "jspdf/dist/jspdf.umd.min.js";

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
