# Deferred Work

Liste centralisée des findings reportés depuis les code reviews BMAD. À traiter
dans une story dédiée ou en cleanup global quand bandwidth.

---

## Deferred from: code review of story-0.1 (2026-05-06)

- ~~**README.md no trailing newline** `[README.md:8]`~~ — **Résolu en story 0.2** (commit `ccd25da`). Le README réécrit finit par `0a` (LF).

## Deferred from: code review of story-0.2 (2026-05-07)

- ~~**README.md links to CONTRIBUTING.md (file missing)** `[README.md:246]`~~ — **Résolu en story 0.3** (commit `3973cbd`). Le fichier `CONTRIBUTING.md` est maintenant publié et le lien depuis le README est fonctionnel.

## Deferred from: code review of story-1.1a (2026-05-10)

- **Rename `QRDatabaseV2` → `QRDatabase`** `[lib/data/db/database.dart:11]` — Nom temporaire pour éviter le clash avec la classe `QRDatabase` v1 sqflite (`lib/tools/db/db.dart`) pendant la cohabitation. Sera renommé lors du cleanup en story **1-1d-migration-v1-vers-v2-avec-backup** une fois que tous les repositories (1.1b, 1.1c) auront migré et que `lib/tools/db/db.dart` sera supprimé.
