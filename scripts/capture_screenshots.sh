#!/usr/bin/env bash
# Capture the six README screenshots from a real device / emulator.
#
# Writes (and overwrites) PNG files named exactly as in README.md:
#   docs/screenshots/home.png
#   docs/screenshots/home-dark.png
#   docs/screenshots/vcard-form.png
#   docs/screenshots/scanner.png
#   docs/screenshots/collection.png
#   docs/screenshots/collection-dark.png
#
# Driven by integration_test/screenshots_test.dart via flutter drive.
# Prefer a clean emulator so Collection does not show personal contacts.
#
# Usage:
#   ./scripts/capture_screenshots.sh                 # first Android/iOS device
#   ./scripts/capture_screenshots.sh emulator-5554   # specific device

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="$ROOT/docs/screenshots"
EXPECTED=(
  home.png
  home-dark.png
  vcard-form.png
  scanner.png
  collection.png
  collection-dark.png
)

DEVICE="${1:-}"

pick_device() {
  flutter devices --machine 2>/dev/null | python3 -c '
import json, sys
try:
    devices = json.load(sys.stdin)
except Exception:
    sys.exit(0)
mobile = []
other = []
for d in devices:
    ident = str(d.get("id") or "")
    platform = str(d.get("targetPlatform") or "").lower()
    if not ident:
        continue
    if "chrome" in ident.lower() or platform.startswith("web"):
        continue
    if platform.startswith("android") or platform.startswith("ios"):
        mobile.append(ident)
    else:
        other.append(ident)
chosen = (mobile or other or [""])[0]
if chosen:
    print(chosen)
'
}

if [ -z "$DEVICE" ]; then
  DEVICE="$(pick_device || true)"
fi

if [ -z "$DEVICE" ]; then
  echo "No phone or emulator found. Connect one, then retry."
  echo
  echo "Available devices:"
  flutter devices
  exit 1
fi

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [ -n "$SDK" ] && [ -d "$SDK/platforms/android-37.0" ] \
    && [ ! -e "$SDK/platforms/android-37" ]; then
  echo "Gradle looks for $SDK/platforms/android-37, but sdkmanager"
  echo "installed android-37.0. Create a symlink, then re-run:"
  echo
  echo "  ln -sfn android-37.0 \"$SDK/platforms/android-37\""
  echo
  exit 1
fi

cleanup() {
  local sig=$?
  pkill -f "flutter_tools.snapshot drive" 2>/dev/null || true
  if [ "$sig" -ne 0 ] && [ "$sig" -ne 130 ]; then
    echo
    echo "Capture script exited with status $sig"
  fi
  return "$sig"
}
trap cleanup EXIT INT TERM

mkdir -p "$OUT_DIR"

echo "Capturing README screenshots on: $DEVICE"
echo "Output: $OUT_DIR"
echo

DRIVE_EXIT=0
if command -v timeout >/dev/null 2>&1; then
  timeout 240 flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshots_test.dart \
    --no-pub \
    -d "$DEVICE"
  DRIVE_EXIT=$?
  if [ "$DRIVE_EXIT" -eq 124 ]; then
    echo "[error] flutter drive timed out after 240s"
  fi
else
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshots_test.dart \
    --no-pub \
    -d "$DEVICE"
  DRIVE_EXIT=$?
fi

echo
if [ "$DRIVE_EXIT" -eq 0 ]; then
  echo "[done] flutter drive succeeded"
else
  echo "[done] flutter drive exited with code $DRIVE_EXIT"
fi

echo
echo "Files in $OUT_DIR:"
ls -lh "$OUT_DIR"/*.png 2>/dev/null || echo "  (none yet)"

MISSING=0
for name in "${EXPECTED[@]}"; do
  path="$OUT_DIR/$name"
  if [ ! -f "$path" ]; then
    echo "[missing] $name"
    MISSING=1
    continue
  fi
  size="$(wc -c < "$path" | tr -d ' ')"
  if [ "$size" -lt 500 ]; then
    echo "[too small] $name ($size bytes)"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 0 ]; then
  echo
  echo "[ok] all 6 README screenshots are present"
  echo
  echo "  | Light | Dark |"
  echo "  | docs/screenshots/home.png | docs/screenshots/home-dark.png |"
  echo "  | docs/screenshots/vcard-form.png | docs/screenshots/scanner.png |"
  echo "  | docs/screenshots/collection.png | docs/screenshots/collection-dark.png |"
fi

shopt -s nullglob
SHOTS=("$OUT_DIR"/*.png)
if [ "${#SHOTS[@]}" -gt 0 ]; then
  echo
  echo "[step] Optimizing PNGs via pngquant"
  if "$ROOT/scripts/optimize_screenshots.sh"; then
    echo "[ok] optimization complete"
  else
    echo "[warn] optimization failed; the raw screenshots are kept as-is"
  fi
fi

if [ "$MISSING" -ne 0 ]; then
  echo
  echo "[error] README set is incomplete. Re-run on a device with the app building."
  if [ "$DRIVE_EXIT" -ne 0 ]; then
    exit "$DRIVE_EXIT"
  fi
  exit 1
fi

exit "$DRIVE_EXIT"
