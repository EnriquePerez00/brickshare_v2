import { defineConfig } from 'vitest/config'
import path from 'path'
import dotenv from 'dotenv'
import fs from 'fs'

export default defineConfig(({ mode }) => {
  // Load environment variables for tests
  const envTestPath = path.resolve(__dirname, '.env.test')
  const envLocalPath = path.resolve(__dirname, '.env.local')
  
  const testEnv: Record<string, string> = {}
  
  // Load .env.test first (takes precedence)
  if (fs.existsSync(envTestPath)) {
    const envConfig = dotenv.config({ path: envTestPath })
    if (envConfig.parsed) {
      Object.assign(testEnv, envConfig.parsed)
    }
  }
  
  // Load .env.local for fallback values
  if (fs.existsSync(envLocalPath)) {
    const envConfig = dotenv.config({ path: envLocalPath })
    if (envConfig.parsed) {
      // Only add values that aren't already in testEnv
      for (const [key, value] of Object.entries(envConfig.parsed)) {
        if (!(key in testEnv)) {
          testEnv[key] = value
        }
      }
    }
  }

  return {
    test: {
      globals: true,
      environment: 'jsdom',
      setupFiles: [],
      // ⚠️ CRITICAL: Inject environment variables into test environment
      env: testEnv,
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
  }
})
