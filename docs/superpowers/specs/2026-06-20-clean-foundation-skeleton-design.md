# Kuro — "Clean Foundation" Skeleton Rebuild (v4.0.0)

**Status:** approved-pending-review · 2026-06-20 · **Branch:** `refactor/clean-foundation`
**Supersedes:** `2026-06-19-clean-foundation-refactor-design.md` (same goal; this version
upgrades it from an *in-place refactor* to a *skeleton-first ground-up rebuild*, per Jay's
direction on 2026-06-20, and is grounded in an exhaustive code inventory).

---

## 0 · What changed vs. the 2026-06-19 spec

The 06-19 spec was an *in-place* token consolidation that explicitly deferred a
forkable skeleton as YAGNI. On 2026-06-20 Jay redirected: **stop patching, rebuild
the code ground-up to current best practices, optimally commented / human-readable,
structured as the skeleton other themes can fork from. Build the ideal skeleton first,
then place the existing elements where they belong.**

Three decisions were locked this session:

1. **Skeleton form = forkable repo skeleton.** ONE clean Kuro repo, structurally split
   into `[skeleton]` (theme-agnostic structure + contract) and `[kuro-values]` (taste).
   A new theme = fork, keep the skeleton, swap the values files. **No** separate shared
   package (YAGNI still honoured — the *structure* is the template, not a distributed base).
2. **Per-component files** (~18 focused files, one component per file) — max readability.
3. **Light-mode bugs are in scope.** The inventory proved light mode is broken too
   (dark-pinned KSP tokens). Fixing it visibly changes the light look *at the buggy spots*
   — this counts as a bug fix, not a redesign.

Public contract stays frozen (Jay's live config + the on-ice companion plugin keep working).

---

## 1 · Why (root cause, from the 2026-06-20 inventory)

A 10-agent workflow inventoried the current theme (6 areas, 110 items) and three
independent architecture proposals were synthesised; a completeness critic returned
**"Spine sound."** The findings:

The real root cause is **a dual token system, only one half of which is both-mode:**

- The **Obsidian-native** layer (`--background-*`, `--text-*`, `--checkbox-*`, …) is the
  *only* layer properly theme-scoped — values for both `.theme-dark` (00-base §1) and
  `.theme-light` (00-base §1b).
- The **KSP semantic** layer (`--surface-*`, `--fg-*`, `--border-*`, `--accent*`,
  `--glow-*`, `--shadow-*`) is defined **once** in `01-tokens-canonical.css :root`,
  pinned to the dark `--void` scale, with **no light variant**. Every component that
  consumes it renders dark-tuned colours in light mode.

Concrete consequences (the visible bugs):

| Symptom | Token cause | file:line |
|---|---|---|
| `--fg-primary` = cream (pearl) in **both** modes → wrong in normal light mode | only a light/dark pair exists *under* `body.kuro-low-contrast`, not generally | `01-tokens:60-64`, `20-kuro2:174-185` |
| Preset tints / code / hanko show the dark chamber colour in light | `--surface-*` dark-only | `01-tokens:53-57` |
| Card/callout "lift" + shadow wrong/absent in light or dark | `--shadow-card` hardcoded dark inset highlight, no light value | `01-tokens:135-141` |
| In **dark**, a signal preset's mood barely reaches any surface | presets tint `--background-*` in `.theme-light` but only `--kuro-ink-*` (9 consumers) in `.theme-dark` | `10-v1:71-345` |
| Code stripe/frame invisible in Live-Preview | **zero** `.HyperMD-codeblock` / `.cm-*` rules exist; only `.markdown-rendered pre` | `10-v1` / `00-base` |
| Checkboxes fight themselves | two competing bases: `.task-list-item-checkbox` (`00-base:954`) vs `input.task-list-item-checkbox` + 12 `[data-task]` (`10-v1:997`) | as cited |

Plus structural debt: `--void` defined **3×** (`00-base:54`, `01-tokens:39`, `20-kuro2:28`),
`--signal` **2×** (`00-base:29`, `01-tokens:25`), type/space/radii/motion 2×; headings split
4 ways; callouts 3 bases; tables/blockquotes reading-only; `--role-*` unused; stale rules for
removed effects (aspects, vignette, scanlines, hanko, §40 gamification).

**The one rule that dissolves the whole class of bugs:** every semantic token has an
explicit value for **both** light and dark. Patching per-selector was tried and failed for
exactly this structural reason — and would be thrown away by the rebuild.

---

## 2 · Architecture — skeleton vs. kuro-values

One repo, two conceptual layers, made visible by file tagging and (optionally) a lint:

- **`[skeleton]`** — theme-agnostic structure: the token *contract* (semantic names + the
  both-mode discipline), the module layout, the `@settings` public-contract shape, and every
  component's selector set (which semantic token each reads). Skeleton files contain
  **no** colour/font/shadow literal and **no** `--signal-*`/`--void-*`/`--paper-*` reference
  (except the semantic files, which are *allowed* to read primitives). A fork never edits these.
- **`[kuro-values]`** — taste: the raw palette, the signal presets, the embedded fonts, glow
  intensity. A fork swaps **only** these ~5 files to become a different theme.

**Lint guard (keeps the cut from rotting):** `grep -E '#[0-9a-fA-F]{3,8}|--signal-|--void-|--paper-'`
over any non-values, non-semantic file must be empty. Add as a build.sh check.

---

## 3 · Token architecture (the heart — bugs die here)

Three layers:

1. **Primitives** (`00-primitives.css`, `[kuro-values]`) — the raw palette, defined **once**:
   - 12 `--signal-*` (hex + their 12 `-rgb` triplets, consolidated from the two split blocks).
   - `--void-*` dark ramp (12 steps).
   - **NEW: `--paper-*` light ramp** (12 steps) — light becomes a first-class scale instead of
     ad-hoc hex, so the semantic-light file has a real ramp to map onto.
   - `--font-*` stacks (reconcile the divergent `--font-display`/`--font-mono` copies).
   - numeric scales (type/space/radii/leading/tracking/motion).
   - No semantics, no Obsidian vars, no selectors beyond `:root`.
2. **Semantic, both modes** (`10-semantic-dark.css` + `11-semantic-light.css`, `[skeleton]`) —
   every semantic token (`--surface-*`, `--fg-*`, `--border-*`, `--accent*`, `--code-*`,
   `--shadow-*`/`--glow-*`, per-callout-type accent map, `--hN-*`, tag/nav/graph) gets a value
   in **each** file. The two files are mirrored **key-for-key** so the both-mode rule is
   auditable side by side. *No semantic token may exist in only one file.* This is the fix.
3. **Bridge** (`12-bridge.css`, `[skeleton]`) — the **one** place Obsidian-native tokens are fed
   from the semantic layer (`--background-*`, `--text-*`, `--interactive-*`, `--code-*`,
   `--checkbox-*`, `--callout-*`, `--tag-*`, `--nav-*`, `--graph-*`, `--link-*`). After this file
   no fragment writes a native var directly. **Accent = one path:** `--accent` ← `--interactive-accent`
   via `color-mix()`. **Never** assume `--interactive-accent-rgb` — Obsidian does not emit it
   (documented trap); the current `--accent`/`--accent-glow` already do this correctly and are kept.

---

## 4 · Module layout (forkable, readable)

`build.sh` prepends `HEADER.css`, then concatenates `[0-9][0-9]-*.css` in numeric order
(strictly 2-digit prefixes — no hex `2a`/`2b`, which would break the glob).

| File | Layer | Purpose |
|---|---|---|
| `HEADER.css` | kuro-values | Banner, version, build-order legend, skeleton/kuro-values explainer |
| `00-primitives.css` | kuro-values | Palette + scales, defined ONCE (signals+rgb, void, paper, fonts, numeric) |
| `02-fonts-embedded.css` | kuro-values | Latin-subset woff2 `@font-face` data-URLs (mechanically unchanged) |
| `05-style-settings.css` | skeleton | `@settings` block — PUBLIC CONTRACT (`id: kuro-theme`, frozen) |
| `10-semantic-dark.css` | skeleton | every semantic token, DARK value |
| `11-semantic-light.css` | skeleton | every semantic token, LIGHT value (mirror of 10, key-for-key) |
| `12-bridge.css` | skeleton | semantic → Obsidian-native, ONE place; single accent path |
| `15-base.css` | skeleton | app shell, editor/reading pane, note-pane LIFT/glow, readable-line-width |
| `20-typography.css` | skeleton | h1–h6, inline-title, colourful-headings — one colouring model, all surfaces |
| `21-checkboxes.css` | skeleton | base + all `[data-task]` variants, ONE def, reading+LP+source |
| `22-code.css` | skeleton | code blocks + inline, ALL surfaces (**adds** `.HyperMD-codeblock`/`.cm-*` — the LP fix) |
| `23-links.css` | skeleton | internal/external/unresolved, reading+LP |
| `24-callouts.css` | skeleton | base + per-type accent map + specialised types + icon anims, ONE def |
| `25-tables.css` | skeleton | reading+LP (**adds** `.cm`/`.HyperMD-table-cell`) |
| `26-blockquote.css` | skeleton | reading+LP (**adds** `.HyperMD-quote`/`.cm-quote`) |
| `27-lists.css` | skeleton | markers, nesting, line-height |
| `28-tags.css` | skeleton | one model (resolve dead `--tag-*` vs accent-pill) |
| `29-chrome.css` | skeleton | tabs, nav/file-explorer + active-file stripe (ONE def), outline/backlinks, properties, sidebars |
| `30-bases.css` | skeleton | Bases cards + table views (carried over intact, re-homed) |
| `31-graph.css` | skeleton | graph view colours, token-driven only (resolves the L1253-vs-L2200 dup) |
| `40-features.css` | skeleton | opt-in toggle behaviours (mono-all, margin-tint, zen, active-line, rainbow-indent, tabs-pill/-underline, slides-frame/-numbers/-progress, no-callout-animations) + decorative (film grain, ambient glow, slides base) |
| `50-presets.css` | kuro-values | the 13 signal mood presets — set SEMANTIC surfaces in **both** modes (asymmetry fix) |
| `55-signal-subthemes.css` | kuro-values | per-note frontmatter tints (companion-plugin-set, private) |
| `60-low-contrast.css` | skeleton | `kuro-low-contrast` a11y, ONE token vocabulary (semantic `--fg-*`/`--glow-*`), both modes |
| `70-reduced-motion.css` | skeleton | `prefers-reduced-motion`, audited to cover ALL named keyframes |
| `build.sh` | — | HEADER + numeric glob → `theme.css`; deterministic; + the lint guard from §2 |

Every file opens with a header block: **PURPOSE · LAYER · SETS · USES · DEPENDS-ON · SURFACES.**

> Final file count/numbering may shift by ±1–2 during implementation; the *shape*
> (primitives → both-mode semantic → bridge → base → per-component → features → presets/values
> → a11y) is fixed.

---

## 5 · How the bugs vanish by construction

| Bug | After |
|---|---|
| Toggle accent (dark) | component reads `--accent` (valid both modes via the single accent path) |
| Checkboxes invisible/fighting | ONE def in `21-checkboxes.css` using theme-scoped `--checkbox-*` → visible box + contrasting marker both modes; the two competing bases collapsed |
| Code stripe/frame invisible in LP | `22-code.css` adds `.HyperMD-codeblock`/`.cm-*`; `--code-border`/`--code-stripe` semantic, both modes |
| Glow / "lift behind notes" | `--kuro-lift` applied to `.markdown-preview-sizer`/`.cm-sizer` (desktop, both modes); `--shadow-card` (light) + `--glow-card` (dark) on cards/callouts |
| Light-mode dark-tuned surfaces / cream `--fg` | `11-semantic-light.css` gives `--surface-*`/`--fg-*`/`--border-*` real `--paper`-based values, independent of low-contrast |
| Preset mood weak in dark | `50-presets.css` writes the SAME semantic surface tokens in both branches |

**Critic's two catches (do not forget):** (a) the `checkbox-container` rule near `10-v1:1016-1017`
must get an explicit owner in `21-checkboxes.css` (else the dark bug regresses); (b) graph-view
shadow tokens around `00-base:2200-2222` must be re-homed in `31-graph.css`, not silently dropped.

---

## 6 · Port strategy (skeleton-first, then populate)

1. **Build the empty skeleton** — every file with its header + the full token contract
   (semantic names declared in both `10`/`11`, bridge wired), components empty. Builds clean.
2. **Baseline** — Jay screenshots the current Kuro in light + dark, Reading + Live-Preview,
   as the "before" regression target. (Rendered look is only verifiable by eye — physics limit.)
3. **Port component-by-component** into its file, covering **all** surfaces, driven by semantic
   tokens. The current `src/[0-9][0-9]-*.css` fragments + `theme.css` are **read-only reference**
   to port *from* — they are not edited.
4. The bugs disappear because every token now resolves in both modes.

**Etappes** (each independently buildable + deployable; code-checked by Claude; Jay's eyes only
at the end):
- **E1 — Skeleton + token SSOT.** Primitives consolidated (kill 3×/2× dup), both-mode semantic
  mirror, bridge, base surfaces. Highest risk → first.
- **E2 — Components.** Port each Markdown/UI component into its file, all surfaces.
- **E3 — Features, presets, a11y.** Opt-in toggles, both-mode presets, low-contrast, reduced-motion.
- **E4 — Docs + `!important` reduction + dead-code/comment removal + final validation:**
  13 presets × light/dark/low-contrast, determinism, size, 0 remote import → release.

---

## 7 · Invariants (true across every step)

1. **The look does not change** — except the in-scope light/dark token bugs get fixed (those
   spots visibly change for the better). Not a redesign.
2. **Public contract frozen** — `@settings id: kuro-theme` + every `kuro-*` class id +
   `--kuro-font-serif`/`--kuro-font-mono` unchanged. Internal `--kuro-*`/`--signal-*`/`--void-*`/
   `--surface-*`/… are free to reorganise.
3. **Zero-dependency build** — `build.sh` numeric-prefix concat → `theme.css`. Deterministic
   (double-build md5-identical).
4. **Submission invariants** — 0 remote `@import`, fonts embedded, < 5 MB, `!important` only where
   Obsidian's specificity forces it (documented, target ≤ current 70).

---

## 8 · Comment standard (best-practice, human-readable)

Per-file header block, e.g.:

```css
/* ─────────────────────────────────────────────────────────────────────────
   22-code.css                                                  [skeleton]
   PURPOSE   Code blocks + inline code — one definition, every surface.
   LAYER     skeleton (reads semantic tokens; defines no literals)
   SETS      (selectors only)
   USES      --code-bg --code-border --code-stripe --fg-primary --font-mono
   DEPENDS   10/11-semantic, 12-bridge
   SURFACES  Reading (.markdown-rendered pre/code) · Live-Preview
             (.HyperMD-codeblock, .cm-inline-code) · Editor source (.cm-*)
   ───────────────────────────────────────────────────────────────────────── */
```

Plus: each component documents which surfaces it covers; each semantic token group notes its
both-mode intent. A `THEME-AUTHORING.md` explains the fork workflow (§9).

---

## 9 · Fork strategy (the deliverable's payoff)

A new theme = `git clone` + edit **only** the `[kuro-values]` files:

1. `00-primitives.css` — rewrite the 12 `--signal-*` (+ `-rgb`), the `--void` dark ramp, the
   `--paper` light ramp, the `--font-*` stacks. The single biggest lever (~60–150 lines, pure `:root`).
2. `02-fonts-embedded.css` — swap woff2 payloads (keep family names aligned with primitives).
3. `50-presets.css` — replace the mood presets (re-tint the SAME semantic surface names).
4. `HEADER.css` — rewrite the banner.
5. `05-style-settings.css` — **only** the preset option labels/value-list + `name:`. The `id` and
   toggle ids stay for config-compat, or are renamed wholesale for a clean new identity (the one
   "skeleton-with-values-edges" seam, documented in both files' headers).

A fork **never** edits: `10`/`11`-semantic, `12-bridge`, `15-base`, all `2x` components,
`30`/`31`, `40-features`, `60`/`70`, `build.sh`.

---

## 10 · Release

The refactored state is the genuinely-submittable **4.0.0** ("rebuilt foundation"). Public
contract unchanged → no user-facing breaks. Replaces the premature 3.4.0. The §40-gamification
extraction (`afe8053`) + the rewritten demo note are the clean starting point.

## Out of scope

- A separate shared multi-theme framework/package (the *structure* is the template; deferred
  until a second theme actually exists).
- Field Report theme; the companion plugin's own code.
- Any visual redesign beyond fixing the in-scope token bugs.
