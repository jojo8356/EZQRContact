# Story 1.1b: Migrer VCardRepository vers Drift

Status: done

<!-- Sub-story 2/4 of original Story E1.1. Depends on 1.1a (Drift setup). -->

## Story

As un **développeur**,
I want **toutes les méthodes liées aux VCards de `lib/tools/db/db.dart` portées dans un nouveau `lib/data/repositories/vcard_repository.dart` qui utilise Drift**,
so that **les VCards sont accédées en mode type-safe sans toucher SimpleQR ni la migration v1→v2, et que je peux brancher l'app dessus en 1.1d**.

## Acceptance Criteria

1. **AC-1** : `VCardRepository` existe avec les 13 méthodes VCard portées.

   **Given** `QRDatabase` v1 sqflite avec `insertVCard`, `getAllVCards`, `getVCardById`, `verifContact`, `modifContact`, `cloneVCard`, `deleteVCard`, `isClone`, `updateVCardPath`, `getPathFromVCard`, `getDeletedVCards`, `isDeletedVCard`, `getLastVCardId`
   **When** je crée `lib/data/repositories/vcard_repository.dart` avec une classe `VCardRepository` prenant un `QRDatabaseV2` en argument
   **Then** chaque méthode est portée avec une signature type-safe Drift (companions, data classes)
   **And** chaque méthode a un comportement équivalent à la version sqflite (filtre `deleted=false` quand pertinent, etc.)

2. **AC-2** : Au moins 10 tests unitaires dans `test/data/repositories/vcard_repository_test.dart`.

   **Given** `sqlite3` + `mocktail` ajoutés en dev_dependencies
   **When** je crée le fichier de test avec `NativeDatabase.memory()` pour une DB in-memory
   **Then** au moins 10 tests couvrent les méthodes principales (insert, getAll, getById, verifContact, modif, clone, delete, isClone, getDeleted, getLastId)
   **And** `flutter test test/data/repositories/vcard_repository_test.dart` retourne tous les tests passed

3. **AC-3** : `QRDatabaseV2` a un constructeur de test.

   **Given** le constructeur unique de la story 1.1a (SqfliteQueryExecutor)
   **When** j'ajoute un constructeur named `QRDatabaseV2.forTesting(QueryExecutor e)` qui prend un executor en argument
   **Then** les tests peuvent injecter `NativeDatabase.memory()` ou tout autre executor pour isoler la DB

4. **AC-4** : `flutter analyze` reste à 0 warning.

   **Given** la base actuelle à "No issues found"
   **When** j'ajoute le repository, les tests, et les deps
   **Then** `flutter analyze` retourne toujours `No issues found!`

5. **AC-5** : Aucun changement runtime de l'app v1.0.1.

   **Given** l'app v1 fonctionnelle
   **When** la story 1.1b est terminée
   **Then** `lib/tools/db/db.dart` (sqflite) est intact
   **And** aucune référence à `VCardRepository` dans `lib/main.dart`, `lib/pages/`, `lib/components/`, `lib/modals/`
   **And** l'app continue à fonctionner via l'ancien `QRDatabase` sqflite

## Tasks / Subtasks

- [x] **Task 1** : Améliorer `lib/data/db/database.dart` pour le testing (AC: #3)
  - [x] 1.1 Ajouter un constructeur named `QRDatabaseV2.forTesting(QueryExecutor e) : super(e)`
  - [x] 1.2 Le constructeur prod existant reste inchangé

- [x] **Task 2** : Ajouter les dépendances de test (AC: #2)
  - [x] 2.1 Dans `dev_dependencies` du `pubspec.yaml`, ajouter :
    ```yaml
    sqlite3: ^2.4.0
    mocktail: ^1.0.4
    ```
  - [x] 2.2 `flutter pub get`

- [x] **Task 3** : Créer `lib/data/repositories/vcard_repository.dart` (AC: #1)
  - [x] 3.1 Créer le dossier `lib/data/repositories/`
  - [x] 3.2 Classe `VCardRepository` avec un champ `final QRDatabaseV2 _db;` et un constructor
  - [x] 3.3 Porter les 13 méthodes :
    - `Future<int> insert(VCardsCompanion companion)` → `_db.into(_db.vCards).insert(companion)`
    - `Future<List<VCardRow>> getAllActive()` → filtre `deleted.equals(false)`, orderBy id desc
    - `Future<VCardRow?> getById(int id)` → `getSingleOrNull()`
    - `Future<VCardRow?> findByName({String? nom, String? prenom})` → équivalent `verifContact`
    - `Future<void> mergeIfExists(VCardsCompanion newData)` → équivalent `modifContact` (merge dans l'existant)
    - `Future<int> clone(int id)` → équivalent `cloneVCard`, set `clone=true` sur la copie
    - `Future<void> softDelete(int id)` → set `deleted=true` + `dateDeleted=now()`
    - `Future<bool> isClone(int id)`
    - `Future<int> updatePath(int id, String path)`
    - `Future<String?> getPath(int id)`
    - `Future<List<VCardRow>> getDeleted()` → filtre `deleted=true`, orderBy dateDeleted desc
    - `Future<bool> isDeleted(int id)`
    - `Future<int?> getLastId()`

- [x] **Task 4** : Créer `test/data/repositories/vcard_repository_test.dart` (AC: #2)
  - [x] 4.1 Setup `setUp()` qui crée un `QRDatabaseV2.forTesting(NativeDatabase.memory())` et un `VCardRepository(db)`
  - [x] 4.2 Setup `tearDown()` qui ferme la DB
  - [x] 4.3 Tests à écrire (1 par méthode minimum, certaines avec edge cases) :
    - `test('insert returns generated id')`
    - `test('getAllActive returns only non-deleted vcards, newest first')`
    - `test('getById returns the matching vcard or null')`
    - `test('findByName returns vcard with matching nom and prenom')`
    - `test('findByName returns null when name does not match')`
    - `test('mergeIfExists keeps existing non-empty fields and fills empty ones')`
    - `test('clone creates a new vcard with clone=true')`
    - `test('softDelete sets deleted=true and dateDeleted')`
    - `test('isClone returns true for cloned vcard, false for original')`
    - `test('getDeleted returns only deleted vcards')`
    - `test('getLastId returns the highest id')`
  - [x] 4.4 Lancer `flutter test test/data/repositories/vcard_repository_test.dart` jusqu'à 100% pass

- [x] **Task 5** : Validation finale (AC: #4, #5)
  - [x] 5.1 `flutter analyze` retourne `No issues found!`
  - [x] 5.2 `grep -r "VCardRepository" lib/main.dart lib/pages/ lib/components/ lib/modals/` retourne vide
  - [x] 5.3 `grep -c "// ignore:" lib/data/repositories/vcard_repository.dart` = 0 (NFR-8.5)

- [x] **Task 6** : Commit + push (AC: tous)
  - [x] 6.1 Stage : `pubspec.yaml pubspec.lock lib/data/ test/data/`
  - [x] 6.2 Commit Conventional : `feat(data): port VCardRepository to Drift (story 1.1b)`
  - [x] 6.3 Push (avec confirmation user)

## Dev Notes

### Versions

| Package | Version | Pourquoi |
|---|---|---|
| `sqlite3` | ^2.4.0 | Standalone SQLite binding pour tests Dart pur (NativeDatabase.memory) |
| `mocktail` | ^1.0.4 | Mocking (au cas où on doive mocker des deps tierces dans les tests futurs) |

### Pattern de repository

```dart
import 'package:drift/drift.dart';
import 'package:qr_code_app/data/db/database.dart';

class VCardRepository {
  final QRDatabaseV2 _db;
  VCardRepository(this._db);

  Future<int> insert(VCardsCompanion companion) =>
      _db.into(_db.vCards).insert(companion);

  Future<List<VCardRow>> getAllActive() =>
      (_db.select(_db.vCards)
            ..where((t) => t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
          .get();

  // ... etc
}
```

### Pattern de test

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/data/repositories/vcard_repository.dart';

void main() {
  late QRDatabaseV2 db;
  late VCardRepository repo;

  setUp(() {
    db = QRDatabaseV2.forTesting(NativeDatabase.memory());
    repo = VCardRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert returns generated id', () async {
    final id = await repo.insert(const VCardsCompanion(
      nom: Value('Dupont'),
      prenom: Value('Marie'),
    ));
    expect(id, greaterThan(0));
  });

  // ... etc
}
```

### Fichiers touchés

| Action | Path |
|---|---|
| **UPDATE** | `lib/data/db/database.dart` (ajout `forTesting` constructor) |
| **UPDATE** | `pubspec.yaml` (sqlite3, mocktail) |
| **UPDATE** | `pubspec.lock` |
| **NEW** | `lib/data/repositories/vcard_repository.dart` |
| **NEW** | `test/data/repositories/vcard_repository_test.dart` |

### Ce qui NE doit PAS changer

- `lib/tools/db/db.dart` (sqflite) reste intact.
- Aucun fichier `lib/main.dart`, `lib/pages/`, `lib/components/`, `lib/modals/`.
- Le runtime de l'app v1.0.1 doit être identique à avant.

## Story Completion Status

Status: ready-for-dev

## Dev Agent Record

(à remplir par dev_story)

## Dev Agent Record

- Commit `0660b77`
- 13/13 tests passants
- Codegen Drift réussi
- Décision en cours d'impl : `@DataClassName('VCardRow')` + `@DataClassName('SimpleQRRow')` pour éviter le clash avec `lib/tools/vcard.dart`

## Senior Developer Review (AI)

**Date :** 2026-05-10
**Reviewer :** Claude Opus 4.7 via `bmad-code-review` workflow
**Outcome :** ✅ **Approve** (clean review)

### Findings
- 0 critical, 0 major, 0 patch, 0 defer, 0 dismiss.
- 13 méthodes portées avec signatures type-safe Drift, comportement aligné avec QRDatabase v1.
- 13 tests passants en mémoire via NativeDatabase.memory().
- Cohabitation respectée : aucune référence à VCardRepository dans l'app.
- Workaround `hide isNull, isNotNull` sur l'import Drift bien commenté dans le fichier de test.
