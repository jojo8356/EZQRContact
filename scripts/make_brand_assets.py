#!/usr/bin/env python3
"""Rebuild launcher icon + splash from the existing QR, in ENCRE inks.

Modules: Cuivre (#C45C26) → Encre (#1A1612) top to bottom.
Quiet zone / canvas: Papier (#F4EFE6).
The DA forbids a Cuivre→Marine mix; this gradient stays in the warm inks.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

CUIVRE = (0xC4, 0x5C, 0x26)
ENCRE = (0x1A, 0x16, 0x12)
PAPIER = (0xF4, 0xEF, 0xE6)


def lerp(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    t = 0.0 if t < 0 else 1.0 if t > 1 else t
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t),
        int(a[2] + (b[2] - a[2]) * t),
    )


def recolor(
    src: Image.Image,
    *,
    module_from: tuple[int, int, int] = CUIVRE,
    module_to: tuple[int, int, int] = ENCRE,
    paper: tuple[int, int, int] = PAPIER,
    keep_transparent: bool = False,
) -> Image.Image:
    im = src.convert("RGBA")
    w, h = im.size
    pix = im.load()

    min_y, max_y = h, 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a < 8:
                continue
            if r > 248 and g > 248 and b > 248:
                continue
            if y < min_y:
                min_y = y
            if y > max_y:
                max_y = y
    span = max(max_y - min_y, 1)

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0) if keep_transparent else (*paper, 255))
    dest = out.load()
    for y in range(h):
        t = (y - min_y) / span
        ink = lerp(module_from, module_to, t)
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a < 8:
                continue
            # How far from white: 0 = paper, 1 = solid module.
            white = min(r, g, b) / 255.0
            k = 1.0 - white
            if k < 0.04:
                if keep_transparent:
                    dest[x, y] = (*paper, 255)
                else:
                    dest[x, y] = (*paper, 255)
                continue
            cr = int(paper[0] + (ink[0] - paper[0]) * k)
            cg = int(paper[1] + (ink[1] - paper[1]) * k)
            cb = int(paper[2] + (ink[2] - paper[2]) * k)
            dest[x, y] = (cr, cg, cb, 255)
    return out


def save_resized(im: Image.Image, path: Path, size: int, *, flatten: tuple[int, int, int] | None = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    work = im
    if work.size != (size, size):
        work = work.resize((size, size), Image.Resampling.LANCZOS)
    if flatten is not None:
        bg = Image.new("RGBA", work.size, (*flatten, 255))
        bg.alpha_composite(work.convert("RGBA"))
        work = bg
    work.convert("RGBA").save(path, "PNG", optimize=True)


def solid(path: Path, rgb: tuple[int, int, int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.new("RGB", (1, 1), rgb).save(path, "PNG")


def main() -> None:
    icon_src = Image.open(ROOT / "assets/icon/icon.png")
    splash_src = Image.open(ROOT / "assets/logo_splash.png")

    icon = recolor(icon_src, keep_transparent=False)
    splash = recolor(splash_src, keep_transparent=True)

    # Master assets
    save_resized(icon, ROOT / "assets/icon/icon.png", 1024, flatten=PAPIER)
    save_resized(splash, ROOT / "assets/logo_splash.png", 1800)
    save_resized(splash, ROOT / "assets/logo_splash_dark.png", 1800)

    android = ROOT / "android/app/src/main/res"
    mipmap = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    for dens, px in mipmap.items():
        save_resized(icon, android / f"mipmap-{dens}/ic_launcher.png", px, flatten=PAPIER)
        save_resized(icon, android / f"mipmap-{dens}/launcher_icon.png", px, flatten=PAPIER)

    splash_dens = {
        "mdpi": 450,
        "hdpi": 675,
        "xhdpi": 900,
        "xxhdpi": 1350,
        "xxxhdpi": 1800,
    }
    for dens, px in splash_dens.items():
        save_resized(splash, android / f"drawable-{dens}/splash.png", px)
        save_resized(splash, android / f"drawable-{dens}/android12splash.png", px)
        save_resized(splash, android / f"drawable-night-{dens}/android12splash.png", px)

    solid(android / "drawable/background.png", PAPIER)
    solid(android / "drawable-v21/background.png", PAPIER)

    ios_icons = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for name, px in [
        ("Icon-App-20x20@1x.png", 20),
        ("Icon-App-20x20@2x.png", 40),
        ("Icon-App-20x20@3x.png", 60),
        ("Icon-App-29x29@1x.png", 29),
        ("Icon-App-29x29@2x.png", 58),
        ("Icon-App-29x29@3x.png", 87),
        ("Icon-App-40x40@1x.png", 40),
        ("Icon-App-40x40@2x.png", 80),
        ("Icon-App-40x40@3x.png", 120),
        ("Icon-App-50x50@1x.png", 50),
        ("Icon-App-50x50@2x.png", 100),
        ("Icon-App-57x57@1x.png", 57),
        ("Icon-App-57x57@2x.png", 114),
        ("Icon-App-60x60@2x.png", 120),
        ("Icon-App-60x60@3x.png", 180),
        ("Icon-App-72x72@1x.png", 72),
        ("Icon-App-72x72@2x.png", 144),
        ("Icon-App-76x76@1x.png", 76),
        ("Icon-App-76x76@2x.png", 152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]:
        save_resized(icon, ios_icons / name, px, flatten=PAPIER)

    launch = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    save_resized(splash, launch / "LaunchImage.png", 450)
    save_resized(splash, launch / "LaunchImage@2x.png", 900)
    save_resized(splash, launch / "LaunchImage@3x.png", 1350)
    solid(
        ROOT / "ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png",
        PAPIER,
    )

    web = ROOT / "web"
    save_resized(icon, web / "favicon.png", 16, flatten=PAPIER)
    save_resized(icon, web / "icons/Icon-192.png", 192, flatten=PAPIER)
    save_resized(icon, web / "icons/Icon-512.png", 512, flatten=PAPIER)
    save_resized(icon, web / "icons/Icon-maskable-192.png", 192, flatten=PAPIER)
    save_resized(icon, web / "icons/Icon-maskable-512.png", 512, flatten=PAPIER)
    save_resized(splash, web / "splash/img/light-1x.png", 450)
    save_resized(splash, web / "splash/img/light-2x.png", 900)
    save_resized(splash, web / "splash/img/light-3x.png", 1350)
    save_resized(splash, web / "splash/img/light-4x.png", 1800)
    save_resized(splash, web / "splash/img/dark-1x.png", 450)
    save_resized(splash, web / "splash/img/dark-2x.png", 900)
    save_resized(splash, web / "splash/img/dark-3x.png", 1350)
    save_resized(splash, web / "splash/img/dark-4x.png", 1800)

    print("[ok] brand assets written")


if __name__ == "__main__":
    main()
