#!/usr/bin/env bash
# Capture the five README screenshots from a real device / emulator.
#
# Writes (and overwrites) PNG files named exactly as in README.md:
#   docs/screenshots/home.png
#   docs/screenshots/home-dark.png
#   docs/screenshots/scanner.png
#   docs/screenshots/collection.png
#   docs/screenshots/collection-dark.png
#
# Before driving the UI, the script inserts demo rows if they are missing:
#   Marie Dupont, Jean Martin, https://github.com/jojo8356/EZQRContact
# On Android this is done with adb + sqlite so Collection is already
# populated when the first frame is captured. The Dart test inserts the
# same rows as a fallback (iOS, or if adb seed could not run).
#
# Screenshots are taken with adb screencap when the test prints
# `[ezqr-shot] <name>`. flutter drive is not used: its VM service
# disappears on some Mali devices.
#
# Usage:
#   ./scripts/capture_screenshots.sh                 # first Android/iOS device
#   ./scripts/capture_screenshots.sh emulator-5554   # specific device

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="$ROOT/docs/screenshots"
PACKAGE="com.ezqrcontact.ezqrcontact"
GITHUB_QR="https://github.com/jojo8356/EZQRContact"
EXPECTED=(
  home.png
  home-dark.png
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

is_android() {
  adb -s "$DEVICE" get-state >/dev/null 2>&1
}

app_installed() {
  adb -s "$DEVICE" shell pm path "$PACKAGE" >/dev/null 2>&1
}

db_exists() {
  adb -s "$DEVICE" shell run-as "$PACKAGE" ls databases/qr_app.db >/dev/null 2>&1
}

ensure_app_and_db() {
  if ! app_installed; then
    echo "[step] installing debug app so the demo DB can be seeded"
    if ! flutter install -d "$DEVICE"; then
      echo "[warn] flutter install failed"
      return 1
    fi
  fi
  if ! app_installed; then
    echo "[warn] $PACKAGE is not installed"
    return 1
  fi
  if db_exists; then
    return 0
  fi
  echo "[step] launching the app once to create qr_app.db"
  adb -s "$DEVICE" shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
  adb -s "$DEVICE" shell monkey -p "$PACKAGE" \
    -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true
  local i
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if db_exists; then
      sleep 1
      adb -s "$DEVICE" shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
      return 0
    fi
    sleep 1
  done
  adb -s "$DEVICE" shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
  echo "[warn] qr_app.db did not appear"
  return 1
}

pull_db() {
  local dest="$1"
  adb -s "$DEVICE" exec-out run-as "$PACKAGE" cat databases/qr_app.db \
    > "$dest"
  adb -s "$DEVICE" exec-out run-as "$PACKAGE" cat databases/qr_app.db-wal \
    > "${dest}-wal" 2>/dev/null || true
  adb -s "$DEVICE" exec-out run-as "$PACKAGE" cat databases/qr_app.db-shm \
    > "${dest}-shm" 2>/dev/null || true
  if [ ! -s "${dest}-wal" ]; then
    rm -f "${dest}-wal"
  fi
  if [ ! -s "${dest}-shm" ]; then
    rm -f "${dest}-shm"
  fi
}

push_db() {
  local src="$1"
  adb -s "$DEVICE" push "$src" /data/local/tmp/ezqr_seed.db >/dev/null
  if adb -s "$DEVICE" shell run-as "$PACKAGE" \
      cp /data/local/tmp/ezqr_seed.db databases/qr_app.db >/dev/null 2>&1; then
    adb -s "$DEVICE" shell run-as "$PACKAGE" \
      rm -f databases/qr_app.db-wal databases/qr_app.db-shm >/dev/null 2>&1 || true
    return 0
  fi
  python3 - "$DEVICE" "$PACKAGE" "$src" <<'PY'
import subprocess, sys

device, package, path = sys.argv[1], sys.argv[2], sys.argv[3]
data = open(path, "rb").read()
cmd = [
    "adb", "-s", device, "shell", "run-as", package,
    "sh", "-c", "cat > databases/qr_app.db",
]
raise SystemExit(subprocess.run(cmd, input=data).returncode)
PY
}

seed_sqlite() {
  local db="$1"
  python3 - "$db" "$GITHUB_QR" <<'PY'
import sqlite3
import sys

path = sys.argv[1]
github = sys.argv[2]
raw = open(path, "rb").read(16)
if not raw.startswith(b"SQLite format 3"):
    print("[error] pulled file is not a SQLite database")
    raise SystemExit(2)

con = sqlite3.connect(path)
con.execute("PRAGMA wal_checkpoint(TRUNCATE)")
tables = {
    row[0]
    for row in con.execute("SELECT name FROM sqlite_master WHERE type='table'")
}
if "VCard" not in tables or "SimpleQR" not in tables:
    print("[error] VCard / SimpleQR tables missing")
    raise SystemExit(2)

added = 0

def missing_vcard(prenom, nom):
    n = con.execute(
        "SELECT COUNT(*) FROM VCard WHERE prenom = ? AND nom = ? AND deleted = 0",
        (prenom, nom),
    ).fetchone()[0]
    return n == 0

if missing_vcard("Marie", "Dupont"):
    con.execute(
        """
        INSERT INTO VCard (
          nom, prenom, nom2, prefixe, suffixe, org, job, photo,
          tel_work, tel_home, adr_work, adr_home, email, rev,
          clone, deleted
        ) VALUES (
          'Dupont', 'Marie', '', '', '', 'Demo Corp',
          'Sales Representative', '',
          '+33 6 12 34 56 78', '', '1 rue Demo, 75001 Paris', '',
          'marie@example.com', '20260510T194800Z',
          0, 0
        )
        """
    )
    print("[seed] inserted Marie Dupont")
    added += 1
else:
    print("[seed] Marie Dupont already present")

if missing_vcard("Jean", "Martin"):
    con.execute(
        """
        INSERT INTO VCard (
          nom, prenom, nom2, prefixe, suffixe, org, job, photo,
          tel_work, tel_home, adr_work, adr_home, email, rev,
          clone, deleted
        ) VALUES (
          'Martin', 'Jean', '', '', '', 'TechCo', 'CTO', '',
          '+33 7 98 76 54 32', '', '', '',
          'jean.martin@example.com', '20260510T194800Z',
          0, 0
        )
        """
    )
    print("[seed] inserted Jean Martin")
    added += 1
else:
    print("[seed] Jean Martin already present")

n_simple = con.execute(
    "SELECT COUNT(*) FROM SimpleQR WHERE text = ? AND deleted = 0",
    (github,),
).fetchone()[0]
if n_simple == 0:
    con.execute(
        "INSERT INTO SimpleQR (text, deleted) VALUES (?, 0)",
        (github,),
    )
    print("[seed] inserted GitHub simple QR")
    added += 1
else:
    print("[seed] GitHub simple QR already present")

con.commit()
con.execute("PRAGMA wal_checkpoint(TRUNCATE)")
con.close()
print("[ok] demo seed done (%s new row(s))" % added)
PY
}

seed_android_demo() {
  echo "[step] seeding demo contacts on $DEVICE"
  if ! command -v adb >/dev/null 2>&1; then
    echo "[warn] adb not in PATH"
    return 1
  fi
  if ! is_android; then
    echo "[info] not Android; Dart test will insert demo rows"
    return 1
  fi
  if ! ensure_app_and_db; then
    return 1
  fi
  adb -s "$DEVICE" shell am force-stop "$PACKAGE" >/dev/null 2>&1 || true
  local tmp
  tmp="$(mktemp -d)"
  local db="$tmp/qr_app.db"
  if ! pull_db "$db"; then
    echo "[warn] could not pull qr_app.db"
    rm -rf "$tmp"
    return 1
  fi
  if ! seed_sqlite "$db"; then
    rm -rf "$tmp"
    return 1
  fi
  if ! push_db "$db"; then
    echo "[warn] could not push seeded qr_app.db"
    rm -rf "$tmp"
    return 1
  fi
  rm -rf "$tmp"
  echo "[ok] device DB now has Marie Dupont, Jean Martin, GitHub QR"
  return 0
}

cleanup() {
  local sig=$?
  pkill -f "screenshots_test.dart" 2>/dev/null || true
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

if ! seed_android_demo; then
  echo "[info] adb seed skipped; integration_test will insert the demo rows"
  echo
fi

export EZQR_DEVICE="$DEVICE"
export EZQR_OUT="$OUT_DIR"
START_EPOCH="$(date +%s)"

echo "[step] driving UI with flutter test (adb screencap on each marker)"
echo

TEST_EXIT=0
if command -v timeout >/dev/null 2>&1; then
  timeout 240 flutter test \
    integration_test/screenshots_test.dart \
    --no-pub \
    -d "$DEVICE" 2>&1 \
    | python3 -u "$ROOT/scripts/adb_capture_on_marker.py"
  TEST_EXIT=${PIPESTATUS[0]}
  if [ "$TEST_EXIT" -eq 124 ]; then
    echo "[error] flutter test timed out after 240s"
  fi
else
  flutter test \
    integration_test/screenshots_test.dart \
    --no-pub \
    -d "$DEVICE" 2>&1 \
    | python3 -u "$ROOT/scripts/adb_capture_on_marker.py"
  TEST_EXIT=${PIPESTATUS[0]}
fi

echo
if [ "$TEST_EXIT" -eq 0 ]; then
  echo "[done] flutter test succeeded"
else
  echo "[done] flutter test exited with code $TEST_EXIT"
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
    continue
  fi
  mtime="$(stat -c %Y "$path" 2>/dev/null || stat -f %m "$path")"
  if [ "$mtime" -lt "$START_EPOCH" ]; then
    echo "[stale] $name (not recaptured this run)"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 0 ]; then
  echo
  echo "[ok] all 5 README screenshots are present"
  echo
  echo "  | Light | Dark |"
  echo "  | docs/screenshots/home.png | docs/screenshots/home-dark.png |"
  echo "  | docs/screenshots/collection.png | docs/screenshots/collection-dark.png |"
  echo "  scanner: docs/screenshots/scanner.png"
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
  if [ "$TEST_EXIT" -ne 0 ]; then
    exit "$TEST_EXIT"
  fi
  exit 1
fi

exit "$TEST_EXIT"
