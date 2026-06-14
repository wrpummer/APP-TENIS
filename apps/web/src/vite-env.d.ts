/// <reference types="vite/client" />

declare module "jspdf/dist/jspdf.umd.min.js" {
  export { jsPDF } from "jspdf";
}

declare module "virtual:pwa-register" {
  export function registerSW(options?: {
    immediate?: boolean;
    onNeedRefresh?: () => void;
    onOfflineReady?: () => void;
  }): (reloadPage?: boolean) => Promise<void>;
}
