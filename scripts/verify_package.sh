#!/usr/bin/env bash
set -euo pipefail

# Runs one package's generator, analyzer, and non-widget tests from a single
# repository-root contract. This prevents working-directory and runner drift.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$PWD" != "$ROOT_DIR" ]]; then
  echo "Run scripts/verify_package.sh from $ROOT_DIR" >&2
  exit 2
fi

PACKAGE="${1:-}"
PACKAGE="${PACKAGE%/}"
case "$PACKAGE" in
  apps/admin_app | apps/commerce_app | packages/commerce_admin_shared | \
    packages/commerce_server | packages/commerce_shared) ;;
  *)
    echo "Choose one workspace package path." >&2
    exit 2
    ;;
esac

SOURCE_COUNT="$(find "$PACKAGE" -name '*.dart' \
  ! -name '*.g.dart' \
  ! -path '*/.dart_tool/*' \
  ! -path '*/build/*' | wc -l | tr -d ' ')"
if [[ "$SOURCE_COUNT" == "0" ]]; then
  echo "No handwritten Dart sources found under $PACKAGE" >&2
  exit 2
fi

CHANGED_SOURCES="$(mktemp)"
trap 'rm -f "$CHANGED_SOURCES"' EXIT
{
  git diff --name-only --diff-filter=ACMRT HEAD -- "$PACKAGE"
  git diff-tree --no-commit-id --name-only --diff-filter=ACMRT -r HEAD \
    -- "$PACKAGE"
  git ls-files --others --exclude-standard -- "$PACKAGE"
} | awk '/\.dart$/ && !/\.g\.dart$/' | sort -u > "$CHANGED_SOURCES"

while IFS= read -r source_file; do
  dart format --output=none --set-exit-if-changed "$source_file"
done < "$CHANGED_SOURCES"

dust check --root "$PACKAGE"
if [[ "$PACKAGE" == "packages/commerce_server" ]]; then
  dust check --db --root "$PACKAGE"
fi

if grep -q 'sdk: flutter' "$PACKAGE/pubspec.yaml"; then
  (cd "$PACKAGE" && flutter analyze --no-pub && flutter test --no-pub)
else
  (cd "$PACKAGE" && dart analyze && dart test)
fi
