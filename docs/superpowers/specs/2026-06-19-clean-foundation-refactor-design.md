# Kuro — "Clean Foundation" Refactor (v4.0.0)

> **⚠️ SUPERSEDED 2026-06-20** by `2026-06-20-clean-foundation-skeleton-design.md`.
> That version upgrades this in-place refactor to a skeleton-first ground-up rebuild
> (forkable skeleton + per-component files + light-mode fix), grounded in an exhaustive
> code inventory. The *goal* and the *root-cause analysis* below remain valid; the
> *approach* is replaced. Read the 06-20 spec.

**Status:** ~~approved 2026-06-19~~ superseded · **Branch:** `refactor/clean-foundation`

## Why

The standalone simplification left the theme functional but structurally messy.
A code-health audit (2026-06-19) plus live testing confirmed the root cause of a
whole class of bugs: **two parallel token systems** (Obsidian-native + a "KSP"
layer `--fg-*`/`--void-*`/`--accent`), only half-bridged, and many values set in
**only one theme mode** (light got manual overrides, dark didn't). Symptoms:
the accent dies in dark mode (toggle, code-block stripe, card/callout glow all
fail in dark but work in light), checkbox tokens are defined-but-unused,
the signal palette is duplicated 3×, colourful-headings logic is split across
3 fragments, ~70 `!important`, stale comments for removed effects.

Patching these one-by-one in the current code was tried and **failed in dark
mode for exactly the structural reason above** — and would be thrown away by the
refactor anyway. Decision: **refactor-first.**

## Scope (decided)

- **Clean, modular, well-documented SINGLE theme** (Kuro), structured so a future
  theme is born by forking + swapping tokens. **No** shared framework/base layer
  (YAGNI — there is exactly one theme today).
- **Depth: "middle"** — fully consolidate the *internal* token system (this is
  what fixes the dark bugs by construction) and reorganise fragments into clear
  modules, **but preserve the public contract**: the `kuro-*` Style-Settings
  class names and user-facing `--kuro-*` variables stay, so saved Style Settings
  configs and the (on-ice) companion plugin do **not** break.

## Invariants (true across every step)

1. **The look does not change.** This is a structural refactor + bug fix, not a
   redesign. The current (clean baseline) appearance in both light and dark is
   the regression target.
2. **Build stays zero-dependency.** `src/build.sh` concatenates numbered
   fragments → `theme.css`. Deterministic (double-build md5-identical).
3. **Public contract preserved.** `kuro-*` classes + user-facing `--kuro-*` vars
   unchanged. Internal token *values/scoping* may be cleaned; internal token
   *names* may be canonicalised only where nothing public depends on them.
4. **Submission invariants hold:** 0 remote `@import`, fonts embedded, < 5 MB,
   `!important` only where Obsidian's own specificity forces it (documented).

## 1 · Token architecture (the heart — bugs disappear here)

One theme-scoped token SSOT in three layers:

- **Primitives** — raw palette (signal colours, neutral/void scale), defined
  **once** (today duplicated across `00-base`, `01-tokens`, `20-kuro2`).
- **Semantic** — `--surface-*`, `--fg-*`, `--border-*`, `--accent*`, `--code-*`,
  `--shadow-*`/`--glow-*`: **every semantic token has an explicit value for BOTH
  light and dark** (via `.theme-light`/`.theme-dark` or `:root` + theme overrides).
  No token is ever correct in only one mode. *This single rule fixes
  toggle / checkbox / code-stripe / glow at once.*
- **Bridge** — Obsidian-native tokens (`--background-*`, `--text-*`,
  `--interactive-accent`, `--checkbox-*`) are fed from the semantic layer at **one**
  place. No second parallel system.
- **Accent = one path** — `--accent ← --interactive-accent` (system); all
  derivations (glow / soft / border / stripe) computed from it and present in
  both modes. **Never** assume `--interactive-accent-rgb` (Obsidian doesn't emit
  it — known trap); use `var(--interactive-accent)` + `color-mix()`.

## 2 · Module structure (clear, documented, forkable)

Split the two mega-fragments (`00-base` 125 KB, `10-v1` 77 KB) into focused
modules. Each fragment gets a header: **PURPOSE · SETS tokens · USES tokens ·
DEPENDS-ON**.

| Module | Content |
|---|---|
| `00-tokens` | primitives + semantic (both-mode) + Obsidian bridge — the SSOT |
| `10-base` | editor, typography, surfaces, nav — semantic tokens only |
| `20-components` | callouts, checkboxes, code, tables, cards, **toggles** (today's bug sites) |
| `30-features` | opt-in: margin-tint, colourful-headings, zen, slides, terminal-mode … |
| `40-presets` | the 13 signal presets (mood tints) |
| `50-style-settings` | `@settings` block — **public contract, names unchanged** |
| `60-low-contrast` · `70-reduced-motion` · `80-fonts` | as today, cleaned |

Build remains `build.sh` numeric-prefix cascade.

## 3 · How the four dark-mode bugs vanish by construction

| Bug | Root today | After |
|---|---|---|
| Toggle accent (dark) | accent rule only effective in light | component uses `--accent` (valid both modes) |
| Checkboxes | `--checkbox-*` defined but bypassed (`--text-faint`, hardcoded `#fff`) | theme-scoped `--checkbox-*` actually used → visible box + contrasting marker both modes; glyph centred |
| Code stripe (dark) | only light has the border/stripe override | `--code-border` / `--code-stripe` semantic tokens set for both |
| Glow / lift (dark) | `--shadow-card`/`--glow-*` defined but never applied | `--shadow-card` (light) + `--glow-card` (dark) applied to the same elements |

## 4 · Regression safety (the look must NOT change)

- **Visual baseline:** an extended test note covering every element; Jay
  screenshots the current clean baseline in light + dark as the "before".
- **Staged etappes**, each independently buildable + deployable + spot-checkable:
  - **E1 — Token SSOT.** Consolidate + theme-scope every token; bridge; one
    accent path. Goal: appearance **identical**, *and* the four bugs fixed
    (because tokens now resolve in dark). Highest risk → first, smallest to verify.
  - **E2 — Module split.** Move the mega-fragments into the module layout. Pure
    relocation; appearance identical.
  - **E3 — Docs + `!important` reduction + dead-code/comment removal.**
  - **E4 — Final validation:** 13 presets × light/dark/low-contrast, determinism,
    size, 0 remote import → release.
- **Each etappe gate:** deterministic build + code-level adversarial verification
  (trace every semantic token resolves in both themes; confirm bug-fix points;
  confirm look-affecting tokens unchanged) + invariants + **Jay visual spot-check**
  before proceeding. (Rendered look is only verifiable by eye — physics limit.)

## 5 · Release

The refactored state becomes the genuinely-submittable version: **4.0.0**
("rebuilt foundation"). Public contract unchanged → no user-facing breaks.
Replaces the premature 3.4.0 submission. The §40-gamification extraction
(commit `afe8053`) + the rewritten demo note are the clean starting point.

## Out of scope

- Shared multi-theme framework/base (deferred until a second theme exists).
- Field Report theme, the companion plugin's own code.
- Any visual redesign.
