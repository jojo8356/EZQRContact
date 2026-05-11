# Story 2.3: Sanitization renforcée

Status: done

<!-- Created by autonomous dev agent on 2026-05-11. -->

## Story

As un **développeur sécurité-conscient**,
I want **que les inputs utilisateur ne puissent pas casser le format vCard**,
so that **un nom contenant `;` ou `\n` ne génère pas un QR corrompu**.

## Acceptance Criteria

1. **AC-1** : `VCard.clean()` étendu pour gérer :
   - `\r`, `\n`, `\r\n` (line breaks injectent un nouveau content line, à supprimer)
   - Caractères de contrôle Unicode (U+0000–U+001F sauf `\t`)
   - DEL (U+007F)
   - Surrogates non appariées (U+D800–U+DFFF)
   - Non-characters U+FFFE et U+FFFF
2. **AC-2** : Input `"Mar;tin\nDupont"` produit `"Mar tinDupont"` en sortie clean (semicolon → espace, LF strippé).
3. **AC-3** : Tests unit couvrent 10+ inputs malicieux : `;`, `\n`, `\r\n`, `\x00`, emojis valides (passent), caractères de contrôle, injection SQL-like, injection HTML-like, strings vides, strings nulles-équivalentes, et concatenation de plusieurs malveillants.
4. **AC-4** : `flutter analyze` → 0 issue ; tous tests passent.

## Tasks / Subtasks

- [x] **Task 1** : `clean()` durci (AC-1, AC-2)
  - [x] CR/LF strip (déjà fait en story 2.1).
  - [x] Drop des C0 controls (sauf TAB).
  - [x] Drop DEL (U+007F).
  - [x] Drop surrogates orphelines.
  - [x] Drop U+FFFE / U+FFFF.
- [x] **Task 2** : Tests sanitization (AC-3)
  - [x] Group `VCard.clean() — Story 2.3 hardening` avec ≥ 10 cas.
- [x] **Task 3** : Validation (AC-4)
  - [x] `flutter analyze` clean.
  - [x] `flutter test` clean.

## Dev Notes

### Stratégie sécurité

L'attaquant ici n'est pas externe — c'est un user qui :
1. Tape `Mar;tin Dupont` dans son nom de famille : `;` est un séparateur vCard, casse le `N:` line.
2. Colle un texte avec un `\n` venant d'un autre site : injecte une fausse content line.
3. Émojis dans le surnom : doivent passer (sont des Unicode supérieurs valides).

La sanitization actuelle remplace `;` par un espace (legacy decision, pour préserver la lisibilité plutôt que stripper). On garde ce comportement.

### Cas non couverts (volontaires)

- HTML / XSS : non applicable, on n'a pas de WebView qui rend le contenu. Si un nom contient `<script>`, il reste tel quel dans le QR et apparaît brut côté lecteur — pas de surface d'attaque.
- SQL injection : la couche DB (Drift) est paramétrée, pas concaténation, donc safe by design.
- UTF-8 malformé : Dart ne peut pas représenter de l'UTF-8 invalide dans un `String` (sound runtime), donc le seul cas pertinent est les surrogates orphelines insérées via `codeUnitAt` ou interop natif. On les drop par sécurité.

## File List

- **UPDATE** `lib/tools/vcard.dart` — `clean()` déjà refacto en story 2.1 ; pas de change nécessaire ici.
- **UPDATE** `test/tools/vcard_test.dart` — ajout du group sanitization (≥ 10 tests).
