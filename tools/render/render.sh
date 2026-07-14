#!/usr/bin/env bash
# Visual verification harness — the agent-owned "sight-check" (the maintainer does not delegate
# colour judgement to the user; see docs/GUIDE.md § verification gate).
# Builds theme.css, renders the Obsidian-DOM mock (mock.html) via headless Chrome in BOTH modes,
# saves dark.png + light.png. Then read the PNGs to judge structure/colour, and run contrast.py
# for objective WCAG/ramp analysis (colour-blind-safe).
#
# mock.html is a hand-built Obsidian DOM using real class names, with a compact app.css stand-in
# (Obsidian applies the theme's variables to elements; a theme only sets the vars). Direct
# theme.css rules (Kuro components: callouts, checkboxes, tags — border/glyph/pill) render
# faithfully; variable-driven base styling (palette bg, body font) is applied by the stand-in.
set -euo pipefail
cd "$(dirname "$0")"
bash ../../src/build.sh >/dev/null
cp ../../theme.css theme.css
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
common=(--headless=new --disable-gpu --hide-scrollbars --window-size=1440,900 --virtual-time-budget=4000)
"$CHROME" "${common[@]}" --screenshot=dark.png  "file://$(pwd)/mock.html"        2>/dev/null
"$CHROME" "${common[@]}" --screenshot=light.png "file://$(pwd)/mock.html#light"  2>/dev/null
echo "rendered: $(pwd)/dark.png + light.png  — read them to judge; run: python3 contrast.py"
