#!/usr/bin/env python3
"""Read flutter test stdout and adb-screencap each [ezqr-shot] marker."""

from __future__ import annotations

import os
import re
import subprocess
import sys

SHOT = re.compile(r"\[ezqr-shot\] (\S+)")


def capture(device: str, dest: str) -> None:
    try:
        data = subprocess.check_output(
            ["adb", "-s", device, "exec-out", "screencap", "-p"],
        )
        start = data.find(b"\x89PNG")
        if start >= 0 and len(data) - start > 500:
            with open(dest, "wb") as fh:
                fh.write(data[start:])
            return
    except (subprocess.CalledProcessError, OSError) as exc:
        print("[warn] exec-out screencap failed: %s" % exc, file=sys.stderr)

    remote = "/sdcard/Download/ezqr_shot.png"
    subprocess.check_call(
        ["adb", "-s", device, "shell", "screencap", "-p", remote],
    )
    subprocess.check_call(
        ["adb", "-s", device, "pull", remote, dest],
        stdout=subprocess.DEVNULL,
    )


def main() -> int:
    device = os.environ.get("EZQR_DEVICE", "")
    out_dir = os.environ.get("EZQR_OUT", "docs/screenshots")
    if not device:
        print("[error] EZQR_DEVICE is empty", file=sys.stderr)
        return 2
    os.makedirs(out_dir, exist_ok=True)
    seen: set[str] = set()
    for raw in sys.stdin:
        sys.stdout.write(raw)
        sys.stdout.flush()
        line = raw.rstrip("\n")
        match = SHOT.search(line)
        if match:
            name = match.group(1)
            dest = os.path.join(out_dir, "%s.png" % name)
            try:
                capture(device, dest)
                size = os.path.getsize(dest)
                print("[ok] adb captured %s (%s bytes)" % (name, size))
                sys.stdout.flush()
                seen.add(name)
            except (subprocess.CalledProcessError, OSError) as exc:
                print("[error] capture %s: %s" % (name, exc), file=sys.stderr)
    print("[done] captured %s shot(s): %s" % (len(seen), ", ".join(sorted(seen))))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
