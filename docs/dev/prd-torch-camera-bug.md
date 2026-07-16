# PRD — Lampe torche inopérante en mode caméra (scanner QR)

**Type :** Bug / UX fix
**Sévérité :** Medium (fonctionnalité inutilisable dans l'obscurité)
**Priorité :** P1
**Date :** 2026-05-12
**Auteur :** Johan

---

## 1. Résumé du problème

Quand l'utilisateur ouvre le scanner QR et appuie sur le bouton de lampe
torche, rien ne se passe. La torche ne s'allume pas et l'icône ne change pas.
Le bouton semble mort.

---

## 2. Contexte technique

### Code actuel (`lib/pages/qr_scanner.dart:43-59`)

```dart
appBarBuilder: (context, controller) => AppBar(
  actions: [
    IconButton(
      icon: controller.torchEnabled
          ? const Icon(Icons.flashlight_off_rounded)
          : const Icon(Icons.flashlight_on_rounded),
      onPressed: controller.toggleTorch,
    ),
  ],
),
```

### Deux bugs identifiés

**Bug 1 — Widget non-réactif (root cause visuel)**

`appBarBuilder` est appelé une seule fois par `AiBarcodeScanner`. Le widget
`AppBar` est construit et n'est **jamais reconstruit** ensuite. Donc
`controller.torchEnabled` n'est évalué qu'une fois à la construction. Quand
`toggleTorch()` change l'état interne du contrôleur, l'icône ne se met pas à
jour et l'utilisateur ne voit pas de feedback visuel.

**Bug 2 — `toggleTorch()` silencieusement ignoré sur certains appareils**

`mobile_scanner v6` expose `controller.toggleTorch()` qui délègue à la
plateforme. Sur Android, en mode caméra continuous focus/exposure (activé
automatiquement par `AiBarcodeScanner`), la commande torch peut être ignorée
silencieusement si la caméra est en mode "auto" car le capteur reprend le
contrôle. Le retour de `toggleTorch()` est un `Future<void>` sans valeur —
impossible de savoir si ça a marché.

---

## 3. Comportement attendu

| Étape | Attendu |
|-------|---------|
| Utilisateur ouvre le scanner | Bouton torch visible, icône = flashlight_on (torch OFF) |
| Utilisateur appuie sur le bouton | Torch s'allume physiquement, icône → flashlight_off |
| Utilisateur appuie à nouveau | Torch s'éteint, icône → flashlight_on |
| Appuie en zone sombre | Caméra capture mieux grâce à la lumière |

---

## 4. Comportement actuel

- Appui sur le bouton : aucun effet visible, aucun feedback
- Torch ne s'allume pas sur device physique (testé Android)
- Icône reste la même (pas de toggle visuel)

---

## 5. Solution proposée

### Option A — Fix minimal : `StreamBuilder` sur `torchState` (recommandé)

`MobileScannerController` expose un `Stream<TorchState>` (via
`controller.torchState` dans mobile_scanner ≥ 5). Wrapper le bouton dans un
`StreamBuilder` force la reconstruction de l'icône à chaque changement.

```dart
appBarBuilder: (context, controller) => AppBar(
  actions: [
    StreamBuilder<TorchState>(
      stream: controller.torchState,
      initialData: TorchState.off,
      builder: (_, snapshot) {
        final isOn = snapshot.data == TorchState.on;
        return IconButton(
          icon: Icon(
            isOn
                ? Icons.flashlight_off_rounded
                : Icons.flashlight_on_rounded,
          ),
          onPressed: controller.toggleTorch,
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.cameraswitch_rounded),
      onPressed: controller.switchCamera,
    ),
  ],
),
```

### Option B — Remplacer `ai_barcode_scanner` par `mobile_scanner` direct

`ai_barcode_scanner` est un wrapper sur `mobile_scanner` qui gère la
configuration de base mais limite le contrôle fin. Utiliser `mobile_scanner`
directement donne accès à toutes les APIs torch (y compris le mode `auto`).

**Trade-off :** Plus de code à écrire pour l'UI du scanner.
**Recommandé pour :** epic-4 (scan caméra) qui nécessitera de toute façon
une refonte du scanner.

---

## 6. Acceptance Criteria

1. **AC-1 :** Quand l'utilisateur appuie sur le bouton torch, la lampe
   s'allume physiquement sur l'appareil Android (testé sur ≥ 2 modèles).
2. **AC-2 :** L'icône du bouton bascule immédiatement entre
   `flashlight_on_rounded` et `flashlight_off_rounded` à chaque appui.
3. **AC-3 :** Torch fonctionne en mode scan actif (caméra ouverte + focus).
4. **AC-4 :** Torch s'éteint automatiquement quand le scanner est fermé
   (pas de fuite état).
5. **AC-5 :** `flutter analyze` → 0 issue.

---

## 7. Out of scope

- Support iOS (le torch iOS est géré différemment via AVFoundation — à traiter séparément si besoin)
- Mode torch "auto" (ajustement luminosité auto) — hors périmètre v2
- Flash photo pour scanner en image (import QR galerie) — concerne `import_qr_page.dart`, pas le scanner caméra

---

## 8. Dépendances

- `mobile_scanner: ^6.0.2` (déjà dans pubspec.yaml)
- `ai_barcode_scanner: ^6.0.1` (à étudier si migration vers mobile_scanner direct pour epic-4)

---

## 9. Notes d'implémentation

Avant de fixer, vérifier si `mobile_scanner v6` expose bien `controller.torchState`
comme un `Stream<TorchState>` ou un `ValueNotifier<TorchState>` :

```bash
grep -r "torchState\|TorchState" ~/.pub-cache/hosted/pub.dev/mobile_scanner-6.0.*/
```

Si l'API a changé en v6, adapter en conséquence (peut-être
`controller.value.torchState` via `MobileScannerState`).
