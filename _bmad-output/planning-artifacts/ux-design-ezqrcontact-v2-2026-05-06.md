---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/product-brief-ezqrcontact-2026-05-06.md
project_name: EZQRContact
target_version: v2.0.0
user_name: Johan
date: 2026-05-06
status: draft
---

# UX Design Specification — EZQRContact v2.0

**Auteur :** Johan
**Date :** 2026-05-06
**Version cible :** v2.0.0

---

## 1. Principes UX directeurs

Inspirés des benchmarks (Wave 2min onboarding, Blinq G2 #1 2026, Plotline
mobile onboarding 2026) :

1. **First meaningful action en moins de 60s** post-installation.
2. **3-5 écrans onboarding max**, skippable.
3. **Minimum d'info avant la première action** (juste nom + tel suffit
   pour générer un QR utile).
4. **Action principale de chaque écran ≤ 1 tap** depuis l'écran
   d'accueil.
5. **Pas de modale qui recouvre 100% de l'écran** sauf onboarding ou
   confirmation destructive.
6. **Feedback immédiat** après chaque action (toast via `toastification`,
   pattern existant).
7. **Mode sombre** au choix de l'utilisateur, suit OS par défaut.

---

## 2. Information Architecture

### Navigation principale (bottom nav, 4 onglets)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│          [Contenu de l'onglet actif]            │
│                                                 │
│                                                 │
├─────────────────────────────────────────────────┤
│  [Ma Carte]  [Scanner]  [Contacts]  [Plus]      │
└─────────────────────────────────────────────────┘
```

| Onglet | Rôle | Action principale |
|---|---|---|
| **Ma Carte** | Affiche le QR de l'user | Tap → afficher QR plein écran pour partage |
| **Scanner** | Lance la caméra | Bouton flottant pour importer image |
| **Contacts** | Historique des scans | Tap contact → détail + actions |
| **Plus** | Settings, événements, export, langue, mode sombre | Liste de sous-écrans |

### Hiérarchie d'écrans

```
Root
├── Onboarding (1er lancement uniquement, 3 écrans)
├── MainShell (4 onglets)
│   ├── MyCardTab
│   │   ├── CardDisplay (QR plein écran)
│   │   ├── EditCardScreen
│   │   │   ├── BasicInfoForm
│   │   │   ├── PhotoPicker
│   │   │   └── VisualCustomization
│   │   └── ShareReverse (échange réciproque)
│   ├── ScannerTab
│   │   ├── CameraScanner
│   │   ├── ImportFromGallery
│   │   └── ScanResult (preview avant save)
│   ├── ContactsTab
│   │   ├── ContactsList
│   │   ├── ContactDetail
│   │   ├── EventFilter
│   │   └── ExportPDF (multi-sélection + options)
│   └── MoreTab
│       ├── Events (gestion des tags événement)
│       ├── ActiveEventBanner (sticky si event actif)
│       ├── Settings
│       │   ├── LanguageToggle
│       │   ├── ThemeToggle
│       │   ├── VCardVersionToggle (3.0 / 4.0)
│       │   └── ReciprocalToggle
│       ├── Trash (corbeille soft-delete)
│       └── About + License
```

---

## 3. User flows critiques

### Flow F1 — Premier usage (onboarding → première carte)

```
[Install] → [Lancement]
              ↓
       [Onboarding 1/3]: "Échangez vos contacts pros sans
                        compte, sans cloud."
              ↓ Suivant
       [Onboarding 2/3]: "Créez votre carte. Personnalisez."
              ↓ Suivant
       [Onboarding 3/3]: "Scannez. Sauvegardez. Exportez."
              ↓ "Créer ma carte"
       [EditCardScreen — minimum]: Nom, Prénom, Tel
              ↓ Save
       [MyCardTab — QR généré et affiché]
```

**Critère de succès** : depuis [Install] jusqu'à [QR généré], moins de
60 secondes.

### Flow F2 — Échanger en face-à-face (commercial B2B en RDV)

```
[App ouverte] → [MyCardTab] (par défaut)
                     ↓ tap sur QR
              [CardDisplay plein écran]
                     ↓ l'autre scanne
              [Toast: "Carte partagée"]
                     ↓ optionnel: bouton "Scanner sa carte en retour"
              [ScannerTab]
                     ↓ scan réussi
              [ScanResult: aperçu de la VCard reçue + photo]
                     ↓ "Sauvegarder"
              [Retour au MyCardTab]
```

### Flow F3 — Capter en masse au salon (exposant)

```
[MoreTab] → [Events]
              ↓ "Nouvel événement"
        [Saisir: nom='Salon Tech Paris 2026', dates]
              ↓ "Activer"
        [Banner sticky: 'Événement actif: Salon Tech Paris']
              ↓ user scanne 50 contacts au fil de la journée
        [Chaque scan auto-taggé 'Salon Tech Paris']
              ↓ Fin de journée
        [ContactsTab > Filter > 'Salon Tech Paris']
              ↓ Multi-select all
              ↓ "Exporter PDF"
        [ExportPDF: choisir layout 1-par-page ou 2x2]
              ↓ Generate
        [PDF prêt → Share sheet OS]
```

**Critère de succès** : du tap "Exporter" au PDF prêt, < 5s pour 50
contacts.

### Flow F4 — Recruteur en forum étudiant

```
[ScannerTab actif en permanence]
        ↓ scan QR candidat
[ScanResult avec photo + LinkedIn (parsé du PHOTO/URL)]
        ↓ "Sauvegarder dans contacts du tel"
[Permission contacts OS si pas déjà accordée]
        ↓ Save
[Toast: "Sauvegardé dans contacts" + bouton "Voir"]
```

### Flow F5 — Personnalisation visuelle (freelance)

```
[MyCardTab] → tap "Modifier"
[EditCardScreen]
        ↓ Onglet "Apparence"
[VisualCustomization]:
   - Couleur primaire (color picker)
   - Logo (upload depuis galerie ou pick prédéfini)
   - Layout/template (3 options visuelles)
        ↓ Aperçu en temps réel à droite/en bas
        ↓ "Appliquer"
[Retour MyCardTab avec QR/card mis à jour]
```

### Flow F6 — Récupérer la config visuelle d'un contact (différenciateur)

```
[ContactsTab] → tap sur contact capté
[ContactDetail affiche la card avec la config visuelle ORIGINALE
 de l'expéditeur]
        — couleur de l'expéditeur
        — son logo si présent
        — layout préservé
[Indicateur: "Carte capturée le X"]
```

C'est l'argument visuel fort à showcase pour la presse / le post Discord.
"Quand tu sauvegardes un contact, tu sauvegardes aussi son identité
visuelle, comme garder la vraie carte de visite."

---

## 4. Wireframes ASCII

### Écran : MyCardTab (par défaut au lancement)

```
┌──────────────────────────────────────┐
│  ◀  Ma Carte                  ⚙     │
├──────────────────────────────────────┤
│                                      │
│       Johan Polsinelli               │
│       Étudiant en BUT Info           │
│                                      │
│       ┌─────────────────┐            │
│       │ ░░██░░░░██░░██  │            │
│       │ ░░░░██░░██░░██  │            │
│       │ ██░░░░██░░░░██  │            │
│       │      [LOGO]      │            │
│       │ ░░██░░░░██░░██  │            │
│       │ ██░░██░░██░░░░  │            │
│       └─────────────────┘            │
│                                      │
│   [📤 Partager]  [✏️ Modifier]        │
│                                      │
├──────────────────────────────────────┤
│ 🪪 Ma Carte | 📷 Scanner | 👥 Contacts | ⋯ Plus │
└──────────────────────────────────────┘
```

### Écran : ScanResult (après scan réussi)

```
┌──────────────────────────────────────┐
│  ✕  Carte reçue                      │
├──────────────────────────────────────┤
│                                      │
│   ┌────────────────────────┐         │
│   │  [Photo profile]        │         │
│   │                         │         │
│   │  Marie Dupont           │         │
│   │  Commerciale B2B        │         │
│   │  Acme Corp              │         │
│   │                         │         │
│   │  📞 +33 6 12 34 56 78   │         │
│   │  ✉ marie@acme.com       │         │
│   └────────────────────────┘         │
│   ↑ Affiché dans la couleur          │
│     et le layout de Marie            │
│                                      │
│   Événement actif: Salon Tech 2026   │
│                                      │
│  [💾 Sauvegarder]  [📱 + Contacts tel]│
│  [↩ Partager ma carte en retour]      │
└──────────────────────────────────────┘
```

### Écran : ExportPDF (après multi-sélection)

```
┌──────────────────────────────────────┐
│  ◀  Exporter PDF (12 contacts)       │
├──────────────────────────────────────┤
│                                      │
│  Layout                              │
│  ◉ 1 contact par page (détaillé)     │
│  ○ 2x2 par page (synthétique)        │
│                                      │
│  Inclure                             │
│  ☑ Photo de profil                   │
│  ☑ Date de capture                   │
│  ☑ Nom de l'événement                │
│  ☐ QR code de la carte               │
│                                      │
│  [Aperçu]  [Générer le PDF]          │
└──────────────────────────────────────┘
```

---

## 5. Patterns visuels et composants

### Couleurs (palette par défaut)
- **Primaire** : bleu `#0369A1` (déjà existant en mode sombre).
- **Background light** : `#FFFFFF`.
- **Background dark** : `#000000` ou `#0F1419`.
- **Texte light** : `#000000`.
- **Texte dark** : `#FFFFFF`.
- **Accent succès** : vert `#10B981`.
- **Accent erreur** : rouge `#EF4444`.

### Composants réutilisables (existants ou à créer)
- `AppBarCustom` (existant `lib/components/app_bar_custom.dart`)
- `BtnAnimated` (existant `lib/components/btn.animated.dart`)
- `QRCard` (existant) à étoffer pour supporter `visual_config`
- **`VCardPreview`** (à créer) : composant qui affiche une VCard avec sa
  config visuelle (couleur, logo, layout).
- **`VisualConfigEditor`** (à créer) : color picker + logo picker +
  layout picker.
- **`PDFOptionsForm`** (à créer) : formulaire de config export.

### Toasts (via `toastification`)
- Succès save : "Carte enregistrée"
- Échec scan : "QR non reconnu"
- Permission refusée : "Caméra requise pour scanner"

---

## 6. Accessibilité

- **Contraste** WCAG AA min sur tous les boutons et textes principaux.
- **Tap targets** ≥ 48dp (recommandation Material Design).
- **Semantics** sur les boutons d'action et les QR (ex: "QR code de
  votre carte personnelle, double-tap pour partager").
- **Mode sombre** : toggle dans Settings, suit OS par défaut.
- **Texte** : taille respecte les préférences système (utiliser
  `MediaQuery.textScaler` pour respecter Dynamic Type iOS / Font Size
  Android).

---

## 7. États et erreurs

### États globaux
- **Empty state** ContactsTab : "Aucun contact encore. Scannez votre
  premier QR depuis l'onglet Scanner." + illustration + bouton CTA.
- **Empty state** Events : "Aucun événement. Créez-en un pour grouper
  vos scans."
- **Loading state** Export PDF : barre de progression sticky.
- **Offline state** : aucun (tout est local). Pas de banner offline.

### Permissions
- Caméra demandée à la première utilisation du Scanner (pas avant).
- Contacts demandée uniquement à l'ajout d'un contact dans le tel.
- Photo demandée uniquement quand l'user upload une photo de profil.
- Tous les rationals affichés en français, courts (1 phrase).

### Erreurs critiques
- **DB corrompue** : afficher écran d'erreur avec bouton "Réinitialiser"
  (efface la DB, recrée).
- **Photo trop volumineuse après recompression max** : message clair
  "Photo non compressible sous 200KB, choisis une autre image".
- **vCard 4.0 X-property** rejeté à l'import : log silencieux mais
  préserver les autres champs.

---

## 8. Sources benchmark

- [Mobile App Onboarding 2026 — Plotline](https://www.plotline.so/blog/mobile-app-onboarding-examples)
- [Mobile Onboarding UX 11 Best Practices — DesignStudio](https://www.designstudiouiux.com/blog/mobile-app-onboarding-best-practices/)
- [9 Best Digital Business Card Apps — SPOTIO](https://spotio.com/blog/digital-business-card-apps/)
- [I studied 200 onboarding flows — DesignerUp](https://designerup.co/blog/i-studied-the-ux-ui-of-over-200-onboarding-flows-heres-everything-i-learned/)
- PRD : `prd-ezqrcontact-v2-2026-05-06.md`
- Brief : `product-brief-ezqrcontact-2026-05-06.md`
