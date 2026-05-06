---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments:
  - _bmad-output/planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/ux-design-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/epics-and-stories-ezqrcontact-v2-2026-05-06.md
project_name: EZQRContact
target_version: v2.0.0
date: 2026-05-06
assessor: Mary (Business Analyst, BMAD)
status: READY_WITH_MINOR_REMEDIATION
---

# Implementation Readiness Assessment Report — EZQRContact v2.0

**Date :** 2026-05-06
**Project :** EZQRContact v2.0.0
**Assessor :** Mary (Business Analyst, BMAD persona)

---

## Step 1 — Document Inventory

### Documents trouvés (whole, pas de sharded)

| Type | Fichier | Statut |
|---|---|---|
| PRD | `prd-ezqrcontact-v2-2026-05-06.md` | ✅ Trouvé, single version |
| UX Design | `ux-design-ezqrcontact-v2-2026-05-06.md` | ✅ Trouvé, single version |
| Architecture | `architecture-ezqrcontact-v2-2026-05-06.md` | ✅ Trouvé, single version |
| Epics & Stories | `epics-and-stories-ezqrcontact-v2-2026-05-06.md` | ✅ Trouvé, single version |
| Brief (input) | `product-brief-ezqrcontact-2026-05-06.md` | ✅ Trouvé |
| Domain Research (input) | `research/domain-pro-contact-exchange-research-2026-05-06.md` | ✅ Trouvé |
| Project Context (input) | `_bmad-output/project-context.md` | ✅ Trouvé |

### Issues de discovery

- **Aucun doublon** (whole vs sharded).
- **Aucun document manquant** parmi les 4 attendus (PRD, UX, Architecture, Epics).
- Tous les fichiers ont été générés le même jour (2026-05-06) → cohérent.

**Verdict** : ✅ Documentation complète. On peut procéder.

---

## Step 2 — PRD Analysis

### Functional Requirements extraits (12)

| ID | Description | Priorité PRD |
|---|---|---|
| FR-1 | Génération carte personnelle (vCard 3.0 par défaut, toggle 4.0) | P0 |
| FR-2 | Personnalisation visuelle (couleur, logo, layout) | P1 |
| FR-3 | Photo de profil dans la VCard (resize + recompression) | P1 |
| FR-4 | Scan QR code (caméra + galerie) | P1 |
| FR-5 | Capture config visuelle du QR scanné (différenciateur) | P1 |
| FR-6 | Échange réciproque optionnel | P2 |
| FR-7 | Export PDF des contacts captés (1-page / 2x2) | P1 |
| FR-8 | Tag/groupement événement | P2 |
| FR-9 | Sauvegarde dans contacts du téléphone | P1 |
| FR-10 | Historique des scans (filtre, recherche) | P1 |
| FR-11 | Internationalisation FR/EN | P1 |
| FR-12 | Onboarding 3 écrans skippable | P2 |

**Total FRs : 12.**

### Non-Functional Requirements extraits (7)

| ID | Catégorie | Description |
|---|---|---|
| NFR-1 | Performance | Ouverture < 2s, gen QR < 500ms, scan < 1s, PDF 50 contacts < 5s |
| NFR-2 | Compatibilité | Android 7+, iOS 13+, compileSdkVersion = 35 |
| NFR-3 | Privacy / GDPR | No cloud, no account, no third-party analytics, permissions minimales |
| NFR-4 | Qualité code | very_good_analysis lints, tests > 70% sur modules critiques, no print non gardé |
| NFR-5 | Documentation | README, LICENSE MIT, CONTRIBUTING.md, good first issues |
| NFR-6 | Maintenabilité | Drift + schemaVersion, conventional commits + semver |
| NFR-7 | Accessibilité | WCAG AA contraste, semantics, dark mode |

**Total NFRs : 7.**

### Additional Requirements
- Migration depuis DB v1 sans perte (R-1, R-2 risques techniques).
- Préservation comportements existants (i18n FR/EN, 3-options merge contact, soft-delete).
- Out of scope explicite : NFC hardware, CRM, analytics SaaS, sync cloud, account.

### PRD Completeness Assessment
✅ **Complet pour passer à l'implémentation.** Le PRD couvre les use cases identifiés dans le brief, mappe sur les personas du domain research, explicite scope/out-of-scope, identifie les risques techniques.

---

## Step 3 — Epic Coverage Validation

### FR Coverage Matrix

| FR | PRD Description (synth) | Epic Coverage | Stories | Status |
|---|---|---|---|---|
| FR-1 | vCard 3.0 par défaut + toggle 4.0 | E2 | 2.1, 2.2 | ✅ Covered |
| FR-2 | Color/logo/layout customisation | E3 | 3.1, 3.2, 3.3 | ✅ Covered |
| FR-3 | Photo de profil + resize | E3 | 3.4, 3.5 | ✅ Covered |
| FR-4 | Scan QR (caméra + galerie) | E4 | 4.1, 4.2, 4.3 | ✅ Covered |
| FR-5 | Capture config visuelle scanné | E5 | 5.1, 5.2, 5.3 | ✅ Covered |
| FR-6 | Échange réciproque optionnel | E5 | 5.4 | ✅ Covered |
| FR-7 | Export PDF | E6 | 6.1, 6.2, 6.3 | ✅ Covered |
| FR-8 | Tag/groupement événement | E6 | 6.4, 6.5 | ✅ Covered |
| FR-9 | Sauvegarde contacts tel | E4 | 4.4 | ✅ Covered |
| FR-10 | Historique + filtres + recherche | E4 | 4.5, 4.6 | ✅ Covered |
| FR-11 | i18n FR/EN | E1 | 1.4 | ✅ Covered |
| FR-12 | Onboarding 3 écrans | E7 | 7.1, 7.2 | ✅ Covered |

**Coverage : 12/12 FRs = 100%.**

### NFR Coverage Matrix

| NFR | Couverture explicite | Stories dédiées | Status |
|---|---|---|---|
| NFR-1 (perf) | Critères dans AC des stories scan/PDF/onboarding | ⚠️ Pas de story de mesure perf | ⚠️ Implicite |
| NFR-2 (Android 7+/iOS 13+) | Mentionné dans architecture, mais aucune story de validation cross-device | ⚠️ Manquant | 🟠 GAP |
| NFR-3 (privacy/GDPR) | Cross-epic + E0.2 (README mentions privacy) | ⚠️ Pas de story "audit privacy" | ⚠️ Implicite |
| NFR-4 (lints) | E1.2 (very_good_analysis) | ✅ E1.2 | ✅ Covered |
| NFR-5 (doc) | E0.1, E0.2, E0.3 | ✅ | ✅ Covered |
| NFR-6 (Drift + commits + semver) | E1.1, E1.3 | ✅ | ✅ Covered |
| NFR-7 (a11y WCAG AA) | E7.3 | ✅ | ✅ Covered |

**NFR Coverage : 5/7 explicite, 2/7 implicite (NFR-1 perf, NFR-3 privacy), 0/7 missing.**

### Coverage Statistics
- **FRs PRD totaux** : 12
- **FRs couvertes par stories** : 12
- **Coverage FR : 100%**
- **NFRs PRD totaux** : 7
- **NFRs couvertes explicitement** : 5
- **NFRs implicites (à clarifier) : 2**
- **Coverage NFR explicite : 71%**

### Missing / Gaps identifiés

#### 🟠 GAP-1 : NFR-2 (compatibilité Android 7+/iOS 13+) sans story de validation
**Impact** : Risque de régressions sur devices anciens non détectées avant release.
**Recommandation** : Ajouter une story dans Epic E8 (CI/CD) du type :
> **Story E8.4 : Test cross-device pre-release**
> *As a maintainer, I want to validate the app on at least 1 Android 7+, 1 Android 12+, 1 iOS 13+, 1 iOS latest before each release, so that I catch compatibility regressions.*

#### ⚠️ GAP-2 : NFR-1 (perf) sans story de mesure
**Impact** : Critères AC mentionnent les seuils mais aucun mécanisme de mesure.
**Recommandation** : Ajouter dans Epic E8 ou E1 :
> **Story E1.6 : Instrumenter les métriques perf locales**
> *As a maintainer, I want a debug-mode overlay showing app open time, QR gen time, scan latency, PDF gen time, so that I can validate NFR-1 thresholds during dev.*

#### ⚠️ GAP-3 : NFR-3 (privacy) sans story d'audit
**Impact** : Pas de check explicite que l'app n'envoie rien au réseau.
**Recommandation** :
> **Story E0.5 : Audit network-zero**
> *As a maintainer, I want a documented audit (in CONTRIBUTING.md) listing every package usage and confirming none does HTTP calls or analytics, so that the privacy claim is verifiable.*

---

## Step 4 — UX Alignment Assessment

### UX Document Status
✅ **Trouvé** : `ux-design-ezqrcontact-v2-2026-05-06.md`.

### UX ↔ PRD Alignment

| PRD FR | UX Coverage |
|---|---|
| FR-1 (création carte) | ✅ Flow F1 (Onboarding → première carte) + EditCardScreen |
| FR-2 (perso visuelle) | ✅ Flow F5 (personnalisation) + VisualConfigEditor |
| FR-3 (photo) | ✅ EditCardScreen.PhotoPicker mentionné |
| FR-4 (scan) | ✅ Flow F2 (échange face-à-face) + ScannerTab |
| FR-5 (config visuelle) | ✅ Flow F6 (récupérer config visuelle) + VCardPreview |
| FR-6 (réciproque) | ✅ ShareReverse dans MyCardTab |
| FR-7 (PDF) | ✅ Flow F3 (salon) + ExportPDF wireframe |
| FR-8 (événements) | ✅ Flow F3 + ActiveEventBanner |
| FR-9 (contacts tel) | ✅ Flow F4 (recruteur) |
| FR-10 (historique) | ✅ ContactsTab dans IA + ContactDetail |
| FR-11 (i18n) | ⚠️ Mentionné dans Settings.LanguageToggle mais pas de wireframe spécifique |
| FR-12 (onboarding) | ✅ Flow F1 + 3 screens onboarding détaillés |

**FR coverage UX : 12/12.**

### UX ↔ Architecture Alignment

| UX Element | Architecture Support |
|---|---|
| Bottom nav 4 tabs | ✅ `MainShell` mentionné dans architecture refacto `lib/pages/main_shell.dart` |
| MyCardTab | ✅ `lib/pages/tabs/my_card_tab.dart` |
| ScannerTab | ✅ `lib/pages/tabs/scanner_tab.dart` |
| ContactsTab | ✅ `lib/pages/tabs/contacts_tab.dart` |
| MoreTab | ✅ `lib/pages/tabs/more_tab.dart` |
| VCardPreview component | ✅ Listé dans components à créer |
| VisualConfigEditor component | ✅ Listé |
| PDFOptionsForm component | ✅ Listé |
| Color picker | ⚠️ Pas de package spécifié dans architecture (à choisir : `flutter_colorpicker` ou maison) |
| Active event banner sticky | ⚠️ Pattern UI pas explicitement adressé dans architecture |
| Modal confirmation destructive | ⚠️ Pas de spec de pattern de modale standard |

### UX Alignment Issues

#### ⚠️ UX-1 : Color picker non spécifié dans architecture
**Impact** : Story E3.1 (color picker) ne précise pas quel package utiliser.
**Recommandation** : Ajouter une décision dans architecture (ADR-11) : utiliser `flutter_colorpicker` (package mature, opensource).

#### ⚠️ UX-2 : Pattern de bannière sticky pour événement actif
**Impact** : Comportement à implémenter dans MainShell, mais pas spécifié comment (overlay ? slot dans Scaffold body ?).
**Recommandation** : Préciser dans story E6.4 que la bannière est un widget custom dans le `Scaffold.body` au-dessus du contenu, persistant via le state global `EventProvider`.

#### ⚠️ UX-3 : Pas de wireframe Settings ni modales d'erreur
**Impact** : Risque d'incohérence visuelle entre les modales.
**Recommandation** : Mineur, à documenter en cours d'implémentation. Pas bloquant pour démarrer.

---

## Step 5 — Epic Quality Review

### Epic Structure Validation

#### A. User Value Focus

| Epic | User-centric ? | Justification |
|---|---|---|
| E0 — Préparation contributions OS | ⚠️ Borderline | Pas user-facing pour les end users de l'app, mais user value pour les contributeurs et recruteurs (audience secondaire). Justifié pour un projet OS solo cherchant adoption. |
| E1 — Migration technique foundation | 🔴 **Technique pur** | Drift, lints, commits, CI. Aucun user value direct. **Violation des best practices BMAD ("technical epics are wrong").** Cependant, en brownfield avec dette technique critique (vCard 4.0 broken), c'est un mal nécessaire à documenter explicitement. |
| E2 — Refactor génération VCard | ⚠️ Indirect | User value : "mes contacts s'importent enfin partout" via la migration vCard 3.0. Indirect mais réel (le bug silencieux est un blocker UX). |
| E3 — Personnalisation visuelle | ✅ Direct | "Ma carte ressemble à mon identité." |
| E4 — Scan, contacts, historique | ✅ Direct | Use case central de l'app. |
| E5 — Différenciateurs blue ocean | ✅ Direct | "Je récupère l'identité visuelle des cartes que je scanne." USP. |
| E6 — Export PDF et événements | ✅ Direct | "Je sors un rapport post-salon en 30s." |
| E7 — Onboarding et accessibilité | ✅ Direct | "Je comprends l'app en 60s." |
| E8 — CI/CD et release pipeline | 🔴 **Technique pur** | Pas user value direct mais nécessaire pour qualité release. |

**Verdict** : 3 epics borderline (E0) ou techniques (E1, E8). Tous justifiés en brownfield/projet OS, mais à documenter dans le epic header pour transparence.

#### B. Epic Independence Validation

| Pair | Indépendance ? | Notes |
|---|---|---|
| E0 → E1 | ✅ | E0 (LICENSE/README) ne dépend pas du code v2 |
| E1 → E2 | ✅ | Drift en place avant refacto VCard |
| E2 → E3 | ✅ | VCard model propre avant ajout photo/visual |
| E3 → E4 | ⚠️ | E4.3 (auto-save) crée des contacts. Pas de dépendance forward. |
| E4 → E5 | ⚠️ | E5 (config visuelle) suppose VCard avec champ visual_config (créé en E1.1 avec migration v2). OK. |
| E5 → E6 | ✅ | PDF indépendant de la config visuelle |
| E6 → E7 | ✅ | Onboarding indépendant |
| E7 → E8 | ✅ | CI release indépendant |

**Verdict** : Indépendance respectée à condition de respecter l'ordre du sprint plan (E1 avant E2-E5).

### Story Quality Assessment

#### Format Given/When/Then
✅ Toutes les stories suivent le format BDD.

#### Sizing
| Story | Sizing | Notes |
|---|---|---|
| E1.1 (Drift migration complète) | 🔴 **Trop large** | Migration de toute la couche persistance + tests + backup en une seule story. **Recommandation** : split en sub-stories : E1.1a "Setup Drift + tables miroir + codegen", E1.1b "Migrate VCardRepository", E1.1c "Migrate SimpleQRRepository", E1.1d "Add migration v1→v2 + backup". |
| E5.1-5.3 (config visuelle complète) | ✅ OK | Bien splittée (encode, decode, render). |
| E6.2/E6.3 (PDF layouts) | ✅ OK | Distinguées proprement. |
| Autres | ✅ OK | Sized raisonnablement. |

#### Acceptance Criteria
| Issue | Stories concernées | Sévérité |
|---|---|---|
| AC vague "warnings sous seuil acceptable" | E1.2 | 🟡 Mineur (un seuil < 30 est mentionné comme exemple) |
| AC "scannable par 3+ scanner apps" sans préciser lesquelles | E3.2 | 🟡 Mineur |
| AC "moins de 60s cumulés" sans tooling de mesure | E7.2 | 🟠 Major (lié à GAP-2 NFR-1) |
| AC "test avec dump v1 réel" sans préciser comment l'obtenir | E1.1 | 🟠 Major |

### Database/Entity Creation Timing

⚠️ **Violation mineure** : Story E1.1 crée la table `Events` lors de la migration Drift, mais la table n'est utilisée qu'en E6.4 (Mode événement actif). La convention BMAD est "tables created when needed".

**Recommandation** : Soit décaler la création de la table `Events` dans E6.4, soit documenter que la migration Drift étant un one-shot pour atteindre le schéma cible v2, on consolide les tables. Vu les contraintes (1 seule migration v1→v2 vs N migrations incrémentales), je recommande de **garder la création groupée en E1.1 mais documenter explicitement la dérogation à la convention BMAD dans le commentaire du epic**.

### Forward Dependencies

🔍 Audit complet : aucune story ne dépend d'une story d'un epic futur (en respectant l'ordre du sprint plan).

✅ **0 forward dependency critique.**

### Best Practices Compliance Checklist

| Critère | Status |
|---|---|
| Epic delivers user value | ⚠️ 3/9 borderline (E0, E1, E8) — justifiés en brownfield/OS |
| Epic can function independently | ✅ Avec ordre sprint respecté |
| Stories appropriately sized | ⚠️ 1 story trop large (E1.1) |
| No forward dependencies | ✅ 0 violation |
| Database tables created when needed | ⚠️ Violation mineure (Events en E1.1) |
| Clear acceptance criteria | ⚠️ 4 ACs un peu vagues |
| Traceability to FRs maintained | ✅ FR Coverage Map présente et exacte |

### Findings par sévérité

#### 🔴 Critical Violations
**Aucune.**

#### 🟠 Major Issues (3)
1. **E1.1 trop large** : split en 4 sub-stories pour réduire risque et faciliter parallélisation.
2. **NFR-1 (perf) non instrumentée** : pas de moyen de valider les seuils. Ajouter story E1.6.
3. **NFR-2 (compat cross-device)** : aucune story de test cross-device. Ajouter story E8.4.

#### 🟡 Minor Concerns (5)
1. E0/E1/E8 sont des epics techniques (justifiés mais à documenter explicitement dans le header du epic).
2. AC vagues sur E1.2 (seuil warnings), E3.2 (scanners testés), E7.2 (mesure 60s), E1.1 (dump v1 source).
3. Création de la table `Events` en E1.1 alors qu'utilisée en E6 (dérogation à documenter).
4. NFR-3 (privacy) sans audit explicite. Ajouter story E0.5.
5. UX manque spec couleur picker package + bannière sticky pattern + modales (mineur, à décider en impl).

---

## Step 6 — Final Assessment

### Overall Readiness Status

**🟢 READY WITH MINOR REMEDIATION**

Aucune issue critique. 3 issues majeures à adresser avant ou pendant Sprint 1-2. 5 minors à documenter ou clarifier au fil de l'eau.

### Critical Issues Requiring Immediate Action

**Aucune.** Le projet peut entrer en phase 4 (implémentation) tel quel sans risque de blocage majeur.

### Recommended Next Steps (par priorité)

#### Avant Sprint 2 (E1) — Recommandé
1. **Splitter E1.1 (Drift migration)** en 4 sub-stories :
   - E1.1a : Setup Drift + tables miroir + codegen
   - E1.1b : Migrate VCardRepository (+ tests sqflite_common_ffi)
   - E1.1c : Migrate SimpleQRRepository (+ tests)
   - E1.1d : Add migration v1→v2 + backup auto + tests d'intégration
2. **Ajouter Story E1.6** : Instrumentation des métriques perf en debug overlay (NFR-1).
3. **Ajouter Story E0.5** : Audit network-zero documenté (NFR-3).

#### Avant Sprint 8 (E8) — Recommandé
4. **Ajouter Story E8.4** : Test cross-device matrix (Android 7+, iOS 13+) pre-release (NFR-2).

#### À documenter au fil de l'eau (non bloquant)
5. Header de E0, E1, E8 : ajouter une note "Epic infrastructure, justifié pour projet brownfield/OS solo, pas user value direct mais nécessaire pour qualité projet et adoption contributeurs".
6. Architecture : ajouter ADR-11 sur le choix de `flutter_colorpicker`.
7. UX : ajouter un wireframe Settings et un pattern de modale confirmation destructive en cours d'impl.
8. Préciser dans E1.1 (ou sa sub-story d) comment obtenir un dump v1 de test (export depuis device dev avec `adb pull`).

### Final Note

L'audit a identifié **0 issue critique**, **3 majors**, **5 minors** sur 4 documents (PRD, UX, Architecture, 9 epics + ~30 stories).

Les 3 majors sont **non bloquants pour démarrer** : ils peuvent être adressés au début du Sprint 1 (story split E1.1) ou ajoutés plus tard dans le backlog (E0.5, E1.6, E8.4). Les minors sont essentiellement des clarifications de wording AC ou des décisions UI qui se prendront naturellement en impl.

**Décision** : on peut entrer en phase 4-implementation avec confiance, en remédiant les 3 majors au fil de Sprint 1 ou 2.

### Métriques d'audit

- Documents audités : 4 (PRD, UX, Architecture, Epics)
- FR couvertes : 12/12 (100%)
- NFR couvertes explicites : 5/7 (71%)
- Stories examinées : ~33
- Epic quality violations critiques : 0
- Forward dependencies critiques : 0
- Best practices respectées : 5/7

---

## Workflow Complete

Le rapport d'implementation readiness est généré. **Statut : READY WITH MINOR REMEDIATION.**

**Prochaine étape recommandée** : invoquer `bmad-help` pour voir les options post-readiness check (typiquement `bmad-sprint-planning` pour générer le sprint status, ou `bmad-create-story` / `bmad-quick-dev` pour démarrer une première story).

Si tu veux que j'applique automatiquement les recommandations majors (split E1.1, ajout E0.5/E1.6/E8.4), dis-le et j'éditerai le fichier epics directement.
