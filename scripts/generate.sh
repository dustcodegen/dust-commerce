#!/usr/bin/env bash
set -euo pipefail

# Regenerates every ignored Dust output from handwritten workspace sources.
# Formatting is intentionally separate and excludes generated .g.dart files.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

for package_root in \
  packages/commerce_shared \
  packages/commerce_admin_shared \
  packages/commerce_server \
  apps/commerce_app \
  apps/admin_app; do
  dust build --root "$package_root"
done

dust db build --root packages/commerce_server
dust i18n build --root apps/commerce_app
