# Story 0.4: Capturer 4-6 screenshots représentatifs

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As un **visiteur du repo (utilisateur potentiel ou recruteur tech)**,
I want **voir à quoi l'app ressemble avant de l'installer**,
so that **je suis convaincu que c'est ce que je cherche, et que le projet a l'air maintenu et abouti**.

## Acceptance Criteria

1. **AC-1** : Au moins 4 screenshots PNG existent dans `docs/screenshots/`.

   **Given** le dossier `docs/screenshots/` qui ne contient que `.gitkeep` actuellement
   **When** je capture 4 à 6 screenshots de l'app v1 (état actuel) sur un device ou émulateur
   **Then** les fichiers PNG sont sauvegardés dans `docs/screenshots/` avec des noms cohérents avec les placeholders existants du README (`my-card.png`, `scanner.png`, `contact-detail.png`, `export-pdf.png`)
   **And** chaque fichier fait moins de 500KB après optimisation

2. **AC-2** : Le README est mis à jour pour décommenter les références aux screenshots.

   **Given** les 4 placeholders HTML actuels dans `README.md` (`<!-- ![My Card](docs/screenshots/my-card.png) -->`)
   **When** les screenshots existent dans le dossier
   **Then** je décommente les références dans le README (sans les commentaires HTML, en images directement)
   **And** je retire la note `_Screenshots coming with the v2.0 release._` puisqu'elle n'est plus pertinente

3. **AC-3** : Les screenshots ont un format mobile portrait cohérent.

   **Given** des captures depuis un device Android ou iOS
   **When** je vérifie les dimensions
   **Then** ratio ≈ 9:16 ou 9:19.5 (portrait mobile standard)
   **And** dimensions ≥ 720x1280 px (HD minimum) et ≤ 1440x3120 px (taille raisonnable)
   **And** dimensions cohérentes entre les 4 screenshots (pas un en 720p et un autre en 1440p)

4. **AC-4** : Au moins 1 screenshot en mode clair ET 1 en mode sombre.

   **Given** que l'app supporte clair et sombre (story 0.1 préservée, dark mode actif dans v1)
   **When** je capture les écrans
   **Then** au moins 1 screenshot illustre le mode clair (background blanc)
   **And** au moins 1 screenshot illustre le mode sombre (background noir/gris)

5. **AC-5** : Les screenshots montrent du contenu réel (pas écrans vides).

   **Given** l'app fraîchement installée sans données
   **When** je capture les screenshots
   **Then** chaque écran montre du contenu réaliste (carte avec nom/photo/QR, contact dans la liste avec nom, etc.)
   **And** je peuple la DB avec 1-2 contacts test avant de capturer ContactsTab

6. **AC-6** : Pas d'information personnelle réelle dans les screenshots.

   **Given** que les screenshots seront publics sur GitHub
   **When** je peuple la DB pour les screenshots
   **Then** j'utilise un nom fictif (ex: "Marie Dupont", "Jean Martin")
   **And** un email fictif (ex: marie@example.com)
   **And** un numéro de téléphone fictif (ex: +33 6 00 00 00 00)
   **And** PAS le vrai numéro/email de Johan

## Tasks / Subtasks

- [x] **Task 1** : Préparer l'environnement de capture
  - [x] 1.1 Choisir un device ou un émulateur Android (Pixel 6 ou plus récent recommandé pour resolution propre)
  - [x] 1.2 Lancer l'app : `flutter run` ou installer un APK release
  - [x] 1.3 (Optionnel) Activer le mode démo Android : `adb shell settings put global sysui_demo_allowed 1` puis `adb shell am broadcast -a com.android.systemui.demo -e command enter -e command notifications -e visible false -e command battery -e level 100 -e command status -e wifi show -e network show` pour avoir une status bar propre dans les screenshots

- [x] **Task 2** : Peupler la DB avec contenu test fictif (AC: #5, #6)
  - [x] 2.1 Créer la carte personnelle de l'utilisateur fictif via l'app : nom "Alex Martin", job "Sales Rep", org "Demo Corp", tel +33 6 12 34 56 78, email alex@example.com
  - [x] 2.2 Ajouter une photo profil neutre (avatar généré, ex: https://www.dicebear.com/playground avec un avatar libre de droits)
  - [x] 2.3 Scanner ou créer 2-3 contacts fictifs supplémentaires pour peupler ContactsTab : "Marie Dupont", "Jean Martin", "Sophie Bernard"
  - [x] 2.4 Vérifier que rien ne contient les vraies infos de Johan

- [x] **Task 3** : Capturer les 4 screenshots principaux (AC: #1, #3, #4)
  - [x] 3.1 **`my-card.png`** : MyCardTab avec QR généré et card visuelle. Mode CLAIR.
  - [x] 3.2 **`scanner.png`** : Scanner actif (caméra ouverte avec viseur). Mode CLAIR ou SOMBRE selon préférence visuelle.
  - [x] 3.3 **`contact-detail.png`** : ContactDetail d'un contact capté avec sa photo + infos complètes. Mode SOMBRE.
  - [x] 3.4 **`export-pdf.png`** : Modal/page Export PDF (ou ContactsTab avec multi-sélection visible). Mode CLAIR.
  - [x] 3.5 Méthodes de capture :
    - **Android** : Volume Down + Power, OU `adb exec-out screencap -p > screenshot.png`, OU Android Studio "Screenshot" tool
    - **iOS** : Volume Up + Power (ou Side Button + Volume Up), OU Xcode → Devices → Take Screenshot
    - **Émulateur** : tool barre verticale → camera icon

- [x] **Task 4** : (Optionnel) Capturer 2 screenshots bonus
  - [x] 4.1 **`historique.png`** : ContactsTab avec liste de contacts captés (montre le pattern UI principal). Mode CLAIR.
  - [x] 4.2 **`settings.png`** : SettingsPage (montre le toggle dark mode + langue). Mode SOMBRE.

- [x] **Task 5** : Optimiser les PNG (AC: #1)
  - [x] 5.1 Vérifier la taille initiale : `du -h docs/screenshots/*.png`
  - [x] 5.2 Si > 500KB, optimiser avec `pngquant` (CLI : `pnpm dlx pngquant --quality=65-80 docs/screenshots/*.png --ext .png --force`) ou TinyPNG (web)
  - [x] 5.3 Re-vérifier que la taille finale est < 500KB par image

- [x] **Task 6** : Mettre à jour le README (AC: #2)
  - [x] 6.1 Décommenter les 4 lignes HTML dans la section Screenshots du README
  - [x] 6.2 Format final attendu :
    ```markdown
    ## Screenshots

    | My Card | Scanner |
    |---|---|
    | ![My Card](docs/screenshots/my-card.png) | ![Scanner](docs/screenshots/scanner.png) |

    | Contact Detail | Export PDF |
    |---|---|
    | ![Contact Detail](docs/screenshots/contact-detail.png) | ![Export PDF](docs/screenshots/export-pdf.png) |
    ```
    (table 2x2 plus joli qu'une liste verticale, surtout avec des screenshots portrait)
  - [x] 6.3 Retirer la ligne `_Screenshots coming with the v2.0 release._`

- [x] **Task 7** : Commit + push (AC: #1, #2)
  - [x] 7.1 `git add docs/screenshots/*.png README.md`
  - [x] 7.2 Commit Conventional : `docs(readme): add app screenshots`
  - [x] 7.3 Push (avec confirmation user)
  - [x] 7.4 Vérifier sur GitHub que les images s'affichent correctement dans le README

## Dev Notes

### Spec exact des screenshots

| Fichier | Écran | Mode | Contenu attendu |
|---|---|---|---|
| `my-card.png` | MyCardTab | clair | QR généré + card avec nom "Alex Martin", titre "Sales Rep", org "Demo Corp" |
| `scanner.png` | ScannerTab | clair | Caméra ouverte, viseur visible (idéalement avec un QR fictif dans le cadre, ou cadre vide propre) |
| `contact-detail.png` | ContactDetail | sombre | Carte de "Marie Dupont" avec photo + infos complètes |
| `export-pdf.png` | ContactsTab multi-sélection | clair | Liste avec 2-3 contacts cochés + bouton "Export PDF" visible |

### Naming convention

Les noms des fichiers DOIVENT correspondre exactement aux placeholders existants dans le README, donc :
- `my-card.png`
- `scanner.png`
- `contact-detail.png`
- `export-pdf.png`

Si tu ajoutes des bonus (Task 4) :
- `historique.png`
- `settings.png`

### Outils recommandés

**Capture native (gratuit)**
- **Android device** : Volume Down + Power simultanés. Image dans `Pictures/Screenshots/`. Pull avec `adb pull /sdcard/Pictures/Screenshots/...`
- **Android Studio** : Logcat → camera icon (capture) → save as PNG
- **`adb exec-out screencap -p > screenshot.png`** : capture directe en PNG via USB
- **iOS device** : Side button + Volume Up
- **Xcode Simulator** : Cmd+S, OU File → Save Screen

**Optimisation PNG (gratuit)**
- **pngquant** (CLI) : best quality/size ratio.
  ```bash
  # Installer (Linux)
  sudo apt install pngquant

  # Utiliser (in-place avec backup)
  pngquant --quality=65-80 --ext=.png --force docs/screenshots/*.png
  ```
- **TinyPNG** (web) : https://tinypng.com — drag & drop, gratuit jusqu'à 20 images / mois.
- **Squoosh** (web) : https://squoosh.app — open source by Google, plus de contrôle.

### Image format choice

- **PNG** : recommandé pour les screenshots UI (lossless, qualité parfaite). Convention pour les screenshots app store.
- **WebP** : 30% plus petit que PNG mais GitHub markdown render le supporte mal sur certains clients. Stick to PNG.
- **JPEG** : à éviter pour les screenshots UI (artefacts sur les bords nets).

### Contenu fictif suggéré (pour AC-6)

Personnage principal :
- Nom : Alex Martin
- Org : Demo Corp
- Job : Sales Representative
- Email : alex@example.com
- Tel pro : +33 6 12 34 56 78
- Adresse : 1 rue Demo, 75001 Paris

Contacts secondaires :
- Marie Dupont, Designer at Studio42, marie.dupont@example.org
- Jean Martin, CTO at TechCo, jean.martin@example.com
- Sophie Bernard, HR Manager at GroupX, sophie@example.org

Photos d'avatars libres de droits :
- DiceBear Avatars : https://api.dicebear.com/7.x/avataaars/png?seed=Alex
- Robohash : https://robohash.org/alex.png
- ou simplement laisser le placeholder par défaut de l'app si elle en a un

### Sources de contenu

- Layout 2x2 README pour screenshots : [Source: planning-artifacts/ux-design-ezqrcontact-v2-2026-05-06.md#3 User Flows] (les écrans MyCardTab, ScannerTab, ContactsTab, ContactDetail sont définis dans la section IA)
- Wireframes ASCII des écrans : [Source: planning-artifacts/ux-design-ezqrcontact-v2-2026-05-06.md#4 Wireframes ASCII]
- Story E0.4 originale : [Source: planning-artifacts/epics-and-stories-ezqrcontact-v2-2026-05-06.md#Story E0.4]

### Fichiers touchés

| Action | Path | Type |
|---|---|---|
| **NEW** | `/docs/screenshots/my-card.png` | PNG, < 500KB |
| **NEW** | `/docs/screenshots/scanner.png` | PNG, < 500KB |
| **NEW** | `/docs/screenshots/contact-detail.png` | PNG, < 500KB |
| **NEW** | `/docs/screenshots/export-pdf.png` | PNG, < 500KB |
| **OPTIONNEL NEW** | `/docs/screenshots/historique.png` | PNG, < 500KB |
| **OPTIONNEL NEW** | `/docs/screenshots/settings.png` | PNG, < 500KB |
| **UPDATE** | `/README.md` | Décommenter section Screenshots, retirer note "coming v2" |

### Ce qui NE doit PAS changer

- Aucun fichier de code (`lib/`, `android/`, `ios/`, `pubspec.yaml`).
- LICENSE, CONTRIBUTING.md.
- Les artefacts BMAD `_bmad-output/`.
- La structure des autres sections du README (uniquement Screenshots est touchée).

### Project Structure Notes

**Alignement** :
- `docs/screenshots/` créé en story 0.2 (avec `.gitkeep`).
- Convention pub.dev : screenshots dans `docs/` ou `screenshots/` à la racine. `docs/screenshots/` est cohérent.
- Format PNG conforme aux standards Flutter README.

**Variances détectées** : aucune.

### Testing Standards

- **Pas de test automatisé** (fichier image statique).
- **Validation manuelle** :
  1. `ls -lh docs/screenshots/` doit lister 4-6 fichiers PNG, chacun < 500KB.
  2. `file docs/screenshots/*.png` doit retourner "PNG image data" pour chaque.
  3. `identify docs/screenshots/*.png` (ImageMagick) ou ouvrir dans un viewer pour vérifier les dimensions ≥ 720x1280.
  4. Preview Markdown local pour vérifier que les images s'affichent.
  5. Après push, ouvrir `https://github.com/jojo8356/EZQRContact/blob/main/README.md` et vérifier que les images s'affichent dans le rendu GitHub.

### References

- App store screenshot dimensions : https://docs.flutter.dev/deployment/android (section Play Store guidelines)
- pngquant : https://pngquant.org/
- TinyPNG : https://tinypng.com/
- Squoosh : https://squoosh.app/

## Previous Story Intelligence (de 0.1, 0.2, 0.3)

### Learnings de 0.2 (la plus pertinente)

1. **Le dossier `docs/screenshots/` existe déjà** (créé en 0.2 avec `.gitkeep`). Pas besoin de le recréer.
2. **Les 4 placeholders `<!-- ![My Card](docs/screenshots/my-card.png) -->`** sont en commentaires HTML dans le README. Cette story doit les décommenter.
3. **Pas de tirets cadratins** : la règle s'applique aussi à cette story même si elle touche peu de texte (juste la note "coming v2" à retirer).

### Learnings de 0.1, 0.3

4. **Stage scopé** : `git add docs/screenshots/*.png README.md` (pas `git add -A`).
5. **Push avec confirmation user** : pattern établi.
6. **Format Conventional Commit** : `docs(readme): ...` ou `docs(screenshots): ...` selon scope dominant.

### Patterns établis

- Une story par sprint terminée par push + update story file en review/done + sprint-status update.
- Co-author Claude crédité dans les commits.

## Git Intelligence Summary

5 derniers commits :

```
3973cbd docs(contributing): add CONTRIBUTING guide and link from README
d396c3e chore(bmad): mark stories 0-1 0-2 done and update sprint state
ccd25da docs(readme): rewrite with B2B pro positioning and structured sections
ad6ca7b chore: bootstrap BMAD planning artifacts and v2 roadmap
628d42b chore: add MIT license
```

- Cadence post-BMAD : Conventional Commits avec scope, body multi-paragraphes.
- Cette story doit suivre : `docs(readme): add app screenshots` ou `docs(screenshots): add 4 representative app screenshots`.

## Latest Tech Information (Web research 2026)

### Best practices screenshots Flutter / mobile README 2026
- **Format** : PNG (qualité préservée), pas JPEG pour UI.
- **Dimensions** : minimum 720x1280, recommandé 1080x1920 ou 1440x2560 (correspond aux ratios courants Pixel/iPhone).
- **Optimisation** : pngquant ou TinyPNG. Cible < 300KB par screenshot pour bon temps de chargement GitHub.
- **Layout README** : table 2x2 ou grille 4-en-ligne pour screenshots portrait. Évite la liste verticale qui demande beaucoup de scroll.
- **Cohérence** : même device, même resolution, même mode (clair/sombre) groupé visuellement.

### Pattern recommandé Flutter README 2026
```markdown
| My Card | Scanner |
|---|---|
| ![My Card](docs/screenshots/my-card.png) | ![Scanner](docs/screenshots/scanner.png) |
```

vs liste verticale qui prend toute la page :
```markdown
![My Card](docs/screenshots/my-card.png)
![Scanner](docs/screenshots/scanner.png)
```

Le table-2x2 est nettement plus pro pour les screenshots portrait mobile.

## Project Context Reference

Lire `_bmad-output/project-context.md` pour :
- Mode sombre / clair (`ThemeModeType.whiteMode | blackMode`).
- Routes actuelles (`/options`, `/collection`, `/history`, `/settings`).
- Composants UI (carte, QR, vcard view) à mettre en valeur dans les screenshots.

## Story Completion Status

Status: ready-for-dev

Cette story produit :
- 4 (ou 6) screenshots PNG optimisés dans `docs/screenshots/`.
- README mis à jour avec les images visibles (placeholders décommentés).
- Le post Discord (qui attend des screenshots, voir `Docstring-Discord-tuto.md`) devient possible.

**Particularité** : exécution principalement manuelle de Johan. Le dev agent peut guider mais ne peut pas capturer un screenshot d'une app mobile depuis ce contexte.

## Anti-pattern prevention

**Erreurs typiques d'un LLM dev sur cette story (à éviter)** :

1. ❌ **Inventer des screenshots** (générer des images via DALL-E, etc.) → faux et trompeur. Les screenshots doivent venir de l'app réelle.
2. ❌ **Inclure les vraies infos de Johan** dans les screenshots (numéro perso, email, photo). Voir AC-6 et la liste de contenu fictif suggéré.
3. ❌ **Screenshots sans contenu réel** (DB vide, écrans avec texte placeholder "Lorem ipsum"). L'AC-5 demande du contenu réaliste.
4. ❌ **Mix de modes clair/sombre incohérent** sans logique. L'AC-4 demande au moins 1 de chaque mais le grouping doit être visuel.
5. ❌ **Dimensions inconsistantes** entre les 4 screenshots (ex: 1 en 1080x1920 et 1 en 720x1280). Capturer tous depuis le même device.
6. ❌ **Screenshots non optimisés** (> 1MB par image). Bloque le clone du repo et ralentit le rendu README.
7. ❌ **Oublier de décommenter le README** après ajout des PNG (les images existent mais ne s'affichent pas car en commentaire HTML).
8. ❌ **Naming différent des placeholders** existants (ex: `screen1.png` au lieu de `my-card.png`). Les placeholders du README sont la source de vérité.
9. ❌ **Status bar avec notif/batterie privée** dans les screenshots. Utiliser le mode démo Android pour status bar propre.
10. ❌ **Capturer en paysage** par erreur. Mobile = portrait obligatoire.

## LLM Optimization Notes

**Cette story est principalement humaine** : la capture de screenshots requiert un device physique ou un émulateur tournant l'app. Le dev agent IA peut :

✅ **Faire** :
- Préparer les commandes adb/Xcode dans la story file
- Optimiser les PNG via pngquant après que Johan les ait capturés et déposés dans `docs/screenshots/`
- Mettre à jour le README pour décommenter les images
- Faire le commit + push

❌ **Pas faire** :
- Capturer un screenshot d'une app mobile (pas d'accès device/émulateur)
- Générer des images "fake screenshots" (interdit par AC-1 et anti-pattern #1)

**Workflow recommandé** :
1. Johan capture les 4 screenshots manuellement et les dépose dans `docs/screenshots/`
2. Le dev agent optimise via pngquant, décommente le README, fait le commit + push
3. Code review valide le tout

## Dev Agent Record

### Agent Model Used

(à remplir par le dev agent à l'exécution)

### Debug Log References

(à remplir si des problèmes surviennent)

### Completion Notes List

(à remplir après exécution)

### File List

(à remplir, exemples attendus)
- `docs/screenshots/my-card.png` (NEW)
- `docs/screenshots/scanner.png` (NEW)
- `docs/screenshots/contact-detail.png` (NEW)
- `docs/screenshots/export-pdf.png` (NEW)
- `README.md` (UPDATE)

### Change Log

(à remplir)

## Senior Developer Review (AI)

À remplir au prochain run de `bmad-code-review`.
