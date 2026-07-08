import { Chip, Stack, Typography } from "@mui/material";
import type { Match } from "@/types/domain";

const teamAColor = "#0a4d3c";
const teamBColor = "#9a6700";

interface ColoredScoreProps {
  match: Match;
  size?: "small" | "medium";
}

export function ColoredScore({ match, size = "medium" }: ColoredScoreProps) {
  const fontSize = size === "small" ? "0.875rem" : "1rem";

  return (
    <Stack direction="row" spacing={0.75} alignItems="center" flexWrap="wrap" useFlexGap>
      {match.sets.map((set, index) => (
        <Stack key={set.id ?? `${match.id}-${set.setOrder}`} direction="row" spacing={0.35} alignItems="center">
          {index > 0 && <Typography color="text.secondary" sx={{ mx: 0.25 }}>/</Typography>}
          <Typography component="span" fontWeight={850} color={teamAColor} sx={{ fontSize }}>
            {set.teamAGames}
          </Typography>
          <Typography component="span" color="text.secondary" sx={{ fontSize }}>
            -
          </Typography>
          <Typography component="span" fontWeight={850} color={teamBColor} sx={{ fontSize }}>
            {set.teamBGames}
          </Typography>
          {set.isTiebreak && set.tiebreakPointsA != null && set.tiebreakPointsB != null && (
            <Typography component="span" color="text.secondary" sx={{ fontSize: size === "small" ? "0.75rem" : "0.82rem" }}>
              ({set.tiebreakPointsA}-{set.tiebreakPointsB} TB)
            </Typography>
          )}
        </Stack>
      ))}
      {match.isWalkover && match.walkoverTeam && (
        <Chip size="small" color="error" variant="outlined" label={`W.O. Dupla ${match.walkoverTeam}`} sx={{ fontWeight: 800 }} />
      )}
    </Stack>
  );
}
