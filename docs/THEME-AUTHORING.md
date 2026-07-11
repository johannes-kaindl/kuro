# Authoring Kuro (Minimal-skeleton fork)

How to change Kuro without reintroducing smelly code. Kuro is a **skeleton-fork of Minimal
8.2.1** — Minimal's CSS is Kuro's own, owned and editable. For *why* it is built this way and
the component anatomy, see **[GUIDE.md](GUIDE.md)**; for the enforced rules, **[CSS-CONVENTIONS.md](CSS-CONVENTIONS.md)**.

## The two kinds of fragment

- **`*-minimal-*.css`** — owned Minimal, transformed to Kuro incrementally. Edit these *at the
  source* when you replace a component (don't override it from elsewhere). Until a part is
  transformed, its `!important`/hex is Minimal's and is tracked as *transform debt*.
- **`*-kuro-*.css`** — Kuro's own. Obey the full discipline: no hex outside the palette, every
  `!important` tagged, ≤ 9 total (`check.sh` enforces on these files only).

## To change a component (the transform four-beat)

Never override — replace, at the source. Every component change follows the same beat:

1. **Understand the anatomy.** Read the component's selectors + specificity in its
   `*-minimal-*.css` fragment. Note which selectors are highly specific (the layered traps) and
   which Obsidian-native / Minimal-alias variables they use.
2. **Write the GUIDE anatomy card first** (doc-driven — *before* the change). If you can't
   describe how it works, you're not ready to replace it cleanly.
3. **Transform at the source.** Remove Minimal's rules for that component from its
   `*-minimal-*.css`, and write Kuro's version in a `NN-kuro-<component>.css` (see the numbering
   in GUIDE § Fragment map). Reference values come from `src/_v4-reference/` — as values, not
   copy-paste layers. Use aliases / native vars / `--role-*` only; no hex outside the palette.
4. **Gate.** `bash src/build.sh && bash src/check.sh` → `ALL CHECKS PASS`, then deploy and
   **look at it live**. If it breaks: back out one change and fix at the real selector (Obsidian
   DevTools, Cmd+Opt+I) — never by piling on `!important`.

## To re-skin (change the palette only)

The single biggest lever. Edit **`03-kuro-palette.css`** — rewrite the Chamber/Paper hex pinned
onto `--bg1/2/3`, `--ui1/2/3`, `--tx1/2/3/4`. Keep **both** `.theme-dark` and `.theme-light`
blocks with the **identical** key set (`check.sh` enforces both-mode parity). Fonts: swap the
woff2 payloads in `05-kuro-fonts.css`. Signal colours: `04-kuro-tokens.css` maps `--role-*` onto
Minimal's 8 accents.

## To fork Kuro into a new theme

1. `git clone`, rename.
2. Edit the `[values]` fragments: `03-kuro-palette.css` (the palette — biggest lever),
   `05-kuro-fonts.css` (fonts), `04-kuro-tokens.css` (signal→accent mapping), `02-kuro-settings.css`
   (the `@settings name:` + option labels), `HEADER.css` (banner).
3. Leave the `*-minimal-*.css` skeleton and the `2x-kuro-*` components alone unless you are
   changing structure. If `check.sh` complains about hex/`!important`, you edited a component,
   not values — back it out or transform it properly.

## To pull Minimal upstream selectively

Kuro **owns** the skeleton, so upstream is never merged blindly. When Minimal releases:
diff the new `theme.css` against `src/_v4-reference/`-style baseline, and hand-pick chrome /
variable fixes into the relevant `*-minimal-*.css` fragment. Never overwrite transformed Kuro
components. Re-run the full gate.

## Build & verify

```bash
bash src/build.sh     # HEADER + numeric-prefix concat → theme.css (zero-dep, deterministic)
bash src/check.sh     # determinism · braces · comment balance · Kuro !important≤9 tagged ·
                      # both-mode palette parity · no-hex in Kuro components · <5MB · 0 remote @import
```

Edit fragments, never the generated `theme.css`. Every change keeps `check.sh` green **and**
passes a live sight-check.
