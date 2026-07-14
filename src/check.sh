#!/usr/bin/env bash
# Verification harness — the test suite for a build-artifact codebase.
# Determinism · brace balance · comment balance · !important discipline (Kuro fragments) ·
# both-mode palette parity · no-hex in Kuro components. Rules: docs/CSS-CONVENTIONS.md.
#
# Skeleton-fork model (2026-07): *-minimal-*.css are OWNED Minimal, transformed incrementally
# to Kuro. They are exempt from Kuro's !important/hex discipline until transformed; their
# living !important count is reported as "transform debt" (tracked, drives cleanup — not gated).
# *-kuro-*.css are Kuro's own and DO obey the discipline.
set -euo pipefail
cd "$(dirname "$0")"

# strip CSS comments (so doc prose mentioning tokens or "!important" never trips a scan)
strip() { perl -0777 -pe 's{/\*.*?\*/}{}gs' "$1"; }
# blank comment CONTENTS but keep newlines, so line numbers still map to the raw file.
blank() { perl -0777 -pe 's{/\*.*?\*/}{ (my $b=$&) =~ s/[^\n]/ /g; $b }ges' "$1"; }

bash build.sh >/dev/null
a=$(md5 -q ../theme.css); bash build.sh >/dev/null; b=$(md5 -q ../theme.css)
[ "$a" = "$b" ] || { echo "FAIL: non-deterministic build"; exit 1; }

o=$(tr -cd '{' < ../theme.css | wc -c); c=$(tr -cd '}' < ../theme.css | wc -c)
[ "$o" -eq "$c" ] || { echo "FAIL: brace imbalance ${o}{ ${c}}"; exit 1; }

# comment balance per fragment: a stray '*/' glued into prose closes a comment early.
for f in HEADER.css [0-9][0-9]-*.css; do
  co=$(grep -oF '/*' "$f" | wc -l | tr -d ' '); cc=$(grep -oF '*/' "$f" | wc -l | tr -d ' ')
  [ "$co" -eq "$cc" ] || { echo "FAIL: comment imbalance in $f (/*=$co */=$cc) — stray '*/' in prose?"; exit 1; }
done

# !important discipline — KURO fragments only. Gate: <=9 total across *-kuro-*.css, each tagged
# inline /* important: <reason> */, except the a11y whitelist 85-kuro-reduced-motion.css.
kuro_imp=0
for f in *-kuro-*.css; do
  [ -e "$f" ] || continue
  n=$( { strip "$f" | grep -oE '!important' || true; } | wc -l | tr -d ' '); kuro_imp=$((kuro_imp + n))
done
echo "  !important (Kuro fragments): $kuro_imp"
[ "$kuro_imp" -le 9 ] || { echo "FAIL: Kuro !important $kuro_imp > 9 — prefer variable bridge (R1) or matched specificity; tag+justify only if unavoidable (R2)"; exit 1; }
for f in *-kuro-*.css; do
  [ -e "$f" ] || continue
  [ "$f" = "85-kuro-reduced-motion.css" ] && continue
  while IFS=: read -r ln _; do
    [ -n "$ln" ] || continue
    raw=$(sed -n "${ln}p" "$f")
    case "$raw" in
      *'/* important:'*) ;;
      *) echo "FAIL: untagged !important in $f:$ln — add inline '/* important: <reason> */' or move to 85-kuro-reduced-motion.css (R2):"; echo "    $raw"; exit 1;;
    esac
  done < <(blank "$f" | grep -n '!important' || true)
done
echo "  !important: Kuro fragments tagged/whitelisted: OK"

# transform debt: !important still living in owned Minimal fragments (informational).
min_imp=0
for f in *-minimal-*.css; do
  [ -e "$f" ] || continue
  n=$( { strip "$f" | grep -oE '!important' || true; } | wc -l | tr -d ' '); min_imp=$((min_imp + n))
done
echo "  !important (Minimal transform-debt): $min_imp"

[ "$(grep -c '@import url(http' ../theme.css || true)" -eq 0 ] || { echo "FAIL: remote @import"; exit 1; }
sz=$(wc -c < ../theme.css); [ "$sz" -lt 5242880 ] || { echo "FAIL: size $sz >= 5MB"; exit 1; }

# both-mode palette parity (R3) — once a Kuro palette exists, its .theme-dark and .theme-light
# blocks must pin the same alias key-set (replaces v4's 10<->11 semantic mirror).
pal=$(ls *-kuro-palette.css 2>/dev/null | head -1 || true)
if [ -n "${pal}" ]; then
  keys_of() { strip "$pal" | awk -v m=".theme-$1" 'index($0,m){f=1} f{print} f&&/}/{f=0}' | grep -oE -- '--[a-z0-9-]+[[:space:]]*:' | grep -oE -- '--[a-z0-9-]+' | sort -u; }
  d=$(keys_of dark); l=$(keys_of light)
  if [ "$d" != "$l" ]; then echo "FAIL: palette both-mode key mismatch:"; diff <(echo "$d") <(echo "$l"); exit 1; fi
  echo "  palette both-mode parity: OK"
fi

# no-hex in Kuro component fragments (R1 variable-first). Palette is the [values] exception;
# owned *-minimal-*.css keep Minimal's literals until transformed.
for f in *-kuro-*.css; do
  [ -e "$f" ] || continue
  case "$f" in *-kuro-palette.css) continue;; esac
  if strip "$f" | grep -nEq -- '#[0-9a-fA-F]{3,8}\b'; then
    echo "FAIL: hex literal in Kuro fragment $f (use --role-*/aliases/native, R1):"
    strip "$f" | grep -nE -- '#[0-9a-fA-F]{3,8}\b'; exit 1
  fi
done
echo "  no-hex in Kuro components: OK"

echo "ALL CHECKS PASS"
