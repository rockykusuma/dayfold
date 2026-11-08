# Rehearsal: Dayfold hero

- **Started from:** `hero-demo` (structure, script shape) with `static-card`'s pinned bottom-bleed framing.
- **Story:** tick "Review Arjun's design doc" → › to tomorrow (done tasks fold away, open ones carry with
  their age pills rolling 5d→6d and 1d→2d, "0 of 4 done") → hold → Today → untick. Ends on its first frame.
- **Poster (reduced motion):** tomorrow's page with the carried tasks.
- **Wide (720×400):** Mac window with sidebar, pinned one 48px gutter from the top and sides, off the bottom.
- **Compact (358×420, below 560px):** the iPhone app (kit `Phone`), touch cursor.
- **Filmed with `--gate`, passed:** the wide loop, the 390px loop, the reduced-motion poster (playground);
  both widths on the real page served from `docs/`.
- **Known film lines on the real page:** `kit override` on `.ss-phone__status` / `__island`. False positives:
  the check skips stylesheets whose URL contains `/kit/`, and the bundle puts the kit's CSS in `hero.css`.
  The same component in the playground reports none.
- **Not checked:** the dark theme of the page around it (the window stays a light product shot by design),
  Safari and Firefox (filmed in Chrome only), live frame pacing on a real device, a fresh-eye review.
