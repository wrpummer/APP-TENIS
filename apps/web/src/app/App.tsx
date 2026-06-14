import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { AppShell } from "@/components/layout/AppShell";
import { AdminPage } from "@/features/admin/AdminPage";
import { DashboardPage } from "@/features/dashboard/DashboardPage";
import { HallOfFamePage } from "@/features/hall-of-fame/HallOfFamePage";
import { HistoryPage } from "@/features/history/HistoryPage";
import { HeadToHeadPage } from "@/features/head-to-head/HeadToHeadPage";
import { PlayersPage } from "@/features/players/PlayersPage";
import { RankingPage } from "@/features/ranking/RankingPage";

const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [
      { index: true, element: <DashboardPage /> },
      { path: "ranking", element: <RankingPage /> },
      { path: "jogadores", element: <PlayersPage /> },
      { path: "historico", element: <HistoryPage /> },
      { path: "hall-da-fama", element: <HallOfFamePage /> },
      { path: "confronto-direto", element: <HeadToHeadPage /> },
      { path: "admin", element: <AdminPage /> }
    ]
  }
]);

export function App() {
  return <RouterProvider router={router} />;
}
