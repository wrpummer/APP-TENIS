import { useQuery } from "@tanstack/react-query";
import { ensureSeasonsRange, getSeasons } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function useSeasons() {
  return useQuery({
    queryKey: queryKeys.seasons,
    queryFn: getSeasons
  });
}

export function useAdminSeasons() {
  return useQuery({
    queryKey: [...queryKeys.seasons, "admin-range-2026-2036"],
    queryFn: () => ensureSeasonsRange(2026, 2036)
  });
}
