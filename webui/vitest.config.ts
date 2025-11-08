import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [['babel-plugin-react-compiler']],
      },
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  test: {
    globals: true, // use vitest globals like describe, it
    environment: 'jsdom', // DOM APIs available for React components
    setupFiles: './tests/setup.ts', // optional setup file for RTL & mocks
    coverage: {
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['node_modules/', 'tests/'],
    },
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
    // optional timeout for async tests
    testTimeout: 10000,
  },
});
