import MilitaryTechRoundedIcon from "@mui/icons-material/MilitaryTechRounded";
import { Avatar, Chip, Paper, Stack, Table, TableBody, TableCell, TableHead, TableRow, Typography } from "@mui/material";
import type { RankingRow } from "@/types/domain";
import { formatPercentage } from "@/utils/tennis";

interface RankingTableProps {
  rows: RankingRow[];
}

export function RankingTable({ rows }: RankingTableProps) {
  return (
    <Paper sx={{ overflow: "hidden", border: "1px solid rgba(10,77,60,0.08)" }}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Pos.</TableCell>
            <TableCell>Jogador</TableCell>
            <TableCell align="right">Pontos</TableCell>
            <TableCell align="right">Jogos</TableCell>
            <TableCell align="right">Vitorias</TableCell>
            <TableCell align="right">Derrotas</TableCell>
            <TableCell align="right">Aproveitamento</TableCell>
            <TableCell align="right">Saldo Sets</TableCell>
            <TableCell align="right">Saldo Games</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {rows.map((row) => (
            <TableRow key={row.playerId} hover>
              <TableCell>
                <Stack direction="row" spacing={1} alignItems="center">
                  {row.rankingPosition <= 3 && <MilitaryTechRoundedIcon color="secondary" fontSize="small" />}
                  <Typography fontWeight={700}>{row.rankingPosition}</Typography>
                </Stack>
              </TableCell>
              <TableCell>
                <Stack direction="row" spacing={2} alignItems="center">
                  <Avatar src={row.photoUrl ?? undefined}>{row.playerName.slice(0, 1)}</Avatar>
                  <div>
                    <Typography fontWeight={700}>{row.playerName}</Typography>
                    {row.importedFromLegacy && <Chip size="small" label="Legado" color="secondary" />}
                  </div>
                </Stack>
              </TableCell>
              <TableCell align="right">{row.points}</TableCell>
              <TableCell align="right">{row.matchesPlayed}</TableCell>
              <TableCell align="right">{row.wins}</TableCell>
              <TableCell align="right">{row.losses}</TableCell>
              <TableCell align="right">{formatPercentage(row.winRate)}</TableCell>
              <TableCell align="right">{row.setsWon - row.setsLost}</TableCell>
              <TableCell align="right">{row.gamesWon - row.gamesLost}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </Paper>
  );
}
