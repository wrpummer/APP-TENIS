import { useQuery } from "@tanstack/react-query";
import { getFunnyStories } from "@/services/api";
import { queryKeys } from "@/services/queryKeys";

export function useFunnyStories() {
  return useQuery({
    queryKey: queryKeys.funnyStories,
    queryFn: getFunnyStories
  });
}
