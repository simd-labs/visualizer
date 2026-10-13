import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: 'test',
  testMatch: '*.spec.mjs',
  outputDir: 'test-results',
  use: { baseURL: 'http://127.0.0.1:8787' },
  webServer: {
    command: 'python3 -m http.server 8787 --bind 127.0.0.1',
    url: 'http://127.0.0.1:8787',
    reuseExistingServer: !process.env.CI,
  },
});
