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

## Deferred from: code review of story-1-2 (2026-05-11)

Tous les findings ci-dessous sont **pré-existants** (pas causés par le commit `2ad1c60` strict-lints) — à reprendre dans une story de hardening dédiée, pas critiques.

- **`VCard.parse` n'a pas de branche `ADR;HOME` / `ADR;TYPE=home`** [`lib/tools/vcard.dart:80-83`] — adresses domicile silencieusement perdues à l'import vCard scanné.
- **`VCard.parse` accepte payloads sans `BEGIN:VCARD`/`END:VCARD`** [`lib/tools/vcard.dart:50-87`] — usage direct sans gate `isVCard()` peut produire une VCard depuis n'importe quel QR contenant `N:`.
- **`VCard.parse` ne gère pas le RFC 6350 line continuation** [`lib/tools/vcard.dart:67`] — lignes continues (espace/tab en début) cassent le parsing.
- **`VCard.clean()` parité dépendante** [`lib/tools/vcard.dart:184`] — `;;;` → `;`, `;;;;` → `''`. Edge case adversarial.
- **`saveQrCode` pas de length check sur `data`** [`lib/components/qr_save.dart:14`] — payload >2953 chars throw `Exception` non catchée par les call sites.
- **`saveFile` pas de check d'existence du fichier source** [`lib/tools/tools.dart:103`] — `PathNotFoundException` silencieuse car appelée via `unawaited(saveFile(...))`.
- **`createSimpleQR`/`createVCard` pas transactionnels avec `saveQrCode`** [`lib/data/db/database.dart`] — DB row créé avant écriture du fichier ; si l'écriture throw, row orphelin avec `path=null`.
- **`updateVCardPath`/`saveQrCode` pas atomiques** — kill app entre rendering PNG et `UPDATE` → fichier orphelin sur disk.
- **`pickAndDecodeImage` ne décode jamais l'image** [`lib/pages/import_qr_page.dart:21-27`] — flow mort, picker ouvert mais résultat ignoré.
- **`Navbar` `Navigator.pushReplacementNamed` unawaited** [`lib/components/navbar.dart:48`] — double-tap rapide sur deux onglets queue deux replacements.
- **`importContacts` pas de `mounted` check entre `verifyPermission()` et `getContacts()`** [`lib/tools/import_contact.dart:13-15`] — pré-existant, race au permission dialog.
- **`Navigator.pop(context, chosen)` sans `mounted` guard** [`lib/components/contact_app.dart:99-105`] — double-tap Validate pop deux fois.
- **`extractValues` `controllers[key]!.text`** [`lib/tools/tools.dart:114`] — race théorique si dispose pendant iteration.
- **`AssetManifest.json` format change** [`lib/tools/tools.dart:130`] — Flutter 3.10+ a changé le schema (`v2`) ; le cast cassera si on bump Flutter.
- **`btn['action'] as Function)(context)` settings** [`lib/pages/settings.dart:174`] — typage Function loose.
- **`saveQrCode` exception message fallback** [`lib/components/qr_save.dart:45`] — si la clé i18n manque, `LangProvider.t` retourne le path littéral.
- **`data['photo'] as String?` runtime risk** [`lib/components/qr_card.dart:41`] — non-string dans le map (peu probable vu le schema Drift) throw.

## Deferred from: code review of story-1.5 (2026-05-11)

- **`runs-on: ubuntu-latest` image rolling** [`.github/workflows/ci.yml:13`] — pratique standard, risque de changement OS silencieux entre Ubuntu 22/24. Préférer `ubuntu-24.04` pour reproductibilité stricte.
- **Pas de seuil de couverture de tests** [`.github/workflows/ci.yml:31`] — `flutter test --coverage` + threshold explicitement hors scope story 1.5. À adresser en story 8.x ou cleanup CI.
- **`Directory('lib')` chemin relatif dans `langs_consistency_test.dart`** [`test/providers/langs_consistency_test.dart:39`] — fonctionne si CWD = racine projet. Fragile si `flutter test` appelé depuis sous-répertoire. Préférer un path absolu via `Platform.script`.
