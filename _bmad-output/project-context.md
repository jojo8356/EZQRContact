---
project_name: EZQRContact
user_name: Johan
date: 2026-05-06
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'quality_rules', 'workflow_rules', 'anti_patterns']
existing_patterns_found: 8
status: complete
rule_count: 47
optimized_for_llm: true
---

# Contexte projet pour les agents IA

_Ce fichier contient les règles critiques et les patterns que les agents IA
doivent suivre lors de l'implémentation. Focus sur les détails non évidents
qu'un agent risque de manquer._

---

## Stack technique et versions

### Runtime / SDK
- **Flutter** SDK `^3.8.1`
- **Dart** (canal stable, hérité du SDK Flutter)
- **Plateformes cibles** : Android, iOS (Linux/macOS/Windows/Web scaffoldés mais pas testés)

### Dépendances de production (pubspec.yaml)
- **State management** : `provider ^6.1.5+1`
- **Persistance locale** : `sqflite ^2.4.2`, `shared_preferences ^2.5.3`, `path ^1.9.1`, `path_provider ^2.1.5`
- **QR scan** : `mobile_scanner ^6.0.2`, `flutter_qrcode_analysis ^1.0.2`, `ai_barcode_scanner ^6.0.1`
- **QR génération** : `qr_flutter ^4.0.0`
- **Contacts** : `flutter_contacts ^1.1.9+2`, `permission_handler ^12.0.1`
- **Fichiers / images** : `image ^4.5.4`, `file_saver ^0.3.1`, `file_picker ^10.3.2`, `image_picker ^1.2.0`
- **i18n / format** : `intl ^0.20.2`
- **UI** : `toastification ^3.0.3`, `font_awesome_flutter ^10.10.0`, `flutter_markdown ^0.7.7+1`
- **Réseau** : `http ^1.5.0`, `url_launcher ^6.3.2`
- **Utils** : `collection ^1.19.1`

### Dépendances de dev (état actuel)
- `flutter_lints ^5.0.0` (config par défaut, aucune règle perso dans `analysis_options.yaml`)
- `flutter_native_splash ^2.4.6`
- `flutter_launcher_icons ^0.14.4`

### Incohérence à connaître
- `pubspec.yaml` déclare `name: qr_code_app` mais le repo s'appelle **EZQRContact**.
  Tous les imports internes utilisent `package:qr_code_app/...`. Ne pas
  renommer le package sans refactor global.

### Contraintes de versioning (Android)
- `permission_handler ^12.0.1` impose `compileSdkVersion = 35` dans
  `android/app/build.gradle` (breaking de la v12.0.0). Vérifier ce fichier
  à chaque bump majeur de `permission_handler`.
- `flutter_contacts` gère ses permissions **en interne** via
  `FlutterContacts.permissions.request(PermissionType.readWrite)`. Il ne
  dépend pas de `permission_handler`.
- **Règle critique** : pour les contacts, choisir une seule API (soit
  `FlutterContacts.permissions`, soit `Permission.contacts` du
  `permission_handler`). Mélanger les deux crée des bugs de cache de
  statut où l'OS dit "granted" mais une lib retourne "denied".

---

## Architecture et organisation

### Arborescence `lib/`
```
lib/
├── main.dart              # Entry point + MaterialApp + routes
├── colors.dart            # Palette via enum ThemeModeType
├── pages/                 # Écrans top-level (8)
├── components/            # Widgets réutilisables (12)
├── modals/                # Modales / popups (6)
├── providers/             # Provider singletons (theme, darkmode, lang)
└── tools/                 # Helpers métier
    └── db/                # Accès SQLite (singleton QRDatabase)
```

### Routing
- Routes déclarées dans `MaterialApp.routes` (pas de `go_router` ni `auto_route`)
- Routes principales : `/options`, `/collection`, `/history`, `/settings`
- Route initiale : `/options`

### Patterns structurels notables
1. **Singleton manuel partout** : `QRDatabase`, `LangProvider`, `DarkModeProvider`. Pattern `static final _instance = _internal()` + factory.
2. **DB locale SQLite** via `sqflite`, fichier `qr_app.db`. 2 tables : `SimpleQR` et `VCard`. Schéma dans `lib/tools/db/db.dart`.
3. **Soft delete** dans la DB : colonnes `deleted INTEGER DEFAULT 0` et `date_deleted TEXT` plutôt que `DELETE FROM`. Toujours filtrer par `deleted = 0` dans les `SELECT`.
4. **VCard format 4.0** généré à la main (pas de lib externe). Voir `lib/tools/vcard.dart`.
5. **Theme via enum** : `ThemeModeType.whiteMode | blackMode` mappé vers une `Map<String, Color>`. Lookup : `appColorsEnum[mode]?['popup-text']`.
6. **i18n maison** : `LangProvider` charge des JSON depuis `assets/langs/`. Détection auto via `PlatformDispatcher.instance.locale.languageCode`. FR + EN supportés.
7. **Asset guides Markdown** : `assets/GUIDEME.fr.md`, `assets/GUIDEME.en.md` rendus via `flutter_markdown`.
8. **Notifier pattern** : `ValueNotifier<String>` pour la langue, `ChangeNotifier` pour le dark mode.

---

## Règles d'implémentation critiques

### Conventions de nommage
- **Fichiers Dart** : `snake_case.dart` (standard Dart) avec exception notable : `btn.animated.dart` (point dans le nom). À ne pas généraliser, mais respecter si on touche ce fichier.
- **Classes / widgets** : `PascalCase`
- **Variables / méthodes** : `camelCase`
- **DB** : colonnes en `snake_case` (`tel_work`, `adr_home`, `date_deleted`) mais propriétés Dart en `camelCase` (`telWork`, `adrHome`). La conversion se fait dans `VCard.fromMap` / `toMap`.

### Règles Dart spécifiques
- **Imports** : toujours via `package:qr_code_app/...`, jamais de chemins relatifs profonds. Cohérent dans tout le code.
- **Async** : `async/await` partout, pas de `.then()` chains. `Future<T>` typé explicitement sur les méthodes publiques (vu dans `db.dart`).
- **Null safety** : sound null safety (Dart 3.x). Pattern `Map<String, dynamic>?` avec fallback `?? ''` ou `?? defaultValue` plutôt que `!` (vu dans `VCard.fromMap`).
- **Logs** : toujours garder `print()` dans `if (kDebugMode) { ... }` (import `package:flutter/foundation.dart`). Aucun `print` non gardé en prod.

### Sécurité VCard
- **Toujours** appeler `VCard.clean()` avant d'écrire dans le format vCard 4.0. La fonction strip les `;` (sinon corruption du format) et les `;;` doublons.
- Le champ `PHOTO` accepte uniquement `data:image/...` (base64) ou une URL valide via `isImageUrl()`. Tout le reste est rejeté.

### Persistance
- **Singleton DB obligatoire** : utiliser `QRDatabase()` (factory), jamais instancier directement.
- **Path des QR codes** : générés via `getApplicationDocumentsDirectory()` puis `${dir.path}/$id.png` (ou `.jpg` pour les clones VCard, à vérifier ce mismatch).
- **Schéma version 1** dans `_initDB`. Ajouter une migration si on modifie le schéma (la DB locale des users est en v1).

### State management
- Pattern Provider mais **utilisé en singleton statique**, pas via `MultiProvider` au top-level. Conséquence : pas besoin de `Provider.of(context)` partout, juste `LangProvider.get('key')` ou `DarkModeProvider().isDarkMode`.
- Pour réagir aux changements : `ValueListenableBuilder` (lang) ou `AnimatedBuilder` / `ListenableBuilder` (dark mode).
- **Règle** : ne pas introduire `MultiProvider` ni `Provider.of(context)` pour préserver la cohérence du paradigme singleton-statique.

### Routing
- `MaterialApp.routes` déclaratif (pas de `go_router` ni `auto_route`).
- 4 routes nommées : `/options`, `/collection`, `/history`, `/settings`. Route initiale `/options`.
- Navigation via `Navigator.pushNamed(context, '/route')`.

### Theme
- Pas de `ThemeData` standard. Lookup via `appColorsEnum[mode]?['popup-text']` (`Map<ThemeModeType, Map<String, Color>>`).
- Toggle via `DarkModeProvider().toggle()`.

### Globals UI
- `GlobalKey<ScaffoldMessengerState>` exposée dans `main.dart` pour afficher toasts/snackbars hors d'un BuildContext (utilisé avec `toastification`).

### Splash & icons
- `flutter_native_splash` + `flutter_launcher_icons` configurés dans `pubspec.yaml`.
- Après modif des assets : `flutter pub run flutter_native_splash:create` et `flutter pub run flutter_launcher_icons`.

### i18n
- `LangProvider` charge des JSON depuis `assets/langs/` (FR + EN).
- Détection auto via `PlatformDispatcher.instance.locale.languageCode`.
- Fallback silencieux : si la clé manque, retourne la clé elle-même. Vérifier les JSON quand on ajoute une chaîne.
- Choix volontaire : pas de `flutter_localizations` / `.arb` / `l10n`. i18n maison.

---

## Règles de tests

État actuel : aucun test. `TDL.txt` liste tests unitaires + intégration en backlog.

### Recommandations benchmark (consensus Flutter 2026)

**Structure**
- Dossier `test/` à la racine, **arborescence miroir de `lib/`**.
  Exemple : `lib/tools/vcard.dart` → `test/tools/vcard_test.dart`.
- Suffixe `_test.dart` obligatoire (sinon `flutter test` ignore le fichier).
- Séparer unit tests (logique pure) et widget tests dans des sous-dossiers si la suite grossit.

**Outils à ajouter en `dev_dependencies`**
- `mocktail` : mocking sans build_runner ni codegen. Standard 2026, préféré à `mockito` pour sa simplicité.
- `sqflite_common_ffi` : tester la DB en in-memory sur desktop (pas besoin d'émulateur).
- `integration_test` (SDK Flutter) : pour E2E si nécessaire (à reporter, overkill au stade actuel).

**Priorités à tester en premier (ROI maximal)**
1. `lib/tools/vcard.dart` : `parse()`, `toVCard()`, `clean()`. Logique pure, pas d'IO. Couvre le risque de corruption de format vCard.
2. `lib/tools/db/db.dart` : insert / soft-delete / `verifContact`. Utiliser `sqflite_common_ffi` en in-memory.
3. `lib/providers/lang.dart` : fallback sur clé absente, changement de langue.

**Stratégie de mocks**
- Logique pure (parsing, sanitization) : pas de mock, tests directs.
- DB : pas de mock, utiliser `sqflite_common_ffi` (DB réelle in-memory).
- Permissions / contacts / file system : `mocktail` avec interfaces fines.

**Règles de style des tests**
- Un test = un comportement vérifié. Nom explicite : `test('clean() strips semicolons from vcard fields', ...)`.
- `setUp()` / `tearDown()` pour le boilerplate. Pas de logique conditionnelle dans les tests.
- Pas d'objectif de couverture chiffré au stade actuel. Couvrir d'abord les zones critiques (vcard, db).

**À ne pas faire (pour ce projet)**
- Pas de golden tests : l'app n'a pas de design system stable.
- Pas de E2E avant que les unit/widget tests soient en place.
- Pas de mock de DB via `mocktail` (préférer `sqflite_common_ffi` pour fiabilité).

---

## Règles de qualité de code et style

### Recommandation benchmark : migrer vers `very_good_analysis`

**État actuel** : `flutter_lints ^5.0.0` config par défaut. Bonne base mais limite production.

**Recommandation 2026** : remplacer par `very_good_analysis` (Very Good Ventures, agence Flutter de référence). Sur le même code, `very_good_analysis` détecte ~2x plus d'issues que `flutter_lints` (18 vs 9 dans benchmarks publiés). Inclut des règles d'architecture et de complexité que `flutter_lints` n'a pas.

**Migration**
1. Remplacer dans `dev_dependencies` :
   ```yaml
   # Retirer
   flutter_lints: ^5.0.0
   # Ajouter
   very_good_analysis: ^9.0.0  # vérifier dernière version
   ```
2. Modifier `analysis_options.yaml` :
   ```yaml
   include: package:very_good_analysis/analysis_options.yaml
   ```
3. Lancer `flutter analyze` et corriger / `// ignore_for_file:` ce qui ne peut pas être corrigé immédiatement.

**Règles de qualité immédiates (avant migration)**
- Pas de `print()` non gardé par `kDebugMode`.
- Pas de `BuildContext` traversant un async gap (voir Pièges).
- Pas de `late` non initialisé sur des champs publics.
- Préférer `const` constructors quand possible (impact perf significatif sur les widgets).
- Pas de mutation directe de listes/maps exposées : retourner une copie via `List.unmodifiable()` ou `[...list]`.

**Documentation**
- Commentaires `///` (DartDoc) sur les méthodes publiques des classes utilitaires (`VCard`, `QRDatabase`, providers).
- Pas de commentaires inline qui expliquent "ce que fait" le code (le nom du symbole le fait). Commenter uniquement le "pourquoi" si non évident.

---

## Workflow de développement

### Versionnement actuel
- `version: 1.0.0+1` dans `pubspec.yaml`.
- Roadmap historique dans `TDL.txt` avec versionning interne `alpha 0.XX`. Pratique perso de Johan, pas un standard.
- Release GitHub `v1.0.0` du 2025-11-01.

### Recommandation benchmark : Conventional Commits + Semantic Versioning

**Format de commit (Conventional Commits)**
```
<type>(<scope>): <description>

[corps optionnel]

[footer optionnel]
```

Types standards :
- `feat:` nouvelle feature → bump minor
- `fix:` correction de bug → bump patch
- `docs:` documentation seule
- `style:` formatage, pas de logique modifiée
- `refactor:` ni feature ni fix
- `test:` ajout ou correction de tests
- `chore:` build, deps, configs
- `perf:` amélioration de performance
- `ci:` pipeline CI

Breaking change : `feat!:` ou footer `BREAKING CHANGE: ...` → bump major.

Exemples pour ce projet :
```
feat(vcard): support du champ NICKNAME en parsing
fix(db): éviter doublons quand on clone une VCard existante
chore(deps): bump permission_handler 12.0.1 → 12.1.0
docs(readme): ajouter screenshots de l'app
```

**Outillage recommandé**
- `commitlint` + `husky` (via Node, déjà dans l'écosystème Johan) : refuse les commits hors format.
- `semantic-release` ou `standard-version` : auto-bump du `version:` dans `pubspec.yaml` + génération du CHANGELOG.

**Branches**
- `main` : code stable, prête à release.
- `feat/<short-name>` ou `fix/<issue>` pour le travail. Pas de `develop`/`release/` (overkill pour un projet solo).
- PR > push direct sur `main` : permet de garder un historique de review même solo.

### Build & release
- `build.sh` et `prod.sh` à la racine (lire avant d'inventer une commande).
- Icônes via `flutter_launcher_icons` (config dans `pubspec.yaml`).
- Splash via `flutter_native_splash` (config dans `pubspec.yaml`).
- Tag Git aligné avec `version:` du pubspec : `v1.0.0` → `version: 1.0.0+N` (N = build number).

### Permissions Android/iOS
- Contacts : voir contraintes de versioning ci-dessus.
- Vérifier `AndroidManifest.xml` et `Info.plist` à chaque ajout de permission.

### Licence
- **Manquante actuellement**. Sans licence explicite, le code est par défaut "tous droits réservés" et personne ne peut légalement contribuer. Ajouter `LICENSE` (MIT par défaut pour un projet ouvert aux contribs).

---

## Pièges Flutter critiques (à ne jamais reproduire)

### Spécifiques EZQRContact
1. **Pas de `print()` non gardé** par `kDebugMode` (lint warning + bruit en prod).
2. **Pas d'`INSERT` direct dans la DB** sans passer par les méthodes de `QRDatabase` (singleton).
3. **Toujours filtrer `deleted = 0`** dans les `SELECT` (sinon on remonte les éléments soft-deleted).
4. **`cloneVCard` génère un path en `.jpg`** alors que les autres sont en `.png`. À aligner si on touche cette zone.
5. **`LangProvider.get()` retourne la clé** si la traduction manque (fallback silencieux). Vérifier les JSON `assets/langs/` quand on ajoute une chaîne.
6. **Le nom du package Dart (`qr_code_app`)** ne matche pas le repo (`EZQRContact`). Tout import doit utiliser `qr_code_app`.

### Pièges Flutter standards (à connaître)
7. **`BuildContext` à travers un async gap** : si tu fais `await something();` puis utilises `context`, le widget peut avoir été démonté. Toujours :
   ```dart
   await something();
   if (!context.mounted) return;
   Navigator.pushNamed(context, '/x');
   ```
   Le lint `use_build_context_synchronously` couvre ce cas.

8. **`setState()` après `dispose()`** : si une opération async se termine après que le widget soit démonté, `setState()` crash. Toujours vérifier `mounted` :
   ```dart
   final result = await fetchSomething();
   if (!mounted) return;
   setState(() => _result = result);
   ```

9. **`dispose()` manquant** sur les controllers, timers, streams, focus nodes, animation controllers, text editing controllers. Sans `cancel()` / `dispose()` explicite, fuite mémoire garantie. Override `dispose()` dans les `StatefulWidget` qui en utilisent.

10. **`FutureBuilder` re-exécuté à chaque rebuild** : si tu passes `future: fetchData()` directement, la fonction est appelée à chaque rebuild. Stocker le `Future` dans une variable d'instance ou utiliser `initState` :
    ```dart
    late final Future<X> _future = fetchData();
    // puis: future: _future
    ```

11. **Accès `context` dans `initState`** : le widget n'est pas encore monté, certains lookups échouent. Différer via `WidgetsBinding.instance.addPostFrameCallback((_) { ... })`.

12. **Pas de `const` sur les widgets immuables** : impact perf direct (Flutter rebuild des widgets non-const à chaque frame). `flutter_lints` et `very_good_analysis` flagguent ça (`prefer_const_constructors`).

---

---

## Migration recommandée : sqflite → Drift (équivalent Prisma)

**Statut** : non implémenté, recommandation issue d'un benchmark des ORMs Flutter
2026 pour trouver un équivalent à Prisma (TypeScript). À planifier comme refacto
dédié.

### Pourquoi Drift

- **Prisma-like DX** : codegen type-safe, migrations versionnées, query API
  fluide, streams réactifs auto-updating.
- **Maintenu activement** par Simon Binder (le seul gros ORM Flutter avec une
  vélo de release stable en 2026).
- **Migration progressive depuis sqflite** via `drift_sqflite` : pas besoin
  de tout réécrire d'un coup, on peut cohabiter pendant la transition.
- **Multiplateforme** y compris Web (utile si EZQRContact passe sur web un jour).
- **Compile-time safety** sur les requêtes SQL : finis les
  `Map<String, dynamic>?` et les casts à la main qu'on a partout dans
  `db.dart` actuel.

### Pourquoi pas les autres

- **Isar** : 2x plus rapide que Drift, mais **abandonné depuis 2 ans**. v4
  jamais sortie. Forks community (`isar_community`, `isar_plus`) instables.
- **ObjectBox** : NoSQL propriétaire, ajoute une dépendance entreprise. Casse
  le modèle relationnel.
- **Floor** : maintenance ralentie, perf 2x moins bonne que Drift, pas de Web.
- **Realm** : owned by MongoDB, sync cloud Atlas non nécessaire ici. Lourd.

### Différences avec Prisma

- **Pas de Studio GUI officiel** : utiliser `drift_db_viewer` (package séparé)
  pour avoir un viewer en mode dev.
- **Pas de DSL séparé** type `schema.prisma` : le schéma est en classes Dart
  ou en fichiers `.drift` (SQL annoté).
- **Pas d'introspection** depuis une DB existante : on écrit le schéma à la
  main (OK pour ce projet, schéma déjà connu).

### Plan de migration (à exécuter dans une session dédiée)

1. **Setup** : ajouter `drift`, `drift_sqflite`, `drift_dev`, `build_runner`
   dans `pubspec.yaml`.
2. **Tables Dart** : créer `lib/tools/db/tables.dart` avec `SimpleQRs` et
   `VCards` en classes `Table` Drift. Mapper exactement le schéma actuel.
3. **Database class** : `@DriftDatabase(tables: [...])` avec
   `SqfliteQueryExecutor.inDatabaseFolder(path: 'qr_app.db')` pour pointer
   sur la DB existante.
4. **Codegen** : `dart run build_runner build --delete-conflicting-outputs`.
5. **Remplacement progressif** : migrer une méthode à la fois (commencer par
   les `SELECT` simples, finir par `modifContact` qui est complexe). Le
   singleton `QRDatabase()` reste l'API publique pour le reste du code.
6. **Tests** : ajouter des tests unit avec `sqflite_common_ffi` pour valider
   chaque méthode migrée.
7. **Drop sqflite direct** une fois 100% migré, garder uniquement
   `drift` + `drift_sqflite` (ou passer à `drift_flutter` qui utilise
   `sqlite3_flutter_libs` directement, sans bridge sqflite).

### Code exemple cible

```dart
// Avant (sqflite)
final results = await db.query('VCard', where: 'deleted = 0');
final vcard = VCard.fromMap(results.first); // unsafe, runtime errors

// Après (Drift)
final vcards = await (select(vCards)
  ..where((t) => t.deleted.equals(false))).get();
// vcards: List<VCardData>, type-safe à la compilation
```

### Bonus dev
- `drift_db_viewer` pour explorer la DB pendant le dev.
- Streams auto-updating : `(select(vCards)..where(...)).watch()` retourne un
  `Stream<List<VCardData>>` qui se met à jour à chaque mutation. Plug direct
  dans `StreamBuilder` ou les Notifier providers existants.

---

## Guide d'utilisation

**Pour les agents IA**
- Lire ce fichier avant toute implémentation.
- Suivre toutes les règles à la lettre. En cas de doute, choisir l'option la plus restrictive.
- Mettre à jour ce fichier si de nouveaux patterns émergent dans le code.

**Pour Johan**
- Garder ce fichier lean et focus sur les besoins des agents.
- Mettre à jour quand le stack ou les patterns changent (notamment après un bump majeur de `permission_handler` ou Flutter SDK).
- Revoir tous les 3 mois pour retirer les règles devenues évidentes ou obsolètes.

---

## Sources benchmark utilisées

- Tests : [Flutter testing best practices Walturn](https://www.walturn.com/insights/best-practices-for-testing-flutter-applications), [Flutter cookbook unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- Quality : [very_good_analysis pub.dev](https://pub.dev/packages/very_good_analysis), [DCM lint guide 2025](https://dcm.dev/blog/2025/10/21/getting-started-flutter-static-analytics-lints/), [OnlyFlutter benchmark](https://onlyflutter.com/improving-code-quality-in-flutter-with-very-good-analysis/)
- Workflow : [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/), [Flutter Inner Source semver](https://innersource.flutter.com/sdlc/semver/)
- Pièges : [DCM 15 common mistakes](https://dcm.dev/blog/2025/03/24/fifteen-common-mistakes-flutter-dart-development/), [BuildContext async gap](https://medium.com/nerd-for-tech/do-not-use-buildcontext-in-async-gaps-why-and-how-to-handle-flutter-context-correctly-870b924eb42e), [Flutter memory leaks](https://devharshmittal.medium.com/flutter-memory-leaks-causes-prevention-and-best-practices-with-code-examples-df089566736e)
- ORM : [Drift pub.dev](https://pub.dev/packages/drift), [Drift official docs](https://drift.simonbinder.eu/), [Migrate to Drift guide](https://drift.simonbinder.eu/guides/migrating_to_drift/), [Flutter ORM Benchmarking](https://medium.com/@sidharthmudgil/flutter-dart-orm-benchmarking-drift-vs-floor-vs-isar-vs-sqlite3-d096465d87e1), [Hive vs Drift vs Floor vs Isar 2025](https://quashbugs.com/blog/hive-vs-drift-vs-floor-vs-isar-2025), [Future of Isar #1498](https://github.com/isar/isar/discussions/1498)
- Versioning permissions : [permission_handler changelog pub.dev](https://pub.dev/packages/permission_handler/changelog), [flutter_contacts pub.dev](https://pub.dev/packages/flutter_contacts), [Baseflow issue #859](https://github.com/Baseflow/flutter-permission-handler/issues/859)
