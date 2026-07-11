# Render harness — agent-owned visual verification

The maintaining agent verifies the theme visually itself (the user has red-green colour
deficiency and is not asked to judge colours — see `docs/GUIDE.md` § verification gate).

## Use

```bash
bash tools/render/render.sh     # builds theme.css, renders dark.png + light.png (headless Chrome)
python3 tools/render/contrast.py   # objective WCAG contrast + ramp analysis (colour-blind-safe)
```

Then **read the two PNGs** and judge: do structural components render (callout box, checkbox
glyph, tag pill)? Do palette + fonts read right in both modes? Report to the user in plain
language — never a "which colour?" question.

## Files
- `mock.html` — hand-built Obsidian DOM (real class names) + compact `app.css` stand-in that
  applies the theme's variables the way Obsidian does. Add elements here as new components land.
- `render.sh` — build + headless-Chrome screenshot, both modes.
- `contrast.py` — WCAG contrast + surface-ramp analysis for the palette.
- `theme.css`, `dark.png`, `light.png` — generated (gitignored).

## Known limits
Obsidian's real `app.css` is JS-bundled (not extractable), so the stand-in approximates base
styling. Direct `theme.css` rules (Kuro's own components) render faithfully; the stand-in covers
variable-driven base surfaces/fonts. Good enough to catch broken structure and gross colour
issues; the live Obsidian deploy (`Kuro v5` test slot in 10_Pallas) remains the final ground truth.
