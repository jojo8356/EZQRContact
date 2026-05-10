#!/usr/bin/env bash
# Forensic inspection of the EZQRContact SQLite database on a connected
# Android device. Useful after a v1 -> v2 migration to verify schema,
# data preservation, backup presence, and row counts without writing
# code.
#
# Usage:
#   ./scripts/inspect_db.sh                  # auto-pick first device
#   ./scripts/inspect_db.sh emulator-5554    # specific device id

set -uo pipefail

PACKAGE="com.ezqrcontact.ezqrcontact"
DEVICE="${1:-}"

# 1. Pick a device
if [ -z "$DEVICE" ]; then
  DEVICE=$(adb devices | grep -v "List of" | grep "device$" | head -1 | awk '{print $1}')
fi

if [ -z "$DEVICE" ]; then
  echo "[error] no device connected. Plug a phone or start an emulator."
  echo
  adb devices
  exit 1
fi

echo "[info] using device: $DEVICE"
echo "[info] inspecting package: $PACKAGE"
echo

# 2. Sanity check: app installed and accessible via run-as
if ! adb -s "$DEVICE" shell run-as "$PACKAGE" id >/dev/null 2>&1; then
  echo "[error] cannot run-as $PACKAGE. The app must be installed in"
  echo "        debug mode on this device. Run:"
  echo "          flutter run -d $DEVICE"
  exit 1
fi

# 3. List databases/ directory
echo "=== databases/ contents ==="
adb -s "$DEVICE" shell run-as "$PACKAGE" ls -la databases/ 2>&1 \
  || echo "  (no databases/ directory yet — open the app and trigger a DB read first)"
echo

# 4. Pull DB files locally for inspection
TMP=$(mktemp -d)
trap 'echo; echo "[info] inspection files kept in: $TMP"' EXIT

echo "=== Pulling DB files ==="
adb -s "$DEVICE" shell run-as "$PACKAGE" cat databases/qr_app.db \
  > "$TMP/qr_app.db" 2>/dev/null

if [ ! -s "$TMP/qr_app.db" ]; then
  echo "  [error] could not pull qr_app.db (file is empty or missing)."
  echo
  echo "  The app has not yet created the database. Open the app and"
  echo "  navigate to the Collection or VCard form to trigger a write,"
  echo "  then re-run this script."
  exit 1
fi
echo "  qr_app.db: $(du -h "$TMP/qr_app.db" | cut -f1)"

adb -s "$DEVICE" shell run-as "$PACKAGE" cat databases/qr_app.db.backup \
  > "$TMP/qr_app.db.backup" 2>/dev/null

if [ -s "$TMP/qr_app.db.backup" ]; then
  echo "  qr_app.db.backup: $(du -h "$TMP/qr_app.db.backup" | cut -f1) (migration v1 -> v2 ran on this device)"
else
  rm -f "$TMP/qr_app.db.backup"
  echo "  qr_app.db.backup: not found (fresh install or no v1 -> v2 migration happened)"
fi
echo

# 5. Inspect with sqlite3
if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "[error] sqlite3 not in PATH. Install with: sudo apt install sqlite3"
  exit 1
fi

echo "=== Schema version ==="
ver=$(sqlite3 "$TMP/qr_app.db" "PRAGMA user_version;")
echo "  user_version = $ver"
if [ "$ver" = "2" ]; then
  echo "  [ok] v2 schema confirmed"
elif [ "$ver" = "1" ]; then
  echo "  [warn] still on v1 — migration did not run"
else
  echo "  [warn] unexpected version $ver"
fi
echo

echo "=== Tables ==="
sqlite3 "$TMP/qr_app.db" ".tables" | tr -s ' ' '\n' | sed 's/^/  /'
echo

echo "=== VCard schema ==="
sqlite3 "$TMP/qr_app.db" ".schema VCard"
echo

echo "=== SimpleQR schema ==="
sqlite3 "$TMP/qr_app.db" ".schema SimpleQR"
echo

echo "=== events schema (v2 new table) ==="
events_schema=$(sqlite3 "$TMP/qr_app.db" ".schema events" 2>/dev/null)
if [ -n "$events_schema" ]; then
  echo "$events_schema"
  echo "  [ok] events table exists"
else
  echo "  [warn] events table does NOT exist (v2 migration incomplete)"
fi
echo

echo "=== V2 columns on VCard (visual_config, event_id, captured_at) ==="
v2_cols=$(sqlite3 "$TMP/qr_app.db" "PRAGMA table_info(VCard)" \
  | grep -iE "visual_config|event_id|captured_at")
if [ -n "$v2_cols" ]; then
  echo "$v2_cols" | sed 's/^/  /'
  echo "  [ok] all 3 v2 columns present"
else
  echo "  [warn] none of the 3 v2 columns found (migration did not add them)"
fi
echo

echo "=== Row counts ==="
echo "  VCards (active):  $(sqlite3 "$TMP/qr_app.db" "SELECT COUNT(*) FROM VCard WHERE deleted = 0")"
echo "  VCards (deleted): $(sqlite3 "$TMP/qr_app.db" "SELECT COUNT(*) FROM VCard WHERE deleted = 1")"
echo "  SimpleQRs (active):  $(sqlite3 "$TMP/qr_app.db" "SELECT COUNT(*) FROM SimpleQR WHERE deleted = 0")"
echo "  SimpleQRs (deleted): $(sqlite3 "$TMP/qr_app.db" "SELECT COUNT(*) FROM SimpleQR WHERE deleted = 1")"
events_count=$(sqlite3 "$TMP/qr_app.db" "SELECT COUNT(*) FROM events" 2>/dev/null || echo "n/a")
echo "  Events: $events_count"
echo

# 6. Backup comparison (if backup exists)
if [ -s "$TMP/qr_app.db.backup" ]; then
  echo "=== Backup vs current ==="
  backup_ver=$(sqlite3 "$TMP/qr_app.db.backup" "PRAGMA user_version;")
  backup_vcards=$(sqlite3 "$TMP/qr_app.db.backup" "SELECT COUNT(*) FROM VCard" 2>/dev/null || echo "n/a")
  current_vcards=$(sqlite3 "$TMP/qr_app.db" "SELECT COUNT(*) FROM VCard")
  echo "  Backup user_version: $backup_ver (should be 1)"
  echo "  Backup VCards total: $backup_vcards"
  echo "  Current VCards total: $current_vcards"
  if [ "$backup_vcards" = "$current_vcards" ]; then
    echo "  [ok] row count preserved through migration"
  else
    echo "  [warn] row count differs — investigate"
  fi
  echo
fi

echo "[done] inspection complete"
