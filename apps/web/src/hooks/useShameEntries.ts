import { useQuery } from "@tanstack/react-query";
import { getShameEntries } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function useShameEntries() {
  return useQuery({
    queryKey: queryKeys.shame,
    queryFn: getShameEntries
  });
}
