#!/usr/bin/env bash
set -euo pipefail

: "${DUST_VERSION:?set DUST_VERSION}"
: "${DUST_LINUX_X64_SHA256:?set DUST_LINUX_X64_SHA256}"

asset="dust-x86_64-unknown-linux-gnu.tar.gz"
work_root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
archive="$work_root/$asset"
install_root="$work_root/dust-cli"

rm -f "$archive"

if command -v gh >/dev/null 2>&1; then
  gh release download "$DUST_VERSION" \
    --repo dustcodegen/dust \
    --pattern "$asset" \
    --dir "$work_root" \
    --clobber ||
    curl --fail --location --retry 8 --retry-all-errors --retry-delay 5 \
      "https://github.com/dustcodegen/dust/releases/download/$DUST_VERSION/$asset" \
      --output "$archive"
else
  curl --fail --location --retry 8 --retry-all-errors --retry-delay 5 \
    "https://github.com/dustcodegen/dust/releases/download/$DUST_VERSION/$asset" \
    --output "$archive"
fi

if command -v sha256sum >/dev/null 2>&1; then
  printf '%s  %s\n' "$DUST_LINUX_X64_SHA256" "$archive" |
    sha256sum --check --status -
else
  printf '%s  %s\n' "$DUST_LINUX_X64_SHA256" "$archive" |
    shasum -a 256 --check --status -
fi

mkdir -p "$install_root/bin"
tar -xzf "$archive" -C "$install_root/bin"
chmod 0755 "$install_root/bin/dust"
if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$install_root/bin" >> "$GITHUB_PATH"
fi
if [[ "$(uname -s)" == "Linux" ]]; then
  "$install_root/bin/dust" --version
else
  echo "Installed Linux Dust CLI at $install_root/bin/dust"
fi
