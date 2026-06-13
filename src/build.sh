#!/usr/bin/env bash
# Build themes/kuro/theme.css by concatenating numbered source files in src/.
# Maintainers: name new files with a numeric prefix to control cascade order.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$(cd "$HERE/.." && pwd)/theme.css"

{
  cat "$HERE/HEADER.css"
  echo ""
  for f in "$HERE"/[0-9][0-9]-*.css; do
    echo ""
    echo "/* ═══════════════════════════════════════════════════════════════════════════"
    printf '   FRAGMENT · %s\n' "$(basename "$f")"
    echo "   ═══════════════════════════════════════════════════════════════════════ */"
    echo ""
    cat "$f"
  done
} > "$OUT"

LINES=$(wc -l < "$OUT")
BYTES=$(wc -c < "$OUT")
echo "Built $OUT — $LINES lines, $BYTES bytes"
