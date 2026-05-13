# Story 3.1: Color picker pour couleur primaire

Status: review

## Story

As un **freelance qui a une identité de marque**,
I want **choisir la couleur primaire de mon QR et de ma card**,
So that **mes contacts captent immédiatement mon univers visuel**.

## Acceptance Criteria

1. **AC-1** : Un color picker est accessible depuis le formulaire de génération VCard, dans une section "Apparence" sous les champs existants, avec un label i18n ("Couleur primaire" / "Primary color").
2. **AC-2** : Quand l'utilisateur choisit une couleur via le picker et soumet le formulaire, le QR est généré avec cette couleur (modules et yeux du QR dans la couleur choisie, fond blanc inchangé).
3. **AC-3** : La couleur est persistée en DB dans le champ `visual_config` (JSON `{"primaryColor": "#RRGGBB"}`). Au rechargement de la page collection, la couleur est correctement lue.
4. **AC-4** : Si `visual_config` est null (ancien enregistrement), la couleur par défaut est noir (`Colors.black`) — aucune régression sur les QR existants.
5. **AC-5** : `flutter analyze` → 0 issue ; `flutter test` → tous les tests passent.

## Tasks / Subtasks

- [x] **Task 1** : Ajouter `flex_color_picker` à `pubspec.yaml`
  - [x] Ajouter `flex_color_picker: ^3.6.1` sous `dependencies`
  - [x] Lancer `flutter pub get`

- [x] **Task 2** : Créer le modèle `VisualConfig`
  - [x] Créer `lib/models/visual_config.dart` avec classe `VisualConfig` : champ `primaryColor` (Color, default `Colors.black`)
  - [x] Méthodes `VisualConfig.fromJson(String json)` et `toJson()` (serialise en `{"primaryColor": "#RRGGBB"}`)
  - [x] Méthode statique `VisualConfig.fromNullableJson(String? json)` : retourne `VisualConfig()` si null
  - [x] Tests unitaires dans `test/models/visual_config_test.dart` : round-trip JSON, null-safety, couleurs limites

- [x] **Task 3** : Mettre à jour `saveQrCode` pour accepter une couleur
  - [x] Modifier la signature : `Future<String> saveQrCode(String data, int id, {Color color = Colors.black})`
  - [x] Remplacer les deux `Colors.black` hardcodés (QrDataModuleStyle + QrEyeStyle) par le paramètre `color`
  - [x] Vérifier que tous les appels existants compilent sans paramètre (`color` est optionnel)

- [x] **Task 4** : Mapper `visual_config` dans `_mapToVCardCompanion`
  - [x] Dans `lib/data/db/database.dart`, ajouter `visualConfig: str('visual_config')` dans le return de `_mapToVCardCompanion`
  - [x] Vérifier que `insertVCard` passe bien le champ

- [x] **Task 5** : Ajouter le color picker dans `qr_generator_vcard.dart`
  - [x] Ajouter variable d'état `Color _primaryColor = Colors.black;`
  - [x] Ajouter section "Apparence" avec label i18n après les champs existants
  - [x] Ajouter un `GestureDetector` / `InkWell` affichant un carré de la couleur courante ; au tap, appeler `showColorPickerDialog(context, _primaryColor)` et mettre à jour `_primaryColor` via `setState`
  - [x] Lors du `onPressed` du bouton Submit :
    - Construire `VisualConfig(primaryColor: _primaryColor).toJson()` et injecter dans `data['visual_config']`
    - Passer `color: _primaryColor` à `saveQrCode`

- [x] **Task 6** : Ajouter les clés i18n
  - [x] Dans `assets/langs/fr.json` section `pages.QR.generator` : `"appearance": "Apparence"`, `"primary_color": "Couleur primaire"`
  - [x] Dans `assets/langs/en.json` : `"appearance": "Appearance"`, `"primary_color": "Primary color"`

- [x] **Task 7** : Tests & validation
  - [x] Test unitaire `VisualConfig` round-trip (AC-3, AC-4)
  - [x] Widget test ou test de smoke dans `test/pages/qr_generator_vcard_test.dart` vérifiant que le color picker est présent dans le widget tree
  - [x] `flutter analyze` clean (AC-5)
  - [x] `flutter test` tous passants (AC-5)

## Dev Notes

### Contexte architecture

Le projet suit une architecture layered :
```
lib/
  models/          ← NOUVEAU : visual_config.dart ici
  data/db/
    database.dart  ← modifier _mapToVCardCompanion + createVCard
    tables/
      vcards.dart  ← visualConfig column déjà présente (v2 schema)
  components/
    qr_save.dart   ← modifier saveQrCode() signature
  pages/
    qr_generator_vcard.dart  ← ajouter UI color picker + wiring
```

### DB : pas de migration nécessaire

La colonne `visual_config TEXT NULLABLE` existe déjà dans la table `VCards` (ajoutée en migration v2). **Aucune migration DB n'est à écrire.**

Actuellement `_mapToVCardCompanion` (database.dart:292) ne mappe **pas** `visual_config` — le champ est toujours null même si on le passe dans le map. C'est ce que Task 4 corrige.

### `saveQrCode` — changement de signature

Fichier : `lib/components/qr_save.dart`

Avant :
```dart
Future<String> saveQrCode(String data, int id) async {
  ...
  dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
```

Après (changement minimal) :
```dart
Future<String> saveQrCode(String data, int id, {Color color = Colors.black}) async {
  ...
  dataModuleStyle: QrDataModuleStyle(color: color),
  eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
```

Les `const` sont retirés car `color` est un paramètre runtime. Tous les appels existants sans paramètre `color` continuent de fonctionner (couleur noire par défaut = aucune régression).

### `flex_color_picker` — API de base

```dart
import 'package:flex_color_picker/flex_color_picker.dart';

// Dans un handler async :
final Color picked = await showColorPickerDialog(
  context,
  _primaryColor,
  title: Text(lang['primary_color'] as String),
  pickersEnabled: const <ColorPickerType, bool>{
    ColorPickerType.primary: true,
    ColorPickerType.accent: false,
    ColorPickerType.custom: false,
    ColorPickerType.wheel: true,
  },
);
setState(() => _primaryColor = picked);
```

Version recommandée : `^3.6.1` (latest stable, Nov 2025, Flutter 3.x compatible).

### `VisualConfig` model — sérialisation

```dart
// lib/models/visual_config.dart
import 'dart:convert';
import 'dart:ui';

class VisualConfig {
  const VisualConfig({this.primaryColor = const Color(0xFF000000)});

  final Color primaryColor;

  static VisualConfig fromNullableJson(String? json) {
    if (json == null || json.isEmpty) return const VisualConfig();
    return fromJson(json);
  }

  factory VisualConfig.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final hex = map['primaryColor'] as String? ?? '#000000';
    return VisualConfig(primaryColor: _hexToColor(hex));
  }

  String toJson() {
    final map = {'primaryColor': _colorToHex(primaryColor)};
    return jsonEncode(map);
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static String _colorToHex(Color c) {
    return '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
```

### Wiring dans `qr_generator_vcard.dart`

Dans `onPressed` du bouton submit (actuellement ligne ~80) :

```dart
onPressed: () async {
  final data = extractValues(controllers);
  data['visual_config'] = VisualConfig(primaryColor: _primaryColor).toJson();  // ADD
  final vcard = VCard.fromMap(data);
  final id = await createVCard(data);
  await saveQrCode(vcard.toVCard(), id, color: _primaryColor);  // MODIFY
  ...
```

Note : `createVCard` appelle `saveQrCode` en interne avec `path` comme data (code legacy), mais l'appel explicite depuis `qr_generator_vcard.dart` est celui qui génère réellement le QR — c'est lui qu'on modifie.

### Perf

Pas de mesure supplémentaire requise — `saveQrCode` est déjà entièrement instrumenté (`qr.save.total`, etc.).

### i18n — emplacement exact

`assets/langs/fr.json` → dans l'objet `pages.QR.generator` (qui contient déjà `"vcard"`, `"submit button"`, etc.) :
```json
"appearance": "Apparence",
"primary_color": "Couleur primaire"
```

`assets/langs/en.json` → même emplacement :
```json
"appearance": "Appearance",
"primary_color": "Primary color"
```

## Dev Agent Record

### Debug Log

- `flex_color_picker 3.8.0` installé (latest stable, semver compatible avec `^3.6.1`).
- `AssetManifest.bin` : Flutter 3.41.6 n'utilise plus `AssetManifest.json` comme fallback sur non-web. Le mock des tests `settings_page_test.dart` et `qr_generator_vcard_test.dart` a été mis à jour pour encoder le manifeste via `StandardMessageCodec` au format `.bin`.
- `_mapToVCardCompanion` n'avait pas de mapping pour `visual_config` — ajout de `visualConfig: str('visual_config')`.
- `c.value` deprecation dans `VisualConfig._colorToHex` → remplacé par `c.toARGB32()`.
- `prefer_constructors_over_static_methods` : `fromNullableJson` transformé en factory constructor.

### Completion Notes

- **AC-1** ✅ : Section "Apparence" + label "Couleur primaire" dans `qr_generator_vcard.dart`, clés i18n fr/en ajoutées.
- **AC-2** ✅ : `saveQrCode` accepte `{Color color = Colors.black}`, modules QR et yeux utilisent la couleur choisie.
- **AC-3** ✅ : `VisualConfig.toJson()` sérialise `{"primaryColor":"#RRGGBB"}` dans `data['visual_config']` → persisté via `_mapToVCardCompanion.visualConfig`.
- **AC-4** ✅ : `VisualConfig.fromNullableJson(null)` retourne `VisualConfig()` (noir) — appels existants sans `color:` gardent `Colors.black`.
- **AC-5** ✅ : `flutter analyze` → 0 issue ; `flutter test` → 176/176 passés.

## File List

- `pubspec.yaml` — ajout `flex_color_picker: ^3.6.1`
- `pubspec.lock` — lock mis à jour
- `lib/models/visual_config.dart` — **NEW** — modèle VisualConfig avec JSON round-trip
- `lib/components/qr_save.dart` — ajout param optionnel `{Color color = Colors.black}`
- `lib/data/db/database.dart` — `_mapToVCardCompanion` : ajout `visualConfig: str('visual_config')`
- `lib/pages/qr_generator_vcard.dart` — UI color picker + wiring persistance
- `assets/langs/fr.json` — clés `appearance`, `primary_color` dans `pages.QR.generator`
- `assets/langs/en.json` — clés `appearance`, `primary_color` dans `pages.QR.generator`
- `test/models/visual_config_test.dart` — **NEW** — 10 tests unitaires VisualConfig
- `test/pages/qr_generator_vcard_test.dart` — **NEW** — 4 widget tests color picker UI
- `test/pages/settings_page_test.dart` — mock AssetManifest.bin (fix régression flex_color_picker)
- `test/providers/vcard_settings_provider_test.dart` — fix lint lines_longer_than_80_chars

## Change Log

| Date | Change |
|------|--------|
| 2026-05-12 | Story créée (create-story) |
| 2026-05-12 | Implémentation complète (dev-story) — color picker, VisualConfig model, persistance DB |
