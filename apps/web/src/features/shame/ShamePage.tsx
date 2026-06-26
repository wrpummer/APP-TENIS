import CalendarMonthRoundedIcon from "@mui/icons-material/CalendarMonthRounded";
import LocationOnRoundedIcon from "@mui/icons-material/LocationOnRounded";
import WarningAmberRoundedIcon from "@mui/icons-material/WarningAmberRounded";
import { Alert, Avatar, Box, Chip, Grid, Paper, Stack, Typography } from "@mui/material";
import { LoadingState } from "@/components/common/LoadingState";
import { useShameEntries } from "@/hooks/useShameEntries";
import type { ShameEntry } from "@/types/domain";
import { formatDateOnlyBR } from "@/utils/tennis";

interface PlayerShameGroup {
  playerId: string;
  playerName: string;
  photoUrl?: string | null;
  absences: ShameEntry[];
}

function groupAbsences(entries: ShameEntry[]) {
  const groups = new Map<string, PlayerShameGroup>();

  for (const entry of entries) {
    const group = groups.get(entry.playerId) ?? {
      playerId: entry.playerId,
      playerName: entry.playerName,
      photoUrl: entry.photoUrl,
      absences: []
    };
    group.absences.push(entry);
    groups.set(entry.playerId, group);
  }

  return Array.from(groups.values()).sort((a, b) =>
    b.absences.length - a.absences.length
    || b.absences[0].matchDate.localeCompare(a.absences[0].matchDate)
    || a.playerName.localeCompare(b.playerName)
  );
}

function getInitials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase();
}

export function ShamePage() {
  const { data: entries = [], isLoading, error } = useShameEntries();

  if (isLoading) {
    return <LoadingState />;
  }

  const groups = groupAbsences(entries);

  return (
    <Stack spacing={3}>
      <Paper
        sx={{
          overflow: "hidden",
          borderRadius: 5,
          color: "#fff8df",
          background: "linear-gradient(120deg, #24113f 0%, #53153d 52%, #9d251f 100%)",
          boxShadow: "0 24px 70px rgba(76, 20, 48, 0.24)"
        }}
      >
        <Grid container alignItems="stretch">
          <Grid size={{ xs: 12, md: 7 }}>
            <Stack spacing={2} sx={{ p: { xs: 3, sm: 4, md: 5 } }}>
              <Chip
                icon={<WarningAmberRoundedIcon />}
                label="Cantinho da vergonha"
                sx={{ alignSelf: "flex-start", bgcolor: "#ffd447", color: "#3a173d", fontWeight: 900 }}
              />
              <Typography variant="h2" sx={{ fontSize: { xs: "2.4rem", md: "4rem" }, lineHeight: 0.95 }}>
                Dick Vigarista
              </Typography>
              <Typography variant="h6" sx={{ color: "rgba(255,248,223,0.82)", maxWidth: 650 }}>
                Confirmou, sumiu e deixou a dupla procurando até agora? O radar dos furões não perdoa.
              </Typography>
              <Typography variant="body2" sx={{ color: "rgba(255,248,223,0.72)" }}>
                Só aparece aqui quem foi marcado como “Faltou” pelo administrador. Ausências justificadas ficam fora da brincadeira.
              </Typography>
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 5 }}>
            <Box
              component="img"
              src="/dick-vigarista.jpg"
              alt="Dick Vigarista"
              sx={{ width: "100%", height: { xs: 260, md: "100%" }, minHeight: { md: 360 }, objectFit: "cover", display: "block" }}
            />
          </Grid>
        </Grid>
      </Paper>

      {error && (
        <Alert severity="error">{error instanceof Error ? error.message : "Não foi possível carregar as faltas."}</Alert>
      )}

      {!error && groups.length === 0 ? (
        <Paper sx={{ p: 4, textAlign: "center", borderRadius: 4, border: "1px dashed rgba(10,77,60,0.25)" }}>
          <Typography variant="h5" fontWeight={850}>Por enquanto, ninguém deu perdido!</Typography>
          <Typography color="text.secondary" mt={1}>Quando o administrador marcar alguém como “Faltou”, o nome aparecerá aqui.</Typography>
        </Paper>
      ) : (
        <Grid container spacing={2}>
          {groups.map((group, index) => (
            <Grid key={group.playerId} size={{ xs: 12, lg: 6 }}>
              <Paper
                sx={{
                  p: { xs: 2, sm: 3 },
                  borderRadius: 4,
                  height: "100%",
                  border: index === 0 ? "2px solid #b52b24" : "1px solid rgba(83,21,61,0.14)",
                  bgcolor: index === 0 ? "#fff8ed" : "background.paper"
                }}
              >
                <Stack spacing={2}>
                  <Stack direction="row" alignItems="center" spacing={1.5}>
                    <Avatar src={group.photoUrl ?? undefined} sx={{ width: 58, height: 58, bgcolor: "#53153d" }}>
                      {getInitials(group.playerName)}
                    </Avatar>
                    <Box flex={1} minWidth={0}>
                      <Typography variant="h6" fontWeight={900}>{group.playerName}</Typography>
                      <Typography color="text.secondary">
                        {group.absences.length === 1 ? "1 escapada registrada" : `${group.absences.length} escapadas registradas`}
                      </Typography>
                    </Box>
                    <Chip label={`#${index + 1}`} sx={{ bgcolor: "#ffd447", color: "#3a173d", fontWeight: 900 }} />
                  </Stack>

                  <Stack spacing={1}>
                    {group.absences.map((absence) => (
                      <Paper key={absence.id} variant="outlined" sx={{ p: 1.5, borderRadius: 3, bgcolor: "rgba(83,21,61,0.025)" }}>
                        <Stack direction={{ xs: "column", sm: "row" }} gap={1} justifyContent="space-between">
                          <Stack direction="row" spacing={0.75} alignItems="center">
                            <CalendarMonthRoundedIcon sx={{ color: "#9d251f", fontSize: 20 }} />
                            <Typography fontWeight={800}>{formatDateOnlyBR(absence.matchDate)}</Typography>
                          </Stack>
                          <Stack direction="row" spacing={0.75} alignItems="center">
                            <LocationOnRoundedIcon sx={{ color: "#53153d", fontSize: 20 }} />
                            <Typography>{absence.matchLocation || "Local não informado"}</Typography>
                          </Stack>
                        </Stack>
                      </Paper>
                    ))}
                  </Stack>
                </Stack>
              </Paper>
            </Grid>
          ))}
        </Grid>
      )}
    </Stack>
  );
}
