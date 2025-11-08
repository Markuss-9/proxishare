import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [["babel-plugin-react-compiler"]],
      },
    }),
    tailwindcss(),
  ],
  build: {
    outDir: "../assets/webui",
    emptyOutDir: true,
    watch: {},
  },
  // NOTE: so the html requires js, css etc... from subpath /webui . this path is the one declared in flutter local server
  base: "/webui/",

  /* shadcn */
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
