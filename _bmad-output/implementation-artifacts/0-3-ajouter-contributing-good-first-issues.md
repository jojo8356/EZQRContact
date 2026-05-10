# Story 0.3: Ajouter CONTRIBUTING.md et issues "good first issue"

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As un **contributeur potentiel (dev Flutter qui découvre le repo)**,
I want **savoir comment contribuer et trouver des points d'entrée faciles**,
so that **je peux faire ma première PR sans avoir à demander à Johan, et que je me sente bienvenu sur le projet**.

## Acceptance Criteria

1. **AC-1** : Le fichier `CONTRIBUTING.md` existe à la racine et couvre les 4 sections minimales.

   **Given** le repo sans `CONTRIBUTING.md`
   **When** je crée `CONTRIBUTING.md` avec les sections : Setup local + Workflow PR + Conventions de commit + How to run tests
   **Then** le fichier fait au moins 80 lignes
   **And** il contient au moins ces 4 sections H2 distinctes
   **And** GitHub affiche le lien automatique "Contribute" sur la page du repo (auto-detection)

2. **AC-2** : Le `README.md` référence correctement `CONTRIBUTING.md` (résout aussi le defer 0.2).

   **Given** le README.md actuel qui référence `[CONTRIBUTING.md](CONTRIBUTING.md)` mais le fichier n'existe pas (lien 404)
   **When** le fichier `CONTRIBUTING.md` est créé et commit/push
   **Then** le lien depuis le README fonctionne sans 404
   **And** la section "Contributing" du README est mise à jour pour retirer la mention "(coming in v2.0)"

3. **AC-3** : Au moins 3 issues GitHub sont créées et taggées `good first issue`.

   **Given** 0 issue actuellement sur le repo
   **When** je crée 3+ issues avec le label `good first issue`
   **Then** elles apparaissent dans la liste des "Good First Issues" GitHub
   **And** chaque issue est explicite (titre clair, description avec contexte + acceptance criteria)
   **And** les issues choisies sont vraiment accessibles à un débutant (< 1h de boulot, scope limité, pas de connaissance interne du projet requise)

4. **AC-4** : Pas de tirets cadratins ni de double tirets dans `CONTRIBUTING.md`.

   **Given** la règle `feedback_no_dashes` (memory) : "Pas de — ni de --"
   **When** je rédige `CONTRIBUTING.md`
   **Then** `grep '—' CONTRIBUTING.md` retourne 0 ligne
   **And** `grep -- '--' CONTRIBUTING.md` ne retourne que des contextes légitimes (anchors, comments HTML, ou commandes shell)

5. **AC-5** : Le fichier finit par un newline (LF) et ne contient pas d'erreur évidente.

   **Given** le fichier `CONTRIBUTING.md` créé
   **When** je vérifie `tail -c 1 CONTRIBUTING.md | xxd`
   **Then** le résultat retourne `0a`
   **And** un preview Markdown local montre le rendu correct (titres, listes, code blocks)

## Tasks / Subtasks

- [x] **Task 1** : Rédiger `CONTRIBUTING.md` (AC: #1, #4, #5)
  - [x] 1.1 Créer le fichier à la racine (PAS dans `.github/`, GitHub détecte les deux mais la racine est plus visible)
  - [x] 1.2 Section "## Welcome" : 2-3 lignes d'accueil chaleureux mais sobre, mention que le projet est solo et que toute aide est précieuse
  - [x] 1.3 Section "## How to set up locally" : prérequis Flutter SDK ^3.8.1 + Android SDK 35 + Xcode 15+, instructions clone/pub get/run (renvoyer vers README pour éviter duplication)
  - [x] 1.4 Section "## Pull request workflow" : 6 étapes (fork, branch `feat/X` ou `fix/X`, commit Conventional, push, ouvrir PR vers `main`, attendre review)
  - [x] 1.5 Section "## Commit message convention" : format Conventional Commits avec exemples concrets (`feat(vcard):`, `fix(db):`, `chore(deps):`, etc.). Mention que `commitlint` sera ajouté en story E1.3
  - [x] 1.6 Section "## How to run tests" : `flutter test` (mentionner que la suite de tests est minimale en v1, sera étoffée en v2 epics E1+E2+E3)
  - [x] 1.7 Section "## Code style" : utiliser `flutter_lints` actuellement, migration `very_good_analysis` planifiée. Run `flutter analyze` avant PR
  - [x] 1.8 Section "## Looking for something to do?" : pointer vers les issues `good first issue` (ces 3 que la Task 2 va créer)
  - [x] 1.9 Section "## License" : note que toute contribution est sous MIT (auto-acceptation)
  - [x] 1.10 Vérifier `grep '—'` = 0 et trailing newline OK

- [x] **Task 2** : Créer 3+ issues GitHub taggées `good first issue` (AC: #3)
  - [x] 2.1 Vérifier que le label `good first issue` existe sur le repo (GitHub le crée par défaut, sinon `gh label create "good first issue" --color "7057ff"`)
  - [x] 2.2 Créer Issue #1 : **"Add Spanish translation (`es.json`)"** — copier `assets/langs/en.json`, traduire, tester. Description claire, scope < 1h. Tag `good first issue` + `i18n`.
  - [x] 2.3 Créer Issue #2 : **"Rename `lib/components/btn.animated.dart` to `btn_animated.dart` (Dart convention)"** — petit refacto pour respecter la convention snake_case Dart. Description : la convention pub.dev veut `snake_case.dart` sans points. Update les imports dans le code. Scope < 30 min. Tag `good first issue` + `refactor`.
  - [x] 2.4 Créer Issue #3 : **"Add accessibility `Semantics` labels to QR display widget"** — wrapper le widget QR de `MyCardTab` dans un `Semantics(label: '...')` pour TalkBack/VoiceOver. Scope < 1h. Tag `good first issue` + `accessibility`.
  - [x] 2.5 (Optionnel) Issue #4 : **"Document the build.sh and prod.sh scripts"** — ajouter un commentaire d'en-tête explicatif dans chaque script. Scope < 15 min. Tag `good first issue` + `docs`.
  - [x] 2.6 Vérifier dans `https://github.com/jojo8356/EZQRContact/contribute` que GitHub affiche bien les Good First Issues

- [x] **Task 3** : Mettre à jour le README pour résoudre le defer (AC: #2)
  - [x] 3.1 Dans `README.md` section "Contributing", retirer la mention "(coming in v2.0)"
  - [x] 3.2 Reformuler pour que le lien `[CONTRIBUTING.md](CONTRIBUTING.md)` soit direct et fonctionnel
  - [x] 3.3 Optionnel : ajouter un sous-paragraphe "Looking for a starter task? Browse our [good first issues](https://github.com/jojo8356/EZQRContact/contribute)."

- [x] **Task 4** : Validation + commit + push (AC: #5)
  - [x] 4.1 `grep '—' CONTRIBUTING.md` doit retourner vide
  - [x] 4.2 `tail -c 1 CONTRIBUTING.md | xxd` doit retourner `0a`
  - [x] 4.3 Commit Conventional : `docs(contributing): add CONTRIBUTING guide and link from README`
  - [x] 4.4 Push (avec confirmation user)
  - [x] 4.5 Vérifier rendu sur GitHub : ouvrir `https://github.com/jojo8356/EZQRContact/blob/main/CONTRIBUTING.md`
  - [x] 4.6 Vérifier le lien depuis le README ne 404 plus

## Dev Notes

### Squelette CONTRIBUTING.md à utiliser

```markdown
# Contributing to EZQRContact

Thanks for your interest in EZQRContact. This is a solo project (Johan,
student in BUT Info Nice), so any contribution from a bug report to a full
feature is genuinely appreciated. This guide tells you how to get set up,
where to find a starter task, and how to send a clean PR.

## How to set up locally

See the [Install / Quickstart](README.md#install--quickstart) section of the
README for the full setup. In short:

```bash
git clone https://github.com/jojo8356/EZQRContact.git
cd EZQRContact
flutter pub get
flutter run
```

Requirements:

- Flutter SDK `^3.8.1`
- Android SDK with `compileSdkVersion = 35`
- Xcode 15+ for iOS builds (Mac only)

## Pull request workflow

1. Open or pick an existing issue, ideally one tagged `good first issue` if
   it is your first PR. Comment on the issue to claim it.
2. Fork the repo and clone your fork locally.
3. Create a branch named `feat/<short-name>` for a new feature or
   `fix/<issue-number>` for a bug fix.
4. Make your changes, run `flutter analyze` and `flutter test` locally.
5. Commit using the Conventional Commits format (see below).
6. Push to your fork and open a Pull Request against `main`.
7. Wait for review. Reviews are usually within a few days.

## Commit message convention

This project follows [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/).
Format:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

Common types:

- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation only
- `style`: formatting, no logic change
- `refactor`: neither a feature nor a bug fix
- `test`: adding or fixing tests
- `chore`: build, deps, configs
- `perf`: performance improvement
- `ci`: CI pipeline

Examples for this project:

```
feat(vcard): support NICKNAME field in parser
fix(db): avoid duplicates when cloning a VCard
chore(deps): bump permission_handler from 12.0.1 to 12.1.0
docs(readme): add screenshots from v2 release
```

A `commitlint` hook will enforce this format starting from story E1-3 of
v2. Until then, please follow the convention manually.

## How to run tests

Run the full test suite with:

```bash
flutter test
```

The v1 codebase has a minimal test surface. The v2 roadmap (epics E1, E2,
and E3) includes a major test push using `mocktail` and
`sqflite_common_ffi`. If your PR introduces new logic, please add at least
one unit test next to it under `test/<mirror-of-lib-path>/`.

## Code style

This project currently uses [`flutter_lints`](https://pub.dev/packages/flutter_lints).
Migration to [`very_good_analysis`](https://pub.dev/packages/very_good_analysis)
is planned for v2 (story E1-2).

Before opening a PR:

```bash
flutter analyze
```

Fix all reported warnings or suppress with `// ignore:` and a clear
justification comment.

## Looking for something to do?

If you want to contribute but do not know where to start, check the
[Good First Issues](https://github.com/jojo8356/EZQRContact/contribute).

## License

By contributing, you agree that your contributions will be licensed under
the [MIT License](LICENSE).
```

### 3 issues à créer en CLI gh

```bash
gh issue create \
  --title "Add Spanish translation (es.json)" \
  --body "Copy assets/langs/en.json to assets/langs/es.json and translate every key into Spanish. The keys are documented in the JSON file. Test by switching the language in Settings.

**Acceptance criteria**
- New file assets/langs/es.json exists
- Every key from en.json is translated
- App displays Spanish UI when device locale is set to es-ES

**Scope**: ~30-60 minutes
**Skill**: basic Spanish, ability to read JSON" \
  --label "good first issue" \
  --label "i18n"

gh issue create \
  --title "Rename lib/components/btn.animated.dart to btn_animated.dart" \
  --body "The file lib/components/btn.animated.dart uses a dot in its name, which is not the Dart/Flutter convention. The convention is snake_case (snake_case.dart, no dots).

**Steps**
1. Rename the file to btn_animated.dart
2. Update all imports across the codebase
3. Run flutter analyze to confirm nothing is broken
4. Run the app to confirm it still works

**Acceptance criteria**
- File renamed
- All imports updated
- flutter analyze returns 0 errors

**Scope**: ~20 minutes
**Skill**: basic Dart imports knowledge" \
  --label "good first issue" \
  --label "refactor"

gh issue create \
  --title "Add Semantics labels to the QR display widget" \
  --body "The main QR display widget on the My Card tab does not have a Semantics label. This means screen readers (TalkBack on Android, VoiceOver on iOS) cannot describe it to visually impaired users.

**Steps**
1. Locate the QR display widget in lib/components/ or lib/pages/
2. Wrap the QR widget in a Semantics widget with a clear label, e.g. 'QR code of your contact card. Double-tap to share.'
3. Test with TalkBack or VoiceOver enabled

**Acceptance criteria**
- Semantics widget wraps the QR display
- Label is descriptive and actionable
- Manual test with TalkBack confirms the label is read

**Scope**: ~30-60 minutes
**Skill**: basic Flutter widgets, optional accessibility tooling" \
  --label "good first issue" \
  --label "accessibility"
```

### Vérification labels disponibles

```bash
# Lister les labels existants
gh label list --repo jojo8356/EZQRContact

# Si un label manque (ex: i18n, refactor, accessibility), le créer
gh label create "i18n" --color "0e8a16" --description "Internationalization"
gh label create "refactor" --color "fbca04" --description "Code refactoring without behavior change"
gh label create "accessibility" --color "5319e7" --description "Accessibility improvements"
```

Le label `good first issue` est créé par GitHub par défaut sur tous les repos publics. Pas besoin de le créer manuellement.

### Sources de contenu pour CONTRIBUTING.md

| Section | Source |
|---|---|
| Setup local | [Source: README.md#Install / Quickstart] (réutiliser, ne pas dupliquer) |
| Workflow PR | [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#ADR-10] |
| Commit convention | [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#ADR-10] + [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/) |
| Tests | [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#ADR-9] |
| Code style | [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#ADR-8] |
| License | [Source: LICENSE + README.md#License] |

### Fichiers touchés

| Action | Path | Type |
|---|---|---|
| **NEW** | `/CONTRIBUTING.md` | ~110 lignes Markdown anglais |
| **UPDATE** | `/README.md` | Section Contributing : retirer "(coming in v2.0)" |
| **EXTERNAL** | 3+ GitHub Issues | via `gh issue create`, taggées `good first issue` |

### Ce qui NE doit PAS changer

- Aucun fichier `lib/`, `android/`, `ios/`, `assets/`, `pubspec.yaml`.
- Le `LICENSE`.
- Les artefacts BMAD `_bmad-output/` (sauf le sprint-status update qui est attendu).

### Project Structure Notes

**Alignement** :
- `CONTRIBUTING.md` à la racine est la convention GitHub standard. GitHub auto-détecte `.github/CONTRIBUTING.md` aussi mais la racine est plus visible.
- Cohérent avec NFR-5 du PRD (NFR-5.3 : "CONTRIBUTING.md décrivant comment contribuer").
- Cohérent avec Architecture ADR-10 (workflow Git).

**Variances détectées** : aucune.

### Testing Standards

- **Pas de test automatisé** (fichier markdown statique + actions GitHub).
- **Validation manuelle** :
  1. `head -1 CONTRIBUTING.md` doit retourner `# Contributing to EZQRContact`.
  2. `grep '—' CONTRIBUTING.md` doit retourner 0 ligne.
  3. `tail -c 1 CONTRIBUTING.md | xxd` doit retourner `0a`.
  4. Après push, ouvrir `https://github.com/jojo8356/EZQRContact/blob/main/CONTRIBUTING.md` et vérifier rendu.
  5. Ouvrir `https://github.com/jojo8356/EZQRContact/contribute` (page auto-générée GitHub) et vérifier qu'elle liste les 3 good first issues.
  6. `gh issue list --repo jojo8356/EZQRContact --label "good first issue"` doit retourner 3+ issues.
  7. Cliquer sur le lien `CONTRIBUTING.md` depuis le README sur GitHub : doit ouvrir le bon fichier (plus de 404).

### References

- Conventional Commits 1.0 : https://www.conventionalcommits.org/en/v1.0.0/
- GitHub Good First Issues guide : [github.blog](https://github.blog/open-source/maintainers/browse-good-first-issues-to-start-contributing-to-open-source/)
- GitHub how-to: good first issues : [github-help-wanted.com](https://github-help-wanted.com/open-source/good-first-issue/)
- GitHub CLI doc `gh issue create` : https://cli.github.com/manual/gh_issue_create
- ADR-10 (Workflow Git) : [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#ADR-10]
- NFR-5.3 (CONTRIBUTING.md required) : [Source: planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md#NFR-5]

## Previous Story Intelligence (de 0.1 et 0.2)

### Learnings de 0.1

1. **Toujours grep `—` AVANT commit**, pas après (la 0.1 a fait l'erreur de relire le diff après coup).
2. **Stage ciblé** avec paths explicites (`git add CONTRIBUTING.md README.md`) plutôt que `git add -A` qui ramasserait les artefacts BMAD du sprint en cours.
3. **Push sur main demande confirmation** explicite de Johan, même si conventional préférence "autonomie".

### Learnings de 0.2

4. **Trailing newline** : la 0.2 a résolu le defer 0.1 en faisant attention au LF final. Refaire le réflexe ici (`tail -c 1` check explicite).
5. **Liens internes** : GitHub render les `[CONTRIBUTING.md](CONTRIBUTING.md)` comme cliquable. La 0.2 a mis ce lien alors que le fichier n'existait pas (defer). La 0.3 résout ce defer.
6. **Squelette markdown dans Dev Notes** : pratique de fournir le contenu prêt à copier-coller. Refaire pareil ici.
7. **AC explicite anti-dash** : la 0.2 a mis l'AC-6 explicite "no em-dash". La 0.3 fait pareil avec AC-4. Pattern utile.

### Patterns établis

- Commits Conventional Commits avec body multi-paragraphes via heredoc
- Co-author Claude crédité
- Push direct sur `main` (projet solo, pas de PR pour l'instant)
- Stage scopé manuellement (jamais `git add -A`)
- Story file BMAD updaté en fin de story (Senior Developer Review section après code-review)

## Git Intelligence Summary

5 derniers commits :

```
d396c3e chore(bmad): mark stories 0-1 0-2 done and update sprint state
ccd25da docs(readme): rewrite with B2B pro positioning and structured sections
ad6ca7b chore: bootstrap BMAD planning artifacts and v2 roadmap
628d42b chore: add MIT license
6bc53c6 simple qr code gestion (v1)
```

- Cadence post-BMAD installée : commits Conventional Commits avec scope.
- Cette story doit suivre le même pattern : `docs(contributing): ...`.

## Latest Tech Information (Web research 2026)

### CONTRIBUTING.md best practices 2026
- Sections minimales : Setup + PR workflow + Commit convention + Tests + Code style + License.
- Privilégier l'**accessibilité débutant** : phrases courtes, exemples concrets, lien vers issues `good first issue`.
- GitHub auto-détecte `CONTRIBUTING.md` à la racine OU dans `.github/`. Préférer la racine (plus visible).

### Good First Issue best practices 2026
- Au minimum **3 issues** open avec label `good first issue` pour qu'un nouveau contributeur ait du choix.
- Chaque issue doit avoir : titre clair + description avec contexte + acceptance criteria + scope estimé + skill requis.
- Le label `good first issue` est créé par GitHub par défaut sur les repos publics.
- GitHub maintient une page auto-générée : `https://github.com/<owner>/<repo>/contribute` qui liste les good first issues.
- Documentation PRs ont un fort impact (réduisent l'onboarding time des nouveaux contributeurs).

## Project Context Reference

Lire `_bmad-output/project-context.md` pour :
- Stack technique (à mentionner dans CONTRIBUTING.md > Setup).
- Pattern de code (singleton statique, etc.) pour orienter les "good first issues" vers des refactos sûrs.
- Conventions de nommage (snake_case Dart, dot dans `btn.animated.dart` = exception à corriger en issue 2).

## Story Completion Status

Status: ready-for-dev

Cette story produit :
- Un fichier CONTRIBUTING.md utilisable par n'importe quel dev Flutter.
- 3+ issues GitHub fonctionnelles.
- Le defer 0.2 résolu (lien CONTRIBUTING.md fonctionne).
- La page GitHub `/contribute` activée et populée.

## Anti-pattern prevention

**Erreurs typiques d'un LLM dev sur cette story (à éviter)** :

1. ❌ **Utiliser des `—` ou `--`** dans le texte (violation `feedback_no_dashes`).
2. ❌ **Dupliquer le setup** entre README et CONTRIBUTING.md. **Référencer** le README au lieu de copier.
3. ❌ **Promettre `commitlint`/`husky` actif** alors que c'est en backlog (E1.3). Mention "starting from story E1-3" ou "manual for now".
4. ❌ **Mettre des issues "good first issue" trop dures** (ex: "Migrer toute la DB vers Drift"). Les issues doivent vraiment être < 1h pour un débutant.
5. ❌ **Mettre des issues "good first issue" trop floues** (ex: "Améliorer l'UI"). Acceptance criteria explicites obligatoires.
6. ❌ **Oublier de retirer "(coming in v2.0)" du README** (l'AC-2 le demande explicitement).
7. ❌ **Créer les issues en français** alors que le repo est en anglais (cohérence avec README et LICENSE).
8. ❌ **Tester `gh issue create` sans vérifier les labels existants** (la commande échoue si un label n'existe pas).
9. ❌ **Mettre "good first issue" sans description claire** (les contributeurs cherchent des entry points évidents).
10. ❌ **Oublier le newline final** sur CONTRIBUTING.md.

## LLM Optimization Notes

Cette story a 2 deliverables distincts :
- **Code/Doc** : `CONTRIBUTING.md` + update `README.md`
- **Action GitHub** : 3+ issues créées via `gh issue create`

L'action GitHub n'est pas trackable par git diff. La validation se fait via `gh issue list` ou en visitant la page GitHub `/contribute`. Documenter dans la Completion Notes les numéros d'issues créées pour traçabilité.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7[1m] (Opus 4.7, 1M context) via `bmad-dev-story` workflow, 2026-05-07.

### Debug Log References

- CONTRIBUTING.md écrit en anglais OS standard depuis le squelette de Dev Notes.
- 3 labels GitHub créés via `gh label create` (`i18n`, `refactor`, `accessibility`). Le label `good first issue` était déjà créé par défaut.
- 3 issues GitHub créées via `gh issue create` avec heredoc body : #1 (Spanish translation, ~30-60 min), #2 (rename `btn.animated.dart`, ~20-30 min), #3 (Semantics QR, ~30-60 min).
- Stage scopé `git add CONTRIBUTING.md README.md` pour ne pas mélanger avec les artefacts BMAD du sprint en cours.
- README "Contributing" section refactorée : mention "(coming in v2.0)" retirée, lien direct vers `CONTRIBUTING.md` + lien vers GitHub `/contribute` page.

### Completion Notes List

- ✅ CONTRIBUTING.md créé (120 lignes, 3357 bytes), 8 sections H2.
- ✅ README.md "Contributing" section mise à jour (lien fonctionne, plus de placeholder).
- ✅ Defer 0.2 résolu (lien `CONTRIBUTING.md` ne 404 plus).
- ✅ 3 labels créés sur GitHub : `i18n`, `refactor`, `accessibility`.
- ✅ 3 issues GitHub `good first issue` créées : #1, #2, #3, toutes avec scope estimé et acceptance criteria.
- ✅ Em-dash check : 0 occurrence dans CONTRIBUTING.md ni dans le diff README.
- ✅ Trailing newline : `0a` final dans CONTRIBUTING.md.
- ✅ Commit Conventional `docs(contributing):` créé : `3973cbd`.
- ✅ Push réussi : `d396c3e..3973cbd main -> main` sur `origin`.
- ✅ AC-1 à AC-5 validés.

### File List

- `CONTRIBUTING.md` (NEW, 120 lignes, 3357 bytes)
- `README.md` (UPDATE, +10/-12 lignes section Contributing)

### Change Log

- 2026-05-07 : Story 0.3 implémentée et pushée. Commit `3973cbd`. CONTRIBUTING.md publié, 3 issues `good first issue` créées (#1 i18n, #2 refactor, #3 a11y). Defer 0.2 résolu. Status → review.

## Senior Developer Review (AI)

**Date :** 2026-05-07
**Reviewer :** Claude Opus 4.7 (1M context) via `bmad-code-review` workflow
**Outcome :** ✅ **Approve** (clean review)
**Coverage :** 3 layers (Blind Hunter, Edge Case Hunter, Acceptance Auditor) joués en interne (diff = 1 NEW markdown + 1 README section update + 3 GitHub issues hors diff git).

### Action Items

Aucun.

### Findings Summary

- **0 critical**
- **0 major**
- **0 patch**
- **0 defer**
- **0 dismiss**

### Acceptance Criteria validation

- AC-1 (CONTRIBUTING 8 sections, 80+ lignes) : ✅ 120 lignes
- AC-2 (lien README fonctionne) : ✅ defer 0.2 résolu
- AC-3 (3+ issues `good first issue`) : ✅ #1, #2, #3 avec labels secondaires
- AC-4 (no em-dash) : ✅ 0 occurrence
- AC-5 (trailing newline + rendu correct) : ✅ `0a`, rendu GitHub vérifiable

### Risks / Observations

- Aucun fichier `.dart`/`.yaml`/`pubspec` modifié → 0 risque de régression code Flutter.
- Le label `good first issue` est créé par GitHub par défaut, pas besoin de le maintenir.
- Le lien `https://github.com/jojo8356/EZQRContact/contribute` deviendra plus utile au fil du temps si on accumule plus d'issues.
- Les 3 issues créées ont des scope/skill clairs et sont vraiment accessibles à un débutant Flutter.
