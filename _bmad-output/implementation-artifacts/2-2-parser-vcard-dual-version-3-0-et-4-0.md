# Story 2.2: Parser vCard dual-version (3.0 et 4.0)

Status: done

<!-- Created by autonomous dev agent on 2026-05-11. -->

## Story

As un **utilisateur qui scanne un QR de quelqu'un d'autre**,
I want **que l'app parse correctement le QR peu importe la version vCard utilisée**,
so that **je ne perds pas d'info parce que l'autre a généré du 4.0 ou du 2.1**.

## Acceptance Criteria

1. **AC-1** : `VCard.parse()` détecte le header `VERSION:` (3.0, 4.0, 2.1) et applique les règles de chaque version (notamment `TEL;VALUE=uri:tel:+33...` côté 4.0 et `TEL;TYPE=WORK:` côté 3.0).
2. **AC-2** : Un vCard 3.0 standard est parsé sans perte (N, FN, ORG, TITLE, TEL, EMAIL, ADR, PHOTO, NOTE, URL — pour les champs supportés par le modèle EZQRContact : N, ORG, TITLE, TEL work/home, ADR work/home, EMAIL, PHOTO).
3. **AC-3** : Un vCard 4.0 standard est parsé sans perte (mêmes champs + gestion `TEL;VALUE=uri:tel:` et `PHOTO:data:image/...;base64,...`).
4. **AC-4** : Un vCard 2.1 est parsé en best-effort (N, TEL, EMAIL, PHOTO si possible — pas de garantie sur QUOTED-PRINTABLE).
5. **AC-5** : Line unfolding RFC 6350 §3.2 : les lignes continues commençant par espace ou tab sont rejointes avant parsing.
6. **AC-6** : Tests unit dans `test/tools/vcard_test.dart` avec au moins 5 fixtures (1 iCloud, 1 Google, 1 Outlook, 1 EZQRContact 3.0, 1 EZQRContact 4.0) en strings en dur dans le test.
7. **AC-7** : `flutter analyze` → 0 issue ; tous tests passent.

## Tasks / Subtasks

- [x] **Task 1** : `VCard.parse()` dual-version (AC-1 à AC-5)
  - [x] Détection `VERSION:` (helper `_detectVersion`).
  - [x] Line unfolding RFC 6350 §3.2 (`_unfoldLines`).
  - [x] Routing `TEL` selon types `WORK` / `HOME` / `CELL` / `MOBILE`.
  - [x] Strip `tel:` URI scheme côté 4.0.
  - [x] Décodage `PHOTO;ENCODING=b;TYPE=...:<b64>` → `data:image/...;base64,<b64>`.
  - [x] Fallback `URL:` → `photo` pour les exports 2.1 qui mettent l'avatar là.
- [x] **Task 2** : Fixtures réelles (AC-6)
  - [x] iCloud export (Apple Contacts → Export vCard).
  - [x] Google Contacts export.
  - [x] Outlook export.
  - [x] EZQRContact 3.0 (round-trip via `toVCard()`).
  - [x] EZQRContact 4.0 (round-trip via `toVCard()` avec `useVCard4=true`).
  - [x] 1 vCard 2.1 minimal (legacy / Windows Address Book / Nokia).
- [x] **Task 3** : Validation (AC-7)
  - [x] `flutter analyze` → 0 issue.
  - [x] `flutter test` → tous tests pass.

## Dev Notes

### Contraintes critiques

- **Ne pas casser `toVCard()` de la story 2.1.** Le parser et le générateur sont indépendants ; les changements doivent rester localisés au parser.
- Le modèle EZQRContact est volontairement réduit (N, ORG, TITLE, TEL work/home, ADR work/home, EMAIL, PHOTO). Les champs hors-modèle (NICKNAME, BDAY, URL hormis fallback, X-properties) sont ignorés silencieusement, c'est OK pour cette story.

### Algorithme

1. `_unfoldLines(text)` : split sur `\r?\n`, puis fold les lignes continues (`^[ \t]`) sur la précédente.
2. `_detectVersion(lines)` : cherche la ligne `VERSION:X.X`, défaut `'3.0'`.
3. Pour chaque ligne non-meta : split sur le premier `:`, parse les segments `NAME;PARAM1;PARAM2...` → router selon `NAME`.
4. `TEL` : examine les params, classifie en `work | home | other` (`CELL` et `MOBILE` mappent sur `home` parce que notre modèle n'a pas de `cell`).
5. `PHOTO` : si `ENCODING=B` ou `ENCODING=BASE64`, on reconstruit l'URI `data:image/<type>;base64,<value>`. Sinon, on garde le `value` brut (URI ou data: inline 4.0).
6. `ADR` : routage `WORK | HOME`, valeur stockée brute (le model est un free-string).

### Pourquoi ne pas faire un AST complet vCard

Le modèle EZQRContact est plat. Construire un AST puis le folder dans un mapping plat duplique la logique. Approche directe : extraction ligne-par-ligne avec routing.

### Cas non couverts (volontaires)

- `QUOTED-PRINTABLE` (vCard 2.1 historique) : non implémenté. Les caractères non-ASCII en 2.1 peuvent apparaître bruts si le QR n'a pas été QP-encodé. Tests fixture 2.1 utilisent ASCII only.
- `X-properties` (`X-EZQR-VISUAL:`) : ignorées pour cette story. Décodage prévu en story 5.2.
- Multi-valeurs de `TEL` ou `EMAIL` : on prend la première du genre (work / home). Les doublons sont droppés.

## File List

- **UPDATE** `lib/tools/vcard.dart` — parser dual-version (déjà appliqué en story 2.1)
- **UPDATE** `test/tools/vcard_test.dart` — ajout des 6 fixtures parsing
