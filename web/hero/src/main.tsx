import { createRoot } from 'react-dom/client'
import { DayfoldHero } from './DayfoldHero'

const el = document.getElementById('dayfold-hero')
if (el) createRoot(el).render(<DayfoldHero />)
