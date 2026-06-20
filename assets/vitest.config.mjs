import path from 'path'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, './js')
    }
  },
  test: {
    environment: 'node',
    include: ['js/**/*.{test,spec}.{ts,tsx}']
  }
})
