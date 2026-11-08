# Dayfold hero

The animated product shot at the top of the support page (`docs/index.html`): tick a task done,
step to tomorrow, and the open tasks are already there, a day older. A Mac window on wide pages,
the iPhone app below 560px. Built with the Stageshow kit (`src/kit/`, MIT, brand logos removed).

```sh
cd web/hero
npm install
npm run build      # writes docs/hero/hero.js and docs/hero/hero.css
npm run typecheck
```

Commit the rebuilt `docs/hero/` files; GitHub Pages serves them as they are.
