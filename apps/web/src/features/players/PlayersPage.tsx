import SearchRoundedIcon from "@mui/icons-material/SearchRounded";
import InfoOutlinedIcon from "@mui/icons-material/InfoOutlined";
import {
  Alert,
  Avatar,
  Button,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Grid,
  IconButton,
  InputAdornment,
  Paper,
  Stack,
  TextField,
  Typography
} from "@mui/material";
import { useState } from "react";
import { LoadingState } from "@/components/common/LoadingState";
import { SectionHeader } from "@/components/common/SectionHeader";
import { usePlayerStatistics, usePlayers } from "@/hooks/usePlayers";
import { formatDateOnlyBR, formatPercentage } from "@/utils/tennis";

function normalizeSearch(value: string) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();
}

export function PlayersPage() {
  const { data: players, isLoading: playersLoading } = usePlayers();
  const { data: statistics, isLoading: statisticsLoading } = usePlayerStatistics();
  const [search, setSearch] = useState("");
  const [helpOpen, setHelpOpen] = useState(false);

  if (playersLoading || statisticsLoading || !players || !statistics) {
    return <LoadingState />;
  }

  const normalizedSearch = normalizeSearch(search);
  const filteredPlayers = normalizedSearch
    ? players.filter((player) => normalizeSearch(player.displayName).includes(normalizedSearch))
    : players;
  const statisticsByPlayerId = new Map(statistics.map((item) => [item.playerId, item]));

  return (
    <Stack spacing={3}>
      <SectionHeader
        title={(
          <Stack direction="row" spacing={1} alignItems="center">
            <span>Jogadores</span>
            <IconButton
              aria-label="Ver explicacao dos resultados dos jogadores"
              color="primary"
              size="small"
              onClick={() => setHelpOpen(true)}
              sx={{
                border: "1px solid rgba(10,77,60,0.18)",
                bgcolor: "rgba(10,77,60,0.06)"
              }}
            >
              <InfoOutlinedIcon fontSize="small" />
            </IconButton>
          </Stack>
        )}
        subtitle="Lista completa de todos os jogadores cadastrados, inclusive novos registros feitos pelo painel administrativo."
      />

      <TextField
        label="Pesquisar jogador"
        value={search}
        onChange={(event) => setSearch(event.target.value)}
        placeholder="Digite o nome para encontrar rapidamente"
        fullWidth
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchRoundedIcon />
            </InputAdornment>
          )
        }}
      />

      {filteredPlayers.length === 0 ? (
        <Alert severity="info">Nenhum jogador encontrado com esse nome.</Alert>
      ) : (
        <Grid container spacing={2}>
          {filteredPlayers.map((player) => {
            const playerStatistics = statisticsByPlayerId.get(player.id);

            return (
              <Grid key={player.id} size={{ xs: 12, md: 6 }}>
                <Paper sx={{ p: 3, border: "1px solid rgba(10,77,60,0.08)", borderRadius: 4, height: "100%" }}>
                  <Stack spacing={2}>
                    <Stack direction="row" spacing={2} alignItems="center">
                      <Avatar src={player.photoUrl ?? undefined} sx={{ width: 64, height: 64 }}>
                        {player.displayName.slice(0, 1).toUpperCase()}
                      </Avatar>
                      <Stack spacing={0.5} sx={{ flex: 1 }}>
                        <Typography variant="h5">{player.displayName}</Typography>
                        <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap">
                          <Chip
                            size="small"
                            label={player.status === "active" ? "Ativo" : "Inativo"}
                            color={player.status === "active" ? "success" : "default"}
                          />
                          <Typography color="text.secondary">Jogador desde: {formatDateOnlyBR(player.registeredAt)}</Typography>
                        </Stack>
                      </Stack>
                    </Stack>

                    <Typography color="text.secondary">
                      Telefone: {player.phone?.trim() ? player.phone : "Não informado"}
                    </Typography>

                    {playerStatistics ? (
                      <Stack spacing={1}>
                        <Typography color="text.secondary">
                          {playerStatistics.matchesPlayed} partidas | {playerStatistics.wins} vitórias | {formatPercentage(playerStatistics.winRate)}
                        </Typography>
                        <Typography>Parceiro favorito: {playerStatistics.favoritePartner ?? "A definir"}</Typography>
                        <Typography>Melhor parceiro: {playerStatistics.bestPartner ?? "A definir"}</Typography>
                        <Typography>Rival mais enfrentado: {playerStatistics.mostFacedRival ?? "A definir"}</Typography>
                        <Typography>Rival mais difícil: {playerStatistics.hardestRival ?? "A definir"}</Typography>
                        <Typography>Maior sequência de vitórias: {playerStatistics.bestWinStreak}</Typography>
                        <Typography>Maior sequência de derrotas: {playerStatistics.worstLossStreak}</Typography>
                        <Typography>Melhor mês: {playerStatistics.bestMonth ?? "Sem dados"}</Typography>
                      </Stack>
                    ) : (
                      <Paper sx={{ p: 2, bgcolor: "rgba(194,255,61,0.14)", borderRadius: 3 }}>
                        <Typography fontWeight={700}>Ainda sem partidas registradas</Typography>
                        <Typography color="text.secondary">
                          Este jogador já está cadastrado e aparecerá nas estatísticas assim que tiver partidas lançadas.
                        </Typography>
                      </Paper>
                    )}
                  </Stack>
                </Paper>
              </Grid>
            );
          })}
        </Grid>
      )}

      <Dialog open={helpOpen} onClose={() => setHelpOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle>Como os resultados dos jogadores são calculados</DialogTitle>
        <DialogContent>
          <Stack spacing={1.5} sx={{ pt: 1 }}>
            <Typography>
              Cada lançamento feito no Admin conta como uma partida. Se for super tiebreak, ele também conta como uma partida normal para as estatísticas.
            </Typography>
            <Typography>
              <strong>Partidas:</strong> quantidade de partidas em que o jogador participou.
            </Typography>
            <Typography>
              <strong>Vitórias e derrotas:</strong> mostram quantas partidas o jogador venceu ou perdeu. Como cada cadastro representa uma partida, isso acompanha o resultado daquele lançamento.
            </Typography>
            <Typography>
              <strong>Aproveitamento:</strong> percentual de vitórias do jogador, calculado por vitórias divididas pelo total de partidas com resultado.
            </Typography>
            <Typography>
              <strong>Pontuação:</strong> a dupla vencedora recebe 3 pontos para cada jogador; a dupla perdedora recebe 1 ponto para cada jogador.
            </Typography>
            <Typography>
              <strong>Parceiro favorito:</strong> jogador que mais atuou junto com a pessoa.
            </Typography>
            <Typography>
              <strong>Melhor parceiro:</strong> parceiro com melhor aproveitamento junto com a pessoa, usando vitórias e derrotas da dupla.
            </Typography>
            <Typography>
              <strong>Rival mais enfrentado:</strong> adversário que mais apareceu do outro lado da quadra.
            </Typography>
            <Typography>
              <strong>Rival mais difícil:</strong> adversário contra quem o jogador teve pior aproveitamento.
            </Typography>
            <Typography>
              <strong>Sequências:</strong> maior quantidade seguida de vitórias ou derrotas, respeitando a ordem das datas cadastradas.
            </Typography>
            <Typography>
              <strong>Melhor mês:</strong> mês em que o jogador somou mais pontos. Em empate, o app olha mais vitórias.
            </Typography>
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button variant="contained" onClick={() => setHelpOpen(false)}>
            Entendi
          </Button>
        </DialogActions>
      </Dialog>
    </Stack>
  );
}
