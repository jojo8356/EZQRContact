---
stepsCompleted: [1, 2, 3, 4, 5]
inputDocuments:
  - _bmad-output/planning-artifacts/product-brief-ezqrcontact-2026-05-06.md
  - _bmad-output/planning-artifacts/research/domain-pro-contact-exchange-research-2026-05-06.md
  - _bmad-output/project-context.md
workflowType: 'prd'
project_name: EZQRContact
target_version: v2.0.0
user_name: Johan
date: 2026-05-06
status: draft
---

# Product Requirements Document — EZQRContact v2.0

**Auteur :** Johan
**Date :** 2026-05-06
**Version cible :** v2.0.0 (refonte avec repositioning B2B pro)
**Version actuelle :** v1.0.0 (release 2025-11-01)

---

## 1. Vision et objectifs

### Vision V2
EZQRContact devient l'app mobile **opensource MIT** de référence pour
l'échange de contacts pros en face-à-face en EU francophone, en répondant à
4 standards d'usage validés par la recherche domain (commerciaux B2B,
exposants salons, recruteurs, freelances).

### Objectifs business (non commerciaux)
- **OBJ-1** : 500+ téléchargements Play Store cumulés à 6 mois post-release.
- **OBJ-2** : 50+ stars GitHub à 6 mois.
- **OBJ-3** : 3+ contributeurs externes (PRs mergées) à 6 mois.
- **OBJ-4** : projet présentable comme item portfolio en entretiens
  alternance/stage (Johan).

### Non-objectifs explicites
- Pas de monétisation, pas de tier Pro.
- Pas de support hardware NFC (out of scope).
- Pas de sync cloud / multi-device.

---

## 2. Personas et use cases

### P1 — Le Commercial B2B (priorité haute)
**Use case** : 5-15 RDV / semaine, échanger en moins de 10s, retrouver le
contact, exporter en bulk pour CRM en fin de journée.

### P2 — L'Exposant en salon (priorité haute)
**Use case** : 50-200 contacts captés / jour, export propre fin de journée
sans login, pas de transit cloud, < 30s pour générer le PDF.

### P3 — Le Recruteur / Talent acquisition
**Use case** : forums étudiants, capter candidat avec photo + LinkedIn +
tel sans pinger LinkedIn, retrouver visuellement 2 semaines après.

### P4 — Le Freelance / Consultant indépendant
**Use case** : afterworks, conférences, BNI, carte qui reflète son
identité visuelle perso (couleurs, logo).

---

## 3. Functional Requirements (FR)

### FR-1 — Génération de carte personnelle
- **FR-1.1** : L'utilisateur peut créer une VCard personnelle (saisie nom,
  prénom, org, job, tel pro/perso, email, adresse pro/perso, photo).
- **FR-1.2** : La VCard est générée au format **vCard 3.0** par défaut
  (compat universelle iCloud/Google/Outlook/Android/iPhone).
- **FR-1.3** : Toggle optionnel pour générer en vCard 4.0 (mode "compat
  moderne uniquement").
- **FR-1.4** : Le QR code intègre la VCard complète (via standard
  `BEGIN:VCARD ... END:VCARD`).

### FR-2 — Personnalisation visuelle de la carte
- **FR-2.1** : L'utilisateur peut choisir une couleur primaire pour son QR.
- **FR-2.2** : L'utilisateur peut ajouter un logo au centre du QR
  (image upload ou pick depuis bibliothèque).
- **FR-2.3** : L'utilisateur peut choisir un layout/template pour la
  card affichée (3 templates min pour V2).
- **FR-2.4** : Aperçu en temps réel de la card pendant l'édition.

### FR-3 — Photo de profil dans la VCard
- **FR-3.1** : L'utilisateur peut ajouter une photo de profil via
  `image_picker` (camera ou galerie).
- **FR-3.2** : La photo est resized automatiquement à 720x720 max
  (Android Jelly Bean+) ou 256x256 (Android plus anciens), format JPEG
  qualité 85%.
- **FR-3.3** : La photo est encodée en base64 dans la VCard 3.0 sous le
  format `PHOTO;ENCODING=b;TYPE=JPEG:`.
- **FR-3.4** : Taille totale du fichier vCard ne doit pas dépasser
  **200KB** (pour rester sous la limite iOS 224KB avec marge).
- **FR-3.5** : Si la photo dépasse, recompresser progressivement (qualité
  75% → 65% → 55%) jusqu'à passer sous la limite.

### FR-4 — Scan d'un QR code reçu
- **FR-4.1** : L'utilisateur peut scanner un QR code via la caméra
  (`mobile_scanner`).
- **FR-4.2** : L'utilisateur peut importer un QR code depuis une image
  de la galerie (`flutter_qrcode_analysis`).
- **FR-4.3** : Le QR scanné est parsé : si VCard détectée, sauvegarde
  automatique en local DB.
- **FR-4.4** : Si non-VCard, fallback "texte simple" (table SimpleQR).

### FR-5 — Capture de la config visuelle du QR scanné (différenciateur)
- **FR-5.1** : Lorsqu'un QR VCard est scanné, l'app extrait sa config
  visuelle (couleur dominante, présence d'un logo, layout).
- **FR-5.2** : La config visuelle est stockée à côté de la VCard (table
  `VCard.visual_config TEXT JSON`).
- **FR-5.3** : Quand l'utilisateur consulte un contact capté, la card
  s'affiche avec la config visuelle de l'expéditeur original.

### FR-6 — Échange réciproque optionnel
- **FR-6.1** : Toggle dans paramètres : "Proposer mon QR en retour quand
  on me scanne".
- **FR-6.2** : Si activé, après réception d'un scan, l'app affiche un
  prompt "Partager votre carte en retour à [Nom] ?" avec un QR de
  retour.
- **FR-6.3** : Pas de mécanique synchronisée cloud (chacun scanne le QR
  de l'autre, pas de "request/accept" comme Whova).

### FR-7 — Export PDF des contacts captés
- **FR-7.1** : L'utilisateur peut sélectionner N contacts et exporter en
  PDF (via package `pdf` + `printing`).
- **FR-7.2** : Filtres : par date, par tag/événement.
- **FR-7.3** : PDF généré contient : nom, prénom, org, job, tel(s),
  email, photo si présente, date de capture. 1 contact par page ou
  layout 2x2 par page (toggleable).
- **FR-7.4** : Le PDF est sauvegardé via `file_saver` ou partagé via
  `printing`.
- **FR-7.5** : Génération en local, jamais de transit cloud.

### FR-8 — Tag/groupement événement
- **FR-8.1** : L'utilisateur peut nommer un "événement" (ex: "Salon Tech
  Paris 2026") et grouper les contacts captés sous ce tag.
- **FR-8.2** : Mode "événement actif" : tous les scans suivants taggés
  jusqu'à désactivation.
- **FR-8.3** : Liste des événements consultable depuis un onglet dédié.

### FR-9 — Sauvegarde dans contacts du téléphone
- **FR-9.1** : L'utilisateur peut envoyer un contact capté vers les
  contacts natifs du téléphone (`flutter_contacts`).
- **FR-9.2** : Si un contact du même nom/prénom existe déjà, proposer 3
  actions : Replace / Clone / Fill empty fields (existant en v1, à
  préserver).

### FR-10 — Historique des scans
- **FR-10.1** : Onglet historique listant tous les scans VCard et
  SimpleQR, triés par date desc.
- **FR-10.2** : Soft delete (existant), avec corbeille consultable.
- **FR-10.3** : Recherche par nom dans l'historique.

### FR-11 — Internationalisation
- **FR-11.1** : Support FR + EN (existant).
- **FR-11.2** : Détection automatique de la langue du device.
- **FR-11.3** : Toggle manuel de la langue dans les paramètres.

### FR-12 — Onboarding
- **FR-12.1** : Onboarding 3 écrans max au premier lancement.
- **FR-12.2** : Premier écran utile (= création de la première carte) en
  moins de 60 secondes après installation.
- **FR-12.3** : Skip-able onboarding (lien "Passer" en haut à droite).
- **FR-12.4** : Une fois fait, plus jamais réaffiché.

---

## 4. Non-Functional Requirements (NFR)

### NFR-1 — Performance
- **NFR-1.1** : Temps d'ouverture de l'app < 2s sur device milieu de
  gamme (Android 10+).
- **NFR-1.2** : Génération du QR < 500ms après saisie.
- **NFR-1.3** : Scan d'un QR détecté < 1s.
- **NFR-1.4** : Export PDF de 50 contacts < 5s.

### NFR-2 — Compatibilité
- **NFR-2.1** : Android 7.0+ (API 24+).
- **NFR-2.2** : iOS 13+ (couvre 95% du parc actif).
- **NFR-2.3** : `compileSdkVersion = 35` (contrainte permission_handler 12).

### NFR-3 — Privacy / GDPR
- **NFR-3.1** : Aucune donnée transite hors du device (sauf si l'user
  partage explicitement un PDF/contact via OS share sheet).
- **NFR-3.2** : Aucun compte requis. Aucun pipeline analytics tiers.
- **NFR-3.3** : Permission demandée uniquement avant usage (caméra avant
  scan, contacts avant export, photo avant prise de profile pic).

### NFR-4 — Qualité code
- **NFR-4.1** : Lint via `very_good_analysis` (migration depuis
  `flutter_lints`).
- **NFR-4.2** : Tests unitaires sur logique pure (`vcard.dart`,
  `db.dart`) avec couverture > 70% sur ces modules.
- **NFR-4.3** : Pas de `print()` non gardé par `kDebugMode`.

### NFR-5 — Documentation
- **NFR-5.1** : README structuré (titre, pitch, screenshots, install,
  features, stack, license).
- **NFR-5.2** : LICENSE MIT à la racine.
- **NFR-5.3** : CONTRIBUTING.md décrivant comment contribuer.
- **NFR-5.4** : Issues GitHub taggées `good first issue` pour onboarding
  contributeurs.

### NFR-6 — Maintenabilité
- **NFR-6.1** : Migration sqflite → Drift (codegen, type-safety).
- **NFR-6.2** : Schema versioning explicite (`schemaVersion` dans
  `QRDatabase`), avec migration depuis v1 (DB existante des users).
- **NFR-6.3** : Conventional Commits + semantic versioning.

### NFR-7 — Accessibilité
- **NFR-7.1** : Contraste WCAG AA min sur les éléments d'UI critiques.
- **NFR-7.2** : Tous les boutons d'action ont un label sémantique
  (`Semantics` widget Flutter).
- **NFR-7.3** : Mode sombre supporté (existant en v1, à préserver).

---

## 5. Success Criteria

### Critères techniques (validables avec metrics in-app)
- 95%+ d'imports vCard réussis (instrumenter le parsing pour mesurer
  les échecs).
- 0 crash sur les use cases golden path après 100 sessions.
- Migration de 100% des users v1 vers v2 sans perte de données.

### Critères usage (validables via Play Store / GitHub)
- 500+ téléchargements Play Store à 6 mois.
- 50+ stars GitHub à 6 mois.
- 3+ contributeurs externes à 6 mois.

### Critères marché (validables via observation)
- Au moins 1 mention dans `awesome-flutter` ou liste équivalente.
- Au moins 2 articles/posts externes parlant du projet.
- Au moins 1 user pro identifiable via review/feedback.

---

## 6. Scope V2.0

### In scope
Les 12 FR + 7 NFR ci-dessus.

### Out of scope (V2.0, à reconsidérer V3)
- Apple Wallet / Google Wallet integration.
- Mode "lecture publique" (URL partagée vers carte web).
- Sync entre appareils (WebRTC peer-to-peer).
- Export CSV.
- Intégration directe avec CRM (HubSpot, Pipedrive).

### Out of scope explicitement refusé
- Hardware NFC (vente de cartes physiques).
- Account / signup.
- Cloud sync.
- Analytics dashboard.
- AR / blockchain / voice features.

---

## 7. Dépendances et risques

### Dépendances clés
- `pdf` + `printing` (PDF generation, opensource).
- Migration de `flutter_lints` → `very_good_analysis`.
- Migration de `sqflite` → `drift` + `drift_sqflite` (transition).
- Maintien de `permission_handler ^12`, `flutter_contacts ^1.1.9+2`,
  `mobile_scanner ^6`, `qr_flutter ^4`.

### Risques techniques
- **R-1** : compat vCard 3.0 sur edge cases iOS (X-properties custom
  pourraient être perdues). Mitigation : tests sur 5+ devices.
- **R-2** : Migration DB v1 → v2 sans perte. Mitigation : tests
  d'intégration avec un dump v1 réel + backup auto avant migration.
- **R-3** : Tailles de photo qui font sauter la limite 200KB après
  encoding base64. Mitigation : recompression progressive (FR-3.5).

### Risques produit
- **R-4** : adoption insuffisante (< 50 stars à 6 mois). Mitigation :
  post Discord Smaug + listes awesome-flutter + post LinkedIn perso
  Johan.
- **R-5** : copies par concurrents si la feature "config visuelle
  préservée" prend. Mitigation : licensing MIT mais leadership de
  feature en restant rapide sur les itérations.

---

## 8. Sources

- [pdf package pub.dev](https://pub.dev/packages/pdf)
- [printing package pub.dev](https://pub.dev/packages/printing)
- [Flutter PDF tutorial — ASOasis 2026](https://asoasis.tech/articles/2026-04-12-2053-flutter-pdf-generation-viewing-tutorial/)
- [Mobile App Onboarding 2026 — Plotline](https://www.plotline.so/blog/mobile-app-onboarding-examples)
- [9 Best Digital Business Card Apps — SPOTIO](https://spotio.com/blog/digital-business-card-apps/)
- Brief produit : `_bmad-output/planning-artifacts/product-brief-ezqrcontact-2026-05-06.md`
- Research domaine : `_bmad-output/planning-artifacts/research/domain-pro-contact-exchange-research-2026-05-06.md`
