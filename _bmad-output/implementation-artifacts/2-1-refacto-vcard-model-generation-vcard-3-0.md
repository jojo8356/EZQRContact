# Story 2.1: Refacto VCard model + génération vCard 3.0

Status: done

<!-- Created by autonomous dev agent on 2026-05-11. -->

## Story

As un **utilisateur qui partage son contact**,
I want **que le QR scanné s'importe correctement sur n'importe quel iPhone, Android, Outlook ou Gmail**,
so that **les gens à qui je donne ma carte arrivent vraiment à m'enregistrer dans leur tel**.

## Acceptance Criteria

1. **AC-1** : `VCard.toVCard()` génère du vCard 3.0 par défaut (`VERSION:3.0`, line endings CRLF strict `\r\n` séparant chaque content line, y compris la dernière ligne avant `END:VCARD`).
2. **AC-2** : Un toggle `useVCard4` dans `lib/providers/vcard_settings_provider.dart` (singleton statique comme `LangProvider`/`DarkModeProvider`, `SharedPreferences` key `use_vcard4`, default `false`) permet de forcer vCard 4.0. L'API : `VCardSettingsProvider.init()`, `VCardSettingsProvider.useVCard4` (getter sync), `VCardSettingsProvider.setUseVCard4(bool)` (persiste).
3. **AC-3** : Le fichier `.vcf` exporté s'importe sans erreur sur iOS Contacts, Google Contacts, Outlook — vérifié via fixtures unit tests (round-trip parse + assertions sur les headers `BEGIN:VCARD`, `VERSION:3.0`, `N:`, `FN:`, `TEL`, `EMAIL`, `END:VCARD`, et conformité CRLF).
4. **AC-4** : Tests unit dans `test/tools/vcard_test.dart` couvrent : génération 3.0 basique, CRLF dans chaque ligne, champs vides ignorés, photo base64 incluse si présente, toggle 4.0 produit `VERSION:4.0`, line folding > 75 octets.
5. **AC-5** : `flutter analyze` → 0 issue ; `flutter test` → tous les tests passent (47 baseline + nouveaux).

## Tasks / Subtasks

- [x] **Task 1** : Créer `lib/providers/vcard_settings_provider.dart` (AC-2)
  - [x] Singleton statique comme `DarkModeProvider`, `static const _kPrefKey = 'use_vcard4'`, default `false`.
  - [x] API : `static Future<void> init()`, `static bool get useVCard4`, `static Future<void> setUseVCard4(bool value)`.
- [x] **Task 2** : Refacto `toVCard()` (AC-1, AC-2)
  - [x] Brancher sur `VCardSettingsProvider.useVCard4`.
  - [x] Émettre du vCard 3.0 par défaut : `VERSION:3.0`, `TEL;TYPE=WORK,VOICE:`, `TEL;TYPE=HOME,VOICE:`, `ADR;TYPE=WORK:`, `ADR;TYPE=HOME:`, `EMAIL;TYPE=INTERNET:`, `PHOTO;ENCODING=b;TYPE=JPEG:` pour data:image/jpeg base64.
  - [x] CRLF strict (`\r\n`) entre chaque content line, fin de fichier avec CRLF trailing.
  - [x] Line folding vCard 3.0 : 75 octets max par ligne, continuation par `\r\n ` (espace en début).
  - [x] Champs vides ignorés (sauf `N` et `FN` qui doivent toujours être présents même vides — exigence RFC 2426).
  - [x] Branche `useVCard4=true` : génère le format vCard 4.0 (l'ancien comportement, mais avec CRLF strict et line folding).
- [x] **Task 3** : Tests unit (AC-4)
  - [x] Créer `test/tools/vcard_test.dart` avec couverture des 6 points AC-4.
- [x] **Task 4** : Validation (AC-5)
  - [x] `flutter analyze` → 0 issue.
  - [x] `flutter test` → tous tests pass.

## Dev Notes

### Contraintes critiques

- Conserver `VCard.clean()` tel quel.
- Conserver `VCard.parse()` tel quel (story 2.2).
- Conserver `isImageUrl()` tel quel (tools.dart).
- CRLF = `\r\n` dans le **contenu** vCard, pas seulement à la fin.
- Format vCard 3.0 (RFC 2426) — types en MAJUSCULES par convention :
  - `TEL;TYPE=WORK,VOICE:+33...`
  - `TEL;TYPE=HOME,VOICE:+33...`
  - `ADR;TYPE=WORK:;;Street;City;State;Zip;Country`
  - `EMAIL;TYPE=INTERNET:foo@bar.com`
  - `PHOTO` : soit `PHOTO;VALUE=URI:https://...`, soit `PHOTO;ENCODING=b;TYPE=JPEG:<base64>` (fold required pour base64).
- Line folding (RFC 2425 / 6350 §3.2) : si une content line excède 75 octets (UTF-8), couper et préfixer la continuation par un seul espace ou tab. Le folding se fait après assemblage de la ligne et **avant** ajout du CRLF.

### Pattern singleton (à suivre)

Voir `lib/providers/darkmode.dart` pour le pattern factory+`_internal()`. Pour la pref, voir `lib/providers/lang_provider.dart:36-46` (lecture en `init()`, écriture en setter).

### Choix d'implémentation

- Pas de getter async — on suit le pattern existant : `init()` charge depuis `SharedPreferences` au boot ; le getter `useVCard4` est sync.
- Pas de `ChangeNotifier` pour l'instant (pas d'UI à rebuild dans cette story).
- `toVCard()` reste synchrone : on lit `VCardSettingsProvider.useVCard4` (sync) à l'appel.
- En test, `SharedPreferences.setMockInitialValues({'use_vcard4': true})` + `await VCardSettingsProvider.init()` avant d'appeler `toVCard()`.

## File List

- **NEW** `lib/providers/vcard_settings_provider.dart`
- **UPDATE** `lib/tools/vcard.dart` — refacto `toVCard()` dual-version + CRLF + folding
- **NEW** `test/tools/vcard_test.dart` — tests génération
