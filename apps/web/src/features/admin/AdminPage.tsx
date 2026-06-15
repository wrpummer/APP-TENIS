import { Grid, Stack } from "@mui/material";
import { useEffect, useRef, useState } from "react";
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
  const playerFormRef = useRef<HTMLDivElement | null>(null);
  const matchFormRef = useRef<HTMLDivElement | null>(null);
  const { data: players, isLoading: playersLoading } = usePlayers();
  const { data: dashboard, isLoading: dashboardLoading } = useDashboardData();
  const { data: recentMatches, isLoading: recentMatchesLoading } = useRecentMatches();
  const { data: seasons, isLoading: seasonsLoading } = useAdminSeasons();

  function scrollToEditor(target: HTMLDivElement | null) {
    if (!target) {
      return;
    }

    const top = target.getBoundingClientRect().top + window.scrollY - 88;
    window.scrollTo({
      top: Math.max(top, 0),
      behavior: "smooth"
    });
  }

  function handleEditPlayer(player: Player) {
    setEditingPlayer(player);
    requestAnimationFrame(() => {
      scrollToEditor(playerFormRef.current);
    });
  }

  function handleEditMatch(match: Match) {
    setEditingMatch(match);
    requestAnimationFrame(() => {
      scrollToEditor(matchFormRef.current);
    });
  }

  useEffect(() => {
    if (!editingPlayer) {
      return;
    }

    scrollToEditor(playerFormRef.current);
  }, [editingPlayer]);

  useEffect(() => {
    if (!editingMatch) {
      return;
    }

    scrollToEditor(matchFormRef.current);
  }, [editingMatch]);

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
          <div ref={playerFormRef}>
            <PlayerForm
              editingPlayer={editingPlayer}
              onSaved={() => setEditingPlayer(null)}
              onCancelEdit={() => setEditingPlayer(null)}
            />
          </div>
        </Grid>
        <Grid size={{ xs: 12, lg: 8 }}>
          <div ref={matchFormRef}>
            <MatchForm
              players={players}
              seasons={seasons}
              editingMatch={editingMatch}
              onSaved={() => setEditingMatch(null)}
              onCancelEdit={() => setEditingMatch(null)}
            />
          </div>
        </Grid>
        <Grid size={{ xs: 12 }}>
          <PlayersAdminTable players={players} onEditPlayer={handleEditPlayer} />
        </Grid>
        <Grid size={{ xs: 12 }}>
          <RecentMatchesAdminTable matches={recentMatches} players={players} onEditMatch={handleEditMatch} />
        </Grid>
      </Grid>
    </Stack>
  );
}
