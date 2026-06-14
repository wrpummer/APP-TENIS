import { useQuery } from "@tanstack/react-query";
import { getPlayerStatistics, getPlayers } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function usePlayers() {
  return useQuery({
    queryKey: queryKeys.players,
    queryFn: getPlayers
  });
}

export function usePlayerStatistics() {
  return useQuery({
    queryKey: ["player-statistics"],
    queryFn: getPlayerStatistics
  });
}
