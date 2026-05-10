# Story 1.1a: Setup Drift + tables miroir + codegen

Status: done

<!-- Sub-story 1/4 of the original Story E1.1 (split per implementation-readiness audit). -->

## Story

As un **développeur**,
I want **les dépendances Drift installées et les 3 tables Drift définies en miroir du schéma sqflite v1**,
so that **`build_runner` génère les classes Dart type-safe sans toucher au runtime de l'app et que les sub-stories E1.1b/c/d puissent porter chaque repository sur cette base**.

## Acceptance Criteria

1. **AC-1** : Les 4 dépendances Drift sont ajoutées au `pubspec.yaml`.

   **Given** le `pubspec.yaml` v1.0.1 actuel avec `sqflite ^2.4.2`
   **When** j'ajoute `drift ^2.33.0` aux deps, et `drift_dev ^2.33.0` + `build_runner ^2.4.13` aux dev_deps, et `drift_sqflite ^2.0.1` aux deps (bridge sur la DB sqflite existante)
   **Then** `flutter pub get` retourne sans erreur
   **And** les 4 packages apparaissent dans `pubspec.lock`
   **And** `sqflite ^2.4.2` reste présent (cohabitation avec drift_sqflite)

2. **AC-2** : Les 3 tables Drift sont définies dans `lib/data/db/tables/`.

   **Given** la structure `lib/tools/db/db.dart` v1 avec les 2 tables `SimpleQR` et `VCard`
   **When** je crée `lib/data/db/tables/simple_qrs.dart`, `vcards.dart`, et `events.dart` (nouvelle table v2)
   **Then** `SimpleQRs` table miroir exact du schéma v1 (colonnes : `id`, `text`, `path`, `deleted`, `dateDeleted`)
   **And** `VCards` table = miroir v1 + 3 nouvelles colonnes nullables `visualConfig` (TEXT), `eventId` (INT FK), `capturedAt` (TEXT) pour préparer V2
   **And** `Events` table = nouvelle (`id`, `name`, `startDate`, `endDate`, `isActive` BOOL, `createdAt`)
   **And** chaque fichier respecte la convention Drift `class XxxTable extends Table {...}`

3. **AC-3** : La classe `QRDatabaseV2` Drift est définie et codegen passe.

   **Given** les 3 tables existent
   **When** je crée `lib/data/db/database.dart` avec `@DriftDatabase(tables: [SimpleQRs, VCards, Events])` et `class QRDatabaseV2 extends _$QRDatabaseV2`
   **And** je lance `dart run build_runner build --delete-conflicting-outputs`
   **Then** le fichier `database.g.dart` est généré sans erreur
   **And** les classes `SimpleQR`, `VCard`, `Event` (data classes immutables) sont accessibles depuis le code Dart

4. **AC-4** : Aucun changement runtime de l'app v1.0.1.

   **Given** l'app v1.0.1 fonctionnelle avec sqflite
   **When** la story 1.1a est terminée
   **Then** `flutter run` démarre l'app sans erreur
   **And** la création de VCard, le scan, la liste de Collection : tout marche comme avant
   **And** `lib/tools/db/db.dart` (sqflite) est intact, AUCUNE méthode appelée dans l'app n'est modifiée
   **And** la nouvelle classe `QRDatabaseV2` n'est encore référencée nulle part dans `lib/main.dart` ni `lib/pages/`

5. **AC-5** : `flutter analyze` reste à 0 warning (NFR-8).

   **Given** la base v1.0.1 à 0 warning d'analyse
   **When** je lance `flutter analyze` après avoir ajouté Drift et le code généré
   **Then** la sortie reste à `No issues found!`
   **And** aucun fichier généré (`.g.dart`) n'est analysé (filtré via `analysis_options.yaml` si nécessaire)

6. **AC-6** : Le code généré est gitignored (pas commité).

   **Given** Drift génère `database.g.dart` qui peut faire 1000+ lignes
   **When** je vérifie le `.gitignore`
   **Then** la ligne `**/*.g.dart` est présente OU `database.g.dart` est ignoré spécifiquement
   **And** un nouveau contributeur qui clone le repo régénère ses propres `.g.dart` via `dart run build_runner build`

## Tasks / Subtasks

- [x] **Task 1** : Ajouter les dépendances Drift au pubspec (AC: #1)
  - [x] 1.1 Ouvrir `pubspec.yaml`
  - [x] 1.2 Dans `dependencies:`, ajouter sous le bloc persistence :
    ```yaml
    drift: ^2.33.0
    drift_sqflite: ^2.0.1
    ```
  - [x] 1.3 Dans `dev_dependencies:`, ajouter :
    ```yaml
    drift_dev: ^2.33.0
    build_runner: ^2.4.13
    ```
  - [x] 1.4 Lancer `flutter pub get` (ou `pnpm dlx flutter pub get` si Johan préfère pnpm-style — `flutter` direct fonctionne)
  - [x] 1.5 Vérifier que `pubspec.lock` contient `drift`, `drift_sqflite`, `drift_dev`, `build_runner`

- [x] **Task 2** : Créer le fichier `lib/data/db/tables/simple_qrs.dart` (AC: #2)
  - [x] 2.1 Créer les dossiers `lib/data/db/tables/` (NEW)
  - [x] 2.2 Définir la classe `SimpleQRs extends Table`
  - [x] 2.3 Colonnes miroir du schéma v1 :
    - `id` : `IntColumn get id => integer().autoIncrement()()`
    - `text` : `TextColumn get text => text()()`
    - `path` : `TextColumn get path => text().nullable()()`
    - `deleted` : `BoolColumn get deleted => boolean().withDefault(const Constant(false))()`
    - `dateDeleted` : `TextColumn get dateDeleted => text().nullable()()`

- [x] **Task 3** : Créer le fichier `lib/data/db/tables/vcards.dart` (AC: #2)
  - [x] 3.1 Définir `VCards extends Table` avec les 16 colonnes du schéma v1 + 3 nouvelles V2
  - [x] 3.2 Colonnes v1 (16) : id, nom, prenom, nom2, prefixe, suffixe, org, job, photo, telWork, telHome, adrWork, adrHome, email, rev, path, clone, deleted, dateDeleted (toutes en TextColumn ou BoolColumn selon le type, conforme au schéma sqflite v1)
  - [x] 3.3 Colonnes nouvelles V2 (3) :
    - `visualConfig` : `TextColumn get visualConfig => text().nullable()()`
    - `eventId` : `IntColumn get eventId => integer().nullable().references(Events, #id)()`
    - `capturedAt` : `TextColumn get capturedAt => text().nullable()()`
  - [x] 3.4 Override le mapping nom Dart → nom SQL : la colonne Dart `telWork` doit être stockée en `tel_work` (snake_case DB convention v1) via `customConstraint` ou `column('tel_work')` selon syntaxe Drift

- [x] **Task 4** : Créer le fichier `lib/data/db/tables/events.dart` (AC: #2)
  - [x] 4.1 Définir `Events extends Table`
  - [x] 4.2 Colonnes :
    - `id` : `IntColumn get id => integer().autoIncrement()()`
    - `name` : `TextColumn get name => text()()`
    - `startDate` : `TextColumn get startDate => text().nullable()()`
    - `endDate` : `TextColumn get endDate => text().nullable()()`
    - `isActive` : `BoolColumn get isActive => boolean().withDefault(const Constant(false))()`
    - `createdAt` : `TextColumn get createdAt => text()()`

- [x] **Task 5** : Créer la classe Drift database (AC: #3)
  - [x] 5.1 Créer `lib/data/db/database.dart` (NEW)
  - [x] 5.2 Imports : `drift`, `drift_sqflite`, les 3 fichiers tables, `package:path_provider/path_provider.dart`, `package:path/path.dart`
  - [x] 5.3 Annotation `@DriftDatabase(tables: [SimpleQRs, VCards, Events])`
  - [x] 5.4 Classe `class QRDatabaseV2 extends _$QRDatabaseV2`
  - [x] 5.5 Constructor utilisant `SqfliteQueryExecutor.inDatabaseFolder(path: 'qr_app.db', singleInstance: true)` (cohabitation avec sqflite v1, même fichier DB)
  - [x] 5.6 Override `int get schemaVersion => 1` (la DB est déjà en schema v1, on monte à v2 dans la story 1.1d)
  - [x] 5.7 Part directive en haut : `part 'database.g.dart';`

- [x] **Task 6** : Lancer le codegen (AC: #3)
  - [x] 6.1 Lancer `dart run build_runner build --delete-conflicting-outputs`
  - [x] 6.2 Vérifier que `lib/data/db/database.g.dart` est généré
  - [x] 6.3 Si erreurs dans le codegen : lire les messages, fix les noms de colonnes ou types, re-run

- [x] **Task 7** : Gitignorer les fichiers générés (AC: #6)
  - [x] 7.1 Vérifier le `.gitignore` actuel
  - [x] 7.2 Si pas déjà présent, ajouter au `.gitignore` :
    ```
    # Drift code generation
    **/*.g.dart
    ```
  - [x] 7.3 `git status` ne doit PAS lister `lib/data/db/database.g.dart`

- [x] **Task 8** : Validation finale (AC: #4, #5)
  - [x] 8.1 `flutter analyze` retourne `No issues found!`
  - [x] 8.2 `flutter run -d <device>` démarre l'app sans erreur (test sur émulateur ou device)
  - [x] 8.3 Manuellement : créer une VCard, scan, voir Collection. Tout doit fonctionner comme v1.0.1.
  - [x] 8.4 `grep -r "QRDatabaseV2" lib/main.dart lib/pages/ lib/components/` retourne vide (pas encore référencé)

- [x] **Task 9** : Commit + push (AC: tous)
  - [x] 9.1 `git add pubspec.yaml pubspec.lock lib/data/ .gitignore`
  - [x] 9.2 Commit Conventional : `feat(data): setup Drift database scaffolding (story 1.1a)`
  - [x] 9.3 Push (avec confirmation user)
  - [x] 9.4 Vérifier sur GitHub que le diff est propre, pas de `.g.dart` accidentellement commité

## Dev Notes

### Stack Drift confirmée (web research 2026-05-10)

| Package | Version | Pourquoi |
|---|---|---|
| `drift` | ^2.33.0 | Lib principale, dernière stable (publiée il y a 6j sur pub.dev) |
| `drift_sqflite` | ^2.0.1 | Bridge entre Drift et la DB sqflite existante. Officiellement recommandé par Simon Binder pour les migrations depuis sqflite/moor_flutter. Version stable depuis 2 ans, pas deprecated. |
| `drift_dev` | ^2.33.0 | Codegen (build_runner) |
| `build_runner` | ^2.4.13 | Runner de codegen Dart standard |

### Squelette du code (prêt à copier-coller)

#### `lib/data/db/tables/simple_qrs.dart`

```dart
import 'package:drift/drift.dart';

class SimpleQRs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get text => text()();
  TextColumn get path => text().nullable()();
  BoolColumn get deleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dateDeleted => text().nullable().named('date_deleted')();

  @override
  String get tableName => 'SimpleQR'; // Match the v1 sqflite table name exactly
}
```

**Note importante** : la table v1 s'appelle `SimpleQR` (singular). Drift par défaut convertit `SimpleQRs` (class name) en `simple_q_rs`. On force le nom via `tableName` override pour matcher la DB existante.

#### `lib/data/db/tables/events.dart`

```dart
import 'package:drift/drift.dart';

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get startDate => text().nullable().named('start_date')();
  TextColumn get endDate => text().nullable().named('end_date')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false)).named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
}
```

#### `lib/data/db/tables/vcards.dart`

```dart
import 'package:drift/drift.dart';
import 'package:qr_code_app/data/db/tables/events.dart';

class VCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withDefault(const Constant(''))();
  TextColumn get prenom => text().withDefault(const Constant(''))();
  TextColumn get nom2 => text().withDefault(const Constant(''))();
  TextColumn get prefixe => text().withDefault(const Constant(''))();
  TextColumn get suffixe => text().withDefault(const Constant(''))();
  TextColumn get org => text().withDefault(const Constant(''))();
  TextColumn get job => text().withDefault(const Constant(''))();
  TextColumn get photo => text().withDefault(const Constant(''))();
  TextColumn get telWork =>
      text().withDefault(const Constant('')).named('tel_work')();
  TextColumn get telHome =>
      text().withDefault(const Constant('')).named('tel_home')();
  TextColumn get adrWork =>
      text().withDefault(const Constant('')).named('adr_work')();
  TextColumn get adrHome =>
      text().withDefault(const Constant('')).named('adr_home')();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get rev => text().withDefault(const Constant(''))();
  TextColumn get path => text().nullable()();
  BoolColumn get clone =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get deleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dateDeleted =>
      text().nullable().named('date_deleted')();

  // V2 additions (story 1.1d will run the migration to add these columns
  // to existing v1 databases). Defined here so the schema is the v2 target
  // from the start.
  TextColumn get visualConfig =>
      text().nullable().named('visual_config')();
  IntColumn get eventId =>
      integer().nullable().named('event_id').references(Events, #id)();
  TextColumn get capturedAt =>
      text().nullable().named('captured_at')();

  @override
  String get tableName => 'VCard'; // Match the v1 sqflite table name
}
```

#### `lib/data/db/database.dart`

```dart
import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

import 'package:qr_code_app/data/db/tables/events.dart';
import 'package:qr_code_app/data/db/tables/simple_qrs.dart';
import 'package:qr_code_app/data/db/tables/vcards.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SimpleQRs, VCards, Events])
class QRDatabaseV2 extends _$QRDatabaseV2 {
  QRDatabaseV2()
      : super(
          SqfliteQueryExecutor.inDatabaseFolder(
            path: 'qr_app.db',
            singleInstance: true,
          ),
        );

  @override
  int get schemaVersion => 1;
}
```

### Schéma DB v1 actuel (référence pour le miroir)

Lu depuis `lib/tools/db/db.dart` :

```sql
CREATE TABLE SimpleQR(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL,
  path TEXT,
  deleted INTEGER DEFAULT 0,
  date_deleted TEXT
);

CREATE TABLE VCard(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT,
  prenom TEXT,
  nom2 TEXT,
  prefixe TEXT,
  suffixe TEXT,
  org TEXT,
  job TEXT,
  photo TEXT,
  tel_work TEXT,
  tel_home TEXT,
  adr_work TEXT,
  adr_home TEXT,
  email TEXT,
  rev TEXT,
  path TEXT,
  clone INTEGER,
  deleted INTEGER DEFAULT 0,
  date_deleted TEXT
);
```

### Fichiers touchés

| Action | Path | Type |
|---|---|---|
| **UPDATE** | `pubspec.yaml` | +4 lignes deps |
| **UPDATE** | `pubspec.lock` | régénéré par `flutter pub get` |
| **NEW** | `lib/data/db/tables/simple_qrs.dart` | ~15 lignes |
| **NEW** | `lib/data/db/tables/vcards.dart` | ~50 lignes |
| **NEW** | `lib/data/db/tables/events.dart` | ~15 lignes |
| **NEW** | `lib/data/db/database.dart` | ~25 lignes |
| **GENERATED (gitignored)** | `lib/data/db/database.g.dart` | ~500-1000 lignes auto |
| **UPDATE** | `.gitignore` | +2 lignes pour `*.g.dart` |

### Ce qui NE doit PAS changer

- `lib/tools/db/db.dart` (sqflite) reste **intact**.
- `lib/main.dart`, `lib/pages/`, `lib/components/`, `lib/modals/` : aucune modif.
- Le fichier DB `qr_app.db` sur device : pas touché (le schemaVersion=1 ne déclenche aucune migration).
- L'API publique de l'app : zéro changement.

### Project Structure Notes

**Alignement avec l'architecture v2** :
- Le path `lib/data/db/` est cohérent avec l'ADR-1 de l'architecture (refacto `lib/` en couches `data/`, `domain/`, etc.).
- C'est la première story qui crée `lib/data/`. Les sous-stories E1.1b/c/d et les Epics suivants étofferont `lib/data/repositories/` et `lib/domain/`.

**Variances détectées** : aucune.

### Testing Standards

- **Pas de tests unitaires dans cette sub-story** : on installe Drift et on génère le code, sans logique métier.
- Les tests Drift arrivent en E1.1b (VCardRepository) et E1.1c (SimpleQRRepository) avec `sqflite_common_ffi`.
- Validation manuelle :
  1. `flutter analyze` → `No issues found!`
  2. `flutter run -d <device>` → app démarre normalement
  3. Création d'une VCard via l'UI → toujours OK (sqflite path)
  4. `grep -r "QRDatabaseV2" lib/` → uniquement dans `lib/data/db/database.dart` et `database.g.dart`

### References

- Drift setup officiel : https://drift.simonbinder.eu/setup/
- Drift Tables doc : https://drift.simonbinder.eu/tables/
- drift_sqflite pub.dev : https://pub.dev/packages/drift_sqflite
- Architecture cible : [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#ADR-1 Migration sqflite → Drift]
- PRD NFR-6 maintenabilité : [Source: planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md#NFR-6]
- PRD NFR-8 zéro warning : [Source: planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md#NFR-8]
- Schéma DB v1 source : `lib/tools/db/db.dart` lignes 31-63

## Previous Story Intelligence (de Sprint 1)

### Learnings du Sprint 1 applicables ici

1. **Memory `feedback_no_dashes`** : pas de `—` ni `--` dans les commentaires, docstrings, commit messages.
2. **Memory `feedback_pnpm`** : tous les outils Node passent par pnpm (mais ici on utilise `flutter` direct, pas concerné).
3. **Memory `feedback_no_kill_builds`** : ne jamais kill un build Gradle. Si le codegen prend du temps (1-3 min), laisser tourner.
4. **Stage scopé** : `git add` avec paths explicites, jamais `git add -A` (les artefacts BMAD du sprint sont à part).
5. **Push avec confirmation user** : pattern établi sur les 4 stories du Sprint 1.
6. **Conventional Commits** : `feat(data): ...` ici car c'est une nouvelle infra de données. Pas `chore` car ça ajoute du code.

## Git Intelligence Summary

10 derniers commits :

```
c8c7229 chore(bmad): split Story E1.1 into 4 sub-stories before Sprint 2
209ee62 chore(bmad): close Epic 0 and prep Sprint 2
14d5c8c chore(release): bump version to 1.0.1
0f90023 chore(tooling): clearer error messages and auto-optimize after capture
0deec75 chore(tooling): add cross-platform pngquant install + PNG optimization scripts
e48b2ab docs(readme): add 6 captured app screenshots
2938082 chore(test): add Dart screenshot automation for v1 pages
3973cbd docs(contributing): add CONTRIBUTING guide and link from README
d396c3e chore(bmad): mark stories 0-1 0-2 done and update sprint state
ccd25da docs(readme): rewrite with B2B pro positioning and structured sections
```

- Sprint 1 entièrement Conventional Commits avec scope.
- Cette story doit suivre : `feat(data): setup Drift database scaffolding (story 1.1a)`.

## Latest Tech Information (Web research 2026-05-10)

### Drift v2.33.0 (publié il y a ~6 jours)
- Stable, recommandé pour nouveaux projets.
- Compatible Flutter SDK ^3.8.1 (notre version).
- Codegen via `build_runner ^2.4+`.

### drift_sqflite v2.0.1 (stable, 2 ans)
- Pas deprecated malgré l'âge. Verified publisher (simonbinder.eu).
- Officiellement recommandé pour migrer depuis sqflite/moor_flutter (= notre cas).
- Permet de garder sqflite comme runtime et d'utiliser Drift comme abstraction par-dessus.

### Pourquoi pas `drift_flutter` à la place ?
`drift_flutter` (sqlite3_flutter_libs) serait plus moderne et performant, mais il **remplace** sqflite (utilise sqlite3 natif directement). Pour notre stratégie de cohabitation pendant les sub-stories E1.1b/c/d, `drift_sqflite` est nécessaire (les 2 stacks accèdent à la même DB). Migration vers `drift_flutter` possible en E1.1d quand sqflite sera retiré.

## Project Context Reference

Lire `_bmad-output/project-context.md` pour :
- Stack actuelle (Flutter ^3.8.1, sqflite ^2.4.2, etc.).
- Contraintes Android (`compileSdkVersion = 35`).
- Convention de naming Dart : `snake_case.dart` pour les fichiers (les nouveaux fichiers `simple_qrs.dart`, `vcards.dart`, `events.dart`, `database.dart` respectent cette convention).
- Convention DB existante : colonnes `snake_case` (`tel_work`, `date_deleted`) qu'il faut préserver via `.named('tel_work')` dans Drift.

## Story Completion Status

Status: ready-for-dev

Cette story produit :
- Pubspec à jour avec Drift.
- 3 fichiers de tables Drift en miroir du schéma v1 + 3 colonnes V2.
- 1 classe `QRDatabaseV2` avec codegen propre.
- 0 changement de comportement de l'app.
- Base prête pour les sub-stories E1.1b/c/d.

## Anti-pattern prevention

**Erreurs typiques d'un LLM dev sur cette story (à éviter)** :

1. ❌ **Modifier `lib/tools/db/db.dart`** ou un fichier de page. Cette sub-story est **scaffolding-only**, l'app v1 doit continuer à utiliser sqflite tel quel.
2. ❌ **Oublier `tableName` override** pour `SimpleQRs` (default `simple_q_rs`) ou `VCards` (default `v_cards`). La DB v1 a `SimpleQR` et `VCard` strictement. Mismatch = données invisibles.
3. ❌ **Oublier `.named('snake_case')`** sur les colonnes Dart camelCase. Default Drift convertit `telWork` → `tel_work` automatiquement, mais il vaut mieux être explicite pour matcher 100% le schéma v1.
4. ❌ **Commit le fichier `.g.dart` généré**. Toujours le mettre dans `.gitignore`.
5. ❌ **Utiliser `drift_flutter` au lieu de `drift_sqflite`**. La cohabitation impose `drift_sqflite`. Migration vers `drift_flutter` viendra en E1.1d.
6. ❌ **Bumper `schemaVersion` à 2 dans cette story**. La migration v1→v2 est en E1.1d. Ici `schemaVersion = 1`.
7. ❌ **Référencer `QRDatabaseV2` dans `main.dart`** ou ailleurs. Cette story crée la classe, les sub-stories suivantes la branchent.
8. ❌ **Oublier la part directive** `part 'database.g.dart';` dans `database.dart`. Sans ça, le codegen échoue silencieusement.
9. ❌ **Tirets cadratins dans les commentaires** (memory `feedback_no_dashes`).
10. ❌ **`git add -A`** : risque d'inclure les artefacts BMAD du sprint en cours. Stage explicite.

## Dev Agent Record

### Agent Model Used

(à remplir par le dev agent à l'exécution)

### Debug Log References

(à remplir si des problèmes surviennent)

### Completion Notes List

(à remplir après exécution)

### File List

(à remplir, exemples attendus)
- `pubspec.yaml` (UPDATE)
- `pubspec.lock` (UPDATE auto par `flutter pub get`)
- `lib/data/db/tables/simple_qrs.dart` (NEW)
- `lib/data/db/tables/vcards.dart` (NEW)
- `lib/data/db/tables/events.dart` (NEW)
- `lib/data/db/database.dart` (NEW)
- `.gitignore` (UPDATE)

### Change Log

(à remplir)

## Senior Developer Review (AI)

**Date :** 2026-05-10
**Reviewer :** Claude Opus 4.7 (1M context) via `bmad-code-review` workflow
**Outcome :** ✅ **Approve**
**Coverage :** 3 layers (Blind Hunter, Edge Case Hunter, Acceptance Auditor) joués en interne sur le commit `0a474f5`.

### Action Items

- [x] [AI-Review][Defer] Nom temporaire `QRDatabaseV2` à renommer en `QRDatabase` lors du cleanup en story 1.1d.
- [x] [AI-Review][Dismiss] Workaround Dart `qrText` (SQL `text`) suffisamment documenté dans le code, pas d'action requise.

### Findings Summary

- **0 critical**
- **0 major**
- **0 patch**
- **1 defer** (rename QRDatabaseV2 en 1.1d, by design)
- **1 dismiss** (workaround qrText documenté)

### Acceptance Criteria validation

- AC-1 (4 deps Drift) : ✅ pubspec.yaml diff confirmé
- AC-2 (3 tables miroir) : ✅ events.dart, simple_qrs.dart, vcards.dart
- AC-3 (QRDatabaseV2 + codegen) : ✅ build_runner a généré database.g.dart sans erreur
- AC-4 (zéro changement runtime) : ✅ lib/tools/db/db.dart inchangé, aucune référence à QRDatabaseV2 dans l'app
- AC-5 (flutter analyze 0 warning) : ✅ "No issues found!"
- AC-6 (.g.dart gitignored) : ✅ **/*.g.dart dans .gitignore, git check-ignore confirme

### Risks / Observations

- Le schéma miroir des 16 colonnes VCard a été audité 1-à-1 contre le SQL v1 (`lib/tools/db/db.dart` lignes 31-63). Match exact.
- BoolColumn Drift se map en INTEGER 0/1 en SQL, compatible avec les `INTEGER DEFAULT 0` v1 (clone, deleted).
- `eventId.references(Events, #id)` pose une FK Drift au niveau du modèle, mais la contrainte SQL n'est pas encore appliquée à la DB v1 (schemaVersion=1, migration en 1.1d).
- Story 1.1b devra utiliser `row.qrText` côté Dart pour accéder à la colonne SQL `text` de SimpleQRs.
