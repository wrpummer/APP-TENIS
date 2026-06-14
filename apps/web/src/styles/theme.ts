import { createTheme } from "@mui/material/styles";

export const theme = createTheme({
  palette: {
    mode: "light",
    primary: {
      main: "#0a4d3c"
    },
    secondary: {
      main: "#c2ff3d"
    },
    background: {
      default: "#f2f5ee",
      paper: "#fbfcf8"
    },
    text: {
      primary: "#112018",
      secondary: "#456154"
    }
  },
  typography: {
    fontFamily: "'Segoe UI', 'Trebuchet MS', sans-serif",
    h1: { fontWeight: 800 },
    h2: { fontWeight: 800 },
    h3: { fontWeight: 700 },
    button: { fontWeight: 700, textTransform: "none" }
  },
  shape: {
    borderRadius: 18
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          minHeight: 48,
          paddingInline: 18
        }
      }
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundImage: "none"
        }
      }
    }
  }
});
