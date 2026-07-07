# Kuro auf Minimal — Skelett-Fork (Design)

**Datum:** 2026-07-06 · **Architektur-Kurskorrektur:** 2026-07-07 (Layered → Skelett-Fork)
**Status:** Design überarbeitet. Layered-Fork verworfen (Begründung §3b). Implementierung startet neu in frischer Session.
**Ersetzt strategisch:** die Eigen-Armature-Linie (v4.0.x). Kuro wird ein **Skelett-Fork von Minimal** (kepano) — eine echte Abzweigung, die Minimals Variablen-/Chrome-Skelett übernimmt und besitzt, statt es als read-only Layer zu überschreiben.

---

## 1. Motivation

Die Eigen-Armature (v4) hat Both-Mode/native-Variablen für uns gelöst, aber um den Preis dauerhafter Infrastruktur-Wartung. Minimal löst dieselben Probleme *by construction* und deutlich reifer. **Kuro nutzt Minimals Skelett — besitzt es aber selbst, statt sich davon abhängig zu machen.**

**Drei Motivationen (unverändert gültig):**
1. **Wartung/Robustheit** — Minimals HSL-Variablen-Architektur + Both-Mode + Chrome-Handling ist die ausgereifteste Basis im Ökosystem.
2. **Features** — reine-CSS-Features (Callouts, Checkboxen, Tags, Typo) kommen als Kuros eigene Komponenten; Colorful-Headings = Neu-Bau (Phase 3); plugin-abhängige (Vignette, per-Note-Signale) bleiben Companion-Territorium.
3. **Submission** — neutraler Nebeneffekt; MIT erlaubt Forks.

## 2. Architektur-Entscheidungen (getroffen)

| Achse | Entscheidung |
|---|---|
| **Aufbau-Modell** | **Skelett-Fork** — Minimals CSS wird zu Kuros *eigenem*, editierbarem Code. Kein read-only Basis-Layer, keine Override-Schicht. Eine integrierte Codebase. |
| **Was wir von Minimal übernehmen (Skelett)** | die HSL-Variablen-Architektur (`--base-*`/`--accent-*` → `--bg/ui/tx/ax`), der Both-Mode-Mechanismus (`.theme-dark`/`.theme-light`), das Chrome-/native-Variablen-Handling. |
| **Was wir ersetzen (Fleisch)** | Minimals Komponenten-Styles (Callouts, Checkboxen, Tags, …) durch Kuros — **direkt in der Codebase**, nicht per Override. Damit keine Spezifitäts-Kämpfe mehr (§3b). |
| **Was wir weglassen (Ballast)** | Minimal Cards, Minimal Advanced Settings, die 14 Color-Schemes, Minimals Callout-/Checkbox-Systeme, `minimal-*`-Feature-Toggles, die wir nicht brauchen. |
| **Update-Politik** | Minimal-Upstream wird **bewusst/selektiv** nachgezogen, nicht blind übernommen. Wir besitzen die Basis. |
| **Scope** | Nur Theme. Companion-Plugin = eigener Spec. |
| **Subtheme-System** | Zwei Achsen **Welt × Materie** (§6, unverändert gültig). |
| **Lizenz** | **MIT**, mit Minimals Copyright-Notice erhalten. |

## 3. Faktenbasis: Minimal 8.2.1 (analysiert 2026-07-06)

- **261 KB / 8.809 Zeilen** ausgeliefertes `theme.css`, Build-Artefakt aus `src/scss/` (92 SCSS-Dateien).
- **Farbsystem = 6 HSL-Steuerwerte** `--base-h/-s/-l` + `--accent-h/-s/-l` → per `hsl()`+`calc()` abgeleitete Aliase `--bg1/2/3`, `--ui1/2/3`, `--tx1/2/3/4`, `--ax1/2/3`, `--hl1/2`, gemappt auf Obsidian-Standard. 8 Akzente `--color-*` (+`-rgb`).
- **Both-Mode** über `.theme-light`/`.theme-dark`-Werte gespiegelt.
- **Color-Scheme-Mechanik** (Träger fürs Subtheme-System): Subthemes pinnen an `.theme-*.minimal-<name>-*` die Aliase direkt — global umschaltbar, plugin-frei.
- **Lizenz:** MIT (© 2020–2024 Steph Ango).

### 3b. Warum Layered-Fork verworfen wurde (Erkenntnis 2026-07-07)

Der erste Implementierungsversuch war ein **Layered-Fork**: Minimals `theme.css` unverändert als read-only `00-minimal-base.css`, Kuro als Override-Fragmente (`50+`) darüber. Vollständig gebaut (Branch `feat/minimal-fork`, 12 Tasks, `check.sh` grün) und in 10_Pallas sicht-geprüft. Ergebnis des Sicht-Checks:

- ✅ **Funktionierte:** Farb-Palette (Chamber/Paper), Typo (Serif-H1 + Mono-Body), Tag-Pills, Inline-Formatting, App-Farbwelt. → alles, was über **Variablen-Overrides** läuft.
- ❌ **Brach:** **Callouts** (kein Kasten/Border/BG — nur Icon+Titel) und **Checkboxen** (Minimals SVG-Masken-Icons statt Kuros Glyphen, leere `[ ]` unsichtbar, falsches strikethrough). → alles, was **strukturelle Komponenten** sind.

**Root cause:** Minimal hat *eigene, hochspezifische* Komponenten-Systeme — z.B. `li[data-task=">"] > p > input:checked` (Spezifität 0,2,3) mit `-webkit-mask-image`-SVGs pro Task-Typ; Callout-Rahmen nur unter Opt-in `.callouts-outlined`. Kuros portierte Regeln (niedrige Spezifität aus der Eigen-Armature, wo Kuro die *einzige* Quelle war) verlieren dagegen. Ein Override-Layer müsste Minimal bei **jeder** Komponente überbieten — dauerhafter Kampf, fragil bei jedem Minimal-Update.

**Schlussfolgerung:** Der Layered-Ansatz kauft „einfache Updates", aber (a) diese wollen wir für ein eigenständiges Produkt gar nicht blind, und (b) der Preis (permanente Spezifitäts-Reibung + geerbter Ballast + Update-Bruch-Risiko) ist zu hoch. Ein Skelett-Fork, bei dem wir Minimals Komponenten *ersetzen* statt *überbieten*, eliminiert die Reibung an der Wurzel.

## 4. Skelett-Fork-Architektur

Kuro besitzt eine integrierte Codebase, die aus Minimals Skelett + Kuros Fleisch besteht. Kein `00-minimal-base.css` read-only mehr.

**Übernommenes Skelett** (aus Minimal, in Kuro-Code integriert + editierbar):
- Die HSL-Variablen-Definitionen + Alias-Ableitung (`--base-*` → `--bg/ui/tx/ax`) und das Mapping auf Obsidian-Standard-Variablen.
- Chrome-/Workspace-/native-Element-Handling (Tabs, Sidebars, Titlebar, Prompts), soweit Kuro es nicht selbst gestaltet.

**Kuros Fleisch** (ersetzt Minimals Komponenten direkt — keine Overrides):
- Chamber/Paper-Palette, Callout-Library, Signal-Checkboxen, Tag-Pills, Typo (Serif-H1/Mono-Body), Ambiente (Film-Grain, H1-Glow), reduced-motion.

### 4a. Offene Sub-Entscheidung: SCSS-Quellbaum vs. CSS-Fragmente

Wie das Skelett konkret in Kuros Codebase kommt — **in der neuen Session final entscheiden:**

| Variante | Pro | Contra |
|---|---|---|
| **CSS-Fragmente (Empfehlung)** | Bleibt bei Kuros zero-dep-Philosophie (`build.sh`/`check.sh`, kein Node/sass). Minimals gebautes CSS wird in thematische, editierbare Kuro-Fragmente zerlegt; unnötiges Fleisch fällt beim Zerlegen weg. | Minimals SCSS-Abstraktion (Loops, Mixins) geht verloren — aber die brauchen wir für ein schlankes Skelett kaum. |
| **SCSS-Quellbaum forken** | Behält Minimals modulare SCSS-Struktur + Upstream-Mergebarkeit. | Bricht zero-dep (Node + `sass` als Build-Dep) — Fremdkörper in Kuros Toolchain. |

**Empfehlung:** CSS-Fragmente. Wir wollen nur das *Skelett* (Variablen + Chrome), nicht Minimals SCSS-Maschinerie; zero-dep bleibt Kuros Stärke.

## 5. Was aus dem Layered-Versuch übernommen wird

Der `feat/minimal-fork`-Branch bleibt als dokumentiertes Lern-Experiment stehen (**nicht mergen**). Wiederverwendbar:

- **Voll gültig (Design):** dieser Spec, das Subtheme-System (§6), die Chamber/Paper-Palettenwerte, das 12→8-Signal-Mapping, die Font-Signatur, die Materie-Presets.
- **Ausgangsmaterial (Code):** die portierten Fragmente `50-palette`, `51-tokens`, `60-callouts`, `61-checkboxes`, `62-tags-typo`, `70-reduced-motion` — sie wandern *in* das Skelett (mit korrekter Spezifität, da sie Minimals Komponenten dann ersetzen statt überbieten). Die Chamber-Werte + Token-Mappings sind byte-genau übernehmbar.
- **Verworfen (Mechanik):** read-only `00-minimal-base.css` + Override-Prinzip + der angepasste Layered-`check.sh`.

## 6. Subtheme-System (Phase 2) — Zwei Achsen

Unverändert gültig. Zwei unabhängige Achsen, je ein Style-Settings-`class-select`-Dropdown, disjunkte Variablen-Sets. Namensschema *„Materie Welt"* (z.B. *Brutalist Sanctum*).

### Achse „Welt" (Farbe) — 6 Welten (Basis-Rampe + Akzent, je einmal AA-getunt)
Chamber *(Default)* · Furnace (Ember) · Observatory (Circuit) · Sanctum (Voidwitch) · Archive (Rust) · Phosphor.

### Achse „Materie" (Form) — 4 Presets (Font/Radius/Dichte/Border/Tiefe)
Standard *(Default)* · Brutalist · Terminal · Manuscript.

Kombinatorik 6 × 4 = 24, aber nur 6 Paletten + 4 Form-Presets zu tunen (Kontrast lebt in der Welt-Achse). Im Skelett-Fork sind die Welten Kuro-eigene Klassen (`.kuro-world-*`), kein Kampf gegen Minimals Color-Schemes (die wir weglassen).

## 7. Kern-Charakter (Phase 1) — Chamber-Werte

Verifiziert aus v4 (bleibt gültig):

| Alias | Dark (Chamber) | Light (Paper) |
|---|---|---|
| `--bg1` (Note) | `#060709` | `#faf8f5` |
| `--bg2` (raised/sidebar) | `#0b0d11` | `#e2ddd3` |
| `--bg3` (overlay) | `#181c24` | `#d8d3c8` |
| `--ui1` (border subtle) | `#22272f` | `rgba(0,0,0,0.10)` |
| `--ui3` (border strong) | `#3d4450` | `#b0a99a` |
| `--tx1` (text) | `#e8e4d8` (Pearl) | `#2b2824` (Ink) |
| `--tx2` (muted) | `#828a97` | `#6b6761` |
| `--tx3` (faint) | `#6b7280` | `#847f75` |

Fonts: Mono-Body (JetBrains Mono) überall, Serif (EB Garamond italic) für H1 + inline-title. 12→8-Signal-Mapping: crimson→red, ember/rust→orange, toxic→yellow, phosphor/biolink→green, circuit→cyan, ghost→blue, spectre/voidwitch→purple, neural-bleed→pink, pearl→neutral.

## 8. Phasen

| Phase | Liefert |
|---|---|
| **P1 — Kern** | Skelett integriert + Chamber-Palette + Standard-Materie + Callouts/Checkboxen/Tags/Typo/Ambiente als Kuro-Komponenten (kein Override) + konfliktfreier Kuro-`@settings`. Ergebnis = v4-Look, robust. |
| **P2 — Subtheme-System** | 5 weitere Welten + 3 weitere Materie-Presets + zwei Dropdowns. |
| **P3 — Colorful-Headings** | Neu-Bau, srgb (optional). |

## 9. Nicht im Scope

- Companion-Plugin (eigener Spec).
- Plugin-abhängige Features (Vignette/Scanlines, per-Note-Colour-Vision).
- Hanko-Wasserzeichen (verschoben).
- Minimals Cards / Advanced Settings / Color-Schemes / Komponenten-Systeme (bewusst weggelassen).

## 10. Lizenz & Migration

- `LICENSE` → MIT, Minimals Copyright (© 2020–2024 Steph Ango) erhalten, README/CHANGELOG nennen Fork-Herkunft.
- Version-Bump 5.0.0 (Foundation-Wechsel), `minAppVersion` an Minimals Floor (1.9.0).
- Verifikation: `check.sh` grün + **Jays Sicht-Check** (der echte Funktionstest — Lehre aus dem Layered-Versuch: build-verifiziert ≠ funktionsgetestet; strukturelle Komponenten immer live prüfen).
