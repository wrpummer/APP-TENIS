import path from "node:path";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { VitePWA } from "vite-plugin-pwa";
export default defineConfig({
    root: path.resolve(__dirname),
    envDir: path.resolve(__dirname, "../.."),
    plugins: [
        react(),
        VitePWA({
            registerType: "autoUpdate",
            includeAssets: ["app-icon-180.png", "app-icon-192.png", "app-icon-512.png"],
            workbox: {
                maximumFileSizeToCacheInBytes: 3 * 1024 * 1024
            },
            manifest: {
                name: "Ranking Tennis",
                short_name: "Ranking Tennis",
                description: "Aplicativo de ranking de tênis de duplas.",
                theme_color: "#0a4d3c",
                background_color: "#f2f5ee",
                display: "standalone",
                start_url: "/",
                scope: "/",
                lang: "pt-BR",
                icons: [
                    {
                        src: "/app-icon-192.png",
                        sizes: "192x192",
                        type: "image/png",
                        purpose: "any"
                    },
                    {
                        src: "/app-icon-512.png",
                        sizes: "512x512",
                        type: "image/png",
                        purpose: "any"
                    },
                    {
                        src: "/app-icon-512.png",
                        sizes: "512x512",
                        type: "image/png",
                        purpose: "maskable"
                    }
                ]
            }
        })
    ],
    resolve: {
        alias: {
            "@": path.resolve(__dirname, "src")
        }
    },
    server: {
        host: "0.0.0.0",
        port: 4173
    },
    build: {
        outDir: "dist",
        emptyOutDir: true
    }
});
