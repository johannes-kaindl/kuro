# Changelog

All notable changes to the Kuro theme are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] — Clean Foundation (the Armature)

A ground-up rebuild on a clean, forkable skeleton — **the Armature**. The look is
preserved (Kuro still looks like Kuro), but a whole class of light/dark bugs is gone
by construction, the code is modular and documented, and Style Settings gains a curated
set of personalisation knobs. The public `kuro-*` contract is unchanged, so saved Style
Settings configs keep working.

### Fixed
- **Light *and* dark now resolve correctly.** The root cause was a dual token system
  where only one half was both-mode; every semantic token now has an explicit value in
  both modes (`10-semantic-dark.css` + `11-semantic-light.css`, mirrored, enforced by
  `check.sh`). This fixes, by construction: checkboxes invisible in dark, the code
  stripe/frame missing in Live Preview, the note "lift" glow, and cream-on-paper text
  in light mode.
- **Checkboxes** consolidated from two competing rule sets into one, all surfaces.
- **Code blocks** styled in Live Preview / editor for the first time (not just Reading).
- **Colourful headlines** now use a distinct signal hue per level (was tied to the
  system accent, which rendered monochrome when the accent is light/desaturated).

### Added
- **The Armature.** The repo is split into `[armature]` (structure/contract) and
  `[values]` (palette/presets/fonts) — a future theme is a fork that swaps the values
  files. See `docs/THEME-AUTHORING.md`. A new `--paper-*` light ramp makes light a
  first-class scale alongside the `--void-*` dark ramp.
- **Accessibility:** a keyboard focus ring (`:focus-visible`), WCAG-AA contrast across
  text / syntax / status colours, and a canonical `prefers-reduced-motion` reset.
- **Style Settings knobs:** note & card lift strength, corner roundness, interface
  density, code font size, body font size, callout style (filled / subtle / border-only),
  link underline, table zebra, border crispness, focus-ring style, heading-glow toggle —
  plus polish for the quick switcher, command palette and context menus.

### Changed
- Per-component file structure (`20-typography` … `31-graph`), each component defined
  once across Reading + Live Preview + editor. Build stays a zero-dependency,
  deterministic `build.sh` cascade with a `check.sh` verification harness.
- Reading measure defaults to ~640px and now applies without the Style Settings plugin.
- Mono body leading tuned to 1.6; heading ramp widened (H2 1.5em / H3 1.2em).

### Removed
- The Slides (reveal.js) styling and its toggles — slide theming belongs in a dedicated
  plugin, not the theme.

## [3.4.0] — Standalone & Style-Settings native

A focused pass to make the theme genuinely usable without any companion plugin. The
accent now follows Obsidian's own system colour, and plugin-coupled extras that could
not work reliably without the companion's JavaScript were retired for a cleaner,
simpler standalone theme.

### Added
- **Style Settings support.** A new `src/05-style-settings.css` fragment carries a
  `@settings` block exposing **Colour & Mood** (signal presets, low contrast),
  **Typography**, **Reading** (margin tint, reading width, pattern intensity, colourful
  headlines), **Slides**, and **Editor & Tabs**. It is inert when the plugin is absent —
  the theme uses its CSS defaults.
- **Reduced-motion coverage.** Decorative callout-box loops and the `.kuro-pulse` utility
  now stop under `prefers-reduced-motion: reduce` (`src/75-reduced-motion.css`).

### Changed
- **Accent follows the system colour.** In both light and dark, the accent is Obsidian's
  own accent colour (`Settings → Appearance → Accent color`). The forced phosphor (dark)
  and copper (light) overrides are gone; `--accent` and the accent glow derive from it.
- Frontmatter heading aligns with its rows; H1 top spacing reduced; the tab-style
  dropdown's default entry is now labelled; Style-Settings descriptions clarified.

### Removed
- **Aspects** (the four faces). Standalone they only re-set the accent, which the system
  accent now covers.
- **CRT vignette & scanlines.** Obsidian's app container overlaps CSS overlay
  pseudo-elements, so a theme cannot render full-app overlays reliably without the
  companion's JS-injected element.
- **Colour Vision Mode.** Its core — per-note signal glyphs — needs the companion's
  per-note classes.
- **Hanko watermark** and all of its Style-Settings controls.
- **Aspect wallpapers** (fragile margin-tint + readable-line-width chain).

## [3.3.0] — Release-readiness

Submission-readiness pass for the Obsidian community catalogue. No visual redesign —
this release makes the theme self-contained and guideline-compliant.

### Changed
- **Fonts are now embedded.** The four families (JetBrains Mono, Space Grotesk, Inter,
  EB Garamond) ship as Latin-subset `woff2` `@font-face` data-URLs in a new
  `src/02-fonts-embedded.css` fragment. The theme no longer reaches the network.
  All four families are licensed under the SIL Open Font License 1.1.
- **`!important` reduced from 316 to 69.** Overrides were re-expressed through selector
  specificity and Obsidian CSS variables, verified against Obsidian's `app.css`. The
  remaining declarations are justified keeps (state/inline-var overrides, defensive
  light-mode flags) and carry inline rationale comments.

### Removed
- Remote `@import` of `fonts.googleapis.com` from `01-tokens-canonical.css`.

### Fixed
- Back-ported the §39·6b Mermaid-padding patch from the live Pallas install into the
  source fragment, so the build reproduces the deployed state.

### Internal
- `Kuro/` is now a standalone Git repository, bootstrapped byte-identically from the
  consolidated archive sources. `src/build.sh` regenerates `theme.css` deterministically.

## [3.2.0] — 2026-05-11 — Visibility & accessibility

### Added
- **Color Vision Mode** — a fourth orthogonal axis (`body.kuro-color-vision-boost`):
  saturation lift, red-green hue spread, and non-colour cues (per-aspect border
  patterns, per-signal glyphs, heading-weight bump).
- Light-mode aspect differentiators (border + surface tint).

### Changed
- Aspect wallpaper opacity raised 5–10 % → 15–20 % via `--kuro-wallpaper-alpha`.
- Signal subtheme background 4 % → 9 %, L-shape border, brighter glow.
- Low-contrast wallpaper attenuation refactored from the v3.1 full-coverage inset-veil
  hack to an alpha-multiplier override.

### Fixed
- Inverse-glow bug in Editor Mode under margin-tint dark, traced to the retired veil;
  a defensive comment now guards against reintroduction.

## [3.1.0] — 2026-05

Low-contrast layer, colorful headings, callout extensions, graph WebGL polish, zen mode,
custom checkboxes, and assorted polish (`10-v1-polish-addendum`).

## [3.0.0] — 2026-05 — Signal Protocol Edition

Twelve Signals palette, Void Scale, four Aspects (shugo / gunshi / kantoku / sensei),
plugin body-class contract, hanko / ribbon-kanji marks.

## [2.0.0] — 2026-05

"Signal Protocol Edition" lineage (X1_v6t2b9 active dev).

## [1.0.0] — 2026-04

Canonical design system consolidated from ten source vaults.

[3.3.0]: https://github.com/v6t2b9/kuro/releases/tag/3.3.0
[3.2.0]: https://github.com/v6t2b9/kuro/releases/tag/3.2.0
