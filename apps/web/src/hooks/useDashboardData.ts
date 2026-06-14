import { useQuery } from "@tanstack/react-query";
import { getDashboard } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function useDashboardData() {
  return useQuery({
    queryKey: queryKeys.dashboard,
    queryFn: getDashboard
  });
}
