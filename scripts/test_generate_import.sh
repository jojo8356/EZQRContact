#!/usr/bin/env bash
# Live generate→import: raster SimpleQR + vCard QR photos and import them
# through the production decoder (ML Kit then ZXing).
#
# Usage:
#   ./scripts/test_generate_import.sh                 # first connected device
#   ./scripts/test_generate_import.sh emulator-5554   # specific device

set -uo pipefail

DEVICE="${1:-}"

if [ -z "$DEVICE" ]; then
  DEVICE=$(flutter devices --machine 2>/dev/null \
    | python3 -c "import sys, json; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" \
    || echo "")
fi

if [ -z "$DEVICE" ]; then
  echo "No device found. Connect a phone or start an emulator first."
  echo
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

echo "Running generate→import integration test on: $DEVICE"
echo

flutter test integration_test/generate_and_import_test.dart --no-pub -d "$DEVICE"
