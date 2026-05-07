#!/usr/bin/env bash
# Lance le driver integration_test pour capturer les screenshots de l'app.
# Les PNG arrivent dans docs/screenshots/.
#
# Usage :
#   ./scripts/capture_screenshots.sh                  # auto-pick first device
#   ./scripts/capture_screenshots.sh emulator-5554    # specific device

set -euo pipefail

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

echo "Capturing screenshots on device: $DEVICE"
echo

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart \
  -d "$DEVICE"

echo
echo "Screenshots saved to docs/screenshots/"
ls -lh docs/screenshots/
