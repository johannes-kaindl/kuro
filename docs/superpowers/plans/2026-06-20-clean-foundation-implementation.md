# Kuro v4 "Clean Foundation" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild Kuro from the ground up as a forkable theme **Armature** (`[armature]` structure) + swappable `[values]`, with a both-mode token SSOT that fixes the light/dark bugs by construction, one file per component covering all surfaces, optimal comments — shipping as v4.0.0 with the public `kuro-*` contract frozen.

**Architecture:** `build.sh` prepends `HEADER.css` then concatenates `src/[0-9][0-9]-*.css` numerically → `theme.css` (zero-dep, deterministic). Tokens flow Primitives (`[values]`) → both-mode Semantic mirror (`10-dark`/`11-light`, `[armature]`) → Bridge to Obsidian-native vars (`12`, `[armature]`) → components read **only** semantic tokens. A fork swaps the ~5 `[values]` files and never touches an `[armature]` file. The current `src/` fragments + `theme.css` are **read-only reference** to port FROM.

**Tech Stack:** Hand-authored CSS fragments · POSIX `bash` build + verification harness · macOS `md5` · no Node, no network, no preprocessor.

**Spec:** `docs/superpowers/specs/2026-06-20-clean-foundation-skeleton-design.md`.

---

## Ground rules for every task

- **Never edit `theme.css` directly** — it is generated. Edit fragments, run `bash src/build.sh`.
- **`[armature]` files contain no literal** — no hex, no `--signal-*`/`--void-*`/`--paper-*`. They read semantic tokens by name. (The two semantic files `10`/`11` are the only `[armature]` files allowed to reference primitives.) Enforced by `src/check.sh`.
- **Both-mode rule** — any token in `10-semantic-dark.css`'s `.theme-dark{}` MUST have a same-named sibling in `11-semantic-light.css`'s `.theme-light{}`. Enforced by `src/check.sh`.
- **Port, don't invent** — when a component task says "port", lift the *current computed values* from the cited source rule so the look is preserved; only the dark/light token bugs change.
- **Verify every task** with `bash src/check.sh` (build + determinism + invariants + both-mode mirror + armature-lint). A task is done only when `check.sh` prints `ALL CHECKS PASS` and the task's own grep assertions hold.
- **Commit after every task** with the message shown.
- **Work happens in a fresh `src-v4/` dir, swapped in at the end** — so the current `src/` stays a working reference throughout E1–E3. Final swap is an E4 task. (Build during E1–E3 targets `src-v4/build.sh` → a scratch `theme-v4.css` for checking; the real `theme.css` is only regenerated at the E4 swap.)

---

## File structure (target `src-v4/`, becomes `src/` at E4)

| File | Layer | Responsibility |
|---|---|---|
| `HEADER.css` | values | Banner: name, version, build-order legend, Armature/values explainer |
| `00-primitives.css` | values | Raw palette + scales ONCE: 12 signals (+`-rgb`), `--void` dark ramp, `--paper` light ramp, fonts, type/space/radii/leading/tracking/motion |
| `02-fonts-embedded.css` | values | woff2 `@font-face` data-URLs (copied byte-for-byte from current `src/02-fonts-embedded.css`) |
| `05-style-settings.css` | armature | `@settings` block, `id: kuro-theme` — PUBLIC CONTRACT, frozen |
| `10-semantic-dark.css` | armature | `.theme-dark{}` — every mode-varying semantic token, mapped to `--void`/`--signal` |
| `11-semantic-light.css` | armature | `.theme-light{}` — same keys, mapped to `--paper`/`--signal` |
| `12-bridge.css` | armature | `:root{}` — mode-independent semantic aliases (`--accent*`, `--role-*`) + feed Obsidian-native vars from semantic tokens |
| `15-base.css` | armature | app shell, splits/sidebars, editor+reading pane surface, note-pane LIFT/glow, readable-line-width, body type wiring |
| `20-typography.css` | armature | h1–h6 + inline-title + colourful-headings — one colouring model, all surfaces |
| `21-checkboxes.css` | armature | checkbox base + all `[data-task]` variants, ONE def, reading+LP+source |
| `22-code.css` | armature | code blocks + inline code, ALL surfaces (adds `.HyperMD-codeblock`/`.cm-*`) |
| `23-links.css` | armature | internal/external/unresolved links, reading+LP |
| `24-callouts.css` | armature | callout base + per-type accent map + specialised types + icon anims |
| `25-tables.css` | armature | tables, reading+LP |
| `26-blockquote.css` | armature | blockquotes, reading+LP |
| `27-lists.css` | armature | list markers, nesting, line-height |
| `28-tags.css` | armature | tags, one model |
| `29-chrome.css` | armature | tabs, nav/file-explorer + active-file stripe, outline/backlinks, properties, sidebars |
| `30-bases.css` | armature | Bases cards + table views |
| `31-graph.css` | armature | graph view colours, token-driven |
| `40-features.css` | armature | opt-in toggles (mono-all, margin-tint, zen, active-line, rainbow-indent, tabs-pill/-underline, slides-*, no-callout-animations) + decorative (film grain, ambient glow, slides base) |
| `50-presets.css` | values | 13 signal mood presets — set semantic surfaces in BOTH modes |
| `55-signal-subthemes.css` | values | per-note frontmatter tints (companion-set, private) |
| `60-low-contrast.css` | armature | `kuro-low-contrast` a11y, one token vocabulary, both modes |
| `70-reduced-motion.css` | armature | `prefers-reduced-motion`, all keyframes |
| `build.sh` · `check.sh` | — | build + verification harness |

---

## The Armature semantic-token contract (authoritative)

These keys live in BOTH `10-semantic-dark.css` (`.theme-dark{}`) and `11-semantic-light.css` (`.theme-light{}`):

```
--surface-vault --surface-primary --surface-raised --surface-overlay --surface-inset
--fg-primary --fg-secondary --fg-tertiary --fg-disabled --fg-on-accent
--border-subtle --border-default --border-strong
--code-bg --code-border --code-stripe        (NEW — makes code both-mode)
--shadow-card --shadow-modal                  (NEW light variants)
--glow-card                                   (NEW — dark note/card lift; light = none)
```

Mode-independent semantic tokens live in `12-bridge.css` `:root{}` (they derive from system accent / signals, identical in both modes):

```
--accent --accent-soft --accent-glow          (← var(--interactive-accent) + color-mix)
--glow-accent --glow-focus
--border-circuit                               (color-mix of --signal-circuit)
--role-error --role-success --role-warning --role-info --role-link --role-focus --role-review --role-drift
```

Dark mappings (from current `01-tokens-canonical.css`, preserved):
`--surface-vault=--void-050 · -primary=--void-100 · -raised=--void-150 · -overlay=--void-200 · -inset=rgba(4,5,7,.5) · --fg-primary=--signal-pearl · -secondary=--void-700 · -tertiary=--void-600 · -disabled=--void-500 · -on-accent=--void-050 · --border-subtle=--void-300 · -default=--void-400 · -strong=--void-500`.

Light mappings (NEW, mirror the *role*, mapped onto `--paper`): `--surface-vault=--paper-050 · -primary=--paper-000 · -raised=--paper-100 · -overlay=--paper-000 · -inset=--paper-100 · --fg-primary=--paper-900(ink) · -secondary=--paper-700 · -tertiary=--paper-600 · -disabled=--paper-400 · -on-accent=--paper-000 · --border-subtle=--paper-200 · -default=--paper-300 · -strong=--paper-400`. Exact `--paper` hex is authored in E1-T2 from the current `.theme-light` values so light looks unchanged except where it was buggy.

---

## PHASE E1 — The Armature foundation

### Task E1.0: Scaffold `src-v4/` + the verification harness

**Files:** Create `src-v4/build.sh`, `src-v4/check.sh`, `src-v4/HEADER.css`; copy `src/02-fonts-embedded.css` → `src-v4/02-fonts-embedded.css`.

- [ ] **Step 1: Create the dir and copy the fonts fragment verbatim**

```bash
cd /Users/Shared/code/kuro-obsidian-theme/Kuro
mkdir -p src-v4
cp src/02-fonts-embedded.css src-v4/02-fonts-embedded.css
```

- [ ] **Step 2: Write `src-v4/build.sh`**

```bash
#!/usr/bin/env bash
# Build theme-v4.css from src-v4 fragments. Prepend HEADER, then numeric glob.
set -euo pipefail
cd "$(dirname "$0")"
out="../theme-v4.css"
{ cat HEADER.css; for f in [0-9][0-9]-*.css; do printf '\n'; cat "$f"; done; } > "$out"
echo "built $out ($(wc -c < "$out") bytes)"
```

- [ ] **Step 3: Write `src-v4/check.sh` (the test harness)**

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
bash build.sh >/dev/null
a=$(md5 -q ../theme-v4.css); bash build.sh >/dev/null; b=$(md5 -q ../theme-v4.css)
[ "$a" = "$b" ] || { echo "FAIL: non-deterministic build"; exit 1; }
o=$(tr -cd '{' < ../theme-v4.css | wc -c); c=$(tr -cd '}' < ../theme-v4.css | wc -c)
[ "$o" -eq "$c" ] || { echo "FAIL: brace imbalance $o/{ $c/}"; exit 1; }
imp=$(grep -c '!important' ../theme-v4.css || true); echo "  !important: $imp"
[ "$imp" -le 70 ] || { echo "FAIL: !important $imp > 70"; exit 1; }
[ "$(grep -c '@import url(http' ../theme-v4.css || true)" -eq 0 ] || { echo "FAIL: remote @import"; exit 1; }
sz=$(wc -c < ../theme-v4.css); [ "$sz" -lt 5242880 ] || { echo "FAIL: size $sz >= 5MB"; exit 1; }
# both-mode mirror (only enforced once both semantic files exist)
if [ -f 10-semantic-dark.css ] && [ -f 11-semantic-light.css ]; then
  d=$(grep -oE -- '--[a-z0-9-]+[[:space:]]*:' 10-semantic-dark.css | grep -oE -- '--[a-z0-9-]+' | sort -u)
  l=$(grep -oE -- '--[a-z0-9-]+[[:space:]]*:' 11-semantic-light.css | grep -oE -- '--[a-z0-9-]+' | sort -u)
  if [ "$d" != "$l" ]; then echo "FAIL: semantic mirror mismatch:"; diff <(echo "$d") <(echo "$l"); exit 1; fi
  echo "  both-mode mirror: OK"
fi
# armature-lint: no literals in [armature] files (all except values: HEADER/00/02/50/55)
for f in [0-9][0-9]-*.css; do
  case "$f" in 00-*|02-*|50-*|55-*|10-semantic-*|11-semantic-*) continue;; esac
  if grep -nEq -- '#[0-9a-fA-F]{3,8}\b|--signal-|--void-|--paper-' "$f"; then
    echo "FAIL: literal/primitive in armature file $f:"; grep -nE -- '#[0-9a-fA-F]{3,8}\b|--signal-|--void-|--paper-' "$f"; exit 1
  fi
done
echo "ALL CHECKS PASS"
```

- [ ] **Step 4: Write `src-v4/HEADER.css`** (the banner + the Armature story)

```css
/* ╔══════════════════════════════════════════════════════════════════════╗
   ║  KURO  v4.0.0  ·  Neo-Gothic / Post-Cyberpunk Obsidian theme          ║
   ║  Built on the ARMATURE — a forkable theme skeleton.                    ║
   ║                                                                        ║
   ║  BUILD ORDER (build.sh = HEADER + numeric glob, zero-dep, det.):      ║
   ║   00 primitives[v] · 02 fonts[v] · 05 settings · 10/11 semantic ·     ║
   ║   12 bridge · 15 base · 20–31 components · 40 features ·              ║
   ║   50 presets[v] · 55 subthemes[v] · 60 low-contrast · 70 reduced-mo.  ║
   ║                                                                        ║
   ║  [armature] = structure/contract — NO colour literals, reads tokens.  ║
   ║  [values]   = taste — palette/presets/fonts. FORK = swap [v] files.   ║
   ║  See THEME-AUTHORING.md.                                               ║
   ╚══════════════════════════════════════════════════════════════════════╝ */
```

- [ ] **Step 5: Make executable + verify the harness runs**

```bash
chmod +x src-v4/build.sh src-v4/check.sh
bash src-v4/check.sh
```
Expected: builds, prints `!important: 0`, `ALL CHECKS PASS` (no semantic files yet → mirror skipped; no armature files yet → lint trivially passes).

- [ ] **Step 6: Commit**

```bash
git add src-v4/ && git commit -m "feat(v4): scaffold src-v4 armature build + check harness"
```

### Task E1.1: `00-primitives.css` — palette + scales ONCE

**Files:** Create `src-v4/00-primitives.css`. Reference: `src/01-tokens-canonical.css:23-150` (signals, void, fonts, scales), `src/00-base-x1-foundation.css:43-51,1703-1707` (the `--signal-*-rgb` triplets).

- [ ] **Step 1: Author the file** — a single `:root{}` containing, with section comments:
  - the 12 `--signal-*` hex (verbatim from `01-tokens:25-36`);
  - the 12 `--signal-*-rgb` triplets, consolidated into one block (merge `00-base:43-51` + `:1703-1707`, drop the duplicate `--signal-ghost-rgb`);
  - the `--void-*` dark ramp `000–900` (verbatim from `01-tokens:39-50`);
  - **NEW** `--paper-*` light ramp `000–900`: a warm rice-paper scale, `--paper-000` = lightest (current light `--background-primary`), ascending to `--paper-900` = darkest ink (current light `--text-normal`). Author the 12 hex by reading `src/00-base-x1-foundation.css` `.theme-light` (§1b) background/text values so light is preserved;
  - `--font-display/-sans/-body/-mono` (verbatim from `01-tokens:88-91`);
  - type scale, leading, tracking, spacing, radii, motion (verbatim from `01-tokens:94-149`).
- [ ] **Step 2: Verify primitives resolve** — `bash src-v4/check.sh` → `ALL CHECKS PASS`; then `grep -c -- '--paper-' src-v4/00-primitives.css` ≥ 10 and `grep -c -- '--signal-.*-rgb' src-v4/00-primitives.css` = 12.
- [ ] **Step 3: Commit** — `git add src-v4/00-primitives.css && git commit -m "feat(v4): primitives — signals+rgb, void, NEW paper ramp, scales (once)"`

### Task E1.2: `10-semantic-dark.css` + `11-semantic-light.css` — the both-mode mirror

**Files:** Create both. Reference: the contract table above; dark values from `src/01-tokens-canonical.css:52-141`.

- [ ] **Step 1: Write `10-semantic-dark.css`** — `.theme-dark{}` with every contract key, dark mappings from the contract table; add `--code-bg=var(--surface-inset)`, `--code-border=var(--border-subtle)`, `--code-stripe=var(--accent-glow)`, `--shadow-card`/`--shadow-modal` (verbatim from `01-tokens:135-138`), `--glow-card=var(--glow-accent)`.
- [ ] **Step 2: Write `11-semantic-light.css`** — `.theme-light{}` with the IDENTICAL key set, light mappings onto `--paper` (contract table); `--code-stripe=var(--accent-glow)`; `--shadow-card` = a soft light drop shadow (no white inset); `--shadow-modal` light; `--glow-card=none` (light doesn't glow).
- [ ] **Step 3: Verify mirror** — `bash src-v4/check.sh` must print `both-mode mirror: OK`. If it prints a diff, add the missing key to the lighter file. Expected: `ALL CHECKS PASS`.
- [ ] **Step 4: Commit** — `git add src-v4/10-semantic-dark.css src-v4/11-semantic-light.css && git commit -m "feat(v4): both-mode semantic mirror — every token resolves in light AND dark"`

### Task E1.3: `12-bridge.css` — feed Obsidian-native vars from semantic, ONE place

**Files:** Create `src-v4/12-bridge.css`. Reference: `src/00-base-x1-foundation.css` `.theme-dark` §1 (`:162-339`) + `.theme-light` §1b (`:350-515`) for the full list of native vars Kuro sets.

- [ ] **Step 1: Author `:root{}`** with (a) mode-independent semantic aliases — `--accent`, `--accent-soft`, `--accent-glow`, `--glow-accent`, `--glow-focus`, `--border-circuit`, the 8 `--role-*` (verbatim from `01-tokens:73-85,139-141`); (b) the Obsidian-native feeds, each pointing at a semantic token: e.g. `--background-primary:var(--surface-primary); --background-secondary:var(--surface-raised); --text-normal:var(--fg-primary); --text-muted:var(--fg-secondary); --text-faint:var(--fg-tertiary); --background-modifier-border:var(--border-default); --code-background:var(--code-bg); --checkbox-color:var(--accent); …`. Cover every native var the current §1/§1b set, but source each from a semantic token (never a raw void/paper).
- [ ] **Step 2: Verify** — `bash src-v4/check.sh` → `ALL CHECKS PASS`. Confirm armature-lint passes (12-bridge references only `--surface-*/--fg-*/--border-*/--accent*/--code-*/--role-*/--glow-*`, no `--void-/--paper-/#hex`).
- [ ] **Step 3: Sanity-grep** — every `--background-*`, `--text-*`, `--checkbox-*` that current `theme.css` relies on is present: compare `grep -oE -- '--(background|text|interactive|checkbox|code|callout|nav|tag|graph|link)-[a-z0-9-]+:' src-v4/12-bridge.css | sort -u` against the same grep on current `src/00-base-x1-foundation.css` §1; note any native var not yet bridged in the commit body.
- [ ] **Step 4: Commit** — `git add src-v4/12-bridge.css && git commit -m "feat(v4): bridge — Obsidian-native vars fed from semantic tokens, one place"`

### Task E1.4: `05-style-settings.css` — frozen public contract

**Files:** Create `src-v4/05-style-settings.css` = byte-for-byte copy of `src/05-style-settings.css` (the `@settings` block is the public contract; do not change ids).

- [ ] **Step 1:** `cp src/05-style-settings.css src-v4/05-style-settings.css`
- [ ] **Step 2: Verify contract intact** — `diff <(grep -oE 'id: [^ ]+' src/05-style-settings.css) <(grep -oE 'id: [^ ]+' src-v4/05-style-settings.css)` is empty.
- [ ] **Step 3: Commit** — `git add src-v4/05-style-settings.css && git commit -m "feat(v4): style-settings public contract (frozen, verbatim)"`

### Task E1.5: `15-base.css` — app shell, panes, the note-pane LIFT

**Files:** Create `src-v4/15-base.css`. Reference (port from): `src/00-base-x1-foundation.css` app-shell/editor/reading rules (body type wiring, `.workspace`, splits, `.markdown-preview-view`, `.cm-sizer`, readable-line-width); the `--kuro-lift` callout work from the E1 commit `aa2b66d`.

- [ ] **Step 1: Port** app shell + editor/reading pane base into `15-base.css`, token-driven (surfaces from `--surface-*`, text from `--fg-*`). Apply the note-pane LIFT: `.theme-dark .markdown-preview-sizer, .theme-dark .cm-sizer { box-shadow: var(--glow-card); }` (desktop), light gets `--shadow-card` via the same selector group; both come from semantic tokens so they resolve per mode.
- [ ] **Step 2: Verify** — `bash src-v4/check.sh` → `ALL CHECKS PASS` (armature-lint confirms no literals).
- [ ] **Step 3: Commit** — `git add src-v4/15-base.css && git commit -m "feat(v4): base shell + editor/reading pane + note-pane lift (both modes)"`

**E1 gate:** `bash src-v4/check.sh` green; `theme-v4.css` builds; Claude traces that `--surface-primary`, `--fg-primary`, `--accent`, `--code-stripe`, `--glow-card`/`--shadow-card` each resolve under both `.theme-dark` and `.theme-light`. (No visual check yet — deferred to the single E4 check.)

---

## PHASE E2 — Components (one file each, all surfaces)

> **Every E2 task has the same shape.** Files: create `src-v4/<file>`. Port from the cited current rules. Define each component ONCE, driven by semantic tokens, covering the listed surfaces. Verify: `bash src-v4/check.sh` → `ALL CHECKS PASS` + the per-task grep. Commit: `git add src-v4/<file> && git commit -m "feat(v4): <component> — one def, all surfaces"`. Preserve current computed values (look unchanged) except where a dark/light token bug is fixed.

### Task E2.1: `20-typography.css`
- **Port from:** h1–h6 rules currently split across `00-base`, `10-v1`, `20-kuro2`, `30-plugin-migrated` (grep `--h[1-6]` and `\.markdown-rendered h` across `src/*.css`); colourful-headings base near `20-kuro2:168-170`; inline-title.
- **Surfaces:** Reading (`.markdown-rendered h1…h6`), Live-Preview (`.HyperMD-header-1…6`, `.cm-header-1…6`), inline-title (`.inline-title`).
- **Tokens:** `--fg-primary`, `--accent`, `--font-display`, type scale. One colouring model (delete the 3 competing ones).
- **Grep assert:** `grep -c 'HyperMD-header\|cm-header' src-v4/20-typography.css` ≥ 1 (LP covered).

### Task E2.2: `21-checkboxes.css`
- **Port from:** `src/00-base-x1-foundation.css:954-996` (`.task-list-item-checkbox` + `:checked`) AND `src/10-v1-polish-addendum.css:997-1200` (the `input.task-list-item-checkbox` base + 12 `[data-task]` variants + the `checkbox-container` rule near `:1016`). **Collapse the two competing bases into one.**
- **Surfaces:** Reading + Live-Preview (`.markdown-source-view … input.task-list-item-checkbox`) + the `[data-task]` variants in both.
- **Tokens:** `--checkbox-color`→`--accent`, box bg `--surface-raised`, border `--border-strong`, marker `--fg-on-accent` (NOT hardcoded `#fff`), each `[data-task]` accent from the matching `--role-*`/`--signal-*` via semantic.
- **Critic catch:** the `checkbox-container` rule at `10-v1:1016-1017` MUST be ported here (else dark regresses).
- **Grep assert:** `grep -c 'data-task' src-v4/21-checkboxes.css` ≥ 12; only ONE `.task-list-item-checkbox{` base block.

### Task E2.3: `22-code.css`
- **Port from:** `src/*.css` `.markdown-rendered pre`/`code` rules (the only existing code rules, reading-only). **Add the missing Live-Preview/editor surface from scratch.**
- **Surfaces:** Reading (`.markdown-rendered pre`, `code`), **NEW** Live-Preview/editor (`.HyperMD-codeblock`, `.HyperMD-codeblock-bg`, `.cm-inline-code`, `.cm-codeblock`).
- **Tokens:** bg `--code-bg`, frame `--code-border`, stripe `--code-stripe` (the accent left-border), inline code `--signal-circuit` on `--code-bg`. All both-mode now.
- **Grep assert:** `grep -c 'HyperMD-codeblock\|cm-codeblock' src-v4/22-code.css` ≥ 1 (the LP fix — this is the bug from screenshots #15/#16).

### Task E2.4: `23-links.css`
- **Port from:** internal/external/unresolved link rules in `src/*.css` (grep `internal-link`, `external-link`, `is-unresolved`).
- **Surfaces:** Reading + Live-Preview (add `.cm-link`, `.cm-url`, `.cm-hmd-internal-link`).
- **Tokens:** `--role-link` / `--accent`; unresolved `--fg-disabled`.
- **Grep assert:** `grep -c 'cm-link\|cm-url\|cm-hmd-internal' src-v4/23-links.css` ≥ 1.

### Task E2.5: `24-callouts.css`
- **Port from:** the 3 callout bases (`00-base:~1179`, `00-base:~1639`, `10-v1:~589`) + per-type accent map + specialised types (stat/mood/journal/nav/blank/spoiler/streak) + icon hover anims. **Collapse to one base + one palette.**
- **Surfaces:** Reading + Live-Preview callouts.
- **Tokens:** base bg `--surface-raised`, border/accent from per-type `--role-*`/`--signal-*`; lift `--shadow-card`(light)/`--glow-card`(dark).
- **Grep assert:** exactly ONE `.callout{` base block; `grep -c 'data-callout' src-v4/24-callouts.css` covers the specialised types.

### Task E2.6: `25-tables.css`
- **Port from:** `.markdown-rendered table` rules (reading-only today). **Add LP.**
- **Surfaces:** Reading + Live-Preview (`.cm-table-widget`, `.HyperMD-table-row`).
- **Tokens:** border `--border-subtle`, header bg `--surface-raised`, stripe `--surface-primary`.
- **Grep assert:** `grep -c 'cm-table\|HyperMD-table' src-v4/25-tables.css` ≥ 1.

### Task E2.7: `26-blockquote.css`
- **Port from:** `.markdown-rendered blockquote` (reading-only). **Add LP** (`.HyperMD-quote`, `.cm-quote`).
- **Tokens:** bar `--accent`, text `--fg-secondary`, bg `--surface-primary`.
- **Grep assert:** `grep -c 'HyperMD-quote\|cm-quote' src-v4/26-blockquote.css` ≥ 1.

### Task E2.8: `27-lists.css`
- **Port from:** existing list rules (sparse); author marker colour, nesting indent, line-height.
- **Surfaces:** Reading + Live-Preview markers.
- **Tokens:** marker `--accent`/`--fg-tertiary`, leading from `--leading-relaxed`.

### Task E2.9: `28-tags.css`
- **Port from:** the tag rules; resolve the dead `--tag-*` token system vs the accent-pill — keep ONE (the accent-pill), drop the orphan.
- **Tokens:** pill bg `--accent-soft`, text `--accent`.

### Task E2.10: `29-chrome.css`
- **Port from:** workspace tabs base, nav file/folder + **active-file stripe (resolve `00-base:~1081` vs `70-showcase:~61` drift → ONE)**, outline/backlinks tree, properties/`.metadata-container` (keep the 2026-06-16 frontmatter-flucht fix: `padding:2px 14px`), sidebars.
- **Surfaces:** UI chrome (single surface — no reading/LP split needed).
- **Tokens:** `--surface-*`, `--fg-*`, `--border-*`, active stripe `--accent`.
- **Grep assert:** only ONE active-file stripe rule.

### Task E2.11: `30-bases.css`
- **Port from:** the Bases cards + table-view rules (current `src/*` §29-ish; already both-mode and clean — re-home intact).
- **Tokens:** keep token-driven; honour the `--bases-cards-line-height` public var.

### Task E2.12: `31-graph.css`
- **Port from:** graph view colours — **resolve the token-vs-hardcoded duplication (`00-base:~1253` tokens shadowed by `~2200-2222` rgba)** → keep token-driven only. **Critic catch:** do not silently drop the `:2200-2222` shadow tokens; re-home them here.
- **Tokens:** node `--fg-secondary`, line `--border-default`, accent `--accent`, tag/attachment/unresolved from `--role-*`.

**E2 gate:** `check.sh` green after each; Claude greps that every `.HyperMD-*`/`.cm-*` surface assertion above is present (the scatter+single-surface failure is eliminated).

---

## PHASE E3 — Features, presets, accessibility

### Task E3.1: `40-features.css` — opt-in toggles + decorative
- **Port from:** every `kuro-*` toggle behaviour (grep `body.kuro-` across `src/*.css`): `kuro-mono-all`, `kuro-margin-tint`, `kuro-zen-mode` (merge the two supersets), `kuro-active-line`, `kuro-rainbow-indent`, `kuro-tabs-pill`/`-underline` (on `.is-active` only — drop dead `.mod-active` half), `kuro-slides-frame`/`-numbers`/`-progress`, `kuro-no-callout-animations`; plus decorative film-grain (`.theme-dark .workspace::after`), ambient heading glow (dark-only), slides base frame.
- **Tokens:** all from semantic/accent.
- **Verify:** `check.sh` green; `grep -oE 'kuro-[a-z-]+' src-v4/40-features.css | sort -u` matches the public toggle ids in `05-style-settings.css` (no public toggle left unimplemented).
- **Commit:** `feat(v4): opt-in features + decorative layer, deduped`

### Task E3.2: `50-presets.css` — 13 signal presets, BOTH modes
- **Port from:** `src/10-v1-polish-addendum.css:71-345` (the 13 `kuro-preset-*`). **Fix the asymmetry:** each preset must set the SAME semantic surface tokens (`--surface-*`, and a mood tint on `--background-*` via bridge) in BOTH `.theme-light` AND `.theme-dark` branches — not `--background-*` in light but only `--kuro-ink-*` in dark.
- **Layer:** `[values]` (a fork ships its own presets).
- **Verify:** for a sample preset, `grep -A40 'kuro-preset-toxic-haze' src-v4/50-presets.css` shows both a `.theme-dark` and a `.theme-light` surface assignment.
- **Commit:** `feat(v4): 13 presets retint semantic surfaces in both modes (asymmetry fix)`

### Task E3.3: `55-signal-subthemes.css`
- **Port from:** `src/50-signal-subthemes.css` (per-note frontmatter tints, companion-set) — re-home, keep `[values]`.
- **Commit:** `feat(v4): per-note signal subthemes (values)`

### Task E3.4: `60-low-contrast.css` — one token vocabulary
- **Port from:** `src/60-low-contrast.css` + `10-v1:356` + `20-kuro2:173-185`. **Resolve** the competing systems (`--text-normal`/`--kuro-bone` vs `--fg-*`) to the single semantic `--fg-*`/`--glow-*` set; both modes; no longer the only place light `--fg-*` is correct (that's now in `11-semantic-light.css`).
- **Commit:** `feat(v4): low-contrast a11y on one token vocabulary`

### Task E3.5: `70-reduced-motion.css` — audited
- **Port from:** `src/75-reduced-motion.css`; **audit ALL `@keyframes`** in `src-v4/*` (`grep -h '@keyframes' src-v4/*.css`) and ensure each decorative one is nulled under `@media (prefers-reduced-motion: reduce)` (not just `kuro-pulse`).
- **Verify:** every keyframe name appears in the reduced-motion suppression OR is justified.
- **Commit:** `feat(v4): reduced-motion covers all keyframes`

**E3 gate:** `check.sh` green; public toggle coverage proven; preset both-mode proven.

---

## PHASE E4 — Docs, cleanup, validation, release

### Task E4.1: Per-file headers + `THEME-AUTHORING.md`
- [ ] Add the PURPOSE/LAYER/SETS/USES/DEPENDS/SURFACES header block (spec §8 example) to every `src-v4/*.css` that lacks one.
- [ ] Write `docs/THEME-AUTHORING.md`: the fork workflow (swap `00-primitives`, `02-fonts`, `50-presets`, `HEADER`, the `05` label edges; never touch `[armature]`), with the "if you touched an `[armature]` file you're changing structure" rule.
- [ ] Commit: `docs(v4): file headers + THEME-AUTHORING fork guide`

### Task E4.2: `!important` + dead-code audit
- [ ] For each `!important` in `theme-v4.css`, confirm it fights a real Obsidian specificity; add a token-free keep-comment or remove it. Target ≤ 70 (ideally lower).
- [ ] Remove stale rules/comments for removed effects (aspects, vignette, scanlines, hanko, §40 gamification) — grep `vignette|scanline|hanko|aspect|gamif` across `src-v4/*` and delete dead ones.
- [ ] Confirm `--role-*` and `.ksp-*` utility classes are either used or intentionally kept (note in commit).
- [ ] `bash src-v4/check.sh` green. Commit: `refactor(v4): !important audit + dead-code/comment removal`

### Task E4.3: Swap `src-v4/` → `src/`, regenerate `theme.css`
- [ ] **Step 1:** `git mv src src-v3-reference` (keep the old fragments as in-repo reference) **or** `rm -rf src && git mv src-v4 src` after confirming `src-v3-reference` is committed. Choose: archive old as `src-v3-reference/`, promote `src-v4/`→`src/`.
- [ ] **Step 2:** Update `src/build.sh` + `src/check.sh` output target from `../theme-v4.css` back to `../theme.css`; rebuild.
- [ ] **Step 3:** `bash src/check.sh` → `ALL CHECKS PASS`; double-build md5 identical on `theme.css`.
- [ ] **Step 4:** Commit: `refactor(v4)!: promote armature build to src/, regenerate theme.css`

### Task E4.4: Version bump + final validation
- [ ] Bump `manifest.json` + HEADER + `CHANGELOG.md` to **4.0.0** (note: public contract unchanged, supersedes 3.4.0, list the bug fixes).
- [ ] Validate: 13 presets × {light, dark, low-contrast} resolve (grep each preset class builds without undefined token); `grep -c '!important'`, `@import url(http` = 0, size < 5 MB.
- [ ] Deploy for Jay's visual check: `cp theme.css /Users/Shared/10_ObsidianVaults/10_Pallas/.obsidian/themes/Kuro/theme.css` then md5-verify the copy.
- [ ] Commit: `chore(v4): bump to 4.0.0 + deploy for visual verification`

### Task E4.5: Jay's single comprehensive visual check (HUMAN GATE)
- [ ] Hand off to Jay: test note `10_Pallas/kuro-test/kuro-screenshot-demo.md`, in **both** light and dark, **Reading AND Live-Preview**. Confirm: checkboxes visible both modes · code stripe/frame in LP · note-pane lift in dark · callout lift · toggle accent in dark · light-mode legibility · all 13 presets. This is the ONE visual gate — not piecemeal.
- [ ] On pass → merge `refactor/clean-foundation` → `main`, tag `4.0.0`.

---

## Self-review (run against the spec)

- **Spec §1 root cause** → fixed by E1.2 both-mode mirror + E3.2 preset symmetry. ✓
- **Spec §2 armature/values + lint** → `check.sh` armature-lint (E1.0); tags in every file header (E4.1). ✓
- **Spec §3 token layers** → E1.1 primitives, E1.2 semantic mirror, E1.3 bridge. ✓
- **Spec §4 module layout** → file-structure table maps 1:1 to E1–E3 tasks. ✓
- **Spec §5 bug table** → E2.2 checkboxes (+container catch), E2.3 code LP, E1.5 lift, E1.2 light `--fg`, E3.2 preset; E2.12 graph-shadow catch. ✓
- **Spec §6 port strategy** → `src-v4/` scratch build, baseline (E4.5 is the single check; baseline screenshots requested at handoff), read-only reference preserved as `src-v3-reference/`. ✓
- **Spec §7 invariants** → `check.sh` enforces determinism/braces/!important/import/size/mirror/lint every task; public contract frozen (E1.4). ✓
- **Spec §8 comments** → E4.1. **Spec §9 fork** → THEME-AUTHORING (E4.1). **Spec §10 release** → E4.4/E4.5. ✓
- **Type consistency:** semantic token names identical across contract table, E1.2, E1.3, and component tasks (`--surface-*`/`--fg-*`/`--border-*`/`--code-*`/`--accent*`/`--glow-card`/`--shadow-card`). ✓

**Gap noted & accepted:** the "before" baseline screenshots (spec §6 step 2) depend on Jay; requested at E4.5 handoff rather than as a blocking E1 step, since Claude cannot capture them and the rebuild is value-preserving by construction.
