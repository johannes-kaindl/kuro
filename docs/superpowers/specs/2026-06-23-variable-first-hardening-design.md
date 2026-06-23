# Kuro v4.0.1 — Variable-First Hardening (Design + Implementation Spec)

**Date:** 2026-06-23
**Status:** approved (design gate passed)
**Predecessor:** `2026-06-20-clean-foundation-skeleton-design.md` (the Armature). This is a
**hardening pass on the Armature, NOT a rebuild** — the skeleton is sound.
**Ships as:** 4.0.1, **before** the community submission (the review bot pulls `theme.css`
from the release asset, so fixes must land in a release first).

---

## 1. Motivation

After v4.0.0 shipped, two problems remained:

1. **Chrome fixes were guessed.** White active-tab corners, tab-style switching, and the
   command-palette selection highlight were patched by guessing Obsidian's selectors and
   reaching for `!important` (WIP commit `b26a739`). Guessing is why they miss.
2. **`!important` overuse.** The build carries **24 functional** `!important` declarations
   (the `check.sh` `grep -c` reports 29, but 5 of those are the string `!important` inside
   comment prose — a precision bug that this spec also fixes).

The fix is to **ground every override in Obsidian's real CSS-variable API** and convert
property-overrides into variable bridges or matched-specificity rules wherever Obsidian
exposes the means — then **embed the rules as enforced guardrails** so no future agent can
reintroduce the smell.

## 2. Goals

- **G1 — Ground in the official API.** Every chrome fix maps to a *verified* Obsidian
  variable or a *measured* selector specificity. Source: the official
  `docs.obsidian.md/Reference/CSS+variables/` reference (researched 2026-06-23, see §4).
- **G2 — Variable-first refactor + `!important` audit.** Reduce 24 → single digits
  (target **≤9**, expected **8**), each remaining one justified and enforced.
- **G3 — Re-fix the open chrome bugs the right way** (variable / specificity, no guessing).
- **G4 — Guardrails in three layers:** a canonical doc, per-file rule-stamps + `AGENTS.md`,
  and **`check.sh` enforcement** of the `!important` discipline.

## 3. Non-goals / invariants

- **No rebuild.** The Armature ([armature]/[values] split, both-mode mirror) stays.
- **`kuro-*` public contract frozen** — no Style-Settings / companion config breaks.
- **Look preserved** except the bug-fixes themselves (the `:where()` restructures are
  specificity-only; behaviour is identical when no opt-out/a11y rule is active).
- **`[values]` files untouched** (`00-primitives`, `02-fonts`, `50-presets`, `55-subthemes`).
- **No new dependencies.** `build.sh`/`check.sh` stay zero-dep, deterministic.

---

## 4. Verified Obsidian variable map (the SSOT, with sources)

All names below are `verified=true` against the official reference unless flagged.
The docs publish **no default values** (Variable + Description columns only) — a theme
relies on the *name/semantics contract*, not documented defaults.

| Surface | Official variables | Source page |
|---|---|---|
| **Tabs** | `--tab-background-active`, `--tab-container-background`, `--tab-text-color`, `--tab-text-color-active`, `--tab-text-color-focused`, `--tab-text-color-focused-active`, `--tab-text-color-focused-active-current`, `--tab-text-color-focused-highlighted`, `--tab-outline-color`, `--tab-outline-width`, `--tab-divider-color`, `--tab-curve`, `--tab-radius`, `--tab-radius-active`, `--tab-font-size`, `--tab-font-weight`, `--tab-stacked-*` (8) | `…/Components/Tabs` |
| **Window frame** | `--titlebar-background`, `--titlebar-background-focused`, `--titlebar-border-width`, `--titlebar-border-color`, `--titlebar-text-color`, `--titlebar-text-color-focused`, `--titlebar-text-weight`, `--header-height` | `…/Window/Window+frame` |
| **Checkbox** | `--checkbox-color` (checked bg), `--checkbox-color-hover`, `--checkbox-border-color` (unchecked border), `--checkbox-border-color-hover`, `--checkbox-marker-color`, `--checkbox-radius`, `--checkbox-size` | `…/Components/Checkbox` |
| **Tag** | `--tag-color`, `--tag-color-hover`, `--tag-background`, `--tag-background-hover`, `--tag-border-color`, `--tag-border-color-hover`, `--tag-border-width`, `--tag-decoration(-hover)`, `--tag-radius`, `--tag-padding-x/-y`, `--tag-size`, `--tag-weight` | `…/Editor/Tag` (NOT `/Components/Tag` — 404s) |
| **Callout** | `--callout-radius`, `--callout-padding`, `--callout-border-width/-opacity`, `--callout-blend-mode`, `--callout-title-*`, `--callout-content-*`, + per-type `--callout-<type>` colours | `…/Editor/Callout` |
| **Suggestion / command palette** | **No official variable exists** for the selected-item background; no Suggestion/Menu page. → specificity, not variable. | `…/Components/Prompt`, `…/Components/Modal` |

**Official best-practice quotes (G4 doc cites these):**
- Theme guidelines: *"Declaring styles as `!important` prevents users from overriding styles
  from your theme using snippets."* (`…/Themes/App+themes/Theme+guidelines`)
- Obsidian October checklist: *"Don't use `!important`"*, *"Do use CSS variables whenever you
  can."* (`…/oo/theme`)
- About styling: override the **variables** under `.theme-dark`/`.theme-light` rather than
  writing custom property rules — *"without the need for complex CSS selectors."*

---

## 5. Implementation

### Block A — Bridge corrections (`12-bridge.css`, verified, low-risk)

| Action | Line | Reason |
|---|---|---|
| `--checkbox-marker` → **`--checkbox-marker-color`** | 155 | dead name — Obsidian reads `…-color`; a hidden cause of the checkbox `!important` reliance |
| `--tag-font-size` → **`--tag-size`** | 129 | official name (and update the consumer in `28-tags.css:28`) |
| **remove** `--titlebar-text-color-highlighted` | 193 | does not exist on the Window-frame page (bogus) |
| **add** `--tag-color-hover: var(--accent)` | tag block | was missing → blocked the tag-hover bridge |
| **add** tab geometry: `--tab-curve`, `--tab-radius`, `--tab-radius-active`, `--tab-outline-width` (point at existing `--radius-*`/metric tokens) | tab block | theme the active-tab curve instead of hardcoding → kills the white-corner fallback |

### Block B — `!important` out via the cascade (checkbox + tag)

**Checkbox (`21-checkboxes.css`, −2):** the `:checked` `!important` (lines 53–54) is
load-bearing only because the **base rule outranks it in Live-Preview** (base
`.markdown-source-view.mod-cm6 input.task-list-item-checkbox` = `(0,3,1)` > `:checked`
`(0,2,1)`; notation = id, class/attr/pseudo, element). Fix by **lowering the base to a true
fallback** with `:where()`:

```css
input.task-list-item-checkbox,
:where(.markdown-rendered) input.task-list-item-checkbox,
:where(.markdown-source-view.mod-cm6) input.task-list-item-checkbox { … }   /* all (0,1,1) */
```

Then `:checked` `(0,2,1)` and `[data-task=…]` `(0,2,1)` win **without** `!important`. Drop
both `!important`; keep the rule (robust explicit fill). The `--checkbox-marker-color`
rename (Block A) makes the check glyph colour reach Obsidian's own renderer.

**Tag (`28-tags.css`, −3):** delete the `a.tag:hover { … !important }` rule (lines 65–69).
With `--tag-color-hover`/`--tag-background-hover`/`--tag-border-color-hover` set in the bridge
(Block A), **Obsidian's own `a.tag:hover` rule consumes them** — no theme hover rule needed.
Update the `font-size` consumer and `USES` header (`--tag-font-size` → `--tag-size`).

### Block C — Command-palette highlight (`29-chrome.css`, −2, specificity)

No official variable exists. Obsidian's selected-row rule is `.suggestion-item.is-selected`
`(0,2,0)` (palette: `.mod-command-palette …` `(0,3,0)`); themes load **after** `app.css`, so
the generic `(0,2,0)` rule wins on source order. **Drop both `!important`** (lines 275–276),
keep the dual selector, and scope the palette variant as
`.prompt.mod-command-palette .suggestion-item.is-selected` `(0,4,0)`, which **outranks**
Obsidian's `(0,3,0)` palette rule outright (the generic `(0,2,0)` would lose to it). The
highlight stays accent-driven via `color-mix(var(--interactive-accent) …)` (both-mode safe).

### Block D — Callout animation restructure (`24-callouts.css` −8, `70-reduced-motion.css` −1)

The decorative hover-icon loops (lines 257–302) are `.callout[data-callout="x"]:hover
.callout-icon svg` = **`(0,4,1)`** (the file comments mislabel them `(0,3,1)`). The opt-out
(`body.kuro-no-callout-animations …` `(0,3,1)`) and the reduced-motion resets `(0,2,1)`
cannot beat that → hence 8 `!important`.

**Fix:** wrap each animation selector so it contributes the lowest sensible specificity:

```css
body :where(.callout[data-callout="x"]:hover .callout-icon svg) { animation: … }   /* (0,0,1) */
```

`body` is a stable anchor; `:where(...)` zeroes the rest → `(0,0,1)`. Now every opt-out and
reduced-motion rule (all ≥ `(0,1,0)`) wins **without** `!important`:
- `24-callouts.css` reduced-motion block (lines 329–338) — drop 4 `!important`.
- `24-callouts.css` `kuro-no-callout-animations` block (lines 342–349) — drop 4 `!important`.
- `70-reduced-motion.css:36` (`.callout * { animation:none }`) — drop the `!important`; keep
  the rule as an explicit a11y guarantee (now `(0,1,0)` > `(0,0,1)`, wins cleanly).
- Fix the stale `(0,3,1)` specificity comments while there.

Rejected alternative: `@layer` (one wrap vs ~22). The Obsidian docs do **not** confirm
cascade-layer support against `app.css`; `:where()` is plain CSS and safe. Chosen: `:where()`.

### KEEP — justified `!important` (8 remaining, each tagged)

- `40-features.css` `kuro-mono-all` font (lines 36, 46, 56, 57 → **4**): Obsidian applies
  `font-family` at app level; no variable reaches the editor surfaces. Inline-tag each.
- `70-reduced-motion.css` global reset (lines 24–27 → **4**): the idiomatic
  `prefers-reduced-motion` blanket over all theme **and plugin** motion. This file is the
  enforcement whitelist (see §6).

**Expected final count: 24 → 8.** `check.sh` gate tightened `≤70` → **`≤9`**.

---

## 6. Guardrails (G4, three layers)

**Layer (a) — canonical doc `docs/CSS-CONVENTIONS.md`:** the rules R1–R6, the verified
variable map (§4) with source URLs, links to the official reference + theme guidelines, and
the `!important` tag format. Cross-links `THEME-AUTHORING.md` (which already states R3/R4).

**Layer (b) — per-file rule-stamp + `Kuro/AGENTS.md`:** each fragment header gains a one-line
`RULES` pointer (`see docs/CSS-CONVENTIONS.md · R1 variable-first · R2 tag every !important`).
A new `Kuro/AGENTS.md` (auto-read by agents) summarises the workflow + R1–R6 and points at
the doc. So an agent reading a single fragment still sees the rules.

**Layer (c) — `check.sh` enforcement (the teeth):**
1. **Precise `!important` count** — count only real declarations (strip CSS comments first,
   reusing the existing `strip()` helper) so prose never inflates the number. Report it.
2. **Tag-or-whitelist rule** — every line containing a real `!important` must either live in
   `70-reduced-motion.css` (the a11y whitelist) **or** carry an inline
   `/* important: <reason> */` tag on the same line. Otherwise the build fails with the
   offending file:line.
3. **Gate** `≤9` (was `≤70`).

**The rules (R1–R6):**
- **R1 — variable-first.** If Obsidian exposes a variable for it, set the variable (in
  `12-bridge.css`); do not write a property override.
- **R2 — `!important` only with justification.** Every `!important` carries an inline
  `/* important: <reason> */` tag, or lives in `70-reduced-motion.css`. Enforced by `check.sh`.
- **R3 — both-mode.** Every semantic token has a value in `10-` AND `11-`. Enforced.
- **R4 — layer discipline.** `[armature]` files carry no colour literal / `--signal-*` /
  `--void-*` / `--paper-*`. Enforced.
- **R5 — one component, all surfaces.** Each component is defined once across Reading +
  Live-Preview + editor (not Reading-only).
- **R6 — always `build.sh` + `check.sh`.** Never edit `theme.css` directly; every change
  keeps `check.sh` green.

---

## 7. Verification

After `build.sh` + `check.sh` (ALL CHECKS PASS) and deploy to 10_Pallas, an **adversarial
review workflow** re-checks each block against the API and specificity reasoning and scans
for regressions. Then **Jay's DevTools (Cmd+Opt+I)** confirm the items the research could only
derive from `app.css` convention, not the docs:

1. **White tab corners gone** with `--tab-container-background` + `--tab-background-active`
   bridged (inspect the active-tab corner element; confirm `--tab-curve`/`--tab-radius` apply).
2. **Checkbox fill** renders for `:checked` and `[data-task=x]` in **both** Reading and
   Live-Preview after the `:where()` base + `!important` removal.
3. **Tag hover** picks up the `-hover` variables in **both** Reading and Live-Preview after
   the custom hover rule is deleted (CM hashtag spans are not hover targets — re-verify).
4. **Command-palette highlight** still lands on the selected row without `!important`.

If any fails, Jay pastes the DevTools computed-styles / selector and the fix targets the real
selector — not a guess.

## 8. Risks

- **R-1 (medium):** the `:where()` specificity reasoning for checkbox/callout is sound but
  Obsidian could re-scope its own rules in a future release. Mitigated by DevTools verify +
  the explicit a11y backstop rule.
- **R-2 (low):** deleting the tag-hover rule relies on Obsidian's `a.tag:hover` reading the
  `-hover` vars; verify Reading + Live-Preview.
- **R-3 (low):** `--titlebar-*` only take effect with Appearance → Window frame = "Obsidian
  frame"; the white-corner fix is primarily the `--tab-*` bridge.
- **R-4 (submission):** confirm the 4.0.1 GitHub Release ships `manifest.json` + `theme.css`
  as binary assets on a `4.0.1` tag (Jay-side, at submission time).
