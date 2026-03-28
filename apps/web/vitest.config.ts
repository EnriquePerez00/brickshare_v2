import { defineConfig } from "vitest/config";
import { loadEnv } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";

export default defineConfig(({ mode }) => {
  // Load env file based on `mode` in the current working directory.
  // Set the third parameter to '' to load all env regardless of the `VITE_` prefix.
  const env = loadEnv(mode, path.resolve(__dirname, '../../'), '');

  return {
    plugins: [react()],
    test: {
      globals: true,
      environment: "jsdom",
      setupFiles: ["./src/test/setup.ts"],
      env: {
        // Explicitly pass environment variables to test environment
        VITE_SUPABASE_URL: env.VITE_SUPABASE_URL,
        VITE_SUPABASE_ANON_KEY: env.VITE_SUPABASE_ANON_KEY,
        SUPABASE_SERVICE_ROLE_KEY: env.SUPABASE_SERVICE_ROLE_KEY,
      },
      include: ["src/**/*.test.{ts,tsx}"],
      coverage: {
        provider: "v8",
        reporter: ["text", "json", "html"],
        exclude: [
          "node_modules/**",
          "src/test/**",
          "src/vite-env.d.ts",
          "src/main.tsx",
          "**/*.config.*",
        ],
        thresholds: {
          lines: 50,
          functions: 50,
          branches: 40,
        },
      },
    },
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
  };
});