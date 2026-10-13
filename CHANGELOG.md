# Changelog

All notable changes to EZQRContact are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [SemVer](https://semver.org/) as `pubspec.yaml` `version`.

## [1.1.0] — 2026-10

### Added

- ENCRE visual system (tokens, Outfit / Fraunces, copper + paper)
- Drift schema for vCards and simple QRs (`qr_app.db`)
- Collection: search, import all device contacts, export a flat zip
- Long-press (> 2 s) multi-select to delete or export checked cards
- Reciprocal swap after a scan
- Onboarding + interactive Home coach tour (3 steps, skippable)
- Replay the coach tour from Settings → Read guide
- Gallery import with ML Kit then ZXing (crop, unwarp, EXIF)
- Offline-safe vCard QR: skip PHOTO when there is no network
- French and English UI, light and dark mode
- User guide under `docs/help/`
- ENCRE QR mark as app icon and splash (Cuivre → Encre on Papier)

### Removed

- Events (create / activate / filter / banner). Cards are a flat list.
- PDF export (1 per page or 2×2). Zip export stays.

### Changed

- First-run markdown dialog replaced by the Home coach tour
- vCard 3.0 is the default QR payload; 4.0 is a Settings toggle
- Photos in a QR are a hosted URL, not inline base64
- Lint: `very_good_analysis` plus no-ternary / pure display-return tests

### Security

- Creating a card always writes the in-app QR. The OS address book is
  updated only after Contacts permission is granted.

[1.1.0]: https://github.com/jojo8356/EZQRContact/releases/tag/v1.1.0
