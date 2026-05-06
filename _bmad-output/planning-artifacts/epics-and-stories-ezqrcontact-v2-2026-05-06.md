---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/ux-design-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md
project_name: EZQRContact
target_version: v2.0.0
user_name: Johan
date: 2026-05-06
status: draft
---

# EZQRContact v2.0 — Epic Breakdown

## Overview

Décomposition des requirements (PRD), UX, et Architecture en epics et
stories implémentables. Format Gherkin pour les acceptance criteria.

---

## Requirements Inventory

### Functional Requirements (du PRD)
- **FR-1** Génération carte personnelle (vCard 3.0 par défaut)
- **FR-2** Personnalisation visuelle de la carte
- **FR-3** Photo de profil dans la VCard
- **FR-4** Scan QR code (caméra + galerie)
- **FR-5** Capture config visuelle du QR scanné (différenciateur)
- **FR-6** Échange réciproque optionnel
- **FR-7** Export PDF des contacts captés
- **FR-8** Tag/groupement événement
- **FR-9** Sauvegarde dans contacts du téléphone
- **FR-10** Historique des scans
- **FR-11** Internationalisation
- **FR-12** Onboarding

### Non-Functional Requirements (du PRD)
- **NFR-1** Performance (< 2s ouverture, < 500ms QR gen, < 1s scan, < 5s PDF 50 contacts)
- **NFR-2** Compatibilité (Android 7+, iOS 13+)
- **NFR-3** Privacy / GDPR (no cloud, no account, permissions minimales)
- **NFR-4** Qualité code (very_good_analysis, tests > 70% modules critiques, no print)
- **NFR-5** Documentation (README, LICENSE MIT, CONTRIBUTING)
- **NFR-6** Maintenabilité (Drift, schemaVersion, conventional commits)
- **NFR-7** Accessibilité (WCAG AA, semantics, dark mode)

### UX Requirements (du UX doc)
- 4 onglets bottom nav : Ma Carte, Scanner, Contacts, Plus
- Onboarding 3 écrans skippable
- 6 user flows critiques (F1 à F6)
- Wireframes pour MyCardTab, ScanResult, ExportPDF
- Composants : VCardPreview, VisualConfigEditor, PDFOptionsForm

---

## FR Coverage Map

| FR / NFR | Epic(s) | Story(ies) |
|---|---|---|
| FR-1 (vCard 3.0) | E2 | 2.1, 2.2 |
| FR-2 (perso visuelle) | E3 | 3.1, 3.2, 3.3 |
| FR-3 (photo) | E3 | 3.4, 3.5 |
| FR-4 (scan) | E4 | 4.1, 4.2, 4.3 |
| FR-5 (config visuelle préservée) | E5 | 5.1, 5.2, 5.3 |
| FR-6 (échange réciproque) | E5 | 5.4 |
| FR-7 (export PDF) | E6 | 6.1, 6.2, 6.3 |
| FR-8 (événements) | E6 | 6.4, 6.5 |
| FR-9 (contacts tel) | E4 | 4.4 |
| FR-10 (historique) | E4 | 4.5, 4.6 |
| FR-11 (i18n) | E1 | 1.4 |
| FR-12 (onboarding) | E7 | 7.1, 7.2 |
| NFR-1 (perf) | Cross-epic | testée à chaque story |
| NFR-2 (compat) | E1 | 1.1, 1.2 |
| NFR-3 (privacy) | E0 | 0.1 (LICENSE) + cross-epic |
| NFR-4 (qualité) | E1 | 1.3 (very_good_analysis) |
| NFR-5 (doc) | E0 | 0.2, 0.3 |
| NFR-6 (maintenabilité) | E1 | 1.1 (Drift), 1.5 (commits) |
| NFR-7 (accessibilité) | E7 | 7.3 |

---

## Epic List

| ID | Titre | Goal | Priorité |
|---|---|---|---|
| **E0** | Préparation contributions OS | LICENSE, README, CONTRIBUTING, screenshots, post Discord ready | P0 |
| **E1** | Migration technique foundation | sqflite → Drift, flutter_lints → very_good_analysis, vCard 4.0 → 3.0, conventional commits | P0 |
| **E2** | Refactor génération VCard | API VCard 3.0, parser dual-version, sanitization | P0 |
| **E3** | Personnalisation visuelle de la carte | Color picker, logo, layout templates, photo profil | P1 |
| **E4** | Scan, contacts et historique | Scan caméra/galerie, parsing, save tel, historique, recherche | P1 |
| **E5** | Différenciateurs blue ocean | Capture config visuelle, échange réciproque | P1 |
| **E6** | Export PDF et événements | PDF 1-page/2x2, tags événement, filtres date | P1 |
| **E7** | Onboarding et accessibilité | 3 écrans onboarding, semantics, dark mode preserved | P2 |
| **E8** | CI/CD et release pipeline | GitHub Actions test + analyze, release Play Store + iOS | P2 |

---

## Epic E0: Préparation contributions OS

**Goal** : Rendre le repo accueillant pour contributeurs et présentable pour
le post Discord, AVANT de coder la V2. Pré-requis pour tout le reste.

### Story E0.1: Ajouter LICENSE MIT

As a **mainteneur opensource**,
I want **une licence MIT explicite à la racine du repo**,
So that **les contributeurs sachent qu'ils peuvent fork, modifier, et utiliser sans contrainte AGPL**.

**Acceptance Criteria:**

**Given** le repo `EZQRContact` sans `LICENSE` actuellement
**When** je crée le fichier `LICENSE` avec le texte MIT standard et le copyright "(c) 2026 Johan Polsinelli"
**Then** GitHub affiche la pastille "MIT" sur la page d'accueil du repo
**And** une section "License" est ajoutée à la fin du README

### Story E0.2: Réécrire README structuré

As un **visiteur du repo (contributeur potentiel ou recruteur)**,
I want **un README clair, structuré, avec screenshots**,
So that **je comprends en moins d'1 minute ce que fait l'app, à qui elle sert, et comment l'installer ou contribuer**.

**Acceptance Criteria:**

**Given** le README actuel de 6 lignes en anglais avec des fautes
**When** je le réécris en suivant la structure : titre + pitch 1 phrase + screenshots + Why + features (bullet) + Install + Stack + Contributing + License
**Then** le README rend le projet présentable en moins d'1 minute de scroll
**And** il contient au moins 2 screenshots de l'app
**And** il mentionne explicitement "Open Source MIT" et "Local-first / No Cloud"

### Story E0.3: Ajouter CONTRIBUTING.md et issues "good first issue"

As un **contributeur potentiel**,
I want **savoir comment contribuer et trouver des points d'entrée faciles**,
So that **je peux faire ma première PR sans avoir à demander à Johan**.

**Acceptance Criteria:**

**Given** le repo sans `CONTRIBUTING.md`
**When** je crée `CONTRIBUTING.md` décrivant : setup local, workflow PR, conventions de commit, comment lancer les tests
**Then** le fichier est référencé depuis le README
**And** au moins 3 issues GitHub sont taggées `good first issue` (ex: ajout traduction langue, fix de doc, refacto petit composant)

### Story E0.4: Capturer 4-6 screenshots représentatifs

As un **visiteur du repo et user du Play Store**,
I want **voir à quoi l'app ressemble avant de l'installer**,
So that **je suis convaincu que c'est ce que je cherche**.

**Acceptance Criteria:**

**Given** l'app v1 actuelle qui tourne
**When** je capture des screenshots des écrans clés (MyCardTab avec QR, Scanner, ContactsTab, ContactDetail, Settings, mode sombre)
**Then** les screenshots sont commités dans `.github/screenshots/` ou `docs/screenshots/`
**And** ils sont référencés depuis le README
**And** ils respectent un ratio 9:19 ou similaire mobile

---

## Epic E1: Migration technique foundation

**Goal** : Mettre en place les bases techniques V2 sans changer le comportement
visible de l'app. Sans ça, tout le reste est instable.

### Story E1.1: Migrer sqflite → Drift avec préservation DB v1

As un **développeur qui doit ajouter des features avec confiance**,
I want **toute la couche persistance en Drift type-safe avec migrations versionnées**,
So that **je n'ai plus de bugs runtime liés à des cast Map<String, dynamic> et que je peux faire évoluer le schéma proprement**.

**Acceptance Criteria:**

**Given** la DB v1 sqflite existante avec 2 tables et soft-delete
**When** j'ajoute `drift`, `drift_sqflite`, `drift_dev`, `build_runner` au pubspec et je définis les tables `SimpleQRs`, `VCards`, `Events` en Drift miroir + extensions
**Then** `dart run build_runner build` génère les classes type-safe sans erreur
**And** toutes les méthodes existantes du `QRDatabase` sont remplacées par leurs équivalents Drift, avec tests unit `sqflite_common_ffi` validés
**And** un user qui upgrade depuis v1 voit ses données préservées (test avec dump réel d'une DB v1)
**And** un backup auto `qr_app.db.backup` est créé avant la migration

### Story E1.2: Migrer flutter_lints → very_good_analysis

As un **développeur qui veut maintenir un code prod-grade**,
I want **un set de lint rules plus strict que flutter_lints**,
So that **j'attrape les bugs et anti-patterns plus tôt et que mon code passe mieux à un futur recruteur**.

**Acceptance Criteria:**

**Given** `flutter_lints ^5.0.0` actuellement dans dev_dependencies
**When** je remplace par `very_good_analysis` (dernière stable) et je modifie `analysis_options.yaml` pour `include: package:very_good_analysis/analysis_options.yaml`
**Then** `flutter analyze` tourne sans erreur (warnings autorisés mais sous seuil acceptable, ex: < 30 au début)
**And** les warnings non corrigés sont suppressés explicitement avec `// ignore_for_file:` + commentaire de justification
**And** un commit dédié `chore(deps): switch to very_good_analysis` est fait

### Story E1.3: Configurer Conventional Commits + commitlint

As un **dev qui veut un changelog auto et un historique propre**,
I want **un linter qui refuse les commits hors format Conventional Commits**,
So that **je n'ai plus jamais de commits "fix bug" ou "wip" et je peux générer un CHANGELOG automatiquement**.

**Acceptance Criteria:**

**Given** un repo sans hook Git
**When** j'installe `husky` + `@commitlint/cli` + `@commitlint/config-conventional` (via pnpm) et je configure un hook `commit-msg`
**Then** un commit "fix bug" est rejeté
**And** un commit "fix(db): handle null path in cloneVCard" est accepté
**And** un fichier `.commitlintrc.json` est versionné

### Story E1.4: Préserver le toggle FR/EN i18n existant

As un **utilisateur français ou anglais**,
I want **continuer à voir l'app dans ma langue après la refonte**,
So that **la migration ne me dégrade pas l'expérience**.

**Acceptance Criteria:**

**Given** `LangProvider` actuel chargeant `assets/langs/{fr,en}.json`
**When** je porte le système dans la nouvelle structure `lib/providers/lang_provider.dart` et je vérifie que les clés sont toutes présentes après refacto
**Then** au lancement de l'app sur un device FR, l'UI est en FR
**And** au lancement sur un device EN, l'UI est en EN
**And** un toggle dans Settings > Apparence permet de forcer manuellement

### Story E1.5: Setup CI GitHub Actions de base

As un **mainteneur**,
I want **un workflow CI qui lance analyze + tests sur chaque PR**,
So that **les régressions soient attrapées automatiquement et que le repo paraisse pro à un recruteur ou contributeur**.

**Acceptance Criteria:**

**Given** un repo sans `.github/workflows/`
**When** je crée `.github/workflows/ci.yml` qui : checkout, setup Flutter stable, `flutter pub get`, `flutter analyze`, `flutter test`
**Then** le workflow tourne sur chaque PR vers `main`
**And** un badge "CI" passing/failing est affiché dans le README
**And** le workflow finit en moins de 5 minutes

---

## Epic E2: Refactor génération VCard

**Goal** : Avoir un module VCard propre supportant 3.0 et 4.0, avec parser
dual-version et photo embarquée correctement.

### Story E2.1: Refacto VCard model + génération vCard 3.0

As un **utilisateur qui partage son contact**,
I want **que le QR scanné s'importe correctement sur n'importe quel iPhone, Android, Outlook ou Gmail**,
So that **les gens à qui je donne ma carte arrivent vraiment à m'enregistrer dans leur tel**.

**Acceptance Criteria:**

**Given** le `VCard.toVCard()` actuel qui génère du vCard 4.0
**When** je refacto le code pour supporter les deux versions et je mets le 3.0 par défaut (`buffer.writeln('VERSION:3.0')`)
**Then** un fichier `.vcf` exporté s'importe sans erreur sur iCloud, Google Contacts, Outlook, Android (testé manuellement sur 3+ devices)
**And** les line endings respectent CRLF strict pour vCard 3.0
**And** un toggle "Utiliser vCard 4.0" reste disponible dans Settings

### Story E2.2: Parser vCard dual-version (3.0 et 4.0)

As un **utilisateur qui scanne un QR de quelqu'un d'autre**,
I want **que l'app parse correctement le QR peu importe la version vCard utilisée**,
So that **je ne perds pas d'info parce que l'autre a généré du 4.0 ou du 2.1**.

**Acceptance Criteria:**

**Given** un parser actuel qui ne reconnaît pas explicitement la version
**When** je refacto `VCard.parse()` pour détecter `VERSION:` et appliquer les règles de chaque version (X-properties, ENCODING, line folding)
**Then** un vCard 3.0 standard est parsé sans perte
**And** un vCard 4.0 standard est parsé sans perte
**And** un vCard 2.1 (legacy) est parsé en best-effort (champs principaux N, TEL, EMAIL, PHOTO si possible)
**And** des tests unit avec fixtures réelles (10+ vCards de différentes sources : iCloud export, Google export, Outlook export, generated by HiHello/Blinq) passent tous

### Story E2.3: Sanitization renforcée

As un **développeur sécurité-conscient**,
I want **que les inputs utilisateur ne puissent pas casser le format vCard**,
So that **un nom contenant `;` ou `\n` ne génère pas un QR corrompu**.

**Acceptance Criteria:**

**Given** la fonction `clean()` existante qui strip `;` et `;;`
**When** j'étends pour gérer `\r`, `\n`, et les caractères UTF-8 mal encodés
**Then** un input "Mar;tin\nDupont" produit "MartinDupont" en sortie clean
**And** un test unit couvre 10+ inputs malicieux (incluant XSS attempts dans noms, emojis, caractères de contrôle)

---

## Epic E3: Personnalisation visuelle de la carte

**Goal** : Permettre à l'user de customiser sa carte (couleur, logo, layout) +
ajouter sa photo. Différenciateur émotionnel pour persona freelance/recruteur.

### Story E3.1: Color picker pour couleur primaire

As un **freelance qui a une identité de marque**,
I want **choisir la couleur primaire de mon QR et de ma card**,
So that **mes contacts captent immédiatement mon univers visuel**.

**Acceptance Criteria:**

**Given** un QR généré avec couleur noire par défaut
**When** j'ouvre Edit Card > Apparence > Couleur primaire et je choisis un bleu via color picker
**Then** le QR est régénéré avec cette couleur
**And** la card de prévisualisation utilise la même couleur en accent
**And** la couleur est persistée en DB (champ `visual_config.primaryColor`)

### Story E3.2: Logo center embed dans le QR

As un **commercial avec un logo d'entreprise**,
I want **incruster un petit logo au centre de mon QR**,
So that **on reconnaît visuellement de qui vient le QR avant même de scanner**.

**Acceptance Criteria:**

**Given** un QR sans logo
**When** j'upload une image (PNG/JPG) via image_picker depuis Edit Card > Apparence > Logo
**Then** le logo est resized à 64x64 px max, centré sur le QR avec un padding blanc autour pour préserver la scannabilité
**And** le QR reste scannable par 3+ scanner apps tierces (Google Lens, scanner natif iOS, Lecteur QR Android)
**And** le logo est persisté en DB (champ `visual_config.logoBase64`)

### Story E3.3: 3 layouts de carte au choix

As un **utilisateur qui veut une carte qui ressemble à lui**,
I want **choisir parmi plusieurs layouts visuels pour ma card**,
So that **je ne sois pas coincé avec un seul template générique**.

**Acceptance Criteria:**

**Given** une seule mise en page actuelle
**When** je crée 3 layouts ("minimal", "classic", "modern") avec des dispositions photo+texte+QR différentes
**Then** Edit Card > Apparence > Layout permet de switcher entre les 3
**And** la prévisualisation se met à jour en temps réel
**And** le layout choisi est persisté en DB

### Story E3.4: Photo de profil — capture/upload + resize

As un **user qui veut être identifiable visuellement**,
I want **ajouter une photo à ma carte**,
So that **les gens qui reçoivent mon contact me reconnaissent même 2 semaines après**.

**Acceptance Criteria:**

**Given** une carte sans photo
**When** je tap sur "Ajouter une photo" et je choisis camera ou galerie via `image_picker`
**Then** la photo est resized automatiquement à 720x720 max (ou 256x256 sur Android < Jelly Bean)
**And** elle est compressée en JPEG qualité 85%
**And** elle est encodée base64 dans le champ `VCard.photo`
**And** la card de preview affiche la photo immédiatement

### Story E3.5: Recompression progressive si photo > 200KB

As un **user qui upload une photo HD**,
I want **que l'app gère la compression auto sans casser ma vCard**,
So that **je n'aie pas à savoir que vCard 3.0 a une limite de taille**.

**Acceptance Criteria:**

**Given** une photo qui après encoding base64 dépasse 200KB
**When** l'app détecte le dépassement
**Then** elle recompresse en qualité 75%, puis 65%, puis 55% jusqu'à passer sous 200KB
**And** si même à 55% c'est encore trop, elle réduit en plus la résolution à 512x512 puis 256x256
**And** si toujours trop : message d'erreur clair "Photo non compressible, choisis une autre image"

---

## Epic E4: Scan, contacts et historique

**Goal** : Permettre à l'user de scanner des QR (caméra + galerie), parser
les VCards, sauvegarder en local DB et dans le tel, lister l'historique.

### Story E4.1: Scan via caméra avec mobile_scanner

As un **commercial en RDV**,
I want **scanner le QR de mon interlocuteur en pointant la caméra**,
So that **j'enregistre son contact en moins de 5 secondes**.

**Acceptance Criteria:**

**Given** le ScannerTab ouvert
**When** je pointe vers un QR vCard
**Then** la détection se fait en < 1s (NFR-1.3)
**And** un feedback haptique + visuel confirme la capture
**And** la VCard est parsée et l'écran ScanResult s'affiche

### Story E4.2: Import QR depuis galerie

As un **user qui a reçu un QR par email/screenshot**,
I want **scanner une image depuis ma galerie**,
So that **je n'ai pas à imprimer ou afficher sur un autre écran pour scanner**.

**Acceptance Criteria:**

**Given** un screenshot d'un QR vCard dans ma galerie
**When** je tap "Importer depuis galerie" dans ScannerTab et je choisis l'image
**Then** `flutter_qrcode_analysis` parse l'image
**And** si un QR est détecté, le flow normal de ScanResult se déclenche
**And** si aucun QR détecté, un toast "Pas de QR code dans cette image" s'affiche

### Story E4.3: Sauvegarde auto VCard scannée en DB

As un **user qui scanne 50 contacts en salon**,
I want **que chaque scan soit auto-enregistré sans confirmation**,
So that **je ne perde pas le rythme avec un prompt à chaque scan**.

**Acceptance Criteria:**

**Given** un scan VCard réussi
**When** la VCard est parsée
**Then** elle est insérée immédiatement dans la DB `VCards` (avec `event_id` si événement actif)
**And** le toast confirme "Contact enregistré"
**And** un bouton "Voir" sur le toast ouvre ScanResult pour détails

### Story E4.4: Sauvegarde optionnelle dans contacts du tel

As un **recruteur qui veut retrouver un candidat dans son tel**,
I want **pousser un contact capté dans les contacts natifs**,
So that **je puisse l'appeler/SMS sans rouvrir EZQRContact**.

**Acceptance Criteria:**

**Given** un contact capté dans EZQRContact
**When** je tap "Ajouter aux contacts du téléphone" dans ContactDetail
**Then** la permission contacts est demandée (si pas déjà accordée)
**And** le contact est ajouté via `flutter_contacts`
**And** si un contact même nom/prénom existe déjà, prompt "Replace / Clone / Fill empty fields" s'affiche (préservé de v1)
**And** un toast confirme "Ajouté aux contacts"

### Story E4.5: Liste historique avec filtres

As un **exposant qui rentre du salon**,
I want **filtrer mes contacts par date ou événement**,
So that **je retrouve facilement les 50 contacts du jour pour mon export**.

**Acceptance Criteria:**

**Given** 100+ contacts accumulés en DB
**When** j'ouvre ContactsTab
**Then** la liste est triée par date desc par défaut
**And** un filtre "Par événement" affiche un picker des événements existants
**And** un filtre "Par date" affiche un date range picker
**And** la liste se met à jour en stream Drift (réactif, pas de pull-to-refresh nécessaire)

### Story E4.6: Recherche par nom dans l'historique

As un **freelance qui cherche un contact rencontré il y a 3 mois**,
I want **chercher par nom**,
So that **je retrouve la carte sans scroller dans 200 contacts**.

**Acceptance Criteria:**

**Given** un champ recherche en haut de ContactsTab
**When** je tape "marie"
**Then** la liste se filtre live (debounced 300ms) sur les contacts dont nom OU prénom contient "marie" (case-insensitive)
**And** la recherche utilise une requête Drift typée

---

## Epic E5: Différenciateurs blue ocean

**Goal** : Implémenter les 2 features uniques à EZQRContact dans le marché OS
mobile : capture config visuelle préservée + échange réciproque.

### Story E5.1: Encoder config visuelle dans le QR émetteur

As un **mainteneur du protocole EZQR**,
I want **embarquer la config visuelle dans le QR généré sous forme de X-property**,
So that **un autre user EZQRContact qui scanne puisse récupérer ma couleur, mon logo, mon layout**.

**Acceptance Criteria:**

**Given** une carte avec couleur, logo, layout custom
**When** `VCard.toVCard()` est appelé
**Then** le résultat contient une ligne `X-EZQR-VISUAL:<base64-encoded-json>` avec `{primaryColor, logoBase64, layout}`
**And** le logo embarqué est limité à 64x64 PNG compressé (pour ne pas faire exploser la taille du QR)
**And** la ligne respecte le line folding vCard 3.0 (75 chars + tab)

### Story E5.2: Décoder config visuelle au scan

As un **user qui scanne le QR d'un autre user EZQRContact**,
I want **que sa config visuelle soit extraite et stockée**,
So that **quand je consulte son contact plus tard, je revoie sa carte comme il l'a designée**.

**Acceptance Criteria:**

**Given** un QR vCard avec une ligne `X-EZQR-VISUAL:...` valide
**When** mon scanner parse ce QR
**Then** la config visuelle est décodée et stockée dans `VCard.visual_config` (JSON column)
**And** si la ligne X-EZQR-VISUAL est absente (QR d'une autre app), `visual_config` est null sans erreur
**And** un test unit vérifie ces 2 cases

### Story E5.3: Afficher contact avec sa config visuelle d'origine

As un **user qui consulte un contact capté il y a 1 mois**,
I want **voir la carte exactement comme elle était quand je l'ai scannée**,
So that **je retrouve le "feeling" de la rencontre, pas juste un texte standard**.

**Acceptance Criteria:**

**Given** un contact en DB avec `visual_config` non-null
**When** j'ouvre ContactDetail
**Then** la card est rendue via `VCardPreview` en utilisant la couleur, le logo, et le layout de `visual_config`
**And** un indicateur discret affiche "Carte capturée le [date]"
**And** si `visual_config` est null (contact venu d'un autre outil), un layout par défaut neutre est utilisé

### Story E5.4: Échange réciproque toggleable

As un **commercial qui veut faciliter l'échange à 2 sens**,
I want **proposer ma carte en retour automatiquement après un scan**,
So that **mon interlocuteur l'ait sans que j'aie à lui demander de scanner mon QR séparément**.

**Acceptance Criteria:**

**Given** le toggle "Proposer ma carte en retour" activé dans Settings
**When** je scanne le QR de quelqu'un avec succès
**Then** un prompt non-bloquant apparaît : "Partager votre carte en retour à [Prénom] ?"
**And** un tap sur "Partager" affiche mon QR plein écran pour qu'il scanne en retour
**And** un tap sur "Plus tard" ferme le prompt sans rien faire
**And** si le toggle est désactivé dans Settings, aucun prompt n'apparaît

---

## Epic E6: Export PDF et événements

**Goal** : Permettre les workflows post-event pros (exposants, commerciaux) :
grouper les contacts par événement, exporter en PDF.

### Story E6.1: Page ExportPdf avec multi-sélection

As un **exposant en fin de journée**,
I want **sélectionner les contacts à exporter en PDF**,
So that **je n'envoie pas tout l'historique à mes collègues**.

**Acceptance Criteria:**

**Given** ContactsTab avec 50 contacts d'un événement
**When** je tap "Sélectionner" puis je coche les contacts pertinents
**Then** un compteur en haut affiche "12 sélectionnés"
**And** un bouton "Exporter PDF (12)" me mène à ExportPdfPage
**And** ExportPdfPage rappelle le nombre + permet de configurer les options

### Story E6.2: Génération PDF 1-par-page (layout détaillé)

As un **commercial qui imprime ses leads**,
I want **un PDF où chaque contact prend une page A4**,
So that **j'ai un dossier physique structuré post-event**.

**Acceptance Criteria:**

**Given** 12 contacts sélectionnés et option "1 par page" choisie
**When** je tap "Générer le PDF"
**Then** un PDF A4 de 12 pages est généré via `pdf` package en moins de 5s
**And** chaque page contient : photo (si présente, taille 150x150), nom + prénom en titre, org + job, tels, emails, adresses, date de capture, événement, QR de la carte (option)
**And** le PDF est partageable via `printing.sharePdf()` ou sauvegardable via `file_saver`

### Story E6.3: Génération PDF 2x2 (layout synthétique)

As un **exposant qui veut une vue compacte**,
I want **un PDF 4 contacts par page**,
So that **je consomme moins de papier ou je scrolle moins**.

**Acceptance Criteria:**

**Given** 12 contacts sélectionnés et option "2x2 par page" choisie
**When** je tap "Générer le PDF"
**Then** un PDF A4 de 3 pages est généré (12/4 = 3)
**And** chaque case de 2x2 contient : photo (60x60), nom, org, job, 1 tel, 1 email
**And** date + événement en footer de page

### Story E6.4: Mode événement actif

As un **exposant le matin d'un salon**,
I want **activer un mode événement qui auto-tag tous les scans**,
So that **je n'aie pas à manuellement tagger chaque contact**.

**Acceptance Criteria:**

**Given** aucun événement actif au lancement
**When** j'ouvre More > Events > "Nouvel événement", saisis "Salon Tech Paris 2026", choisis dates, et tap "Activer"
**Then** une bannière sticky "Événement actif: Salon Tech Paris 2026" s'affiche en haut de toutes les pages
**And** chaque scan suivant a son `VCard.event_id` rempli automatiquement
**And** tap sur la bannière ouvre la page de l'événement avec ses contacts captés

### Story E6.5: Désactivation et historique des événements

As un **exposant le soir du dernier jour de salon**,
I want **désactiver l'événement et le retrouver plus tard dans une liste**,
So that **je n'aie pas à le supprimer mais qu'il ne pollue plus le tagging**.

**Acceptance Criteria:**

**Given** un événement actif
**When** je tap sur la bannière > "Désactiver"
**Then** l'événement passe en `is_active = false` mais reste en DB
**And** la bannière disparaît
**And** Events page liste tous les événements (actifs en haut, passés ensuite)
**And** je peux ré-activer un événement passé d'un tap

---

## Epic E7: Onboarding et accessibilité

**Goal** : Premier usage fluide et conformité WCAG AA.

### Story E7.1: Onboarding 3 écrans skippable au premier lancement

As un **nouvel utilisateur qui vient d'installer l'app**,
I want **comprendre en moins de 60 secondes ce que fait EZQRContact**,
So that **je passe en mode "création de ma carte" sans friction**.

**Acceptance Criteria:**

**Given** le tout premier lancement de l'app (`SharedPreferences` n'a pas la clé `onboarding_done`)
**When** l'app démarre
**Then** 3 écrans s'affichent en swipe horizontal : (1) "Échangez vos contacts pros sans compte ni cloud", (2) "Créez votre carte. Personnalisez.", (3) "Scannez. Sauvegardez. Exportez."
**And** un bouton "Passer" en haut à droite skip directement vers EditCard
**And** le bouton "Créer ma carte" sur le 3e écran lance EditCard avec preset minimum (nom, prénom, tel)
**And** une fois fini, `onboarding_done = true` est persisté
**And** au prochain lancement, l'onboarding ne s'affiche plus

### Story E7.2: First meaningful action en moins de 60s

As un **nouvel utilisateur**,
I want **voir mon QR généré moins d'1 minute après l'installation**,
So that **je ressens immédiatement la valeur de l'app**.

**Acceptance Criteria:**

**Given** un user qui vient de finir l'onboarding
**When** il saisit nom + prénom + tel et tap "Save"
**Then** son QR est généré et affiché en moins de 60 secondes cumulés depuis le splash screen (mesure manuelle ou test instrumenté)
**And** un toast positif "Votre carte est prête, partagez-la !" apparaît

### Story E7.3: Semantics et accessibilité WCAG AA

As un **utilisateur de lecteur d'écran (TalkBack / VoiceOver)**,
I want **comprendre ce que fait chaque bouton sans le voir**,
So that **je puisse utiliser EZQRContact comme tout le monde**.

**Acceptance Criteria:**

**Given** l'app actuelle sans Semantics widgets
**When** j'ajoute des `Semantics(label: ...)` sur tous les boutons d'action principaux et le QR (ex: "QR code de votre carte. Double-tap pour partager.")
**Then** TalkBack et VoiceOver lisent correctement les actions
**And** le contraste des textes/boutons est ≥ 4.5:1 sur fond clair (WCAG AA), testé avec Color Contrast Analyzer
**And** les tap targets sont ≥ 48dp

---

## Epic E8: CI/CD et release pipeline

**Goal** : Automatiser test/analyze/build pour réduire la friction des
releases et professionnaliser le repo aux yeux d'un recruteur.

### Story E8.1: Workflow GitHub Actions test+analyze sur PR

(Identique à E1.5, déjà détaillée. Si E1.5 a été faite, cette story est
complétée.)

### Story E8.2: Build APK release sur tag v*

As un **mainteneur qui release**,
I want **qu'un push de tag `vX.Y.Z` déclenche un build APK release**,
So that **je n'aie pas à builder à la main à chaque release**.

**Acceptance Criteria:**

**Given** un tag `v2.0.0` poussé sur le repo
**When** le workflow GitHub Actions `release.yml` se déclenche
**Then** il setup Flutter stable, fait `flutter build apk --release`
**And** l'APK est attaché à la GitHub Release créée pour ce tag
**And** le workflow finit en moins de 15 minutes
**And** le keystore release est stocké en GitHub Secrets (jamais en clair dans le repo)

### Story E8.3: Documentation release process

As un **futur contributeur ou Johan dans 6 mois**,
I want **un fichier `RELEASING.md` qui explique étape par étape la release**,
So that **je n'oublie pas une étape (bump version, tag, push, Play Store upload, iOS upload)**.

**Acceptance Criteria:**

**Given** un repo sans `RELEASING.md`
**When** je crée le fichier décrivant : (1) bump version dans pubspec, (2) merge feature branch, (3) commit "chore(release): vX.Y.Z", (4) tag, (5) push tag, (6) verify CI release passes, (7) upload Play Store track interne, (8) test, (9) promote production, (10) iOS via Xcode/Transporter
**Then** le fichier est référencé depuis CONTRIBUTING.md

---

## Ordre de réalisation suggéré (sprint plan)

1. **Sprint 1** (P0 critique) : E0.1 → E0.2 → E0.3 → E0.4 (préparation OS)
2. **Sprint 2** (P0 foundation) : E1.1 → E1.2 → E1.3 → E1.5 (Drift, lints, commits, CI)
3. **Sprint 3** (P0 vCard) : E2.1 → E2.2 → E2.3 (vCard 3.0 + parser dual)
4. **Sprint 4** (P1 perso) : E3.1 → E3.2 → E3.3 → E3.4 → E3.5 (visuel + photo)
5. **Sprint 5** (P1 scan) : E4.1 → E4.2 → E4.3 → E4.4 → E4.5 → E4.6 (scan + contacts)
6. **Sprint 6** (P1 différenciateurs) : E5.1 → E5.2 → E5.3 → E5.4 (blue ocean)
7. **Sprint 7** (P1 PDF/events) : E6.1 → E6.2 → E6.3 → E6.4 → E6.5 (PDF + events)
8. **Sprint 8** (P2 polish) : E7.1 → E7.2 → E7.3 → E8.2 → E8.3 (onboarding + a11y + release)

Ordre justifié : E0 et E1 sont des pré-requis, E2 doit précéder E5 (parser
dual nécessaire pour X-EZQR-VISUAL), E3/E4 peuvent être parallélisés mais
E3 a moins de dépendances, E5/E6 dépendent de E2-E3-E4.

---

## Sources

- PRD : `prd-ezqrcontact-v2-2026-05-06.md`
- UX : `ux-design-ezqrcontact-v2-2026-05-06.md`
- Architecture : `architecture-ezqrcontact-v2-2026-05-06.md`
- Brief : `product-brief-ezqrcontact-2026-05-06.md`
- Research : `research/domain-pro-contact-exchange-research-2026-05-06.md`
- Project context : `project-context.md`
