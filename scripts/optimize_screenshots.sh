#!/usr/bin/env bash
# Optimize PNG screenshots in docs/screenshots/ via pngquant.
# If pngquant is missing, install it locally first via install_pngquant.sh.
#
# Usage:
#   ./scripts/optimize_screenshots.sh

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_BIN="$PROJECT_ROOT/tools/bin"
TARGET_DIR="$PROJECT_ROOT/docs/screenshots"

# Ensure pngquant is available (will install locally if needed).
"$PROJECT_ROOT/scripts/install_pngquant.sh"
INSTALL_EXIT=$?
if [ $INSTALL_EXIT -ne 0 ]; then
  echo "[abort] pngquant could not be installed"
  exit $INSTALL_EXIT
fi

# Pick the binary: PATH first, then local tools/bin/.
PNGQUANT="$(command -v pngquant 2>/dev/null || true)"
if [ -z "$PNGQUANT" ]; then
  if [ -x "$TOOLS_BIN/pngquant" ]; then
    PNGQUANT="$TOOLS_BIN/pngquant"
  elif [ -x "$TOOLS_BIN/pngquant.exe" ]; then
    PNGQUANT="$TOOLS_BIN/pngquant.exe"
  else
    echo "[error] pngquant not found after install"
    exit 1
  fi
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "[error] $TARGET_DIR does not exist"
  exit 1
fi

shopt -s nullglob
files=("$TARGET_DIR"/*.png)
if [ ${#files[@]} -eq 0 ]; then
  echo "[info] no PNG to optimize in $TARGET_DIR"
  exit 0
fi

echo "[info] using $PNGQUANT"
echo "[info] before:"
du -ch "${files[@]}" | tail -1

# --quality=65-85: skip if cannot get below 85, accept down to 65
# --strip: remove metadata (smaller files)
# --skip-if-larger: never replace with a larger file
# --force --ext .png: overwrite the original PNG in place
"$PNGQUANT" \
  --quality=65-85 \
  --strip \
  --skip-if-larger \
  --force \
  --ext .png \
  "${files[@]}"

echo "[info] after:"
du -ch "${files[@]}" | tail -1
echo "[ok] optimization done"
