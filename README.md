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
- **Signal presets** — full background colour moods, selectable in Style Settings.
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

- **Colour & Mood** — signal presets (background moods) and a low-contrast mode.
- **Typography** — serif/display and monospace fonts, terminal mode.
- **Reading** — reading line width, margin tint, pattern intensity, colourful headlines,
  Bases card density.
- **Slides** — frame, slide numbers, progress bar (for the core Slides plugin).
- **Editor & Tabs** — zen mode, active-line highlight, rainbow indent guides, tab style.

Style Settings is optional; the theme is fully usable without it.

## Build

`theme.css` is a generated monolith — do not edit it directly. The sources live in
`src/` as numbered fragments that `build.sh` concatenates lexically (`00`–`75`):

```sh
./src/build.sh   # regenerates theme.css from src/*.css
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
