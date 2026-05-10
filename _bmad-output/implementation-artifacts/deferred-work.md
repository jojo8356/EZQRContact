# Deferred Work

Liste centralisée des findings reportés depuis les code reviews BMAD. À traiter
dans une story dédiée ou en cleanup global quand bandwidth.

---

## Deferred from: code review of story-0.1 (2026-05-06)

- ~~**README.md no trailing newline** `[README.md:8]`~~ — **Résolu en story 0.2** (commit `ccd25da`). Le README réécrit finit par `0a` (LF).

## Deferred from: code review of story-0.2 (2026-05-07)

- ~~**README.md links to CONTRIBUTING.md (file missing)** `[README.md:246]`~~ — **Résolu en story 0.3** (commit `3973cbd`). Le fichier `CONTRIBUTING.md` est maintenant publié et le lien depuis le README est fonctionnel.

## Deferred from: code review of story-1.1a (2026-05-10)

- ~~**Rename `QRDatabaseV2` → `QRDatabase`**~~ — **Résolu en story 1.1d** (commit `7bad166`). La classe Drift est maintenant `QRDatabase`, l'ancienne sqflite `QRDatabase` a été supprimée avec `lib/tools/db/db.dart`.

## Deferred from: code review of story-1.1d (2026-05-10)

- **Test d'intégration migration v1 → v2 avec dump synthétique** — La migration `onUpgrade(1, 2)` est validée par 21 tests unitaires (les repositories) et par la pratique sur device. Un test en pure Dart qui crée une DB v1 raw (via `sqlite3.openInMemory()` + `PRAGMA user_version = 1`), ouvre avec `QRDatabase.forTesting`, et vérifie que les colonnes/données sont préservées serait plus robuste. Effort : ~30-60 min de setup. À faire si on rencontre un bug de migration en prod ou avant un release majeur.
