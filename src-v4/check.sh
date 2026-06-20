#!/usr/bin/env bash
# Verification harness — the test suite for a build-artifact codebase.
# Determinism · brace balance · invariants · both-mode mirror · armature-lint.
set -euo pipefail
cd "$(dirname "$0")"
bash build.sh >/dev/null
a=$(md5 -q ../theme-v4.css); bash build.sh >/dev/null; b=$(md5 -q ../theme-v4.css)
[ "$a" = "$b" ] || { echo "FAIL: non-deterministic build"; exit 1; }
o=$(tr -cd '{' < ../theme-v4.css | wc -c); c=$(tr -cd '}' < ../theme-v4.css | wc -c)
[ "$o" -eq "$c" ] || { echo "FAIL: brace imbalance ${o}{ ${c}}"; exit 1; }
imp=$(grep -c '!important' ../theme-v4.css || true); echo "  !important: $imp"
[ "$imp" -le 70 ] || { echo "FAIL: !important $imp > 70"; exit 1; }
[ "$(grep -c '@import url(http' ../theme-v4.css || true)" -eq 0 ] || { echo "FAIL: remote @import"; exit 1; }
sz=$(wc -c < ../theme-v4.css); [ "$sz" -lt 5242880 ] || { echo "FAIL: size $sz >= 5MB"; exit 1; }
# strip CSS comments (so doc prose mentioning tokens never trips the scans)
strip() { perl -0777 -pe 's{/\*.*?\*/}{}gs' "$1"; }
# both-mode mirror (only once both semantic files exist)
if [ -f 10-semantic-dark.css ] && [ -f 11-semantic-light.css ]; then
  d=$(strip 10-semantic-dark.css | grep -oE -- '--[a-z0-9-]+[[:space:]]*:' | grep -oE -- '--[a-z0-9-]+' | sort -u)
  l=$(strip 11-semantic-light.css | grep -oE -- '--[a-z0-9-]+[[:space:]]*:' | grep -oE -- '--[a-z0-9-]+' | sort -u)
  if [ "$d" != "$l" ]; then echo "FAIL: semantic mirror mismatch:"; diff <(echo "$d") <(echo "$l"); exit 1; fi
  echo "  both-mode mirror: OK"
fi
# armature-lint: no colour/primitive literals in actual CSS of [armature] files
# (values files exempt: 00 primitives, 02 fonts, 50 presets, 55 subthemes; 10/11 semantic may read primitives)
for f in [0-9][0-9]-*.css; do
  case "$f" in 00-*|02-*|50-*|55-*|10-semantic-*|11-semantic-*) continue;; esac
  if strip "$f" | grep -nEq -- '#[0-9a-fA-F]{3,8}\b|--signal-|--void-|--paper-'; then
    echo "FAIL: literal/primitive in armature file $f:"
    strip "$f" | grep -nE -- '#[0-9a-fA-F]{3,8}\b|--signal-|--void-|--paper-'; exit 1
  fi
done
echo "ALL CHECKS PASS"
