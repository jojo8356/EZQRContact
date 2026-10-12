#!/usr/bin/env bash
# Live integration test: launch the app and tap the trash button.
#
# Usage:
#   ./scripts/test_trash.sh                 # first connected device
#   ./scripts/test_trash.sh emulator-5554   # specific device

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

echo "Running trash integration test on: $DEVICE"
echo

flutter test integration_test/trash_delete_test.dart --no-pub -d "$DEVICE"
