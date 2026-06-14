import { useQuery } from "@tanstack/react-query";
import { getRanking } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function useRanking(seasonId?: string) {
  return useQuery({
    queryKey: queryKeys.ranking(seasonId ?? "active"),
    queryFn: () => getRanking(seasonId)
  });
}
