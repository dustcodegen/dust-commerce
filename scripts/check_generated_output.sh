#!/usr/bin/env bash
set -euo pipefail

# Dust owns generated Dart. CI/CD regenerates it, then this script proves the
# outputs stay ignored, deterministic, and absent from source control.

packages=(
  packages/commerce_admin_shared
  packages/commerce_shared
  packages/commerce_server
  apps/commerce_app
  apps/admin_app
)

test -z "$(git ls-files -- '**/*.g.dart')"

generated_count="$(find apps packages -type f -name '*.g.dart' | wc -l | tr -d ' ')"
test "$generated_count" -gt 0

while IFS= read -r -d '' generated; do
  git check-ignore --no-index --quiet "$generated" || {
    echo "Generated Dart is not ignored: $generated" >&2
    exit 1
  }
done < <(find apps packages -type f -name '*.g.dart' -print0)

for package_root in "${packages[@]}"; do
  dust check --root "$package_root"
done

dust check --db --root packages/commerce_server
dust i18n check --root apps/commerce_app
git diff --exit-code
test -z "$(git ls-files --others --exclude-standard -- "${packages[@]}")"
