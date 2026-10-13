# ZXing blackbox QR samples

Subset of the ZXing Java blackbox corpus used by ZXing, zxing-cpp,
zxing-js and other open-source QR readers.

- Upstream: https://github.com/zxing/zxing
- Path: `core/src/test/resources/blackbox/qrcode-*`
- License: Apache License 2.0 (see the upstream repository)

Each `*.png` has a matching `*.txt` with the expected payload
(`trim()` of the file, same as ZXing's blackbox runner).

| File | Suite | What it is |
| --- | --- | --- |
| `qrcode-1_1` | qrcode-1 | Photographed bookmark QR |
| `qrcode-2_1` | qrcode-2 | Long text, small raster |
| `qrcode-2_12` | qrcode-2 | Photographed sentence |
| `qrcode-3_01` | qrcode-3 | URL with coordinates |
| `qrcode-3_10` | qrcode-3 | MECARD |
| `qrcode-4_01` | qrcode-4 | Print-ad photo |
| `qrcode-4_20` | qrcode-4 | Print-ad URL photo |
| `qrcode-5_01` | qrcode-5 | MECARD contact |
| `qrcode-6_1` | qrcode-6 | Numeric |
