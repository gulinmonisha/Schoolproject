import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['College_logo_left_side.jpeg', 'pwa-192.svg', 'pwa-512.svg'],
      manifest: {
        name: 'CollabOn — Campus Management',
        short_name: 'CollabOn',
        description: 'Educational institution management system',
        theme_color: '#1D6BA3',
        background_color: '#ffffff',
        display: 'standalone',
        start_url: '/login',
        scope: '/',
        icons: [
          {
            src: '/pwa-192.svg',
            sizes: '192x192',
            type: 'image/svg+xml',
            purpose: 'any',
          },
          {
            src: '/pwa-512.svg',
            sizes: '512x512',
            type: 'image/svg+xml',
            purpose: 'any maskable',
          },
        ],
      },
      devOptions: {
        enabled: true,
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,png,jpeg,jpg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https?:\/\/localhost:8080\/api\//,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              networkTimeoutSeconds: 10,
              cacheableResponse: { statuses: [0, 200] },
            },
          },
        ],
      },
    }),
  ],
  optimizeDeps: {
    include: ['xlsx'],
  },
})
