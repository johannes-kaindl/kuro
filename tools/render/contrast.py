#!/usr/bin/env python3
# WCAG contrast + ramp analysis for Kuro's Chamber/Paper palette. Colour-blind-relevant:
# contrast is the objective legibility measure regardless of hue perception.
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

modes = {
  "DARK (Chamber)": {
    "bg1":"#060709","bg2":"#0b0d11","bg3":"#181c24",
    "ui1":"#22272f","ui3":"#3d4450",
    "tx1":"#e8e4d8","tx2":"#828a97","tx3":"#6b7280",
  },
  "LIGHT (Paper)": {
    "bg1":"#faf8f5","bg2":"#eae6de","bg3":"#d8d3c8",
    "ui1":"#e6e6e6","ui3":"#b0a99a",   # ui1 light is rgba on paper ~ approximated
    "tx1":"#2b2824","tx2":"#6b6761","tx3":"#847f75",
  },
}
for name,p in modes.items():
    print(f"\n=== {name} ===")
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
