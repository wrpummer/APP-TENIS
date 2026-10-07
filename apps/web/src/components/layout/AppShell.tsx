import EmojiEventsRoundedIcon from "@mui/icons-material/EmojiEventsRounded";
import HistoryEduRoundedIcon from "@mui/icons-material/HistoryEduRounded";
import HomeRoundedIcon from "@mui/icons-material/HomeRounded";
import MenuRoundedIcon from "@mui/icons-material/MenuRounded";
import ManageAccountsRoundedIcon from "@mui/icons-material/ManageAccountsRounded";
import PersonRoundedIcon from "@mui/icons-material/PersonRounded";
import SportsTennisRoundedIcon from "@mui/icons-material/SportsTennisRounded";
import WarningAmberRoundedIcon from "@mui/icons-material/WarningAmberRounded";
import {
  AppBar,
  Box,
  Button,
  Container,
  Drawer,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Stack,
  Toolbar,
  Typography
} from "@mui/material";
import { useEffect, useMemo, useState } from "react";
import { Link, Outlet, useLocation } from "react-router-dom";
import { usePlayers } from "@/hooks/usePlayers";
import { formatDateOnlyBR } from "@/utils/tennis";

const links = [
  { label: "Principal", href: "/", icon: <HomeRoundedIcon fontSize="small" /> },
  { label: "Ranking", href: "/ranking", icon: <SportsTennisRoundedIcon fontSize="small" /> },
  { label: "Jogadores", href: "/jogadores", icon: <PersonRoundedIcon fontSize="small" /> },
  { label: "Histórico", href: "/historico", icon: <HistoryEduRoundedIcon fontSize="small" /> },
  { label: "Hall da Fama", href: "/hall-da-fama", icon: <EmojiEventsRoundedIcon fontSize="small" /> },
  { label: "Dick Vigarista", href: "/dick-vigarista", icon: <WarningAmberRoundedIcon fontSize="small" /> },
  { label: "Admin", href: "/admin", icon: <ManageAccountsRoundedIcon fontSize="small" /> }
];

export function AppShell() {
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [birthdayOpen, setBirthdayOpen] = useState(false);
  const { data: players } = usePlayers();
  const upcomingBirthdays = useMemo(() => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return (players ?? [])
      .filter((player) => player.status === "active" && player.birthDate)
      .map((player) => {
        const [, month, day] = String(player.birthDate).slice(0, 10).split("-").map(Number);
        const birthday = new Date(today.getFullYear(), month - 1, day);
        if (birthday < today) birthday.setFullYear(today.getFullYear() + 1);
        const days = Math.round((birthday.getTime() - today.getTime()) / 86400000);
        return { player, birthday, days };
      })
      .filter(({ days }) => days >= 0 && days <= 7)
      .sort((a, b) => a.days - b.days);
  }, [players]);

  useEffect(() => {
    if (upcomingBirthdays.length > 0) setBirthdayOpen(true);
  }, [upcomingBirthdays.length]);

  return (
    <Box minHeight="100vh" sx={{ background: "radial-gradient(circle at top, rgba(194,255,61,0.2), transparent 24%), #f2f5ee" }}>
      <AppBar position="sticky" elevation={0} sx={{ bgcolor: "rgba(242,245,238,0.88)", color: "text.primary", backdropFilter: "blur(16px)" }}>
        <Toolbar sx={{ minHeight: { xs: 76, md: 82 }, py: { xs: 1, md: 0 } }}>
          <Container maxWidth="xl" sx={{ display: "flex", flexWrap: "wrap", gap: 2, alignItems: "center", justifyContent: "space-between" }}>
            <Stack direction="row" spacing={2} alignItems="center">
                <Box
                  sx={{
                    display: "grid",
                    placeItems: "center",
                    width: 52,
                    height: 52,
                    borderRadius: "50%",
                    bgcolor: "rgba(255,255,255,0.9)",
                    boxShadow: "0 12px 32px rgba(10, 77, 60, 0.12)",
                    overflow: "hidden",
                    border: "1px solid rgba(10, 77, 60, 0.1)"
                  }}
                >
                  <Box
                    component="img"
                    src="/app-icon-192.png"
                    alt="Ranking Tennis"
                    sx={{
                      width: "100%",
                      height: "100%",
                      objectFit: "cover"
                    }}
                  />
              </Box>
              <div>
                <Typography variant="h5" sx={{ fontSize: { xs: "1.15rem", md: "1.5rem" } }}>Ranking Tennis</Typography>
                <Typography color="text.secondary" sx={{ display: { xs: "none", md: "block" } }}>
                  Duplas, histórico e estatísticas em um lugar só.
                </Typography>
              </div>
            </Stack>

            <Stack direction="row" spacing={1} flexWrap="wrap" sx={{ display: { xs: "none", md: "flex" } }}>
              {links.map((link) => (
                <Button
                  key={link.href}
                  component={Link}
                  to={link.href}
                  startIcon={link.icon}
                  variant={location.pathname === link.href ? "contained" : "text"}
                  color={location.pathname === link.href ? "primary" : "inherit"}
                >
                  {link.label}
                </Button>
              ))}
            </Stack>

            <IconButton
              onClick={() => setMobileMenuOpen(true)}
              sx={{
                display: { xs: "inline-flex", md: "none" },
                bgcolor: "rgba(10,77,60,0.08)"
              }}
              aria-label="Abrir menu"
            >
              <MenuRoundedIcon />
            </IconButton>
          </Container>
        </Toolbar>
      </AppBar>

      <Drawer
        anchor="right"
        open={mobileMenuOpen}
        onClose={() => setMobileMenuOpen(false)}
        PaperProps={{
          sx: {
            width: 280,
            bgcolor: "#f2f5ee"
          }
        }}
      >
        <Box sx={{ p: 3 }}>
          <Typography variant="h6">Menu</Typography>
          <Typography color="text.secondary">Escolha a area que deseja abrir.</Typography>
        </Box>
        <List sx={{ px: 1 }}>
          {links.map((link) => (
            <ListItemButton
              key={link.href}
              component={Link}
              to={link.href}
              onClick={() => setMobileMenuOpen(false)}
              selected={location.pathname === link.href}
              sx={{
                borderRadius: 3,
                mb: 0.5
              }}
            >
              <ListItemIcon sx={{ minWidth: 40 }}>{link.icon}</ListItemIcon>
              <ListItemText primary={link.label} />
            </ListItemButton>
          ))}
        </List>
      </Drawer>

      <Container maxWidth="xl" sx={{ py: { xs: 2, md: 4 } }}>
        <Outlet />
      </Container>

      <Dialog open={birthdayOpen} onClose={() => setBirthdayOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle sx={{ pb: 1 }}>
          <Stack direction="row" spacing={1.5} alignItems="center">
            <Box
              component="img"
              src="/birthday.png"
              alt="Bolo de aniversário"
              sx={{ width: 58, height: 58, objectFit: "contain" }}
            />
            <span>Aniversários próximos</span>
          </Stack>
        </DialogTitle>
        <DialogContent>
          <Typography color="text.secondary" sx={{ mb: 2 }}>
            Tem gente querida fazendo aniversário em breve!
          </Typography>
          <Stack spacing={1.5}>
            {upcomingBirthdays.map(({ player, birthday, days }) => (
              <Stack key={player.id} direction="row" spacing={1.5} alignItems="center">
                <Box
                  component="img"
                  src={player.photoUrl ?? "/app-icon-192.png"}
                  alt=""
                  sx={{ width: 42, height: 42, borderRadius: "50%", objectFit: "cover" }}
                />
                <Typography>
                  <strong>{player.displayName}</strong> faz aniversário em {formatDateOnlyBR(birthday.toISOString())}, {days === 0 ? "hoje" : `daqui a ${days} ${days === 1 ? "dia" : "dias"}`}.
                </Typography>
              </Stack>
            ))}
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setBirthdayOpen(false)} variant="contained">Fechar</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
