#!/usr/bin/env bash
# Verification harness — the test suite for a build-artifact codebase.
# Determinism · brace balance · comment balance · !important discipline (R2) ·
# both-mode mirror (R3) · armature-lint (R4). Rules: docs/CSS-CONVENTIONS.md.
set -euo pipefail
cd "$(dirname "$0")"

# strip CSS comments (so doc prose mentioning tokens or "!important" never trips a scan)
strip() { perl -0777 -pe 's{/\*.*?\*/}{}gs' "$1"; }
# blank comment CONTENTS but keep newlines, so line numbers still map to the raw file —
# lets the !important tag-check see real code declarations and ignore comment prose.
blank() { perl -0777 -pe 's{/\*.*?\*/}{ (my $b=$&) =~ s/[^\n]/ /g; $b }ges' "$1"; }

bash build.sh >/dev/null
a=$(md5 -q ../theme.css); bash build.sh >/dev/null; b=$(md5 -q ../theme.css)
[ "$a" = "$b" ] || { echo "FAIL: non-deterministic build"; exit 1; }

o=$(tr -cd '{' < ../theme.css | wc -c); c=$(tr -cd '}' < ../theme.css | wc -c)
[ "$o" -eq "$c" ] || { echo "FAIL: brace imbalance ${o}{ ${c}}"; exit 1; }

# comment balance per fragment: a '*/' glued into doc prose (e.g. --fg-*/--glow-*)
# closes a comment early and breaks the CSS parser. /* count must equal */ count.
for f in HEADER.css [0-9][0-9]-*.css; do
  co=$(grep -oF '/*' "$f" | wc -l | tr -d ' '); cc=$(grep -oF '*/' "$f" | wc -l | tr -d ' ')
  [ "$co" -eq "$cc" ] || { echo "FAIL: comment imbalance in $f (/*=$co */=$cc) — stray '*/' in prose?"; exit 1; }
done

# !important discipline (R1 variable-first / R2 tag-or-justify) — two gates:
#  (1) precise count: strip comments first, so prose mentioning "!important" never inflates it.
#  (2) every REAL declaration (ends "!important;") must carry an inline
#      /* important: <reason> */ tag — EXCEPT in 70-reduced-motion.css, the a11y
#      whitelist whose whole purpose is the prefers-reduced-motion blanket reset.
imp=$(strip ../theme.css | grep -oE '!important' | wc -l | tr -d ' ')
echo "  !important: $imp"
[ "$imp" -le 9 ] || { echo "FAIL: !important $imp > 9 — prefer a variable bridge (R1) or matched specificity; tag+justify only if unavoidable (R2)"; exit 1; }
for f in HEADER.css [0-9][0-9]-*.css; do
  [ "$f" = "70-reduced-motion.css" ] && continue
  # Match the !important TOKEN in real code (comment-blanked), not the literal "!important;",
  # so a declaration without a trailing semicolon can't dodge the tag rule, and prose can't
  # false-trip it. Each such raw line must carry an inline /* important: <reason> */ tag.
  while IFS=: read -r ln _; do
    [ -n "$ln" ] || continue
    raw=$(sed -n "${ln}p" "$f")
    case "$raw" in
      *'/* important:'*) ;;
      *) echo "FAIL: untagged !important in $f:$ln — add inline '/* important: <reason> */', or move it to 70-reduced-motion.css (R2):"; echo "    $raw"; exit 1;;
    esac
  done < <(blank "$f" | grep -n '!important' || true)
done
echo "  !important: all tagged or whitelisted: OK"

[ "$(grep -c '@import url(http' ../theme.css || true)" -eq 0 ] || { echo "FAIL: remote @import"; exit 1; }
sz=$(wc -c < ../theme.css); [ "$sz" -lt 5242880 ] || { echo "FAIL: size $sz >= 5MB"; exit 1; }

# both-mode mirror (R3) — only once both semantic files exist
if [ -f 10-semantic-dark.css ] && [ -f 11-semantic-light.css ]; then
  d=$(strip 10-semantic-dark.css | grep -oE -- '--[a-z0-9-]+[[:space:]]*:' | grep -oE -- '--[a-z0-9-]+' | sort -u)
  l=$(strip 11-semantic-light.css | grep -oE -- '--[a-z0-9-]+[[:space:]]*:' | grep -oE -- '--[a-z0-9-]+' | sort -u)
  if [ "$d" != "$l" ]; then echo "FAIL: semantic mirror mismatch:"; diff <(echo "$d") <(echo "$l"); exit 1; fi
  echo "  both-mode mirror: OK"
fi

# armature-lint (R4): no colour/primitive literals in actual CSS of [armature] files
# (values files exempt: 00 primitives, 02 fonts, 50 presets, 55 subthemes; 10/11 semantic + 13 roles may read primitives)
for f in [0-9][0-9]-*.css; do
  case "$f" in 00-*|02-*|50-*|55-*|10-semantic-*|11-semantic-*|13-roles.css) continue;; esac
  if strip "$f" | grep -nEq -- '#[0-9a-fA-F]{3,8}\b|--signal-|--void-|--paper-'; then
    echo "FAIL: literal/primitive in armature file $f:"
    strip "$f" | grep -nE -- '#[0-9a-fA-F]{3,8}\b|--signal-|--void-|--paper-'; exit 1
  fi
done
echo "ALL CHECKS PASS"
