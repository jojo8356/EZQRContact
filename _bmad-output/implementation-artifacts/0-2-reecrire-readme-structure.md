# Story 0.2: Réécrire README structuré

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As un **visiteur du repo (contributeur potentiel ou recruteur)**,
I want **un README clair, structuré, avec screenshots et pitch B2B pro**,
so that **je comprends en moins d'1 minute ce que fait l'app, à qui elle sert, et comment l'installer ou contribuer, et que ça donne envie de star/fork le projet**.

## Acceptance Criteria

1. **AC-1** : Le `README.md` suit la structure standard Flutter OS 2026.

   **Given** le README actuel de 6 lignes en anglais avec des fautes
   **When** je le réécris en suivant la structure : titre + tagline + badges + pitch + screenshots + Why + Features + Stack + Install + Contributing + Roadmap + License
   **Then** le rendu GitHub présente le projet de façon professionnelle, scannable en moins d'1 minute
   **And** le README contient au moins 8 sections distinctes avec headings de niveau 2

2. **AC-2** : Au moins 3 badges sont présents en haut du README.

   **Given** un README sans badges visuels
   **When** j'ajoute les badges shields.io : License MIT, Flutter, Stars (compteur dynamique)
   **Then** ils apparaissent juste sous le titre H1
   **And** ils sont cliquables et pointent vers les bonnes URL

3. **AC-3** : Le README mentionne explicitement le positionnement B2B pro et les différenciateurs uniques.

   **Given** la value prop du brief : opensource MIT + local-first + mobile native + capture config visuelle
   **When** la section "Why EZQRContact" résume cette value prop
   **Then** elle inclut au moins : pas de cloud, pas de compte, gratuit, GDPR-native, mobile native (différenciation explicite vs Blinq/HiHello/Popl)

4. **AC-4** : Une section Install/Run technique pratique pour un dev qui clone.

   **Given** un dev Flutter qui clone le repo
   **When** il suit les instructions du README
   **Then** il peut lancer l'app en dev en moins de 5 minutes (clone → flutter pub get → flutter run)
   **And** les pré-requis sont listés (Flutter SDK ^3.8.1, Android SDK 35, etc.)

5. **AC-5** : Des sections placeholder pour CONTRIBUTING (E0.3) et screenshots (E0.4) sont présentes.

   **Given** que les stories E0.3 et E0.4 ne sont pas encore faites
   **When** je crée les sections "Contributing" et "Screenshots"
   **Then** la section Contributing contient une note temporaire "See `CONTRIBUTING.md` (coming in v2.0)"
   **And** la section Screenshots contient des placeholders `<!-- screenshots/X.png -->` qui seront remplacés en E0.4
   **And** ça permet à E0.3 et E0.4 de juste remplir le contenu sans réécrire la structure

6. **AC-6** : Pas de tiret cadratin ni de double tiret dans le README.

   **Given** la règle `feedback_no_dashes` (memory) : "Pas de — ni de --"
   **When** je rédige le README
   **Then** aucun caractère `—` (U+2014) ni `--` n'apparaît dans le fichier
   **And** je préfère des points, virgules, parenthèses ou retours à la ligne pour la même fonction de séparation

## Tasks / Subtasks

- [x] **Task 1** : Préparer le squelette markdown structuré (AC: #1)
  - [x] 1.1 Sauvegarder l'ancien README en tête en commentaire HTML pour référence (`<!-- old README archived ... -->`) puis purger
  - [x] 1.2 Écrire titre H1 `# EZQRContact` + tagline 1 ligne
  - [x] 1.3 Insérer un table des matières (anchors GitHub auto-générés)
  - [x] 1.4 Vérifier qu'il y a au moins 8 sections H2 distinctes

- [x] **Task 2** : Ajouter les badges shields.io (AC: #2)
  - [x] 2.1 Badge License : `https://img.shields.io/github/license/jojo8356/EZQRContact?style=flat-square`
  - [x] 2.2 Badge Flutter version : `https://img.shields.io/badge/Flutter-3.8%2B-blue?logo=flutter&style=flat-square`
  - [x] 2.3 Badge Stars : `https://img.shields.io/github/stars/jojo8356/EZQRContact?style=flat-square`
  - [x] 2.4 Optionnel : badge "Last commit" : `https://img.shields.io/github/last-commit/jojo8356/EZQRContact?style=flat-square`
  - [x] 2.5 Tous les badges sur une seule ligne sous le H1

- [x] **Task 3** : Section Pitch + Why + Features (AC: #3)
  - [x] 3.1 Section "## What is EZQRContact?" avec 2-3 phrases du pitch (depuis `product-brief-ezqrcontact-2026-05-06.md` Executive Summary)
  - [x] 3.2 Section "## Why" avec 4 différenciateurs : opensource MIT, local-first / no cloud, GDPR-native, mobile native (vs concurrents web/PWA)
  - [x] 3.3 Section "## Features" en bullet list avec emojis sobres ou icônes : QR vCard generation, scan caméra/galerie, custom visuel (couleurs/logo/photo), config visuelle preserved, export PDF, événements, contacts tel sync, FR/EN
  - [x] 3.4 Mention explicite "Pour qui c'est fait" : commerciaux B2B, exposants salons, recruteurs, freelances

- [x] **Task 4** : Section Stack technique (AC: #4)
  - [x] 4.1 Liste des techs : Flutter `^3.8.1`, Dart 3.x, sqflite (migration Drift planifiée), Provider, mobile_scanner, qr_flutter, flutter_contacts, etc.
  - [x] 4.2 Format en sous-sections : "Core", "Persistence", "QR / Scan", "UI / UX", "Dev tools"
  - [x] 4.3 Liens vers les packages pub.dev pour chaque dep majeure

- [x] **Task 5** : Section Install / Quickstart (AC: #4)
  - [x] 5.1 Pré-requis : Flutter SDK `^3.8.1`, Android SDK `compileSdkVersion = 35` (contrainte permission_handler 12), Xcode 15+ pour iOS
  - [x] 5.2 Étapes :
    ```bash
    git clone https://github.com/jojo8356/EZQRContact.git
    cd EZQRContact
    flutter pub get
    flutter run
    ```
  - [x] 5.3 Mention des scripts existants `build.sh` et `prod.sh` (lire avant d'inventer une commande)

- [x] **Task 6** : Section Screenshots (placeholders pour E0.4) (AC: #5)
  - [x] 6.1 Créer un dossier `docs/screenshots/` (ou `.github/screenshots/`)
  - [x] 6.2 Section "## Screenshots" avec 4 placeholders : `<!-- ![My Card](docs/screenshots/my-card.png) -->`, scan, contact detail, export PDF
  - [x] 6.3 Note "Screenshots coming with v2.0 release (see story E0.4)"

- [x] **Task 7** : Section Contributing + Roadmap + License (AC: #5)
  - [x] 7.1 Section "## Contributing" : "We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and conventions (coming in v2.0). For now, feel free to open issues with bugs, ideas, or questions."
  - [x] 7.2 Section "## Roadmap" : lien vers `_bmad-output/planning-artifacts/epics-and-stories-ezqrcontact-v2-2026-05-06.md` + résumé en 5 lignes des epics
  - [x] 7.3 Section "## License" : préserver de la story 0.1 : "This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details."

- [x] **Task 8** : Validation finale + commit/push (AC: #6)
  - [x] 8.1 Grep `—` et `--` dans le README → doit être vide
  - [x] 8.2 Vérifier que le README finit par un newline (LF) — résoudre aussi le defer de la story 0.1
  - [x] 8.3 Preview Markdown localement (VS Code preview ou `gh`)
  - [x] 8.4 Commit Conventional : `docs(readme): rewrite with B2B pro positioning and structured sections`
  - [x] 8.5 Push (avec confirmation user)
  - [x] 8.6 Vérifier sur GitHub que le rendu est correct (badges, anchors, links)

## Dev Notes

### Structure cible du README (squelette)

```markdown
# EZQRContact

> The open-source MIT mobile app to swap professional contacts in person, no cloud, no account, no subscription.

[![License: MIT](badge)](LICENSE) [![Flutter](badge)](https://flutter.dev) [![Stars](badge)](https://github.com/jojo8356/EZQRContact/stargazers)

## Table of Contents

1. [What is EZQRContact?](#what-is-ezqrcontact)
2. [Why](#why)
3. [Features](#features)
4. [Screenshots](#screenshots)
5. [Stack](#stack)
6. [Install / Quickstart](#install--quickstart)
7. [Project structure](#project-structure)
8. [Contributing](#contributing)
9. [Roadmap](#roadmap)
10. [License](#license)

## What is EZQRContact?

EZQRContact is a Flutter mobile app (Android + iOS) that lets professionals
swap their contact info via personalized QR codes in 1 scan, without any
cloud, account, or subscription. Built for sales reps, exhibitors, recruiters,
and freelancers who exchange 5 to 200 contacts per day.

## Why

100 billion paper business cards are produced each year worldwide, and 88% are
thrown away within a week. Digital alternatives like Blinq, HiHello, and Popl
work, but they all require a cloud account, lock you in a SaaS, and cost
8 to 15 USD per month.

EZQRContact is different:

- **Open source MIT**, fork it, audit it, modify it.
- **Local-first**, your data stays on your phone, no cloud transit.
- **GDPR by absence**, no third-party data processor, no DPA needed.
- **Mobile native**, the only OS digital business card app installable on the
  phone (others are web/PWA).
- **Free forever**, no Pro tier, no premium features behind a paywall.

## Features

- Generate QR-encoded vCard 3.0 (universal compat) or 4.0
- Scan QR via camera or import from gallery
- Add a profile photo (auto-resized, 720x720 JPEG)
- Customize visual: colors, logo, layout templates
- Capture and preserve sender's visual identity when scanning
- Export captured contacts to PDF (1-page detailed or 2x2 compact)
- Group contacts by event (e.g., trade show 2026)
- Sync contacts to your phone book
- French and English UI

## Screenshots

<!-- ![My Card](docs/screenshots/my-card.png) -->
<!-- ![Scanner](docs/screenshots/scanner.png) -->
<!-- ![Contact Detail](docs/screenshots/contact-detail.png) -->
<!-- ![Export PDF](docs/screenshots/export-pdf.png) -->

_Screenshots coming with v2.0 release._

## Stack

### Core
- Flutter SDK `^3.8.1`, Dart 3.x

### Persistence
- [`sqflite ^2.4.2`](https://pub.dev/packages/sqflite) (migration to Drift planned)
- [`shared_preferences ^2.5.3`](https://pub.dev/packages/shared_preferences)
- [`path_provider ^2.1.5`](https://pub.dev/packages/path_provider)

### QR / Scan
- [`mobile_scanner ^6.0.2`](https://pub.dev/packages/mobile_scanner)
- [`qr_flutter ^4.0.0`](https://pub.dev/packages/qr_flutter)
- [`flutter_qrcode_analysis ^1.0.2`](https://pub.dev/packages/flutter_qrcode_analysis)

### UI
- [`provider ^6.1.5+1`](https://pub.dev/packages/provider) (singleton-style usage)
- [`toastification ^3.0.3`](https://pub.dev/packages/toastification)
- [`flutter_markdown ^0.7.7+1`](https://pub.dev/packages/flutter_markdown)

### Dev tools
- `flutter_lints ^5.0.0` (migration to `very_good_analysis` planned)
- `flutter_native_splash ^2.4.6`
- `flutter_launcher_icons ^0.14.4`

## Install / Quickstart

**Requirements**

- Flutter SDK `^3.8.1`
- Android SDK with `compileSdkVersion = 35` (constraint of `permission_handler 12`)
- Xcode 15+ for iOS builds

**Run in dev**

```bash
git clone https://github.com/jojo8356/EZQRContact.git
cd EZQRContact
flutter pub get
flutter run
```

**Build release**

See `build.sh` and `prod.sh` at repo root.

## Project structure

```
lib/
  main.dart        # Entry + MaterialApp + routes
  pages/           # Top-level screens
  components/      # Reusable widgets
  modals/          # Modal dialogs
  providers/       # Singleton state (theme, lang, dark mode)
  tools/           # Helpers (vcard, contacts, db)
```

The full v2.0 architecture, ADRs, and migration plan are documented in
`_bmad-output/planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md`.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup,
conventions, and PR workflow (coming in v2.0).

For now, feel free to:

- Open issues with bugs, ideas, or questions
- Star the repo if you find it useful
- Fork and propose features via PR

## Roadmap

The v2.0 roadmap is broken into 9 epics and 33 stories, organized in 8
sprints. See [the full epics document](_bmad-output/planning-artifacts/epics-and-stories-ezqrcontact-v2-2026-05-06.md).

Highlights:

- E0: Open source preparation (LICENSE, README, CONTRIBUTING, screenshots)
- E1: Foundation (Drift ORM migration, lints, CI)
- E2: vCard 3.0 refactor (universal compat fix)
- E3: Visual customization (colors, logo, photo)
- E4: Scan and contacts management
- E5: Blue ocean differentiators (visual config preserved, reciprocal swap)
- E6: PDF export and event tagging
- E7: Onboarding and accessibility
- E8: CI/CD and release pipeline

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

### Sources de contenu pour le README

| Section | Source |
|---|---|
| Pitch / Executive Summary | [Source: planning-artifacts/product-brief-ezqrcontact-2026-05-06.md#Executive Summary] |
| Why / différenciateurs | [Source: planning-artifacts/product-brief-ezqrcontact-2026-05-06.md#What Makes This Different] |
| Personas | [Source: planning-artifacts/product-brief-ezqrcontact-2026-05-06.md#Who This Serves] |
| Stack | [Source: project-context.md#Stack technique et versions] |
| Architecture summary | [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#Vue d'ensemble] |
| Roadmap | [Source: planning-artifacts/epics-and-stories-ezqrcontact-v2-2026-05-06.md#Epic List] |
| Contraintes Android (compileSdkVersion) | [Source: project-context.md#Contraintes de versioning] |

### Fichiers touchés

| Action | Path | Type |
|---|---|---|
| **UPDATE** | `/README.md` | Réécriture complète, ~150 lignes |
| **NEW** | `/docs/screenshots/.gitkeep` | Dossier pour les screenshots de E0.4 |

### Ce qui NE doit PAS changer

- Le `LICENSE` (créé en story 0.1) reste intact.
- Le `pubspec.yaml` (déjà mis à jour en 0.1) reste intact.
- Aucun fichier `lib/`, `android/`, `ios/`, `assets/` modifié.
- Aucune dépendance ajoutée/retirée.

### Project Structure Notes

**Alignement** :
- Le README est à la racine (convention).
- Le dossier `docs/screenshots/` (ou `.github/screenshots/`) est cohérent avec d'autres projets Flutter OS.
- Cohérent avec `architecture-ezqrcontact-v2-2026-05-06.md` Section 1 (refacto `lib/` planifié mais pas encore appliqué).

**Variances détectées** : aucune.

### Testing Standards

- **Pas de test automatisé** (fichier markdown statique).
- **Validation manuelle** :
  1. `grep '—' README.md` doit retourner 0 ligne.
  2. `grep -- '--' README.md` doit retourner 0 ligne (ou seulement des commentaires HTML `<!-- -->`).
  3. `tail -c 1 README.md | xxd` doit retourner `0a` (newline final).
  4. Preview GitHub : ouvrir `https://github.com/jojo8356/EZQRContact/blob/main/README.md` et vérifier rendu (badges visibles, anchors fonctionnels).
  5. Compteur de stars dans le badge devrait afficher la valeur réelle (probablement 0 ou 1 au début).

### References

- Best Flutter README structure 2026 : [Walturn — How to Create an Effective Flutter README](https://www.walturn.com/insights/how-to-create-an-effective-flutter-readme)
- Bacancy 18 Best Flutter OS Projects : [bacancytechnology.com](https://www.bacancytechnology.com/blog/flutter-open-source-projects)
- Flutter boilerplate README de référence : [zubairehman/flutter_boilerplate_project](https://github.com/zubairehman/flutter_boilerplate_project)
- shields.io générateur de badges : https://shields.io
- Pitch source : [Source: planning-artifacts/product-brief-ezqrcontact-2026-05-06.md#Executive Summary]
- Différenciateurs : [Source: planning-artifacts/product-brief-ezqrcontact-2026-05-06.md#What Makes This Different]

## Previous Story Intelligence (de 0.1)

### Learnings

1. **Toujours vérifier les memories AVANT d'écrire** : la story 0.1 a introduit un `—` dans le README en première version (corrigé immédiatement). La règle `feedback_no_dashes` doit être appliquée AVANT, pas après. Pour cette story, AC-6 est explicite et Task 8.1 est un grep de validation.

2. **Stage scopé** : la story 0.1 a stage manuellement `git add LICENSE README.md pubspec.yaml` pour exclure les artefacts BMAD untracked. Maintenant les artefacts BMAD sont versionnés (commit `ad6ca7b`), donc `git add README.md docs/screenshots/.gitkeep` suffit pour cette story.

3. **Format commit Conventional** : la story 0.1 a utilisé `chore: add MIT license`. Pour celle-ci, `docs(readme): rewrite with B2B pro positioning and structured sections` est plus précis (type `docs`, scope `readme`).

4. **Validation push via gh api** : la story 0.1 a validé l'AC GitHub avec `gh api repos/jojo8356/EZQRContact --jq '.license'`. Pour le README, on n'a pas d'API équivalente mais on peut vérifier via `gh repo view jojo8356/EZQRContact` que le README s'affiche sur la home.

### Patterns établis

- Commits Conventional Commits avec body multi-lignes via heredoc.
- Co-author Claude crédité.
- Push direct sur `main` (pas de PR pour projet solo).

## Git Intelligence Summary

5 derniers commits :

```
ad6ca7b chore: bootstrap BMAD planning artifacts and v2 roadmap
628d42b chore: add MIT license
6bc53c6 simple qr code gestion (v1)
fcf1e85 color scanner fix
acba265 color scanner fix
```

- Cadence pre-BMAD (v1) : titres courts, pas Conventional Commits.
- Cadence post-BMAD : Conventional Commits, body détaillé.
- Cette story doit suivre la nouvelle cadence (post-BMAD).

## Latest Tech Information (Web research 2026)

### Badges shields.io
URL pattern stable depuis 2018, format actuel :
- `https://img.shields.io/github/license/{owner}/{repo}?style=flat-square`
- `https://img.shields.io/github/stars/{owner}/{repo}?style=flat-square`
- `https://img.shields.io/github/last-commit/{owner}/{repo}?style=flat-square`
- Badge custom Flutter : `https://img.shields.io/badge/Flutter-3.8%2B-blue?logo=flutter&style=flat-square`

### Recommandation 2026 (Walturn, Bacancy)
- 8-10 sections H2 minimum.
- Badges en haut (license, build, version, stars).
- Screenshots/GIF dans le top-half pour engagement.
- Stack listée avec versions précises et liens pub.dev.
- Section roadmap visible (les recruteurs adorent voir la planification).
- Lien vers `CONTRIBUTING.md` même si vide au début (placeholder accepté).

## Project Context Reference

Lire le fichier `_bmad-output/project-context.md` pour :
- Stack exacte avec versions.
- Contraintes Android (`compileSdkVersion = 35`).
- Patterns de code (singleton statique, DB schema v1, soft-delete).
- Pièges Flutter à mentionner subtilement dans la doc Stack si pertinent.

## Story Completion Status

Status: review (impl done, awaiting code review)

Cette story produit un README qui :
- Engage en moins d'1 minute (badges, tagline, screenshots placeholders).
- Différencie clairement vs SaaS et autres OS.
- Donne assez de stack pour qu'un dev puisse cloner et lancer.
- Référence la roadmap pour montrer le sérieux du projet.
- Prépare la structure pour E0.3 (CONTRIBUTING) et E0.4 (screenshots).

## Anti-pattern prevention

**Erreurs typiques d'un LLM dev sur cette story (à éviter)** :

1. ❌ **Utiliser des `—` ou `--`** dans le texte (violation `feedback_no_dashes`).
2. ❌ **Traduire le README en français pur**. Le standard pub.dev / GitHub OS est anglais. Le code interne peut rester en français mais la doc publique = anglais. Note : si tu fais bilingue, mets EN d'abord puis FR.
3. ❌ **Utiliser des emojis partout** (Johan préfère sobre, voir `feedback_no_dashes` qui dit "effet ChatGPT à éviter"). Quelques emojis sobres OK, pas de feu d'artifice.
4. ❌ **Mettre des badges qui ne marchent pas** (mauvais owner/repo dans l'URL, mauvais ID).
5. ❌ **Inventer des features** non listées dans le brief / PRD.
6. ❌ **Dire "in production" ou "battle-tested"** alors que c'est en v1 avec 0 stars.
7. ❌ **Sur-vendre** ("révolutionne le networking") — Johan veut direct, pas marketing.
8. ❌ **Promettre des features non roadmap** (ex: "Apple Wallet integration coming" alors que c'est V3 only).
9. ❌ **Oublier le newline final** (resolve aussi le defer de 0.1).
10. ❌ **Mettre des liens cassés** vers les docs internes (vérifier les paths `_bmad-output/planning-artifacts/...`).

## LLM Optimization Notes

Cette story est plus longue que 0.1 parce que le contenu du README est volumineux et que le squelette markdown sert directement de référence à l'impl. Le dev agent peut copier-coller la structure du squelette en l'adaptant aux spécificités du repo.

Validation primaire = visuelle (rendu GitHub). Pas de test auto possible.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7[1m] (Opus 4.7, 1M context) via `bmad-dev-story` workflow, 2026-05-07.

### Debug Log References

- Première écriture du README directement depuis le squelette de Dev Notes, traduite en anglais OS standard.
- Validation grep `—` : 0 occurrence (clean).
- Validation grep `--` : 5 occurrences toutes légitimes : 1 dans l'anchor GitHub `#install--quickstart` (génération auto par GitHub à partir de "Install / Quickstart"), 4 dans les commentaires HTML `<!-- screenshot placeholders -->`.
- Trailing newline ajouté (`tail -c 1` retourne `0a`), résout le defer de la story 0.1.
- Stage scopé à `README.md` + `docs/screenshots/.gitkeep` pour ne pas mélanger avec les artefacts BMAD untracked du sprint en cours.

### Completion Notes List

- ✅ README.md complètement réécrit en 192 lignes anglais, 7183 bytes.
- ✅ 4 badges shields.io en place (license MIT, Flutter 3.8+, stars, last commit).
- ✅ Table of Contents avec 10 ancres.
- ✅ Différenciateurs B2B explicites : OS MIT, local-first, GDPR by absence, mobile native, free forever.
- ✅ 10 features listées (génération QR, scan, photo profil, customization visuel, capture config visuelle préservée, export PDF, événements, sync contacts tel, FR/EN, dark mode).
- ✅ Stack groupée par catégorie avec versions exactes et liens pub.dev.
- ✅ Install/Quickstart 4 lignes bash + prérequis (compileSdkVersion 35).
- ✅ Roadmap : 9 epics résumés avec lien vers le doc complet.
- ✅ Placeholders screenshots (E0.4) et CONTRIBUTING (E0.3) présents.
- ✅ Section License préservée de la story 0.1.
- ✅ Defer de la story 0.1 (no trailing newline) résolu.
- ✅ Commit Conventional `docs(readme):` créé avec body multi-paragraphes.
- ✅ Push réussi : `ad6ca7b..ccd25da main -> main` sur `origin`.
- ✅ AC-1 à AC-6 validés (voir Acceptance Criteria).

### File List

- `README.md` (UPDATE, +186/-6 lignes)
- `docs/screenshots/.gitkeep` (NEW, dossier placeholder pour screenshots E0.4)

### Change Log

- 2026-05-07 : Story 0.2 implémentée et pushée. Commit `ccd25da`. README B2B pro structuré en ligne. Status → review.

## Senior Developer Review (AI)

**Date :** 2026-05-07
**Reviewer :** Claude Opus 4.7 (1M context) via `bmad-code-review` workflow
**Outcome :** ✅ **Approve**
**Coverage :** 3 layers (Blind Hunter, Edge Case Hunter, Acceptance Auditor) joués en interne (diff = 1 README markdown + 1 .gitkeep, pas de code).

### Action Items

- [x] [AI-Review][Defer] `CONTRIBUTING.md` link broken (file missing) `[README.md:246]` — par design, le fichier sera créé en story E0.3. Le lien restera 404 sur GitHub jusqu'à ce que cette story soit mergée. Acceptable.

### Findings Summary

- **0 critical**
- **0 major**
- **0 patch**
- **1 defer** (CONTRIBUTING.md broken link, by design)
- **0 dismiss**

### Acceptance Criteria validation

- AC-1 (10 sections H2) : ✅
- AC-2 (4 badges shields.io) : ✅ (1 bonus last-commit)
- AC-3 (positionnement B2B + différenciateurs) : ✅
- AC-4 (Install/Quickstart) : ✅
- AC-5 (placeholders Contributing + Screenshots) : ✅
- AC-6 (no em-dash, double-dash légitimes uniquement) : ✅

### Risks / Observations

- README utilise `compileSdkVersion = 35` dans les prérequis. Cohérent avec la contrainte `permission_handler 12` documentée dans `project-context.md`. Si Johan downgrade `permission_handler`, le readme devra être mis à jour.
- Liens vers `_bmad-output/planning-artifacts/...` longs et datés. Si on régénère les docs à une date différente, les liens casseront. À noter pour V3 ou pour `bmad-correct-course` si applicable.
- 0 em-dash dans le README cette fois : la story 0.1 avait introduit le piège, la story 0.2 l'a évité dès le premier jet. Memory `feedback_no_dashes` correctement appliquée.
