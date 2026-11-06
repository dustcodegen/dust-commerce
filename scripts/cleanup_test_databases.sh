#!/usr/bin/env bash
set -euo pipefail

DATABASE_URL="${DUST_DATABASE_URL:-${COMMERCE_TEST_DATABASE_URL:-}}"
if [[ -z "$DATABASE_URL" ]]; then
  exit 0
fi

# Test databases are disposable and have an exact, isolated prefix. Never
# touch the configured application database itself.
psql "$DATABASE_URL" --tuples-only --no-align \
  --command="SELECT format('DROP DATABASE IF EXISTS %I;', datname)
             FROM pg_database WHERE datname LIKE 'dust_test_%';" |
  psql "$DATABASE_URL" --set ON_ERROR_STOP=1 >/dev/null
