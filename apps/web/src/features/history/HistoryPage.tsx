import { MenuItem, Stack, TextField } from "@mui/material";
import { useMemo, useState } from "react";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { MatchHistoryList } from "@/components/history/MatchHistoryList";
import { useMatches } from "@/hooks/useMatches";
import { usePlayers } from "@/hooks/usePlayers";

export function HistoryPage() {
  const { data: matches, isLoading: matchesLoading } = useMatches();
  const { data: players, isLoading: playersLoading } = usePlayers();
  const [selectedPlayerId, setSelectedPlayerId] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const safeMatches = matches ?? [];
  const safePlayers = players ?? [];

  const filteredMatches = useMemo(() => {
    return safeMatches.filter((match) => {
      const playerMatchesFilter = selectedPlayerId === ""
        || [
          match.teamAPlayer1Id,
          match.teamAPlayer2Id,
          match.teamBPlayer1Id,
          match.teamBPlayer2Id
        ].includes(selectedPlayerId);

      const dateMatchesFilter = (startDate === "" || match.matchDate >= startDate)
        && (endDate === "" || match.matchDate <= endDate);

      return playerMatchesFilter && dateMatchesFilter;
    });
  }, [endDate, safeMatches, selectedPlayerId, startDate]);

  if (matchesLoading || playersLoading || !matches || !players) {
    return <LoadingState />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        title="Histórico de partidas"
        subtitle={`Feed cronológico das partidas registradas. Exibindo ${filteredMatches.length} de ${matches.length} partidas.`}
      />
      <Stack direction={{ xs: "column", md: "row" }} spacing={2}>
        <TextField
          select
          label="Jogador"
          value={selectedPlayerId}
          onChange={(event) => setSelectedPlayerId(event.target.value)}
          fullWidth
        >
          <MenuItem value="">Todos os jogadores</MenuItem>
          {safePlayers.map((player) => (
            <MenuItem key={player.id} value={player.id}>
              {player.displayName}
            </MenuItem>
          ))}
        </TextField>
        <TextField
          label="Data inicial"
          type="date"
          value={startDate}
          onChange={(event) => setStartDate(event.target.value)}
          InputLabelProps={{ shrink: true }}
          fullWidth
        />
        <TextField
          label="Data final"
          type="date"
          value={endDate}
          onChange={(event) => setEndDate(event.target.value)}
          InputLabelProps={{ shrink: true }}
          fullWidth
        />
      </Stack>
      <MatchHistoryList matches={filteredMatches} players={safePlayers} />
    </Stack>
  );
}
