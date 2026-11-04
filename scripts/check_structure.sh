#!/usr/bin/env bash
set -euo pipefail

# Enforces the operation naming rule from docs/architecture/backend-structure.md.
#
# Inside handler/, service/ and repository/ there are five permitted file names
# and no others, plus the barrel named after the folder. A rule written down and
# never checked is a rule that lasts until the first hurry.
#
# Only the layer's immediate children are checked. An operation that outgrows
# the line budget becomes a folder of the same name, and the files inside it are
# that operation's breakdown — they are named for what they hold, because they
# are not operations. update/line.dart, update/shipping.dart and
# update/promotion.dart are the three things a cart update can be.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

status=0
STRUCTURE_BASELINE="scripts/backend_structure_baseline.txt"
STRUCTURE_CURRENT="$(mktemp)"

for layer in handler service repository; do
  while IFS= read -r path; do
    name="$(basename "$path")"
    name="${name%.dart}"
    case "$name" in
      create|read|update|delete|list|"$layer") ;;
      *)
        echo "$path" >> "$STRUCTURE_CURRENT"
        ;;
    esac
  done < <(
    find packages/commerce_server/lib/src/features \
      -type d -name "$layer" \
      -exec find {} -mindepth 1 -maxdepth 1 \
        \( -name '*.dart' -o -type d \) \
        ! -name '*.g.dart' \
        \; \
      | sort
  )
done

sort -o "$STRUCTURE_CURRENT" "$STRUCTURE_CURRENT"
if ! diff -u "$STRUCTURE_BASELINE" "$STRUCTURE_CURRENT"; then
  echo "::error::backend naming debt differs from its frozen baseline"
  echo "rename debt and remove its baseline row together; never add new debt"
  status=1
fi

# A response is a public allowlist, never a domain subtype. Inheriting from a
# domain class couples the wire contract to internal fields and can expose a
# newly-added field without an explicit API review.
while IFS= read -r match; do
  echo "::error::$match"
  echo "response DTOs must declare their public fields instead of extending another class"
  status=1
done < <(
  rg --line-number --multiline \
    'class\s+[A-Za-z0-9_]*Response\s+extends\s+' \
    packages/commerce_server/lib/src/features \
    --glob '*.dart' \
    --glob '!*.g.dart' \
    || true
)

# A use case exposes one success/failure boundary. Nested Results force every
# caller to decode transport and domain failures separately and make `?`-style
# propagation impossible. Existing debt is a frozen baseline. Removing debt
# requires shrinking the baseline in the same change, so it cannot return later.
NESTED_RESULT_BASELINE="scripts/nested_result_baseline.txt"
NESTED_RESULT_CURRENT="$(mktemp)"
WIDGET_BUILDER_BASELINE="scripts/widget_builder_baseline.txt"
WIDGET_BUILDER_CURRENT="$(mktemp)"
trap 'rm -f "$STRUCTURE_CURRENT" "$NESTED_RESULT_CURRENT" "$WIDGET_BUILDER_CURRENT"' EXIT
(
  rg --count-matches --multiline \
    'Result\s*<\s*Result\s*<' \
    packages apps \
    --glob '*.dart' \
    --glob '!*.g.dart' \
    || true
) | sort > "$NESTED_RESULT_CURRENT"
if ! diff -u "$NESTED_RESULT_BASELINE" "$NESTED_RESULT_CURRENT"; then
  echo "::error::nested Result debt differs from its frozen baseline"
  echo "remove debt and its baseline row together; never add new debt"
  status=1
fi

# Widget subtrees are real widget classes. Private methods returning Widget
# hide composition and rebuild boundaries inside a parent State. Existing debt
# is frozen by file so a touched feature can pay it down without a broad rewrite.
(
  rg --count-matches \
    '^\s*Widget\s+_[A-Za-z][A-Za-z0-9_]*\s*\(' \
    apps \
    --glob '*.dart' \
    --glob '!*.g.dart' \
    || true
) | sort > "$WIDGET_BUILDER_CURRENT"
if ! diff -u "$WIDGET_BUILDER_BASELINE" "$WIDGET_BUILDER_CURRENT"; then
  echo "::error::private Widget builder debt differs from its frozen baseline"
  echo "replace builders with widget classes and shrink the baseline; never add debt"
  status=1
fi

if [[ "$status" -eq 0 ]]; then
  echo "backend structure and response boundaries are valid"
fi

exit "$status"
