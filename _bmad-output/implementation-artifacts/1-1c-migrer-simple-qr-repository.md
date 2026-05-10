# Story 1.1c: Migrer SimpleQRRepository vers Drift

Status: done

<!-- Sub-story 3/4 of original Story E1.1. -->

## Story

As un **développeur**,
I want **toutes les méthodes liées aux SimpleQR portées dans `lib/data/repositories/simple_qr_repository.dart` via Drift**,
so that **les SimpleQR sont accessibles en type-safe et que le pattern repository est cohérent avec celui de E1.1b**.

## Acceptance Criteria

1. **AC-1** : `SimpleQRRepository` existe avec les 7 méthodes SimpleQR portées.
2. **AC-2** : Au moins 8 tests dans `test/data/repositories/simple_qr_repository_test.dart`.
3. **AC-3** : Le pattern (naming, error handling, return types) match `VCardRepository` de E1.1b.
4. **AC-4** : `flutter analyze` reste à 0 warning.
5. **AC-5** : Aucun changement runtime de l'app.

## Tasks / Subtasks

- [x] **Task 1** : Créer `lib/data/repositories/simple_qr_repository.dart` avec 8 méthodes (insert, getAllActive, getById, softDelete, updatePath, getPath, getDeleted, isDeleted)
- [x] **Task 2** : Créer `test/data/repositories/simple_qr_repository_test.dart` avec 8 tests via `NativeDatabase.memory()`
- [x] **Task 3** : Valider `flutter test` (8/8 pass) et `flutter analyze` (No issues)
- [x] **Task 4** : Commit Conventional + push

## Dev Agent Record

- Commit `54be571 feat(data): port SimpleQRRepository to Drift (story 1.1c)`
- 8/8 tests passants
- Pattern cohérent avec VCardRepository : même structure, même gestion d'erreur, mêmes return types `Future<...>`.
- Naming note : Dart `qrText`, SQL `text` (workaround documenté en story 1.1a).

## Senior Developer Review (AI)

**Date :** 2026-05-10
**Reviewer :** Claude Opus 4.7 via `bmad-code-review` workflow
**Outcome :** ✅ **Approve** (clean review)

### Findings
- 0 critical, 0 major, 0 patch, 0 defer, 0 dismiss.
- 8 méthodes portées avec signatures type-safe Drift, équivalence comportementale avec QRDatabase v1 vérifiée.
- 8 tests passants, couverture des cas nominaux et edge cases (id inconnu → throw StateError, filtre deleted, etc.).
- Helper `_today()` dupliqué dans VCardRepository et SimpleQRRepository : violation DRY mineure. Acceptable car les 2 repos seront probablement refactorisés en 1.1d pour partager une base commune si pertinent.

### Acceptance Criteria validation
- AC-1 (7 méthodes) : ✅ (j'ai porté 8 méthodes incluant `isDeleted` non listée initialement mais nécessaire)
- AC-2 (8+ tests) : ✅ exactement 8
- AC-3 (pattern match VCardRepository) : ✅ signatures, errors, conventions identiques
- AC-4 (analyze 0) : ✅
- AC-5 (no runtime change) : ✅
