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

#### Typography (Task 4)

- **How Minimal handles it:** sets `--font-editor-theme` (a sans stack) and drives heading
  size/weight/variant from `--h1-size … --h6-size` vars (`00-minimal-vars.css`); headings styled
  at `h1,h2,h3,h4` (`20-minimal-content.css`). Obsidian resolves each font as
  `--font-<slot>: var(--font-<slot>-override), var(--font-<slot>-theme), <default>` — the theme's
  job is the `-theme` layer.
- **Kuro's signature:** **mono body everywhere** (JetBrains Mono) + **serif-italic H1**
  (EB Garamond). Fonts embedded as woff2 in `05-kuro-fonts.css` (only these two families — v4's
  Inter/Space Grotesk trimmed, −242 KB). `06-kuro-typography.css` sets `--font-{text,interface,
  editor,monospace}-theme` = mono and gives H1 + inline-title the serif face across Reading +
  Live-Preview + editor (R5). Minimal's heading *ramp* (sizes/weights) is kept — only the H1 face
  changes; finer per-heading tuning (v4's mono-H5 etc.) is deferred (incremental).
- **Verify:** font-var chains are easy to get subtly wrong — confirmed by rendering, not assumed.

#### Callouts (Task 5) — the first layered break-point

- **How Obsidian targets it:** every callout is `.callout` (one selector for Reading *and*
  Live-Preview — `.markdown-source-view.mod-cm6 .callout` resolves to the same node), typed via the
  `[data-callout="…"]` attribute, with `--callout-color` / `--callout-icon` read by Obsidian itself
  for its icon and title. Parts: `.callout-title`, `.callout-icon svg`, `.callout-content`,
  `.callout-fold` (collapsible).
- **How Minimal solves it:** **boxless by default** — Minimal ships no frame, leaning on Obsidian's
  native tint, and hides its real styling behind an *opt-in* body class `.callouts-outlined`
  (`(0,2,0)`+), plus a live-preview readable-line-width centering rule. This is exactly why callouts
  "disappeared" in the failed layered attempt: Kuro's base `.callout` `(0,1,0)` could *set* a border,
  but there was no box to inherit and Minimal's opt-in/native paths fought whatever was layered on top.
- **Specificity / traps:** Minimal's callout weight lives in `.callouts-outlined …` `(0,2,0)` and in
  native `--callout-*` variables set on `body`. A same-or-lower Kuro override loses or is ignored. The
  escape is **ownership, not overriding**: delete Minimal's callout block *at source* so the field is
  clear, then Kuro's single `.callout` `(0,1,0)` base is uncontested. Decorative icon hover-loops are
  deliberately lowered to `(0,0,1)` via `body :where(…)` so the reduced-motion and
  `kuro-no-callout-animations` resets outrank them with a plain class — **no `!important`**.
- **How Kuro replaces it:** `21-kuro-callouts.css` is one owned system — a single `.callout` base
  (1px frame + 4px signal bar + faint self-tint surface + `--lift`), one colour model where each
  `[data-callout]` sets `--callout-color` to a `--role-*-rgb` triplet (built-ins + Kuro's specialised
  types), the special layouts (stat / mood / journal / nav / blank / spoiler / progress) and the icon
  animation library. Minimal's block is removed in `20-minimal-content.css` (only the non-conflicting
  live-preview centering line kept). Titles clamp toward `--tx1` via `color-mix` for AA while the full
  signal stays on the icon + bar.

#### Checkboxes (Task 6) — the second layered break-point

- **How Obsidian targets it:** each task item is `li.task-list-item[data-task="…"]` containing an
  `input.task-list-item-checkbox`. The task *type* is the `[data-task]` attribute (space = open,
  `x`/`X` = done, plus `>`, `<`, `?`, `!`, `i`, `b`, `p`, `c`, `f`, `k`, …). Obsidian reads
  `--checkbox-color`, `--checkbox-radius`, `--checkbox-margin`, `--checkbox-marker-color`.
- **How Minimal solves it:** a `-webkit-mask-image` system — for each alternate task type it sets
  `--checkbox-marker-color: transparent`, `background-color: currentColor` and a per-type SVG
  `-webkit-mask-image`, turning the box into a masked glyph. Empty `[ ]` gets no fill and, crucially,
  **no visible box**.
- **Specificity / traps:** the mask rules are `input[data-task="x"]:checked` `(0,2,1)` and
  `li[data-task="x"] > p > input:checked` `(0,2,3)` — higher than a plain base — AND they live in
  `30-minimal-features.css`, which builds **after** `22-kuro-checkboxes.css`. So even an
  equal-specificity Kuro rule loses on source order. That is why Kuro's glyphs "didn't take" in the
  failed layered attempt and empty boxes were invisible. The escape (again): **delete Minimal's block
  at source**, then Kuro is uncontested. Kuro additionally lowers its base to `(0,1,1)` via `:where()`
  on the view-context selectors, so `:checked`/`[data-task]` override it without `!important`.
- **How Kuro replaces it:** `22-kuro-checkboxes.css` — one `-webkit-appearance:none` base (visible
  square, `--radius-sm`, `--check-border`, faint accent wash) covering Reading + Live-Preview +
  source; an accent-filled `:checked` with an on-accent `--check-marker` tick; and a `::after` glyph
  per `[data-task]` coloured from the role palette (done ✓, cancelled –, deferred ›, scheduled ‹,
  question ?, important !, info i, bookmark ⌖, pro +, con −, fire 🔥, key 🔑). Empty `[ ]` reads as a
  clean square. Completed lines get a token-mapped strikethrough. `--checkbox-margin`/size stay
  Minimal's (native geometry Kuro consumes).

#### Tags (Task 7)

- **How Obsidian targets it:** a reading-view tag is a single `a.tag` span; in Live-Preview the
  hashtag is split across three CM spans `.cm-hashtag-begin/-middle/-end`. Obsidian renders both from
  the native `--tag-color`, `--tag-background`, `--tag-border-color`, `--tag-size`, `--tag-radius`,
  `--tag-padding-x/y` variables (and their `-hover` pairs, consumed by Obsidian's own `a.tag:hover`).
- **How Minimal solves it:** sets the `--tag-*` variables on `body:not(.minimal-unstyled-tags)`
  `(0,1,0)` — a transparent, muted pill with a `--background-modifier-border` outline — plus a
  `.minimal-unstyled-tags` opt-in that strips it. Purely variable-driven; no per-span rules.
- **Specificity / traps:** Minimal's values sit at `(0,1,0)` (the `:not()` adds the class), so a
  plain `body`/`.theme-*` `--tag-*` override from Kuro would *lose*. Not a Live-Preview-mask trap like
  callouts/checkboxes, but still an at-source removal: drop Minimal's block so Kuro's values are
  uncontested. (And, per the T5 scope lesson, Kuro's values read `--accent`/`--tx2`, so they must sit
  on `.theme-*`, not `:root`.)
- **How Kuro replaces it:** `23-kuro-tags.css` sets the `--tag-*` values to an **accent-tinted pill**
  (7% accent bg, 30% accent border, `--tx2` text, accent hover, `--text-xs`, 3px radius) on
  `.theme-*`, then styles `a.tag` + the three `.cm-hashtag-*` spans as one mono pill (the outer two
  carry the rounded ends so the Live-Preview run reads as a single pill). Hover stays var-driven
  (Obsidian's own `:hover` consumes the `-hover` vars — no override, R1). Dark mode adds a signal glow
  (`text-shadow`/`box-shadow` from `--accent-glow`), opt-out via `.kuro-no-glow`.

#### Grey zone: Code · Tables · Blockquote · Lists (Task 8a–8d)

These four have **no high-specificity Live-Preview trap** — Minimal styles them through native
variables and low-specificity rules, and the Kuro fragments build *after* `20-minimal-content` so
they win shared properties by source order. So the transform is a straight token-mapped port from the
v4 quarry (no layered break-point). The shared v4→skeleton token map used throughout: `--fg-primary/
secondary/tertiary → --tx1/2/3`, `--surface-base/raised → --bg1/--bg2`, `--border-subtle → native
--background-modifier-border`; the shared constants `--leading-normal/relaxed`, `--tracking-wide`,
`--radius-full` were added to `04-kuro-tokens`.

- **Code (8a, `24-kuro-code.css`):** inline pill (`--code-bg` = `--bg2`, accent hairline) + fenced
  panel (frame + accent left-stripe) across Reading + Live-Preview, plus the editor CM syntax palette.
  The v4 `--code-*`/`--syntax-*` two-layer palette is collapsed onto roles (normal→link, string→
  warning, value→success, keyword→focus) — both-mode automatic, no hex. **Reading-view code has no
  syntax spans** (Obsidian highlights via Prism `.token.*`, not styled); the `.cm-*` rules are
  Live-Preview/editor only. `--code-*` sit on `.theme-*` (they read roles — T5 scope rule).
- **Tables (8b, `25-kuro-tables.css`):** caps header on a raised surface (`--bg2`), `--tracking-wide`
  uppercase label, cell borders (native), row hover + zebra opt-in (`--overlay-hover`). Minimal's own
  `--table-*` edge-cell geometry stays in `20-minimal-content`; Kuro wins the styling by source order.
- **Blockquote (8c, `26-kuro-blockquote.css`):** the "raven's aside" — serif-italic (`--kuro-font-
  serif`), accent bar + faint accent wash over `--bg1`, one model for Reading `blockquote` and
  per-line CM `.cm-line.HyperMD-quote` (CM6 has no wrapping `<blockquote>`). Minimal's block removed
  at source.
- **Lists (8d, `27-kuro-lists.css`):** accent bullet markers, tertiary ordered numbers, relaxed
  leading, 24px nesting indent, calm indent guides. Additive over Minimal (Minimal sets no marker
  colours — markers inherited Obsidian defaults), so nothing is removed at source.

#### Graph (Task 8f)

- **How Obsidian targets it:** the graph is a **WebGL canvas** — it does *not* honour CSS on
  nodes/edges. Instead Obsidian reads the computed `color` off a set of invisible probe classes
  (`.graph-view.color-fill`, `.color-line`, `.color-circle`, `.color-text`, …) via `getComputedStyle`
  and paints the canvas from those samples.
- **How Kuro replaces it:** `29-kuro-graph.css` sets `color:` on each probe from a `--graph-*` palette
  collapsed onto roles (node→neutral, tag→warning, attachment→drift, focused→`--tx1`, active/ring/
  arrow→accent, line→accent mix, text→`--tx3`, unresolved→faint `--tx1`). `--graph-*` sit on `.theme-*`
  (they read roles/accent — T5 scope rule). Minimal ships no graph probes, so Kuro's are uncontested.
- **Verification:** there is no DOM to screenshot (the canvas is WebGL), so this fragment is verified
  by **code review**, not the render harness — the mapping is mechanical and both-mode by construction.
  A real graph view (Jay) confirms the final look.

#### Ambience · reduced-motion · Style Settings (Task 9)

- **Ambience (`80-kuro-ambient.css`):** dark-only atmosphere, additive (no component owns it) —
  a ~3% film-grain overlay (`body.theme-dark .workspace::after`, an inline fractal-noise SVG data-URI)
  and a soft glow on H1 + inline title (`text-shadow` from `--accent-glow`). The glow honours the
  `.kuro-no-glow` opt-out; both are `.theme-dark`-gated.
- **Reduced-motion (`85-kuro-reduced-motion.css`):** the a11y-whitelist fragment. Under
  `@media (prefers-reduced-motion: reduce)` it near-zeroes all transitions/animations and hard-stops
  the decorative callout-icon loops. This is the ONE fragment allowed un-tagged `!important`
  (check.sh whitelists it by filename) — the resets must beat any third-party animation. Verified by
  code review + check.sh (the media query isn't exercised by the default render).
- **Style Settings (`02-kuro-settings.css`):** Kuro's `@settings` YAML block (`id: kuro-theme`,
  coexists with Minimal's `minimal-style`). Exposes only knobs the fragments actually consume:
  `kuro-no-glow`, `kuro-no-callout-animations`, `kuro-callout-style` (filled/subtle/border-only),
  `kuro-table-zebra` (class toggles/select), and the sliders `--kuro-radius-scale`,
  `--kuro-lift-strength`, `--kuro-card-lift-strength`, `--kuro-code-size` (defaults match the token
  defaults in `04-kuro-tokens`/`24-kuro-code`). The whole block is one CSS comment — verified by
  build + check.sh; live parsing needs the Style Settings plugin.

_Remaining cards (Bases — parked) added at each transform step._

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
