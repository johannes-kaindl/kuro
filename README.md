# Kuro

**Neo-Gothic · Post-Cyberpunk · CRT-Phosphor** — an Obsidian theme built around a
Twelve Signals palette and a Void Scale.

> The chamber is dark. The signal earns its brightness because the chamber is dark.
> Twelve hues, twelve roles.

![Kuro](screenshot.png)

## Features

- **Twelve Signals palette** (`--signal-*`): `crimson`, `phosphor`, `circuit`, `ember`,
  `ghost`, `biolink`, `neural-bleed`, `rust`, `spectre`, `toxic`, `voidwitch`, `pearl` —
  twelve hues mapped to twelve note roles.
- **Void Scale** (`--void-000` … `--void-900`) for chamber depth.
- **Accent follows your system colour.** Kuro uses the accent colour you pick in
  **Settings → Appearance → Accent color**, in both light and dark — no forced override.
- **Signal-driven components** — callouts (40+ types with icons), task-checkbox glyphs, tags
  and the graph are all keyed to the twelve signals.
- **Self-contained** — fonts are embedded; the theme makes no network requests.

## Install

### From the community catalogue

Settings → Appearance → Themes → Manage → browse for **Kuro**, install, and enable.

### Manual

Copy `theme.css` and `manifest.json` into `<your-vault>/.obsidian/themes/Kuro/`,
then enable under **Settings → Appearance → Themes**.

## Configuration

Kuro works out of the box. For live configuration, install the official **Style Settings**
community plugin and open **Settings → Style Settings → Kuro**:

- **Colour & Mood** — a low-contrast mode.
- **Typography** — serif/display and monospace fonts, terminal mode, code font size.
- **Reading** — reading line width, disable callout animations.
- **Depth & glow** — heading-glow toggle, note & card lift strength, border crispness,
  focus-ring style.
- **Editor & Tabs** — zen mode, active-line highlight.
- **Shape & density** — corner roundness, interface density.
- **Components** — callout style, link underline, table zebra striping.

Style Settings is optional; the theme is fully usable without it.

## Build

`theme.css` is generated — do not edit it directly. Kuro is built on **the Armature**:
the sources in `src/` are split into `[armature]` (structure / contract) and `[values]`
(palette, presets, fonts). `build.sh` concatenates the numbered fragments and `check.sh`
verifies the build — determinism, the both-mode token mirror, contrast invariants and the
armature lint. To fork Kuro into a new theme, see
[`docs/THEME-AUTHORING.md`](docs/THEME-AUTHORING.md).

```sh
./src/build.sh   # regenerates theme.css from src/*.css
./src/check.sh   # verifies the build
```

## Compatibility

- `minAppVersion: 1.5.0` — Obsidian 1.5 or newer.

## Fonts

The theme embeds Latin subsets of four typefaces, all under the
[SIL Open Font License 1.1](https://openfontlicense.org/):

- **JetBrains Mono** — © JetBrains s.r.o.
- **Space Grotesk** — © Florian Karsten
- **Inter** — © The Inter Project Authors
- **EB Garamond** — © Georg Duffner & Octavio Pardo

## License

- **Code** (CSS, `build.sh`): [GNU AGPL-3.0](LICENSE).
- **Documentation** (README, CHANGELOG): [CC BY-SA 4.0](LICENSE-DOCS).
- **Embedded fonts**: SIL OFL 1.1 (see above).

See [LICENSING.md](LICENSING.md) for the rationale.
