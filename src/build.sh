#!/usr/bin/env bash
# Build theme.css from src-v4 fragments. Prepend HEADER, then numeric glob.
# Zero-dependency, deterministic. Edit fragments, never theme.css.
set -euo pipefail
cd "$(dirname "$0")"
out="../theme.css"
{ cat HEADER.css; for f in [0-9][0-9]-*.css; do printf '\n'; cat "$f"; done; } > "$out"
echo "built $out ($(wc -c < "$out") bytes)"
