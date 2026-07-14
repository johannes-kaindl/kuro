#!/usr/bin/env python3
# WCAG contrast + ramp analysis for Kuro's Chamber/Paper palette. Colour-blind-relevant:
# contrast is the objective legibility measure regardless of hue perception.
# Values are PARSED from src/03-kuro-palette.css — a hardcoded copy went stale once
# (reported pre-a11y-fix numbers as current, 2026-07-15) and is the same false-oracle
# failure mode as an unfaithful render mock. The palette file is the single source.
import re, pathlib

PALETTE = pathlib.Path(__file__).resolve().parents[2] / "src" / "03-kuro-palette.css"

def lin(c):
    c = c/255
    return c/12.92 if c <= 0.03928 else ((c+0.055)/1.055)**2.4
def lum(hexc):
    hexc = hexc.lstrip('#')
    r,g,b = (int(hexc[i:i+2],16) for i in (0,2,4))
    return 0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b)
def ratio(a,b):
    la,lb = lum(a),lum(b)
    hi,lo = max(la,lb),min(la,lb)
    return (hi+0.05)/(lo+0.05)
def verdict(r, large=False):
    aa = 3.0 if large else 4.5
    aaa = 4.5 if large else 7.0
    return "AAA" if r>=aaa else ("AA" if r>=aa else "FAIL(<AA)")

def parse_palette(css):
    """Extract --varname: #hex per .theme-dark/.theme-light block (rgba vars are skipped)."""
    out = {}
    for cls, label in ((".theme-dark", "DARK (Chamber)"), (".theme-light", "LIGHT (Paper)")):
        m = re.search(re.escape(cls) + r"\s*\{(.*?)\}", css, re.S)
        if not m:
            raise SystemExit(f"palette block {cls} not found in {PALETTE}")
        vals = dict(re.findall(r"--([a-z0-9]+)\s*:\s*(#[0-9a-fA-F]{6})", m.group(1)))
        out[label] = vals
    return out

modes = parse_palette(PALETTE.read_text())
for name,p in modes.items():
    print(f"\n=== {name} ===  (from {PALETTE.name})")
    checks = [
      ("body text  tx1/bg1", p["tx1"], p["bg1"], False),
      ("body text  tx1/bg2 (sidebar)", p["tx1"], p["bg2"], False),
      ("muted      tx2/bg1", p["tx2"], p["bg1"], False),
      ("muted      tx2/bg2 (sidebar)", p["tx2"], p["bg2"], False),
      ("faint      tx3/bg1", p["tx3"], p["bg1"], False),
      ("border     ui3/bg1 (large)", p["ui3"], p["bg1"], True),
    ]
    for label,fg,bg,large in checks:
        r = ratio(fg,bg)
        print(f"  {label:32s} {r:5.2f}:1  {verdict(r,large)}")
    # surface ramp spacing (luminance deltas note->sidebar->overlay)
    l1,l2,l3 = lum(p["bg1"]),lum(p["bg2"]),lum(p["bg3"])
    print(f"  ramp Δlum  note→sidebar {abs(l1-l2)*100:5.2f}  sidebar→overlay {abs(l2-l3)*100:5.2f}  (evenness)")
