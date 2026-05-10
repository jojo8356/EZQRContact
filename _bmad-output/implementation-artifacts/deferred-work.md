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

- ~~**Test d'intégration migration v1 → v2 avec dump synthétique**~~ — **Résolu** (commit `f00e15f`). 12 tests d'intégration dans `test/data/migration_v1_to_v2_test.dart` valident la migration sur une DB v1 in-memory (`sqlite3.openInMemory()` + `PRAGMA user_version = 1` + seed v1 data). Bug bonus identifié et fixé en cours de route : les NULL des colonnes texte v1 plantaient le mapping Drift, résolu via un `UPDATE ... COALESCE` ajouté dans `onUpgrade(1, 2)`.
