# Authoring on the Kuro Armature

Kuro v4 is built on **the Armature** — a forkable theme skeleton. The repo is split
into two kinds of file, marked in every file's header:

- **`[armature]`** — structure + contract. The token *names*, the module layout, the
  `@settings` shape, and every component's selectors. **A fork never edits these.**
  Armature files contain **no** colour literal and **no** `--signal-*`/`--void-*`/`--paper-*`
  reference (enforced by `src/check.sh`). They read tokens by name only.
- **`[values]`** — taste. The actual palette, the signal presets, the embedded fonts.
  **A fork swaps only these.**

> Rule of thumb: *if you touched an `[armature]` file, you are changing structure, not
> the theme.* To re-skin, edit only `[values]` files.

## Token flow (where colour comes from)

```
00-primitives [values]   raw palette: --signal-* (+rgb), --void-* (dark ramp),
                         --paper-* (light ramp), --font-*, numeric scales
        │
        ▼
10-semantic-dark  +  11-semantic-light  [armature]
                         every semantic token (--surface-*, --fg-*, --border-*,
                         --code-*, --status-*, --lift, …) gets a value in BOTH
                         files, mirrored key-for-key. THE both-mode rule.
        │
        ▼
12-bridge [armature]     feeds Obsidian-native vars (--background-*, --text-*,
                         --checkbox-*, …) from the semantic tokens, in ONE place.
13-roles  [armature]     the twelve signals exposed by meaning (--role-error …),
                         colour + -rgb triplet, for component tinting.
        │
        ▼
15-base, 20–31 components, 40-features, 60/70  [armature]
                         read semantic / role / bridged tokens only.
```

The **both-mode rule** is what makes the theme correct in light *and* dark by
construction: no semantic token may exist in only one mode. `check.sh` fails the
build if `10-semantic-dark.css` and `11-semantic-light.css` don't declare the
identical key set.

## To fork Kuro into a new theme

1. `git clone` the repo, rename it.
2. Edit **only** these `[values]` files:
   - **`src/00-primitives.css`** — rewrite the twelve `--signal-*` (+ their `-rgb`),
     the `--void-*` dark ramp, the `--paper-*` light ramp, and the `--font-*` stacks.
     This is the single biggest lever — the whole theme re-skins because semantic,
     bridge, roles and components all read through these. (~one screen of `:root`.)
   - **`src/02-fonts-embedded.css`** — swap the woff2 `@font-face` payloads if your
     theme ships different fonts (keep the family names aligned with `00-primitives`).
   - **`src/50-presets.css`** — your own mood presets (re-tint the same `--surface-*`
     names; remember BOTH `.theme-dark` and `.theme-light` per preset).
   - **`src/55-signal-subthemes.css`** — your per-note tints (or delete).
   - **`HEADER.css`** — your banner.
   - **`src/05-style-settings.css`** — only the preset option **labels** + the
     `kuro-preset-*` value list + the `@settings name:`. Keep the `id:` and toggle ids
     if you want config compatibility, or rename them wholesale for a clean identity.
3. **Do not open** any `[armature]` file. If the lint or `check.sh` complains, you
   edited structure — back it out.
4. (Optional) tune the *mood* without changing the *palette* by retuning which ramp
   step each semantic token points at in `10-semantic-dark.css` / `11-semantic-light.css`
   — that is the one `[armature]` edit a careful fork may make, keeping both-mode parity.

## Build & verify

```bash
bash src/build.sh     # HEADER + numeric-prefix concat → theme.css (zero-dep, deterministic)
bash src/check.sh     # determinism · braces · comment balance · !important≤70 ·
                      # 0 remote @import · <5MB · both-mode mirror · armature-lint
```

Edit fragments, never `theme.css` (it is generated). Every change must keep
`check.sh` green.
