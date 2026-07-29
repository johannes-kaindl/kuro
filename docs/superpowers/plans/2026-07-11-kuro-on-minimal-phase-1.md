# Kuro-on-Minimal — Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Kuro 5.0 als Skelett-Fork von Minimal 8.2.1 — Minimals Variablen-/Chrome-Skelett besessen + editierbar, alle Komponenten auf Kuro-Stand (v4-Look, Standard Chamber), robust; plus ein mitgewachsener Anatomie-/Authoring-Guide.

**Architecture:** Zero-dep CSS-Fragmente (`build.sh` = HEADER + numeric glob; `check.sh` = Verifikation). Inkrementeller Transform: von lauffähigem Minimal ausgehen, Kuro-Abweichungen einzeln einbauen, bei jedem Schritt maschinell (`check.sh`) **und** menschlich (Jays Sicht-Check) verifizieren. Konflikte werden an der Quelle editiert (Minimal ist besessen), nicht überschrieben.

**Tech Stack:** Bash (zero-dep build/check), CSS (Obsidian theme), Obsidian Style Settings (`@settings`-YAML). Kein Node/sass.

**Spec (SSOT):** Vault-Note `[[Kuro-on-Minimal-Fork-Design]]` — `$VAULT/25_Coding/kuro-obsidian-theme/Kuro-on-Minimal-Fork-Design.md`. §4b Methode, §4c Guide.

## Global Constraints

Gelten für JEDEN Task implizit:

- **Version:** manifest `5.0.0`, `minAppVersion` `1.9.0` (Minimals Floor). name bleibt `Kuro`.
- **Lizenz:** MIT; Minimals Copyright (`© 2020–2024 Steph Ango`) im HEADER + LICENSE erhalten.
- **Build:** zero-dep `bash src/build.sh` (HEADER.css + `[0-9][0-9]-*.css` numeric glob). NIE `theme.css` direkt editieren — nur Fragmente.
- **Verifikation-Gate (beide Ebenen, jeder Transform-Task):**
  1. **Maschinell:** `bash src/check.sh` = `ALL CHECKS PASS`.
  2. **Menschlich:** Jays Sicht-Check in 10_Pallas (deploy → Blick → OK/Bruch). Ohne sein OK gilt ein Transform-Task NICHT als fertig.
- **check.sh-Invarianten:** deterministisch (md5 stabil) · brace-balance · comment-balance pro Fragment · `!important` ≤ 9 + jede reale Deklaration inline getaggt (`/* important: <reason> */`, Ausnahme `70-*` a11y-whitelist) · 0 remote `@import` · < 5 MB · **Both-Mode-Parität** (Palette-Fragmente pinnen `.theme-dark`/`.theme-light` mit identischem Alias-Key-Set).
- **Token-Vokabular (Kuro-Komponenten konsumieren):** Minimals Aliase `--bg1/2/3`, `--ui1/2/3`, `--tx1/2/3/4` · Obsidian-native `--background-*`/`--text-*`/… · Kuros `--role-*` (12 Signale → Minimals 8 `--color-*`). **Keine Hex-Literale in Komponenten-Fragmenten** — nur in den `[values]`-Palette-Fragmenten.
- **Doku-getrieben (§4c):** Vor jedem Komponenten-Transform die Guide-Reference-Sektion für diese Komponente schreiben (Anatomie + Spezifitäts-Fallen). Kein Transform ohne vorherige Doku.
- **Referenz/Steinbruch:** Kuros v4-Fragmente (`src/` auf `main`) und die portierten Layered-Fragmente (`feat/minimal-fork`) zeigen *was* Kuro will — sie werden NICHT als Override-Layer draufkopiert. Werte (Palette, 12→8) sind direkt übernehmbar; Komponenten-Regeln werden von Minimal aus behutsam eingespeist.

---

## Task 0: Branch + Baseline-Anker (Minimal zerlegt, verlustfrei)

Der sichere Nullpunkt: Minimals `theme.css` wird zu Kuros eigenen Fragmenten zerlegt und rebuildt **verlustfrei** — Look = reines Minimal.

**Files:**
- Branch: neuer `feat/minimal-skeleton` (von `main`), `Kuro/`-Repo.
- Quelle Minimal: `git show feat/minimal-fork:src/00-minimal-base.css` (= Minimals theme.css 8.2.1 + Kuro-Kommentarkopf; Kopf verwerfen).
- Create: `src/` neue Fragmente entlang der Sektions-Nähte (siehe unten). Altes v4-`src/` nach `src/_v4-reference/` verschieben (Steinbruch, nicht im Build-Glob).
- Modify: `src/HEADER.css` (v5, Minimal-Fork, MIT-Notice), `src/build.sh` (Glob passt schon; nur Kommentar), `src/check.sh` (v4→Minimal-Invarianten, siehe Task 0c).

**Fragment-Zerlegung (Bänder nach Minimals Kaskaden-Reihenfolge; Zeilen = Minimals theme.css):**

| Fragment | Minimal-Zeilen | Inhalt |
|---|---|---|
| `00-minimal-vars.css` | 48–435 | `body`-Variablen (HSL-Kern, Font/Heading/Spacing-Defs) |
| `01-minimal-colormap.css` | 436–615 | „Map colors to semantic Obsidian names" + Shadows |
| `10-minimal-app.css` | 616–1081 | desktop-font-sizes, obsidian-app, ghost-fix, gutters, line-numbers, preview, ribbon |
| `11-minimal-statusbar.css` | 1082–1244 | statusbar, titlebar, alignment, window-frame, animation |
| `12-minimal-components.css` | 1245–1397 | modals, confirm-delete, settings, progress, tooltips |
| `20-minimal-content.css` | 1398–1893 | blockquotes, callouts, transclusions, links, lists, backlinks, tables, tags, headings/fonts |
| `30-minimal-features.css` | 1894–3010 | active-line, line-width, block-button, sorting, cards, helpers, images, checklist-icons |
| `31-minimal-states.css` | 3011–3607 | colorful-states, colorful-headings, focus-mode, collapse, full-width, table-helpers, dark-images, invert |
| `40-minimal-interface.css` | 3608–4257 | interface, links-underline, tabs, sidebar-tabs, underline, sidebar-index, modern-wide, tablet |
| `50-minimal-plugins.css` | 4258–5281 | core+community plugins (backlink, file-browser, calendar, charts, dataview, git, kanban, sortable, style-settings-prefs) |
| `60-minimal-schemes.css` | 5282–8620 | color-schemes (Atom, Eink, Things) |
| `70-minimal-compat.css` | 8621–8814 | plugin-compatibility, tail |

_(Grenzen an den `/* Section */`-Nähten final justieren, sodass keine Regel gespalten wird. Zeilen sind Richtwerte — beim Zerlegen an der nächsten Sektions-Naht schneiden.)_

- [ ] **Step 1: Branch anlegen**

```bash
cd <repo-root>   # das Kuro-Repo-Root
git checkout main && git checkout -b feat/minimal-skeleton
```

- [ ] **Step 2: v4-Fragmente als Referenz beiseite (aus dem Build-Glob nehmen)**

```bash
cd src
mkdir -p _v4-reference
git mv HEADER.css _v4-reference/HEADER.css
for f in [0-9][0-9]-*.css; do git mv "$f" "_v4-reference/$f"; done
# build.sh/check.sh/tools bleiben in src/
```
Der Glob `[0-9][0-9]-*.css` matcht `_v4-reference/`-Inhalte NICHT (glob ist nicht rekursiv) → sauber raus aus dem Build.

- [ ] **Step 3: Minimal-Quelle extrahieren**

```bash
git show feat/minimal-fork:src/00-minimal-base.css > /tmp/minimal-full.css
# Kuro-Kommentarkopf (erste ~6 Zeilen bis zur MIT-Notice) prüfen; der reine Minimal-Body beginnt bei '@charset' / '/* Variables */'.
```

- [ ] **Step 4: In Fragmente zerlegen** (entlang obiger Tabelle, an Sektions-Nähten). Jede Zeile von `/tmp/minimal-full.css` landet in genau EINEM Fragment, in Reihenfolge, ohne Änderung des CSS-Inhalts.

- [ ] **Step 5: HEADER.css v5 schreiben**

```css
/* ╔══════════════════════════════════════════════════════════════════════╗
   ║  KURO  v5.0.0  ·  Neo-Gothic / Post-Cyberpunk Obsidian theme          ║
   ║  Skeleton-fork of Minimal 8.2.1 by @kepano (MIT, © 2020–2024 S. Ango) ║
   ║  Kuro owns & edits the skeleton; components are replaced, not layered. ║
   ║                                                                        ║
   ║  BUILD ORDER (build.sh = HEADER + numeric glob, zero-dep, det.):       ║
   ║   00–01 vars/colormap · 10–12 chrome · 20–40 content/interface ·       ║
   ║   50 plugins · 60 schemes · 70 compat · 8x kuro-additive               ║
   ║                                                                        ║
   ║  Kuro fragments carry `-kuro-` in the name; unmarked = owned Minimal.  ║
   ║  See docs/ (anatomy & authoring guide) + docs/CSS-CONVENTIONS.md.      ║
   ╚══════════════════════════════════════════════════════════════════════╝ */
```

- [ ] **Step 6: build.sh-Kommentar aktualisieren** (Logik unverändert — Glob passt). Zeile „Build theme.css from src-v4 fragments" → „from Minimal-skeleton + Kuro fragments".

- [ ] **Step 7 (Task 0c): check.sh auf Minimal-Invarianten anpassen** — siehe eigener Block unten. Muss VOR dem ersten `check.sh`-Lauf passieren.

- [ ] **Step 8: Rebuild + Verlustfreiheit prüfen**

```bash
bash build.sh
# Body-Vergleich: gebautes theme.css (ohne HEADER) muss Minimals Body byte-genau enthalten.
# HEADER + eingefügte Inter-Fragment-Newlines sind der einzige erlaubte Unterschied.
diff <(git show feat/minimal-fork:src/00-minimal-base.css | sed '1,6d') \
     <(sed -n '/@charset/,$p' ../theme.css | perl -0777 -pe 's/\n{2,}/\n/g') | head -40
```
Expected: nur Whitespace-/Header-Diffs, keine verlorenen/duplizierten Regeln. (Ist der Vergleich zu rauschig, stattdessen Regelzahl vergleichen: `grep -c '{' ` beider Dateien muss gleich sein.)

- [ ] **Step 9: check.sh grün**

Run: `bash check.sh`
Expected: `ALL CHECKS PASS`

- [ ] **Step 10: Sicht-Check-Gate (Jay)** — theme.css nach 10_Pallas deployen (siehe Task-Anhang „Deploy"), Obsidian öffnen. Erwartung: **sieht aus wie Minimal** (nicht wie Kuro — das ist korrekt für den Anker). Jay bestätigt „ist Minimal, funktioniert".

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "feat(skeleton): Task 0 — Minimal 8.2.1 baseline, losslessly split into owned fragments"
```

### Task 0c: check.sh anpassen (Detail zu Step 7)

Zwei v4-Regeln passen nicht mehr:

- [ ] **Both-Mode-Mirror umstellen:** Der `10-semantic-dark ↔ 11-semantic-light`-Block greift nicht (Dateien existieren nicht). Ersetzen durch **Palette-Parität**: sobald ein `*-kuro-palette.css` existiert, muss dessen `.theme-dark`- und `.theme-light`-Block dasselbe Alias-Key-Set setzen.

```bash
# Ersetzt den bisherigen "both-mode mirror (R3)"-Block:
pal=$(ls *-kuro-palette.css 2>/dev/null | head -1 || true)
if [ -n "$pal" ]; then
  keys_of() { strip "$pal" | awk "/\\.theme-$1[^-]/{f=1} f&&/}/{f=0} f" | grep -oE -- '--[a-z0-9-]+[[:space:]]*:' | grep -oE -- '--[a-z0-9-]+' | sort -u; }
  d=$(keys_of dark); l=$(keys_of light)
  if [ "$d" != "$l" ]; then echo "FAIL: palette both-mode mismatch:"; diff <(echo "$d") <(echo "$l"); exit 1; fi
  echo "  palette both-mode parity: OK"
fi
```

- [ ] **Armature-lint anpassen:** Die v4-Primitive `--void-/--paper-/--signal-` existieren nicht mehr. Neue Regel: **Hex-Literale sind nur in `*-kuro-palette.css` erlaubt** (die `[values]`-Datei) und in den unangetasteten `*-minimal-*.css` (Minimals eigenes CSS, besessen aber wörtlich). Kuro-Komponenten-Fragmente (`*-kuro-*.css` außer palette) dürfen keine Hex-Literale einführen.

```bash
# Ersetzt den bisherigen "armature-lint (R4)"-Block:
for f in *-kuro-*.css; do
  case "$f" in *-kuro-palette.css) continue;; esac
  if strip "$f" | grep -nEq -- '#[0-9a-fA-F]{3,8}\b'; then
    echo "FAIL: hex literal in Kuro component fragment $f (use --role-*/aliases/native, R1):"
    strip "$f" | grep -nE -- '#[0-9a-fA-F]{3,8}\b'; exit 1
  fi
done
echo "  no-hex in kuro components: OK"
```

- [ ] Kommentar-Kopf von check.sh entsprechend aktualisieren (R3/R4-Beschreibung).

**Deploy (Anhang, für jeden Sicht-Check):**
```bash
# Backup + deploy in den Vault ($VAULT = Pfad der aktiven Kuro-Theme-Installation):
cp "$VAULT/.obsidian/themes/Kuro/theme.css" \
   "$VAULT/.obsidian/themes/Kuro/theme.css.bak" 2>/dev/null || true
cp ../theme.css "$VAULT/.obsidian/themes/Kuro/theme.css"
# Jay: Obsidian → Theme neu laden / App-Reload.
```

---

## Task 1: Guide-Gerüst (Explanation + Reference-Skelett)

Der Guide (§4c) bekommt sein Grundgerüst, bevor der erste Transform Wissen produziert.

**Files:**
- Create: `docs/GUIDE.md` (Haupt-Guide, Diátaxis-Sektionen).
- Modify: `docs/THEME-AUTHORING.md` → How-to-Teil auf Minimal-Basis umschreiben (v4-Armature-Inhalt ist tot).
- Keep/Reference: `docs/CSS-CONVENTIONS.md` (R1–R6 + Variablen-Map) — bleibt normative SSOT, wird verlinkt.

- [ ] **Step 1: `docs/GUIDE.md` anlegen** mit Diátaxis-Skelett + gefülltem Explanation-Teil (aus Spec §1/§2/§3b/§4): warum Skelett-Fork · Both-Mode · **warum Layered scheiterte (Spezifitäts-Anatomie)** · Skelett/Fleisch-Modell · Token-Fluss-Diagramm. Reference/How-to als Überschriften-Gerüst mit „wächst pro Komponente"-Hinweis.

- [ ] **Step 2: Reference-Grundlagen füllen** (jetzt schon bekannt): Obsidian-CSS-Variablen-API-Verweis auf `CSS-CONVENTIONS.md#verified-obsidian-variable-map`; Minimals HSL-Alias-System (`--base-h/s/l` → `--bg/ui/tx/ax`, aus Spec §3); die Fragment-Landkarte (Tabelle aus Task 0).

- [ ] **Step 3: `THEME-AUTHORING.md` umschreiben** — „Authoring on the Kuro Armature" → „Authoring Kuro (Minimal-skeleton fork)": Token-Flow neu (Chamber→Aliase→native→`--role-*`), Fork-Anleitung (Palette-Fragmente tauschen), Build & verify. Verweis auf `GUIDE.md` als vertiefte Referenz.

- [ ] **Step 4: Im Cockpit verlinken** — `[[kuro-obsidian-theme]]` §🔗: Guide als Repo-Referenz eintragen.

- [ ] **Step 5: Commit**

```bash
git add docs/
git commit -m "docs(guide): anatomy & authoring guide scaffold (explanation + reference skeleton); rewrite THEME-AUTHORING for Minimal basis"
```

---

## Kuro-Fragmentnummern (kollisionsfrei — Single Source of Truth)

Die Nummern in den Task-Blöcken unten sind illustrativ; **maßgeblich ist diese Tabelle** (kollisionsfrei mit Minimals belegten Nummern 00,01,10,11,12,20,30,31,40,50,60,70). Beim Anlegen eines Kuro-Fragments diese Nummer verwenden:

| Kuro-Fragment | Nr. | Band |
|---|---|---|
| `02-kuro-settings.css` (`@settings`) | 02 | values (früh) |
| `03-kuro-palette.css` | 03 | values |
| `04-kuro-tokens.css` (`--role-*`, motion, radius) | 04 | values |
| `05-kuro-fonts.css` (embedded woff2) | 05 | values |
| `06-kuro-typography.css` | 06 | values |
| `21-kuro-callouts.css` | 21 | components |
| `22-kuro-checkboxes.css` | 22 | components |
| `23-kuro-tags.css` | 23 | components |
| `24-kuro-code.css` | 24 | components |
| `25-kuro-tables.css` | 25 | components |
| `26-kuro-blockquote.css` | 26 | components |
| `27-kuro-lists.css` | 27 | components |
| `28-kuro-bases.css` | 28 | components |
| `29-kuro-graph.css` | 29 | components |
| `80-kuro-ambient.css` | 80 | additive |
| `85-kuro-reduced-motion.css` | 85 | additive (a11y-whitelist) |

Kuro-Komponenten (21–29) bauen nach `20-minimal-content` und vor `30-minimal-features`; da die entsprechenden Minimal-Regeln beim Transform *entfernt* werden (kein Override), ist die Kaskade konfliktfrei.

## Transform-Template (gilt für Task 2…N)

Jeder Komponenten-Transform folgt demselben **Vierklang**. Das Template wird pro Task mit den komponenten-spezifischen Angaben (Minimal-Quelle, Kuro-Referenz, Sicht-Check-Kriterien) instanziiert. Kein Vorab-CSS im Plan — der finale CSS entsteht aus Schritt A (das ist die Methode, kein Placeholder).

- [ ] **A — Anatomie verstehen:** Im betroffenen `*-minimal-*.css`-Fragment die Selektoren + Spezifität dieser Komponente lesen. Notieren: welche Selektoren hochspezifisch sind (die Layered-Fallen), welche Obsidian-native/Minimal-Aliase sie nutzen.
- [ ] **B — Guide-Reference-Sektion schreiben** (`docs/GUIDE.md`): „Komponente X — so greift Obsidian an · so löst Minimal · Spezifitäts-Fallen · so setzt Kuro an." VOR der Änderung.
- [ ] **C — Transformieren an der Quelle:** Kuros Regeln in das (besessene) Minimal-Fragment einarbeiten bzw. in ein neues `NN-kuro-<komp>.css` auslagern und Minimals Komponenten-Regeln im `*-minimal-*.css` entfernen/ersetzen (kein Override-Layer). Referenz-Werte aus dem v4-/Layered-Steinbruch. Nur Aliase/native/`--role-*`, keine Hex außerhalb Palette.
- [ ] **D — Gate:** `bash check.sh` = PASS → deploy → **Jays Sicht-Check** → bei OK commit `feat(<komp>): transform to Kuro`; bei Bruch: eine Änderung zurück, Ursache am Selektor (nicht per `!important`) fixen.

---

## Task 2: Palette (Chamber/Paper) — `[values]`

**Files:** Create `05-kuro-palette.css` (früh im Glob, nach colormap). Referenz: `feat/minimal-fork:src/50-kuro-palette.css` (Werte byte-genau übernehmbar).

- [ ] **A/B:** Guide-Sektion „Palette & Token-Fluss": wie Chamber/Paper-Hex die Minimal-Aliase besetzen; Both-Mode über `.theme-*`.
- [ ] **C:** `.theme-dark`/`.theme-light` mit den Chamber/Paper-Werten aus Spec §7 / dem Layered-`50-kuro-palette` pinnen (`--bg1/2/3`, `--ui1/2/3`, `--tx1/2/3/4`, `--check-marker`). **Beide Blöcke identisches Key-Set** (Both-Mode-Parität-Gate).
- [ ] **D:** check.sh (Palette-Parität greift jetzt) → Sicht-Check: **Farben = Kuro Chamber/Paper**, Struktur noch Minimal. Commit.

## Task 3: Rollen-Tokens (12→8) — shared

**Files:** Create `06-kuro-tokens.css`. Referenz: `feat/minimal-fork:src/51-kuro-tokens.css`.

- [ ] **A/B:** Guide-Sektion „Signal-Rollen 12→8": Mapping-Tabelle (crimson→red …), warum `--role-*` (weltunabhängig, recoloriert in Phase 2).
- [ ] **C:** `--role-*` + `--role-*-rgb` auf Minimals `--color-*` mappen; Motion-/Radius-Tokens (aus Layered-51). Kein Hex (nur `--role-neutral` fixes Grau erlaubt — als Ausnahme im Guide notieren, ggf. check.sh-Whitelist).
- [ ] **D:** check.sh → Sicht-Check (noch kein sichtbarer Unterschied; Tokens sind Infrastruktur) → Commit.

## Task 4: Typografie (Serif-H1 + Mono-Body)

**Files:** Create `07-kuro-typography.css` + `08-fonts-embedded.css` (aus `main:src/02-fonts-embedded.css` übernehmen — Werte, byte-genau). Minimals Font-Vars in `00-minimal-vars.css` an der Quelle anpassen.

- [ ] **A:** Minimals Heading-/Font-Variablen (Z. 62–91 `--h1..h6`, `--font-*`) lesen.
- [ ] **B:** Guide-Sektion „Typografie": Minimals Font-Var-System, wo Kuro Serif-H1/Mono-Body einhängt.
- [ ] **C:** Fonts embedden (`08-fonts-embedded.css`); in `00-minimal-vars.css` `--font-text`/`--font-monospace` auf JetBrains Mono, H1/inline-title auf EB Garamond italic (an der Quelle editiert). `07-kuro-typography.css` für Heading-Rampe/Details.
- [ ] **D:** check.sh (Größe < 5 MB prüfen — Fonts ~784 KB) → Sicht-Check: **Mono-Body überall, Serif-H1 italic**. Commit.

## Task 5: Callouts

**Files:** `20-minimal-content.css` (Callout-Block Z. 1414–1503 entfernen/ersetzen) + Create `22-kuro-callouts.css`. Referenz: `feat/minimal-fork:src/60-kuro-callouts.css`, `main:src/24-callouts.css` (44 Signal-Mappings).

- [ ] **A:** Minimals Callout-Anatomie (`.callout`, `.callout[data-callout]`, `.callouts-outlined`-Opt-in) + Spezifität dokumentieren — das war eine Layered-Bruchstelle.
- [ ] **B:** Guide-Sektion „Callouts" (die wichtigste Anatomie-Karte — hier scheiterte Layered).
- [ ] **C:** Minimals Callout-Regeln aus `20-minimal-content.css` entfernen; Kuro-Callout-Library (Kasten/Border/BG/Icon-Mappings, `--role-*`-getrieben) in `22-kuro-callouts.css`. An der Quelle, kein Override.
- [ ] **D:** check.sh → Sicht-Check: **Callouts = Kuro** (Kasten, Border, Signal-Farben, Icons). Commit.

## Task 6: Checkboxen

**Files:** `30-minimal-features.css` (Checklist-icons Z. 2726–3010 entfernen/ersetzen) + Create `23-kuro-checkboxes.css`. Referenz: `feat/minimal-fork:src/61-kuro-checkboxes.css`, `main:src/21-checkboxes.css`.

- [ ] **A:** Minimals SVG-Masken-System (`input[type=checkbox]`, `li[data-task] > … :checked`, `-webkit-mask-image` pro Task-Typ, Spezifität 0,2,3) — die zweite Layered-Bruchstelle.
- [ ] **B:** Guide-Sektion „Checkboxen" (Anatomie + warum Kuros Glyphen brachen).
- [ ] **C:** Minimals Masken entfernen; Kuros Signal-Glyphen (sichtbare leere `[ ]`, Task-Typ-Glyphen). An der Quelle.
- [ ] **D:** check.sh → Sicht-Check: **Kuro-Checkbox-Glyphen, leere sichtbar, korrektes strikethrough**. Commit.

## Task 7: Tags

**Files:** `20-minimal-content.css` (Tags Z. 1814–1843) + Create `24-kuro-tags.css`. Referenz: `feat/minimal-fork:src/62-kuro-tags-typo.css`, `main:src/28-tags.css`.

- [ ] **A/B/C/D** per Template. Sicht-Check: **Kuro-Tag-Pills**.

## Task 8: Grauzone — Code · Tables · Blockquote · Lists · Bases · Graph

Sechs Komponenten, je ein Sub-Zyklus (A–D) und je ein Sicht-Check-Gate + Commit. Referenz jeweils `main:src/{22-code,25-tables,26-blockquote,27-lists,30-bases,31-graph}.css`; Minimal-Quelle im jeweiligen `*-minimal-*.css`.

- [ ] **8a Code** (`main:22-code.css`; Minimal Z. ~1970+ code/line-numbers) → `25-kuro-code.css`. Sicht: Mono-Code-Block, Kuro-Look.
- [ ] **8b Tables** (`main:25-tables.css`; Minimal Z. 1731–1813 + table-helpers 3386+) → `26-kuro-tables.css`. Sicht: Kuro-Tabellen (zebra etc.).
- [ ] **8c Blockquote** (`main:26-blockquote.css`; Minimal Z. 1399–1413) → `27-kuro-blockquote.css`.
- [ ] **8d Lists** (`main:27-lists.css`; Minimal Z. 1643–1656) → `28-kuro-lists.css`.
- [ ] **8e Bases** (`main:30-bases.css`; Minimal Bases-Vars Z. 52–54 + plugin-Block) → `29-kuro-bases.css`. (v4 hatte hier Bugs — Anatomie besonders sorgfältig.)
- [ ] **8f Graph** (`main:31-graph.css`) → `30-kuro-graph.css`.

Jeder Sub-Task: A–D + Commit `feat(<komp>): transform to Kuro`.

## Task 9: Ambiente + reduced-motion + @settings

**Files:** Create `80-kuro-ambient.css` (Film-Grain, H1-Glow), `85-kuro-reduced-motion.css` (aus `feat/minimal-fork:src/70-reduced-motion.css` — a11y-whitelist), `05-kuro-settings.css` (`@settings`-YAML, konfliktfrei mit Minimals Style-Settings-prefs Z. 5136+). Referenz: `main:src/{40-features,70-reduced-motion,05-style-settings}.css`.

- [ ] **A/B:** Guide-Sektionen Ambiente + reduced-motion + Style-Settings-Vertrag.
- [ ] **C:** Ambiente (`--role-*`/native-getrieben), reduced-motion (getaggte a11y-Ausnahmen im `85-`/`70-`-Whitelist-File), Kuro-`@settings`-Gruppen. Prüfen dass Minimals eigene `@settings` (falls im Skelett behalten) nicht kollidieren.
- [ ] **D:** check.sh (`!important`-Whitelist-File-Name in check.sh ggf. auf `85-*`/`70-*` anpassen) → Sicht-Check: **Film-Grain/Glow da, reduced-motion greift**. Commit.

## Task 10: Meta (Version · Lizenz · README · CHANGELOG)

**Files:** Modify `manifest.json`, `LICENSE`, `README.md`, `CHANGELOG.md`.

- [ ] **Step 1:** `manifest.json` → `"version": "5.0.0"`, `"minAppVersion": "1.9.0"`.
- [ ] **Step 2:** `LICENSE` → MIT-Text, Kuro-Copyright + `Portions © 2020–2024 Steph Ango (Minimal, MIT)`.
- [ ] **Step 3:** `README.md`/`CHANGELOG.md` → 5.0.0 Foundation-Wechsel + Fork-Herkunft (Minimal) nennen; Link auf `docs/GUIDE.md`.
- [ ] **Step 4:** check.sh → Sicht-Check (final: v4-Look erreicht, Standard Chamber) → Commit `chore(release): 5.0.0 meta — MIT, minAppVersion 1.9.0, Minimal fork attribution`.

---

## Self-Review (nach Task-Ausführung, gegen Spec)

- [ ] **Spec-Coverage:** §4 Schichten (Task 0 + Transforms) · §4a CSS-Fragmente (Task 0) · §4b Methode/Gate (alle Tasks) · §4c Guide (Task 1 + doku-getrieben je Transform) · §7 Chamber-Werte (Task 2) · §8 P1-Umfang (Tasks 2–9) · §10 Meta (Task 10). Grauzone alle → Kuro (Task 8) ✓. Behalten-Default: Minimal-Extras (`30/31/50/60/70-minimal-*`) bleiben ungelöscht ✓.
- [ ] **Both-Mode-Parität:** greift ab Task 2 (Palette).
- [ ] **Kein `!important`-Wildwuchs:** Gate ≤ 9 durchgängig; neue nur getaggt/whitelisted.
- [ ] **Guide vollständig:** jede transformierte Komponente hat eine Reference-Anatomie-Karte.

## Offene Phase-2-Haken (nicht in diesem Plan)

- Minimals Color-Schemes (`60-minimal-schemes.css`) ↔ Kuros Welten: Koexistenz vs. Ablösung (Spec §6).
- Materie-Presets + 5 weitere Welten + zwei Style-Settings-Dropdowns.
