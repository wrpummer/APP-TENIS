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
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Stack,
  Toolbar,
  Typography
} from "@mui/material";
import { useState } from "react";
import { Link, Outlet, useLocation } from "react-router-dom";

const links = [
  { label: "Resumo", href: "/", icon: <HomeRoundedIcon fontSize="small" /> },
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
    </Box>
  );
}
