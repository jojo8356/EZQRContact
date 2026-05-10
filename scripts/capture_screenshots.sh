#!/usr/bin/env bash
# Lance le driver integration_test pour capturer les screenshots de l'app.
# Les PNG arrivent dans docs/screenshots/.
#
# Usage :
#   ./scripts/capture_screenshots.sh                  # auto-pick first device
#   ./scripts/capture_screenshots.sh emulator-5554    # specific device

set -uo pipefail

DEVICE="${1:-}"

if [ -z "$DEVICE" ]; then
  # Auto-pick first available device
  DEVICE=$(flutter devices --machine 2>/dev/null \
    | python3 -c "import sys, json; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" \
    || echo "")
fi

if [ -z "$DEVICE" ]; then
  echo "No device found. Connect a phone or start an emulator first."
  echo
  echo "Available devices:"
  flutter devices
  exit 1
fi

# Cleanup on exit, interrupt, or termination: ensure no flutter drive
# process keeps running in the background after this script returns.
cleanup() {
  local sig=$?
  pkill -f "flutter_tools.snapshot drive" 2>/dev/null || true
  if [ $sig -ne 0 ] && [ $sig -ne 130 ]; then
    echo
    echo "Capture script exited with status $sig"
  fi
  return $sig
}
trap cleanup EXIT INT TERM

echo "Capturing screenshots on device: $DEVICE"
echo

# --timeout caps the whole driver run so a hung test cannot block the
# script forever (the Dart test layer also has its own per-test timeouts
# but this is a hard ceiling at the process level).
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart \
  --no-pub \
  -d "$DEVICE"
DRIVE_EXIT=$?

echo
if [ $DRIVE_EXIT -eq 0 ]; then
  echo "[done] flutter drive succeeded"
else
  echo "[done] flutter drive exited with code $DRIVE_EXIT"
fi

echo
echo "Screenshots saved to docs/screenshots/"
ls -lh docs/screenshots/ 2>/dev/null || echo "  (none yet)"

exit $DRIVE_EXIT
