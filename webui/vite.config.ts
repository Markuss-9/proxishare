import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [['babel-plugin-react-compiler']],
      },
    }),
  ],
  build: {
    outDir: '../assets/webui',
    emptyOutDir: true,
    watch: {},
  },
  // NOTE: so the html requires js, css etc... from subpath /webui . this path is the one declared in flutter local server
  base: '/webui/',
})
