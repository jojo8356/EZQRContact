# ZXing blackbox QR samples

Subset of the ZXing Java blackbox corpus used by ZXing, zxing-cpp,
zxing-js and other open-source QR readers.

- Upstream: https://github.com/zxing/zxing
- Path: `core/src/test/resources/blackbox/qrcode-*`
- License: Apache License 2.0 (see the upstream repository)

Each `*.png` has a matching `*.txt` with the expected payload
(`trim()` of the file, same as ZXing's blackbox runner).

We keep **photographed / print-ad** samples (gallery-like). Two Java
suites are omitted because zxing2 0.2.4 does not match the Java
detector on them:

- `qrcode-2/1.png` — packed high-version raster, almost no quiet zone
- `qrcode-6/*` — Tim Gernat tiny rotated finders (synthetic, not photos)

| File | Suite | What it is |
| --- | --- | --- |
| `qrcode-1_1` | qrcode-1 | Photographed bookmark QR |
| `qrcode-1_4` | qrcode-1 | Photographed bookmark QR |
| `qrcode-2_12` | qrcode-2 | Photographed sentence |
| `qrcode-3_01` | qrcode-3 | URL with coordinates |
| `qrcode-3_10` | qrcode-3 | MECARD |
| `qrcode-4_01` | qrcode-4 | Print-ad photo |
| `qrcode-4_10` | qrcode-4 | Print-ad photo |
| `qrcode-4_15` | qrcode-4 | Print-ad URL photo |
| `qrcode-4_20` | qrcode-4 | Print-ad URL photo |
| `qrcode-5_01` | qrcode-5 | MECARD contact |
