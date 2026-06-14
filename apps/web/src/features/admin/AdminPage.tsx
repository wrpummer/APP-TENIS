import { Grid, Stack } from "@mui/material";
import { useState } from "react";
import { MatchForm } from "@/components/admin/MatchForm";
import { AdminLoginCard } from "@/components/admin/AdminLoginCard";
import { PlayerForm } from "@/components/admin/PlayerForm";
import { PlayersAdminTable } from "@/components/admin/PlayersAdminTable";
import { RecentMatchesAdminTable } from "@/components/admin/RecentMatchesAdminTable";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { useRecentMatches } from "@/hooks/useMatches";
import { usePlayers } from "@/hooks/usePlayers";
import { useDashboardData } from "@/hooks/useDashboardData";
import { useAdminSeasons } from "@/hooks/useSeasons";
import type { Match, Player } from "@/types/domain";

export function AdminPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [editingPlayer, setEditingPlayer] = useState<Player | null>(null);
  const [editingMatch, setEditingMatch] = useState<Match | null>(null);
  const { data: players, isLoading: playersLoading } = usePlayers();
  const { data: dashboard, isLoading: dashboardLoading } = useDashboardData();
  const { data: recentMatches, isLoading: recentMatchesLoading } = useRecentMatches();
  const { data: seasons, isLoading: seasonsLoading } = useAdminSeasons();

  if (!authenticated) {
    return <AdminLoginCard onAuthenticated={() => setAuthenticated(true)} />;
  }

  if (playersLoading || dashboardLoading || recentMatchesLoading || seasonsLoading || !players || !dashboard || !recentMatches || !seasons) {
    return <LoadingState />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Painel administrativo"
        subtitle="Cadastre jogadores, registre partidas e mantenha o ranking sincronizado com a temporada."
      />
      <Grid container spacing={2}>
        <Grid size={{ xs: 12, lg: 4 }}>
          <PlayerForm
            editingPlayer={editingPlayer}
            onSaved={() => setEditingPlayer(null)}
            onCancelEdit={() => setEditingPlayer(null)}
          />
        </Grid>
        <Grid size={{ xs: 12, lg: 8 }}>
          <MatchForm
            players={players}
            seasons={seasons}
            editingMatch={editingMatch}
            onSaved={() => setEditingMatch(null)}
            onCancelEdit={() => setEditingMatch(null)}
          />
        </Grid>
        <Grid size={{ xs: 12 }}>
          <PlayersAdminTable players={players} onEditPlayer={(player) => setEditingPlayer(player)} />
        </Grid>
        <Grid size={{ xs: 12 }}>
          <RecentMatchesAdminTable matches={recentMatches} players={players} onEditMatch={(match) => setEditingMatch(match)} />
        </Grid>
      </Grid>
    </Stack>
  );
}
