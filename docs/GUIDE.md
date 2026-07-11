# Kuro Theme — Anatomy & Authoring Guide

> The authoritative reference for how Kuro is built and how to change it without guessing.
> Written **doc-driven**: every component section is written from the real Minimal→Kuro
> transformation *before* the code is changed — nothing here is speculative.
>
> Scope: the **principles** are theme-agnostic (they hold for any Obsidian theme); the
> **examples** are grounded in Kuro's concrete skeleton-fork of Minimal 8.2.1.
>
> Companion docs — this guide links to, does not duplicate them:
> **[CSS-CONVENTIONS.md](CSS-CONVENTIONS.md)** (the enforced rules + verified Obsidian variable map) ·
> **[THEME-AUTHORING.md](THEME-AUTHORING.md)** (how-to: change / fork Kuro).

---

## Part I — Explanation (why it is built this way)

### Why a skeleton-fork of Minimal

Kuro v4 built its own "armature" — a hand-made both-mode variable system. It worked, but at
the cost of permanent infrastructure maintenance, and feature after feature proved fragile on
that self-made base. Minimal (kepano, MIT) solves the same problems *by construction* and far
more maturely: a battle-tested HSL variable architecture, both-mode handling, and chrome that
Obsidian updates rarely break.

So Kuro **forks Minimal's skeleton and owns it** — Minimal's CSS becomes Kuro's own editable
code, not a read-only base layer. Kuro replaces Minimal's *components* with its own, directly
in the codebase. Minimal's role is deliberately small but load-bearing: the variable core and
the chrome.

### Why not layer overrides on top of Minimal (the failure that shaped this)

The first attempt was a **layered fork**: Minimal's `theme.css` unchanged as a read-only base,
Kuro as override fragments on top. It built green and *most* of it worked — colour palette,
typography, tags, inline formatting: everything that flows through **variable overrides**.

But two things **broke** in the live sight-check: **callouts** (no box/border) and **checkboxes**
(Minimal's SVG-mask icons instead of Kuro's glyphs; empty `[ ]` invisible). The root cause is
**specificity**: Minimal ships its own *highly specific* component selectors — e.g.
`li[data-task=">"] > p > input:checked` (specificity `0,2,3`) with per-task-type
`-webkit-mask-image` SVGs, and callout borders only under the opt-in `.callouts-outlined`.
Kuro's ported rules — low specificity, written when Kuro was the *only* source — lose to them.
An override layer would have to out-specify Minimal at **every** component: a permanent
specificity war, fragile on every Minimal update.

**The lesson, now built into the process:** you cannot reliably *override* a mature theme's
structural components — you must **replace** them. And because Kuro *owns* Minimal here, any
specificity conflict is resolved by **editing the source**, not by piling on `!important` or
ever-more-specific selectors. This is why the build is a skeleton-fork, not a layer.

### The skeleton / flesh model

| Layer | Origin | What |
|---|---|---|
| **Skeleton** (owned, stays Minimal) | Minimal | HSL variable core (`--base-h/s/l`, `--accent-*` → aliases `--bg/ui/tx/ax`), the map onto Obsidian-native variables, and chrome (app, gutters, ribbon, statusbar, titlebar, window-frame, modals, tooltips, tabs, sidebar). |
| **Flesh** (transformed to Kuro) | Kuro replaces Minimal | Palette, typography, callouts, checkboxes, tags, code, tables, blockquote, lists, bases, graph, ambient, reduced-motion. |
| **Minimal extras** (kept) | Minimal | Cards, colour-schemes, focus-mode, `minimal-*` toggles — kept as-is (they don't harm; most are inert without the Minimal Settings plugin). |

### Token flow (one direction, no back-channels)

```
Chamber/Paper hex values  ──►  Minimal's aliases (--bg1/2/3, --ui1/2/3, --tx1/2/3)
   (pinned on .theme-dark / .theme-light, both modes key-mirrored)
        ▼
Minimal's colour-map  ──►  Obsidian-native variables (--background-primary, --text-normal, …)
        ▼
Kuro components read  native variables  +  --role-* (Kuro's 12 signals → Minimal's 8 accents)
```

Both-mode is Minimal's `.theme-dark` / `.theme-light` mechanism plus the pinned alias values.
Kuro components speak `--role-*` / native tokens, so they are decoupled from the concrete world
values and re-colour with every future world (Phase 2). See the rules in
**[CSS-CONVENTIONS.md](CSS-CONVENTIONS.md)** (R1 variable-first, R3 both-mode parity).

---

## Part II — Reference (look it up)

### Obsidian CSS variable API

The authoritative map lives in **[CSS-CONVENTIONS.md § Verified Obsidian variable map](CSS-CONVENTIONS.md)**
(tabs, window-frame, checkbox, tag, callout, command-palette). Grounded in the official docs,
with the known gotchas. Look there **first** before writing any property override (R1).

### Minimal's variable system (the skeleton)

Minimal drives its whole colour system from **6 HSL control values** — `--base-h/-s/-l` +
`--accent-h/-s/-l` — from which it derives, via `hsl()`+`calc()`, the aliases `--bg1/2/3`,
`--ui1/2/3`, `--tx1/2/3/4`, `--ax1/2/3`, `--hl1/2`, then maps those onto Obsidian's standard
variables. Both-mode comes from mirrored `.theme-light` / `.theme-dark` values.
_(Defined in `00-minimal-vars.css` + `01-minimal-colormap.css`.)_

Kuro does **not** recompute these from HSL — it **pins** hand-tuned Chamber/Paper hex values
directly onto the aliases (see the Palette anatomy card below). Minimal's alias *structure*
stays; Kuro owns the *values*.

### Fragment map (which file does what)

Build = `HEADER.css` + numeric glob (`build.sh`, zero-dep, deterministic).

| Fragment | Role |
|---|---|
| `00-minimal-vars.css` · `01-minimal-colormap.css` | skeleton — HSL core + Obsidian-native map |
| `10-minimal-app.css` · `11-minimal-statusbar.css` · `12-minimal-components.css` | skeleton — chrome |
| `20-minimal-content.css` | Minimal content components (transformed out to Kuro over Phase 1) |
| `30-minimal-features.css` · `31-minimal-states.css` | Minimal features/states (checklist icons live here until transformed) |
| `40-minimal-interface.css` | skeleton — tabs, sidebar, interface |
| `50-minimal-plugins.css` · `60-minimal-schemes.css` · `70-minimal-compat.css` | plugins, colour-schemes, compat (kept) |
| `0x-kuro-*` (settings, palette, tokens, fonts, typography) | Kuro `[values]` + design tokens |
| `2x-kuro-*` (callouts, checkboxes, tags, code, tables, blockquote, lists, bases, graph) | Kuro components (flesh) |
| `8x-kuro-*` (ambient, reduced-motion) | Kuro additive |
| `src/_v4-reference/` | old v4 fragments — **steinbruch/reference only, out of build** |

Naming contract: `*-minimal-*.css` = owned Minimal (transformed incrementally); `*-kuro-*.css`
= Kuro's own. `check.sh` applies the `!important`/no-hex discipline only to `*-kuro-*.css`; the
living `!important` count in Minimal fragments is reported as **transform debt** (drives cleanup).

### Component anatomy cards

> Written per component, *before* its transform (doc-driven). Each card records: **how Obsidian
> targets it · how Minimal solves it · the high-specificity traps (the layered pitfalls) · how
> Kuro replaces it.** They grow as Phase 1 proceeds.

#### Palette (Task 2)

- **How Obsidian targets it:** surfaces, text and borders via native vars —
  `--background-primary/-secondary[-alt]`, `--text-normal/-muted/-faint`,
  `--background-modifier-border[-hover/-focus]`, `--interactive-accent`, …
- **How Minimal solves it:** derives the aliases `--bg1/2/3`, `--ui1/2/3`, `--tx1/2/3/4`,
  `--ax1/2/3` from 6 HSL controls (`--base-h/s/l` + `--accent-h/s/l`) in `.theme-dark` /
  `.theme-light` blocks (`00-minimal-vars.css`), then maps aliases → native in
  `.theme-dark, .theme-light { --background-primary: var(--bg1); --interactive-accent: var(--ax3); … }`
  (`01-minimal-colormap.css`).
- **Specificity / traps:** both the alias definitions and the native map sit at `.theme-*`
  specificity `(0,1,0)`. **No high-specificity trap** — this is why the palette "just worked"
  even in the failed layered attempt (it flows purely through variables).
- **How Kuro replaces it:** pins hand-tuned Chamber (dark) / Paper (light) hex **directly onto
  the aliases** in `03-kuro-palette.css`. Because `03-` builds after `00/01-minimal-*`, source
  order wins at equal specificity — Minimal's alias *structure* stays, Kuro owns the *values*,
  and the whole native map recolours downstream. Both `.theme-dark` and `.theme-light` pin the
  identical key-set (both-mode parity, `check.sh`-enforced). The **accent** is deliberately left
  to follow Obsidian's system accent — Kuro does not pin `--ax*`.

#### Signal roles 12→8 (Task 3)

- **What Minimal offers:** 8 accent colours — `--color-{red,orange,yellow,green,cyan,blue,purple,pink}`
  (+ `-rgb` triplets), defined in `00-minimal-vars.css`.
- **What Kuro needs:** 12 semantic signals (crimson, ember, rust, toxic, phosphor, biolink, circuit,
  ghost, spectre, voidwitch, neural-bleed, pearl) — more meanings than there are accents.
- **The 12→8 mapping** (`04-kuro-tokens.css`, exposed as `--role-*` + `--role-*-rgb`):
  crimson→red · ember/rust/drift→orange · review→yellow · phosphor/biolink/organic→green ·
  circuit/link→cyan · ghost/info→blue · spectre/voidwitch/focus/creative→purple ·
  neural-bleed/reflection→pink. **pearl/neutral** has no Minimal accent → fixed mid-grey
  `rgb(140,140,150)`, legible in both modes.
- **Why `--role-*`:** components reference a role *by meaning*, not a concrete colour — so they are
  decoupled from the active accent and re-colour automatically with every future world (Phase 2).
  Invisible until components consume them (Tasks 5–9).

_Remaining cards (Typography · Callouts · Checkboxes · Tags · Code · Tables · Blockquote ·
Lists · Bases · Graph) added at each transform step._

---

## Part III — How-to

Practical recipes — change a component, add a world/matter (Phase 2), fork Kuro, pull Minimal
upstream selectively — live in **[THEME-AUTHORING.md](THEME-AUTHORING.md)**.

## The verification gate (every change)

1. **Machine:** `bash src/build.sh && bash src/check.sh` → `ALL CHECKS PASS` (determinism ·
   braces · comment balance · Kuro `!important` ≤ 9 tagged · both-mode palette parity ·
   no-hex in Kuro components · < 5 MB · 0 remote `@import`).
2. **Visual (Claude-owned):** build-green ≠ works — structural components are always confirmed by
   rendering, not by the build passing (the lesson from the layered failure). This verification is
   done by the maintaining agent, **not** delegated as a colour judgement to the user: render the
   theme (browser DOM mock or live deploy), inspect Light + Dark, **and** run the objective
   contrast/ramp analysis (`docs/tools/`-style scripts) — the latter is colour-blind-safe and
   catches what an eye can't (e.g. sub-AA text tiers). Surface only a plain-language before/after
   to the user, never a "which colour?" question.
