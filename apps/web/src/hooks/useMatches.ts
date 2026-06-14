import { useQuery } from "@tanstack/react-query";
import { getMatches, getRecentMatches } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function useMatches(seasonId?: string) {
  return useQuery({
    queryKey: queryKeys.history(seasonId ?? "active"),
    queryFn: getMatches
  });
}

export function useRecentMatches() {
  return useQuery({
    queryKey: queryKeys.recentMatches,
    queryFn: getRecentMatches
  });
}
