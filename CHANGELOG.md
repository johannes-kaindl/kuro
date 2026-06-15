# Changelog

All notable changes to the Kuro theme are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.4.0] — Standalone & Style-Settings native

The theme is now fully configurable through the official **Style Settings** plugin and
no longer depends on any companion plugin. No visual redesign — same Kuro, now standalone.

### Added
- **Style Settings support.** A new `src/05-style-settings.css` fragment carries a
  `@settings` annotation block exposing Aspect & Mood, Effects, Typography, Reading,
  Slides, Editor & Tabs, and Identity (hanko). It drives the same `kuro-*` body classes
  and `--kuro-*` variables the companion plugin uses, so the two share one contract.
  The block is inert when the plugin is absent — the theme uses its CSS defaults.
- **Global aspect via body class.** Aspects now respond to `body.kuro-aspect-*` (set by
  Style Settings) in addition to the existing `[data-aspect]` attribute (used by the
  companion for per-note switching).
- **Plugin-free hanko.** The signature kanji watermark survives without any plugin as a
  static CSS pseudo-element (`src/35-hanko-static.css`), with glyph, size, offsets, glow
  and on/off exposed to Style Settings. It is suppressed when a companion plugin injects
  a real hanko (`body.kuro-has-hanko`), so the two never double up.
- **Reduced-motion coverage.** Decorative callout-box loops and the `.kuro-pulse` utility
  now stop under `prefers-reduced-motion: reduce` (`src/75-reduced-motion.css`),
  complementing the existing callout-icon handling.

### Changed
- README reframed: configuration is via Style Settings; no plugin is required.
- No hard plugin dependency remains anywhere in the theme.

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
