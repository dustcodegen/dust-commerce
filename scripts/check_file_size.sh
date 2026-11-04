#!/usr/bin/env bash
set -euo pipefail

# Enforces the 180-line rule from CONTRIBUTING.md.
#
# A limit nobody checks drifts one long file at a time, and the drift is
# invisible in review because each diff is small. This turns it into a failing
# check.
#
# Generated files are exempt: they are output, not source, and their length is
# decided by the generator rather than by an author.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LIMIT="${1:-180}"
BASELINE="scripts/file_size_baseline.txt"
CURRENT="$(mktemp)"
trap 'rm -f "$CURRENT"' EXIT

while IFS= read -r file; do
  # Count code: no blank lines, no doc comments, no line comments.
  lines="$(grep -cve '^[[:space:]]*$' -e '^[[:space:]]*//' "$file" || true)"
  if [[ "$lines" -gt "$LIMIT" ]]; then
    echo "$file:$lines" >> "$CURRENT"
  fi
done < <(
  find packages apps -name '*.dart' \
    -not -name '*.g.dart' \
    -not -path '*/.dart_tool/*' \
    -not -path '*/build/*' \
    | sort
)

sort -o "$CURRENT" "$CURRENT"

if ! diff -u "$BASELINE" "$CURRENT"; then
  echo "::error::file-size debt differs from its frozen baseline"
  echo "split debt and remove its baseline row together; never add or grow debt"
  exit 1
fi

if [[ -s "$CURRENT" ]]; then
  echo "existing file-size debt matches its frozen baseline"
else
  echo "every source file is within $LIMIT lines"
fi
