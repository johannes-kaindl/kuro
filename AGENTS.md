# AGENTS.md — Kuro theme

Conventions for AI agents (Claude Code, Codex, …) working in this repo. Kuro is the
Obsidian theme **"Kuro"** (Neo-Gothic / Post-Cyberpunk), built on the **Armature** — a
forkable skeleton.

## Golden rule

**`theme.css` is generated — never edit it.** Edit the fragments in `src/`, then:

```bash
bash src/build.sh     # HEADER + numeric-prefix concat → theme.css (zero-dep, deterministic)
bash src/check.sh     # MUST print "ALL CHECKS PASS"
```

Every change keeps `check.sh` green (it is the test suite).

## Structure

- `src/[0-9][0-9]-*.css` — the fragments, concatenated in numeric order. Each is tagged
  **`[armature]`** (structure/contract: token names, selectors, `@settings` shape — a fork
  never edits these) or **`[values]`** (taste: palette/presets/fonts — a fork swaps only these).
- `12-bridge.css` is the ONE place Obsidian-native variables (`--tab-*`, `--checkbox-*`,
  `--tag-*`, …) are fed from the semantic tokens.
- `10-semantic-dark.css` + `11-semantic-light.css` mirror every semantic token key-for-key.

## The rules (full text + variable map: `docs/CSS-CONVENTIONS.md`)

- **R1 — variable-first.** Obsidian has a variable for it? Set the variable in `12-bridge.css`;
  don't write a property override. Look up the variable in `docs/CSS-CONVENTIONS.md` first.
- **R2 — `!important` only with justification.** Inline `/* important: <reason> */` tag, or
  it lives in `src/70-reduced-motion.css` (the a11y whitelist). Enforced by `check.sh` (gate ≤9).
  Try first: variable (R1) → matched specificity → `:where()` to lower an own over-specific base.
- **R3 — both-mode.** Every semantic token in BOTH `10-` and `11-`. Enforced.
- **R4 — layer discipline.** `[armature]` files: no colour literal, no `--signal-/--void-/--paper-`. Enforced.
- **R5 — one component, all surfaces** (Reading + Live-Preview + editor), defined once.
- **R6 — always `build.sh` + `check.sh`.**

## Grounding & feedback

Chrome/selector questions: consult the **official** Obsidian CSS-variable reference
(`docs.obsidian.md/Reference/CSS+variables/`) — the verified map is in `docs/CSS-CONVENTIONS.md`.
**Do not guess Obsidian's selectors or class names.** For stuck rendering, inspect the live
element in Obsidian DevTools (Cmd+Opt+I) and fix against the real selector.

The public `kuro-*` Style-Settings / companion contract is **frozen** — don't rename or drop
`kuro-*` body-classes or `--kuro-*` vars (breaks user configs). Fork guide: `docs/THEME-AUTHORING.md`.
