import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// One script and one stylesheet for the GitHub Pages site: docs/hero/hero.js + hero.css
export default defineConfig({
  plugins: [react()],
  define: { 'process.env.NODE_ENV': JSON.stringify('production') },
  build: {
    outDir: '../../docs/hero',
    emptyOutDir: true,
    lib: { entry: 'src/main.tsx', formats: ['es'], fileName: () => 'hero.js', cssFileName: 'hero' },
  },
})
