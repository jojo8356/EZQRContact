---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prd-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/planning-artifacts/ux-design-ezqrcontact-v2-2026-05-06.md
  - _bmad-output/project-context.md
workflowType: 'architecture'
project_name: EZQRContact
target_version: v2.0.0
user_name: Johan
date: 2026-05-06
status: draft
---

# Architecture Decision Document — EZQRContact v2.0

**Auteur :** Johan
**Date :** 2026-05-06
**Version cible :** v2.0.0

---

## 1. Contexte et contraintes

### Contraintes héritées (project-context)
- **Stack actuelle** : Flutter `^3.8.1`, Dart 3.x, sqflite, provider en
  singleton statique, mobile_scanner, flutter_contacts, intl, etc.
- **Structure** : `lib/{pages,components,modals,providers,tools}/`.
- **DB v1** : 2 tables (`SimpleQR`, `VCard`) avec soft-delete, accédée
  via singleton `QRDatabase`.
- **VCard** : génération maison vCard 4.0, à migrer vers 3.0.
- **Cible** : Android 7.0+ (API 24), iOS 13+, `compileSdkVersion = 35`.

### Contraintes V2
- Ajouter PDF export, photo VCard, config visuelle préservée, échange
  réciproque, événements, vCard 3.0.
- Migrer sqflite → Drift (codegen, type-safety, migrations versioned).
- Migrer flutter_lints → very_good_analysis.
- Ne pas casser la DB des users v1 (migration transparente).

---

## 2. Vue d'ensemble (high-level)

### Style architectural retenu : **Layered Architecture light**

Pas de Clean Architecture stricte / pas de DDD complet (overkill pour
une app solo de cette taille). On reste sur une séparation pragmatique
en 4 couches :

```
┌────────────────────────────────────────────┐
│  Presentation Layer (lib/pages, modals)    │
│  - StatelessWidget, StatefulWidget         │
│  - Reactive UI via ValueListenableBuilder  │
│    et ListenableBuilder                    │
├────────────────────────────────────────────┤
│  Application/State Layer (lib/providers)   │
│  - Singletons statiques                    │
│  - LangProvider, DarkModeProvider,         │
│    EventProvider (nouveau), CardProvider   │
│    (nouveau)                               │
├────────────────────────────────────────────┤
│  Domain Layer (lib/domain)                 │
│  - Modèles : VCard, SimpleQR, Event,       │
│    VisualConfig                            │
│  - Logique pure : parsing, sanitization,   │
│    business rules                          │
├────────────────────────────────────────────┤
│  Data Layer (lib/data)                     │
│  - Drift database (QRDatabase v2)          │
│  - Repositories : VCardRepository,         │
│    EventRepository, etc.                   │
│  - Services : PdfExporter, ImageProcessor, │
│    QRGenerator, ContactSync                │
└────────────────────────────────────────────┘
```

### Refacto de la structure `lib/` cible

```
lib/
├── main.dart
├── app.dart                       # MaterialApp + routing
├── colors.dart
├── data/
│   ├── db/
│   │   ├── database.dart          # Drift QRDatabase v2
│   │   ├── tables/
│   │   │   ├── vcards.dart
│   │   │   ├── simple_qrs.dart
│   │   │   └── events.dart
│   │   └── migrations/
│   │       └── v1_to_v2.dart      # Migration depuis schema v1
│   ├── repositories/
│   │   ├── vcard_repository.dart
│   │   ├── event_repository.dart
│   │   └── simple_qr_repository.dart
│   └── services/
│       ├── pdf_exporter.dart      # package:pdf + printing
│       ├── image_processor.dart   # resize/compress photo
│       ├── qr_generator.dart      # qr_flutter wrapper
│       ├── qr_visual_extractor.dart # extraction config visuelle
│       └── contact_sync.dart      # flutter_contacts wrapper
├── domain/
│   ├── models/
│   │   ├── vcard.dart             # VCard 3.0 + photo support
│   │   ├── simple_qr.dart
│   │   ├── event.dart
│   │   └── visual_config.dart
│   ├── parsers/
│   │   └── vcard_parser.dart      # parse vCard 3.0 et 4.0
│   └── validators/
│       └── vcard_validator.dart
├── providers/
│   ├── lang_provider.dart
│   ├── dark_mode_provider.dart
│   ├── event_provider.dart        # NEW: événement actif
│   └── card_provider.dart         # NEW: carte perso de l'user
├── pages/
│   ├── onboarding_page.dart       # NEW
│   ├── main_shell.dart            # NEW: bottom nav 4 tabs
│   ├── tabs/
│   │   ├── my_card_tab.dart
│   │   ├── scanner_tab.dart
│   │   ├── contacts_tab.dart
│   │   └── more_tab.dart
│   ├── card_display_page.dart
│   ├── edit_card_page.dart
│   ├── scan_result_page.dart
│   ├── contact_detail_page.dart
│   ├── export_pdf_page.dart       # NEW
│   ├── events_page.dart           # NEW
│   └── settings_page.dart
├── components/
│   ├── app_bar_custom.dart
│   ├── btn_animated.dart          # rename de btn.animated.dart
│   ├── vcard_view.dart
│   ├── vcard_preview.dart         # NEW: rendu d'une carte avec config visuelle
│   ├── visual_config_editor.dart  # NEW
│   ├── pdf_options_form.dart      # NEW
│   ├── qr_card.dart
│   └── ... (existants à migrer)
└── modals/
    └── ... (existants)
```

---

## 3. Décisions architecturales (ADR)

### ADR-1 : Migration sqflite → Drift

**Décision** : Migrer toute la couche persistance vers `drift` + initialement
`drift_sqflite` (cohabitation avec sqflite existant pendant transition),
puis bascule complète vers `drift_flutter` une fois la migration finie.

**Pourquoi** : codegen type-safe, migrations versioned, queries fluides,
streams réactifs. Détaillé dans `project-context.md` section "Migration
recommandée".

**Alternatives écartées** :
- Garder sqflite : trop de Map<String, dynamic> non-typés, source de bugs.
- Isar : abandonné (v4 jamais sortie, forks community instables).
- ObjectBox : NoSQL propriétaire, casse le modèle relationnel.

**Stratégie de migration**
1. Ajouter `drift`, `drift_sqflite`, `drift_dev`, `build_runner`.
2. Définir les tables Drift miroir du schéma v1.
3. Créer `QRDatabase` v2 utilisant `SqfliteQueryExecutor.inDatabaseFolder`
   pointé sur `qr_app.db` existant.
4. `schemaVersion = 2`. Implémenter `MigrationStrategy` pour ajouter les
   nouvelles colonnes (`visual_config`, `event_id`).
5. Réécrire les méthodes de `QRDatabase` une à la fois. Tests unit avec
   `sqflite_common_ffi` à chaque méthode migrée.

---

### ADR-2 : VCard 3.0 par défaut, 4.0 toggleable

**Décision** : Le parser/generator vCard supporte 3.0 et 4.0. Sortie par
défaut en 3.0 (compat universelle iCloud/Google/Outlook/Android/iPhone).

**Pourquoi** : recherche domain a montré que vCard 4.0 silently fail sur
de nombreux devices (FossifyOrg/Contacts #210, iCloud rejette les
X-properties, perte de contacts à l'import).

**Implémentation**
- Module `lib/domain/parsers/vcard_parser.dart` : detect version, parse
  des deux.
- Module `lib/domain/models/vcard.dart` : méthode `toVCard({version: '3.0'})`.
- Photo encoding : `PHOTO;ENCODING=b;TYPE=JPEG:` pour 3.0 (line folding
  obligatoire à 75 caractères pour compat stricte).
- Toggle dans Settings exposé via `Settings > Compatibilité > vCard
  version` (FR-1.3).

---

### ADR-3 : PDF avec `pdf` + `printing` (opensource)

**Décision** : Utiliser le package `pdf` (battle-tested, opensource) +
`printing` pour la fonction share/save.

**Pourquoi** : opensource compatible MIT, cohérent avec le pitch du
projet. Syncfusion serait plus rapide à mettre en place mais commercial
(license community gratuite mais avec limitations légales).

**Implémentation**
- `lib/data/services/pdf_exporter.dart` : `Future<Uint8List> generate(List<VCard> contacts, PdfExportOptions options)`.
- 2 layouts : 1-par-page (détaillé avec photo grande) et 2x2 (synthétique).
- Police par défaut : `Roboto` ou `Helvetica` (déjà inclus dans
  package `pdf`).
- Embarquer la photo via `pw.MemoryImage(jpegBytes)`.
- Format A4 (`PdfPageFormat.a4`).

---

### ADR-4 : Capture de la config visuelle du QR scanné

**Décision** : Stocker la config visuelle d'un QR scanné dans une nouvelle
colonne `VCard.visual_config` (JSON sérialisé).

**Schéma JSON** :
```json
{
  "primaryColor": "#0369A1",
  "logoBase64": "data:image/png;base64,...",
  "layout": "minimal",
  "extractedAt": "2026-05-06T12:00:00Z"
}
```

**Méthode d'extraction**
- Le QR émetteur encode sa config visuelle dans une property custom :
  `X-EZQR-VISUAL` (data URI JSON base64).
- Le scanner extrait cette property. Si présente : `visual_config`
  rempli. Si absente : null (rendu par défaut).

**Compromis**
- Cela ajoute du payload au QR (taille). À limiter : logo en thumbnail
  64x64 max compressé en PNG, layout encodé sur 1 string court.
- Si le QR scanné vient d'un autre outil (Blinq, HiHello, etc.), pas de
  `X-EZQR-VISUAL` → rendu par défaut. Pas un problème, c'est notre
  feature exclusive.

---

### ADR-5 : Échange réciproque sans backend

**Décision** : Pas de backend pour le swap réciproque. Le pattern est
manuel local : après réception d'un scan, l'app affiche un prompt
suggérant de partager son QR en retour. L'autre user scanne, fin.

**Pourquoi** : pas de cloud, pas de DPA, cohérent local-first. Whova
implémente un swap "request/accept" mais ça nécessite un backend de
matching, hors scope.

---

### ADR-6 : State management — singleton statique préservé

**Décision** : Garder le pattern existant (`LangProvider`,
`DarkModeProvider`) et ajouter `EventProvider`, `CardProvider` au même
modèle. Pas de Bloc / Riverpod / get_it.

**Pourquoi** : pattern déjà présent et fonctionnel, cohérent (project-context
règle "ne pas introduire MultiProvider"). Solo dev, complexité limitée,
pas besoin d'un état distribué.

**Risque** : si l'app grossit beaucoup (V3+), reconsidérer. Pour V2,
suffisant.

---

### ADR-7 : Routing — déclaratif simple préservé

**Décision** : Garder `MaterialApp.routes`. Ajouter les nouvelles routes
nommées : `/onboarding`, `/edit-card`, `/scan-result`, `/contact-detail`,
`/export-pdf`, `/events`.

**Pourquoi** : cohérent avec le code existant, pas de besoin de deep
linking complexe ni de nested navigation.

---

### ADR-8 : Lint — migration vers very_good_analysis

**Décision** : Remplacer `flutter_lints` par `very_good_analysis ^9.x`
(dernière stable). Dans `analysis_options.yaml` :
```yaml
include: package:very_good_analysis/analysis_options.yaml
```

**Pourquoi** : recherche benchmark a montré que `very_good_analysis`
détecte 2x plus d'issues sur le même code (incluant règles d'architecture
et complexité). Cohérent pour un projet "showcase CV".

**Stratégie**
- Ajouter en parallèle.
- Lancer `flutter analyze`. Identifier les warnings nouveaux.
- Corriger / suppress en file-level avec justification commit.

---

### ADR-9 : Tests — pyramide légère

**Décision** : Pyramide de tests adaptée à un projet solo :
- **Unit tests** (priorité) : `vcard.dart`, `vcard_parser.dart`,
  `image_processor.dart`, repositories. Couverture > 70% sur ces modules.
- **Widget tests** (secondaire) : composants critiques (`VCardPreview`,
  `QRCard`).
- **Integration tests** : 1 happy path E2E (créer carte → scanner →
  voir contact). Via `integration_test` package SDK.
- **Pas de golden tests** (overkill pour app pas en design system).

**Outils** : `flutter_test` (déjà en deps), `mocktail` (à ajouter),
`sqflite_common_ffi` (à ajouter pour DB in-memory).

---

### ADR-10 : Workflow Git et release

**Décision** : Conventional Commits + Semantic Versioning. Branches
`feat/*` et `fix/*`. Pas de develop/release branches (overkill solo).

**Tooling** :
- `commitlint` + `husky` (Node, déjà dans l'écosystème Johan via pnpm).
- Releases manuelles via tag `vX.Y.Z` aligné avec `pubspec.yaml:version`.
- Optionnel : `semantic-release` ou `standard-version` plus tard.

---

## 4. Schéma de données (Drift, schemaVersion = 2)

### Table `SimpleQRs` (idem v1)
```
- id INTEGER PRIMARY KEY AUTOINCREMENT
- text TEXT NOT NULL
- path TEXT NULLABLE
- deleted BOOL DEFAULT 0
- date_deleted TEXT NULLABLE
```

### Table `VCards` (v1 + nouvelles colonnes V2)
```
- id INTEGER PRIMARY KEY AUTOINCREMENT
- nom TEXT
- prenom TEXT
- nom2 TEXT
- prefixe TEXT
- suffixe TEXT
- org TEXT
- job TEXT
- photo TEXT (data URI base64 JPEG)
- tel_work TEXT
- tel_home TEXT
- adr_work TEXT
- adr_home TEXT
- email TEXT
- rev TEXT
- path TEXT
- clone BOOL DEFAULT 0
- deleted BOOL DEFAULT 0
- date_deleted TEXT NULLABLE
- visual_config TEXT NULLABLE  -- NEW (JSON)
- event_id INTEGER NULLABLE     -- NEW (FK Events)
- captured_at TEXT NULLABLE     -- NEW (date du scan)
```

### Table `Events` (NEW)
```
- id INTEGER PRIMARY KEY AUTOINCREMENT
- name TEXT NOT NULL
- start_date TEXT NULLABLE
- end_date TEXT NULLABLE
- is_active BOOL DEFAULT 0
- created_at TEXT NOT NULL
```

### Migration v1 → v2
```dart
// dans lib/data/db/migrations/v1_to_v2.dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from == 1) {
      await m.addColumn(vCards, vCards.visualConfig);
      await m.addColumn(vCards, vCards.eventId);
      await m.addColumn(vCards, vCards.capturedAt);
      await m.createTable(events);
    }
  },
);
```

**Backup obligatoire** : avant migration, copier `qr_app.db` →
`qr_app.db.backup` dans le storage app. Si migration échoue, restore
auto et erreur lisible utilisateur.

---

## 5. Flux de données critiques

### Flux : Génération QR perso
```
[CardProvider.currentCard]
        ↓
[QRGenerator.generate(card)]
        ↓ (utilise qr_flutter)
[QrImage widget en mémoire]
        ↓ (pour partage en image)
[Capture en bytes via repaintBoundary]
        ↓
[file_saver / share]
```

### Flux : Scan d'un QR
```
[mobile_scanner stream] → barcode détecté
        ↓
[VCardParser.parse(barcode.rawValue)]
        ↓ (détecte v3.0 ou v4.0)
[VCard model + VisualConfig (si X-EZQR-VISUAL présent)]
        ↓
[VCardRepository.insert(vcard, eventId: activeEvent?.id)]
        ↓
[ContactsTab list update via stream Drift]
        ↓
[ScanResultPage modale]
```

### Flux : Export PDF
```
[ExportPdfPage] ← user select N contacts + options
        ↓
[VCardRepository.getMany(ids)] → List<VCard>
        ↓
[ImageProcessor.loadAndResize(vcard.photo)] → Uint8List
        ↓
[PdfExporter.generate(contacts, options)]
        ↓ (pw.Document via package pdf)
[Uint8List PDF bytes]
        ↓
[printing.sharePdf() OU file_saver.saveFile()]
```

---

## 6. Stratégie de déploiement

### CI/CD (à mettre en place V2)
- **GitHub Actions** :
  - Workflow PR : `flutter analyze` + `flutter test` (unit + widget).
  - Workflow tag `v*.*.*` : build APK release + iOS archive (si secrets
    Apple ok).
- **Pas de déploiement auto Play Store** au début (manuel, plus simple
  pour un projet solo et rapide à corriger en cas de souci).

### Release process
1. Branche `feat/X` ou `fix/X` → PR vers `main` → review (même solo,
   garde un historique).
2. Merge → bump `version:` dans `pubspec.yaml` (semver).
3. Tag `vX.Y.Z`.
4. Build APK release localement, signer.
5. Upload Play Console (track interne d'abord, puis production).
6. iOS : `flutter build ipa`, upload via Transporter / Xcode.

---

## 7. Sécurité et conformité

### Permissions
- **Caméra** : demandée à la première activation du Scanner. Rationale :
  "Pour scanner les QR codes des contacts."
- **Contacts** : demandée à l'ajout dans le tel. Rationale : "Pour
  enregistrer ce contact dans le carnet de votre téléphone."
- **Photo / galerie** : demandée à l'upload photo profil. Rationale :
  "Pour ajouter une photo à votre carte."
- Permissions handling via `permission_handler ^12`. Vérifier
  `compileSdkVersion = 35`.

### GDPR / Privacy
- Aucun pipeline data tiers. Pas de DPA requis.
- Mention dans Settings > À propos : "Vos données restent sur votre
  téléphone. Aucun cloud, aucun compte requis."
- Si l'utilisateur partage un PDF, il consent explicitement via le
  share sheet OS.

### Sanitization
- Tous les champs VCard passent par `clean()` avant écriture (strip `;`,
  `;;`) — règle existante à préserver dans le port Drift.
- Photo : valider que c'est une image valide avant encoding base64
  (`image` package : `decodeImage(bytes)` non-null).

---

## 8. Observabilité et debug

### Logs
- Tous les `print()` sous `if (kDebugMode)`.
- Pour V3 éventuel : envisager `logger` package pour structurer.

### Métriques in-app (locales, pas de tracking tiers)
- Compteur de scans réussis/échoués stockés dans SharedPreferences,
  visible dans Settings > Statistiques.
- Permet à Johan de mesurer le 95%+ d'imports vCard réussis (NFR-4).

### Crashlytics / Sentry ?
- Out of scope V2 (introduit du tracking tiers, casse le pitch
  privacy-first). Si besoin V3, Sentry self-hosted ou rien.

---

## 9. Risques techniques identifiés

| ID | Risque | Probabilité | Impact | Mitigation |
|---|---|---|---|---|
| **R-1** | Migration Drift casse la DB v1 des users | Medium | High | Backup auto avant migration + tests d'intégration avec dump v1 réel |
| **R-2** | Photo > 200KB après recompression max | Low | Medium | Limiter la résolution input à 1024x1024 avant tout |
| **R-3** | vCard 3.0 line folding non strictement respecté | Medium | Medium | Tests unitaires sur fixtures vCard 3.0 réelles |
| **R-4** | very_good_analysis fait sauter trop de warnings d'un coup | High | Low | Migrer par module, suppress avec justification |
| **R-5** | PDF de 200 contacts → out of memory | Low | Medium | Streaming génération page par page, pas tout en mémoire |
| **R-6** | X-EZQR-VISUAL fait dépasser la capacité du QR | Medium | Low | Limiter la taille (logo 64x64, JSON minifié) ; fallback sans visual_config |

---

## 10. Sources

- [Drift documentation](https://drift.simonbinder.eu/)
- [Drift migration guide](https://drift.simonbinder.eu/migrations/)
- [pdf package pub.dev](https://pub.dev/packages/pdf)
- [printing package pub.dev](https://pub.dev/packages/printing)
- [very_good_analysis](https://pub.dev/packages/very_good_analysis)
- [vCard 3.0 spec RFC 2426](https://datatracker.ietf.org/doc/html/rfc2426)
- [vCard 4.0 spec RFC 6350](https://datatracker.ietf.org/doc/html/rfc6350)
- PRD : `prd-ezqrcontact-v2-2026-05-06.md`
- UX : `ux-design-ezqrcontact-v2-2026-05-06.md`
- Project context : `project-context.md`
