# Plan de tests manuels — EZQRContact

**Produit :** EZQRContact (Flutter, Android + iOS)  
**Version couverte :** `v1.1.0+3` / branche de session  
**Date :** 12 octobre 2026  
**Statut :** applicable avant chaque release et après tout merge d’un flux utilisateur  

Ce document est le **catalogue QA device**. Les tests unitaires / widget
(`flutter test`) couvrent la logique pure. Ici on cherche ce que la CI ne
voit pas : caméra, contacts, galerie, permissions, kill, rotation, TalkBack,
vrai QR d’un iPhone, vrai salon.

Méthode (pratiques des grandes boîtes, adaptées à une app locale-first) :

| Source | Ce qu’on reprend |
|---|---|
| **Google** (Testing on the Toilet, Severity Guidelines) | Sévérité S0–S3, smoke vs regression, dogfood, *don’t ship on red* |
| **Apple** (HIG + App Review) | Permissions *just-in-time*, Dark Mode, Dynamic Type, interruptions (appel, background), VoiceOver |
| **Microsoft** SDL | Cas sécurité / sanitisation, pas de fuite de données, kill + relance |
| **ISTQB / session-based** (Bach) | Exploratoire chronométré en plus des cas scriptés |
| **NN/g** | Libellés à information scent, junk drawer, cibles 48 dp |

Le livrable d’une session n’est **pas** « tout est vert ». C’est une liste de
bugs classés, avec un go / no-go.

Le catalogue historique (payloads vCard, import batch) reste dans
[`docs/manual-test.md`](../manual-test.md). Ce plan **l’englobe** et ajoute
tout ce qui manquait (onboarding, collection, PDF, événements, reciprocal,
a11y, interruptions).

---

## 1. Barre de qualité (ship criteria)

On **ne shippe pas** si un S0 ou S1 ouvert n’a pas de workaround documenté.

| ID | Critère | Seuil |
|---|---|---|
| Q1 | Smoke pack (§5) | 100 % pass sur 1 Android **et** 1 iPhone |
| Q2 | Aucun crash (fatal) | 0 pendant smoke + regression |
| Q3 | Aucune perte de données | kill / rotation / refus permission ne wipent pas la base |
| Q4 | Local-first | 0 requête réseau hors ouverture d’un lien user (À propos) |
| Q5 | Permissions | refus = UI explicative, jamais un écran blanc |
| Q6 | i18n | FR et EN, aucun fallback de clé brute (`home.section_more`) |
| Q7 | Contraste | texte encre / cendre lisible en extérieur (HIG / WCAG AA) |
| Q8 | Bugs connus | listés §16, pas rediscovered comme S0 |

**Go** = Q1–Q8 tenus, S2 restants acceptés par écrit.  
**No-go** = 1 crash reproductible, 1 QR illisible, 1 perte de collection.

---

## 2. Sévérité et priorité

### Sévérité (Google)

| Sev | Nom | Définition EZQR | Exemple |
|---|---|---|---|
| **S0** | Blocker | Crash, données perdues, sécu, app inutilisable | DB corrompue au cold start |
| **S1** | Critical | Parcours cœur cassé | Scanner ne détecte aucun QR, vCard vide |
| **S2** | Major | Feature dégradée, workaround existe | Import galerie ignore un QR, dark mode non persisté |
| **S3** | Minor | Polish, copy, 1 px | Icône 2 dp trop petite, « Aussi » |

### Priorité

| P | Quand on le fixe |
|---|---|
| **P0** | Avant le build store |
| **P1** | Sprint en cours |
| **P2** | Backlog |
| **P3** | Nice-to-have |

Un S2 peut être P0 (ex. FR cassé le jour d’un salon). Un S0 est toujours P0.

---

## 3. Matrice devices (minimum)

Tester **au moins** la colonne « must » à chaque release.

| Slot | Must | Nice |
|---|---|---|
| Android récent | API 34–36, 6–6,7″ | pliable / tablette |
| Android bas de gamme | API 33, 4–6 Go RAM | — |
| iPhone | iOS 17 ou 18 | iOS 16 (plancher déclaré) |
| Taille | un petit écran (≤ 5,5″) **et** un grand | landscape (doit rester utilisable, même si portrait-first) |
| Thème système | clair **et** sombre | contraste élevé |
| Langue OS | FR **et** EN | OS DE + app FR (fallback `en` si pack absent) |

Le WP32 Pro de dogfood compte pour « Android récent » s’il est API 34+.

---

## 4. Rôles et déroulement d’une session

1. **Préparer** — build debug signé ou `flutter run`, 2–3 QR de test (vCard 3.0 iOS, vCard Google, QR URL).
2. **Smoke 15 min** (§5) — si rouge, on s’arrête.
3. **Catalogue** — cocher les cas du flux touché par le diff, **plus** un écran voisin.
4. **Exploratoire 25 min** — timer, charte (§14), notes brutes.
5. **Rapports** — un ticket par bug, template §15.
6. **Sign-off** — tableau §17.

Convention de statut dans la checklist : `PASS` / `FAIL` / `BLOCKED` / `N/A`.

---

## 5. Smoke pack — 15 minutes (P0)

À jouer **à chaque** `flutter run` release-candidate, les deux OS.

| # | Action | Attendu |
|---|---|---|
| S-01 | Cold start (données déjà là) | Home ENCRE, pas d’onboarding, pas de crash |
| S-02 | Home | Tagline, 2 tiles featured, section **Outils** / **Tools**, grille 2×2, nav bas |
| S-03 | Créer une vCard minimale (nom + email) → générer | QR affiché, modules lisibles |
| S-04 | Scanner ce QR depuis un **second** téléphone | Contact importable (app tierce ou EZQR) |
| S-05 | Scanner un QR vCard **depuis EZQR** | Fiche résultat, pas d’écran noir |
| S-06 | Collection | La carte vient d’apparaître |
| S-07 | Nav Accueil / Collection / Historique / Réglages | 4 onglets, aucun stack dupliqué |
| S-08 | Réglages : FR↔EN | UI entière change **sans** restart |
| S-09 | Dark mode | Papier nuit, texte ivoire, pas de flash blanc |
| S-10 | Kill + relance | Collection toujours là, langue conservée |

Si S-04 échoue (QR illisible), **stop** — c’est le produit.

---

## 6. Catalogue fonctionnel

Légende des préconditions : **clean** = app désinstallée ou données effacées.

---

### 6.1 Premier lancement / onboarding

| ID | Cas | Steps | Attendu | Sev si fail |
|---|---|---|---|---|
| ON-01 | Premier launch | clean → ouvrir | Onboarding 3 pages, pas la home | S1 |
| ON-02 | Swipe | glisser les 3 pages | Indicateur de page cohérent, pas de skip involontaire | S2 |
| ON-03 | CTA créer | last page → créer ma carte | Onboarding marqué done, formulaire vCard | S1 |
| ON-04 | Skip | skip / plus tard | Home, `onboarding_done` persisté | S1 |
| ON-05 | Relance | kill après skip | Plus d’onboarding | S1 |
| ON-06 | Rotation | tourner pendant l’onboarding | Pas de reset de page, pas de crash | S2 |

---

### 6.2 Home

| ID | Cas | Steps | Attendu | Sev |
|---|---|---|---|---|
| HO-01 | IA | ouvrir Accueil | Featured : VCard, Scanner. Outils : Simple, Import QR, Import contact, Événements | S1 |
| HO-02 | Copy section | — | Libellé **Outils** (FR) / **Tools** (EN). Jamais « Aussi / Also / More » | S3 |
| HO-03 | Icônes outils | — | Well 56 dp **centré**, glyphe 28, titre centré sous l’icône | S3 |
| HO-04 | Tap targets | tap chaque tile | Navigation correcte, ripple dans le radius | S2 |
| HO-05 | App bar | — | Wordmark EZQR + Contact + marque cuivre. Fond 10 % noir, pas une dalle grise | S3 |
| HO-06 | Guide first-run | clean, passer onboarding | Popup guide **une** fois | S2 |
| HO-07 | Guide ensuite | relance | Pas de popup | S2 |
| HO-08 | Bannière event | activer un événement | Bannière visible sur Home **et** Réglages | S2 |

---

### 6.3 Génération vCard

Détail payloads : [`docs/manual-test.md`](../manual-test.md) §1, §2, §11, §12.

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| VC-01 | Tous les champs | QR + import OS : 8 champs, pas de parasite | S1 |
| VC-02 | Nom + email seuls | Pas de lignes TEL/ORG/ADR vides | S1 |
| VC-03 | Payload 3.0 | `VERSION:3.0`, `TEL;TYPE=WORK,VOICE:`, CRLF, fold 75 | S1 |
| VC-04 | Toggle 4.0 | `VERSION:4.0`, `TYPE=` minuscule, `VALUE=uri:tel:` | S1 |
| VC-05 | Toggle persisté | kill → 4.0 toujours ON | S2 |
| VC-06 | Photo | JPEG ≤ 720×720, QR encore scannable | S1 |
| VC-07 | Photo refusée | galerie refusée → message, formulaire intact | S2 |
| VC-08 | Couleur primaire | modules de la couleur choisie, fond blanc, scan OK | S2 |
| VC-09 | Couleur persistée | rouvrir la fiche = même couleur | S2 |
| VC-10 | Logo centre | logo visible, quiet zone suffisante, scan OK | S2 |
| VC-11 | `;` dans le nom | sanitizé, pas d’injection de champ | S1 |
| VC-12 | `\\n` collé | CR/LF retirés | S1 |
| VC-13 | Nom `;;;` | `N:;;;;`, pas de crash | S2 |
| VC-14 | Adresse longue | line-fold `\\r\\n `, reconstituée au scan | S1 |
| VC-15 | Back sans sauver | confirmation ou données encore là si brouillon — **noter le réel** | S2 |
| VC-16 | Champs tel FR | `+33` conservé, pas de `00` magique | S2 |

---

### 6.4 QR simple

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| QS-01 | URL | scan = URL exacte | S1 |
| QS-02 | Texte unicode | accents, emoji : round-trip | S2 |
| QS-03 | Vide | CTA disabled **ou** erreur claire, pas de QR blanc | S2 |
| QS-04 | Très long | QR dense encore scannable **ou** message « trop long » | S2 |
| QS-05 | Collection | entrée type `simple`, pas vCard | S1 |

---

### 6.5 Scanner caméra

Bug connu torche : [`docs/dev/prd-torch-camera-bug.md`](../dev/prd-torch-camera-bug.md) — **KB-torch**, ne bloque pas la release, **consigner le modèle**.

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| SC-01 | Permission allow | preview, overlay ENCRE | S1 |
| SC-02 | Permission deny | pas de crash, chemin pour ouvrir Réglages | S1 |
| SC-03 | vCard tierce (iOS Contacts) | parse + écran résultat | S1 |
| SC-04 | vCard Google | idem | S1 |
| SC-05 | QR URL / texte | sauvé en SimpleQR | S1 |
| SC-06 | QR non-vCard / non-texte (Wi-Fi, SMS) | pas de crash, message utile | S2 |
| SC-07 | Double scan | un seul push de résultat (`_scanned`) | S1 |
| SC-08 | Switch caméra | front/rear sans crash | S2 |
| SC-09 | Torche | on/off **ou** KB-torch reproduite | S2 (connu) |
| SC-10 | Low light | toujours détecte un QR 3×3 cm à ~20 cm | S2 |
| SC-11 | Background | app → home OS → retour : preview reprend | S2 |
| SC-12 | Appel entrant | pas de freeze caméra au retour | S2 |

---

### 6.6 Résultat de scan + reciprocal

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| SR-01 | Fiche | nom, org, tel, mail visibles | S1 |
| SR-02 | Ajouter aux contacts OS | land dans le carnet, options replace/clone/fill | S1 |
| SR-03 | Voir collection | carte dans Collection | S1 |
| SR-04 | Reciprocal ON | prompt « proposer ma carte » | S2 |
| SR-05 | Reciprocal share | partage / affichage de **ma** carte | S2 |
| SR-06 | Reciprocal later | dismiss, scan quand même sauvé | S2 |
| SR-07 | Reciprocal OFF | pas de prompt | S2 |
| SR-08 | vCard pourrie | pas de crash, message parse | S1 |

---

### 6.7 Import QR depuis une image

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| IM-01 | Screenshot vCard | parse + save + liste | S1 |
| IM-02 | Screenshot URL | SimpleQR | S1 |
| IM-03 | Photo sans QR | SnackBar « Aucun QR code trouvé », pas de nav | S2 |
| IM-04 | Annuler le picker | retour import, no-op | S2 |
| IM-05 | Permission photos deny | message + Settings | S1 |
| IM-06 | Image HEIC / WebP | decode ou erreur claire | S2 |
| IM-07 | QR tout petit dans une grande photo | détecté **ou** hint « rapprocher » | S2 |

---

### 6.8 Import contacts téléphone

Détail batch : [`docs/manual-test.md`](../manual-test.md) §5.

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| IC-01 | 1 contact | apparaît (nom, tél, mail) | S1 |
| IC-02 | ≥ 5 contacts | dialog `k / N` non dismissible, puis fermeture | S1 |
| IC-03 | Dialog dark | pas de fond blanc forcé | S2 |
| IC-04 | Dialog EN | « Importing… » | S3 |
| IC-05 | Refus permission (1er) | pas de 2ᵉ dialog parasite | S1 |
| IC-06 | Permission révoquée | dialog « Accès requis » + Ouvrir les Réglages | S1 |
| IC-07 | Contact sans nom | pas de crash, fallback « Nom inconnu » | S2 |
| IC-08 | Doublon | pas N copies silencieuses — **noter le réel** | S2 |

---

### 6.9 Collection

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| CO-01 | Empty | empty state copy home.empty_collection + CTA | S2 |
| CO-02 | Liste | cartes papier, pas de cards Material élevées | S3 |
| CO-03 | Ouvrir une vCard | fiche / QR / actions | S1 |
| CO-04 | Ouvrir un simple | payload texte | S1 |
| CO-05 | Delete | disparait, atterrit Historique | S1 |
| CO-06 | Save PNG | galerie, ~2048², fond blanc, scannable | S1 |
| CO-07 | Share | sheet OS, destinataire reçoit une image scannable | S1 |
| CO-08 | PDF entry | nav vers export | S1 |
| CO-09 | Scroll 50+ cartes | 60 fps ressenti, pas de jank bloquant | S2 |

---

### 6.10 Historique / corbeille

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| HI-01 | Empty | copy empty_history | S3 |
| HI-02 | 1 vCard + 1 simple supprimés | 2 lignes, types corrects | S1 |
| HI-03 | Restore si existe | revient en collection | S2 |
| HI-04 | Purge si existe | vraiment parti, confirm destructif | S1 |

---

### 6.11 Événements

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| EV-01 | Empty | copy + CTA créer | S2 |
| EV-02 | Créer « Salon Tech 2026 » | apparaît, **activé** | S1 |
| EV-03 | Annuler dialog | no-op | S3 |
| EV-04 | Nom vide | pas d’event vide | S2 |
| EV-05 | Activer B alors que A actif | un seul actif | S1 |
| EV-06 | Désactiver | plus de bannière | S1 |
| EV-07 | Scanner pendant event actif | scan **rattaché** à l’event | S1 |
| EV-08 | Relance | actif persisté | S1 |

---

### 6.12 Export PDF

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| PD-01 | 0 sélection | CTA disabled ou message | S2 |
| PD-02 | 1 carte, 1/page | PDF partageable, QR scannable sur papier | S1 |
| PD-03 | 4 cartes, 2×2 | 4 QR lisibles, pas de crop | S1 |
| PD-04 | Annuler share sheet | pas de fichier orphelin obligatoire | S3 |
| PD-05 | Dark mode | PDF **fond clair** (impression), UI app sombre | S2 |

---

### 6.13 Réglages

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| ST-01 | Langue FR→EN | immédiat, persisté après kill | S1 |
| ST-02 | EN→FR | idem | S1 |
| ST-03 | Drapeaux | emoji 🇬🇧 / 🇫🇷, **pas** d’erreur asset `.si` | S3 |
| ST-04 | Dark ON | lerp ~300 ms, toutes les pages | S1 |
| ST-05 | Dark persisté | **kill + relance** — si reset, c’est un S2 (déjà noté hist.) | S2 |
| ST-06 | vCard 4.0 | voir VC-04/05 | S1 |
| ST-07 | Reciprocal | ST on/off = SR-04/07 | S2 |
| ST-08 | Lire le guide | popup, fermable | S2 |
| ST-09 | À propos | réseaux, liens externes, Retour OK | S3 |
| ST-10 | Nav bas | onglet Réglages sélectionné | S3 |

---

## 7. Non-fonctionnel (Apple interruptions + Google dogfood)

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| NF-01 | Rotation home / form / scanner | pas de perte de saisie, pas de crash | S2 |
| NF-02 | Split / multi-fenêtre Android | UI utilisable ou letterbox, pas de overflow jaune | S3 |
| NF-03 | Background 30 min | collection intacte | S1 |
| NF-04 | Appel / visio pendant scan | retour caméra OK | S2 |
| NF-05 | Low storage | save PNG : erreur claire, pas de crash | S2 |
| NF-06 | Offline total (avion) | **toute** l’app marche (local-first) | S0 si non |
| NF-07 | Changement d’heure / TZ | events / dates affichées cohérentes | S3 |
| NF-08 | Cold start après reboot téléphone | DB ouvre, pas de migration cassée | S0 |
| NF-09 | Deux instances (n’arrive pas) | — N/A mobile | — |
| NF-10 | Back Android vs chevron iOS | même sémantique (pop 1) | S2 |

---

## 8. Accessibilité (Apple VoiceOver + Android TalkBack + WCAG 2.2 AA)

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| A-01 | TalkBack home | chaque tile a un nom, pas juste « bouton » | S2 |
| A-02 | Cibles | ≥ 48 dp (tiles, nav, switches) | S2 |
| A-03 | Contraste | encre/papier et cendre/papier AA | S2 |
| A-04 | Dynamic Type / font scale 1.3 | pas d’overflow irrécupérable | S2 |
| A-05 | Switch dark / vCard4 | état annoncé (on/off) | S2 |
| A-06 | QR image | sémantique `qr_image` (pas muet) | S3 |
| A-07 | Focus order formulaire vCard | haut → bas logique | S3 |

---

## 9. i18n et locale device

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| L-01 | App FR, OS FR | tout en FR, aucun mot EN parasite hors noms propres (vCard, QR) | S2 |
| L-02 | App EN | Tools, Scan, Events… | S2 |
| L-03 | Clé manquante | affichage de la clé **uniquement** si bug — noter le path | S2 |
| L-04 | OS `de` sans pack | fallback **en**, pas de crash `zz.json` | S1 |
| L-05 | Dates / tel | formats locaux, pas `undefined` | S3 |

---

## 10. Vie privée / sécu (Microsoft SDL light)

EZQRContact **n’a pas de backend**. Toute requête réseau est un bug sauf
tap user sur un lien À propos.

| ID | Cas | Attendu | Sev |
|---|---|---|---|
| SE-01 | Charles / PCAPdroid pendant smoke | 0 host inattendu | S0 |
| SE-02 | Photo vCard | EXIF GPS **strippé** ou documenté | S2 |
| SE-03 | Injection vCard | VC-11/12 | S1 |
| SE-04 | Backup Android | données restent dans l’app sandbox | S2 |
| SE-05 | Logs debug | pas de vCard complète en `debugPrint` **release** | S2 |
| SE-06 | QR d’un tiers | jamais uploadé | S0 |

---

## 11. Compatibilité parseurs (le vrai métier)

| ID | Source du QR | Attendu | Sev |
|---|---|---|---|
| CP-01 | iPhone Camera (QR EZQR 3.0) | fiche contact iOS complète | S1 |
| CP-02 | Google Lens / Camera Android | idem | S1 |
| CP-03 | Outlook desktop (photo du QR) | vCard ouvrable | S2 |
| CP-04 | EZQR scanne iOS Contacts export | champs reconnus | S1 |
| CP-05 | EZQR scanne Google Contacts export | idem | S1 |
| CP-06 | EZQR 4.0 lu par iOS | tel/email quand même là | S1 |

Fixtures : `docs/test-qrcodes/` si présent, sinon générer à la volée.

---

## 12. Visual / DA ENCRE (dogfood design)

Pas des goûts : des **écarts au token**.

| ID | Check |
|---|---|
| DA-01 | Fond home = papier `#F4EFE6`, cartes `#FFFCF7`, jamais blanc `#FFF` |
| DA-02 | Cuivre `#C45C26` sur wells / CTA, marine sur section labels |
| DA-03 | Pas de `ElevatedButton` / `FilledButton` Material brut sur la home |
| DA-04 | Nav flottante, radius 18, ombre paper, pas de `BottomNavigationBar` stock |
| DA-05 | App bar scrim 10 % noir, status bar icônes lisibles |
| DA-06 | Dark : nuit `#141210`, pas un gris Material You violet |
| DA-07 | Press 0.98, pas de bounce 1.1 |

---

## 13. Pack regression 30 min (avant tag)

Jouer dans cet ordre, 1 Android + 1 iPhone :

1. Smoke §5  
2. VC-01, VC-03, VC-04, VC-11  
3. SC-01, SC-03, SC-07  
4. IM-01, IM-03  
5. IC-01, IC-05  
6. CO-05, CO-06, PD-02  
7. EV-02, EV-07  
8. ST-01, ST-04, ST-05  
9. NF-06 (avion)  
10. SE-01 si Charles dispo  

---

## 14. Exploratoire (session-based, 25 min)

Une charte = une phrase. Timer 25 min. Notes brutes, puis tickets.

Charte A — *« Je suis commercial en salon, 40 scans en 2 h, zéro cloud. »*  
Charte B — *« Je refuse toutes les permissions et j’essaie quand même. »*  
Charte C — *« Je suis VoiceOver, je veux le téléphone d’un contact scanné. »*  
Charte D — *« Je bascule FR/EN et dark toutes les 10 s pendant que je remplis une vCard. »*  
Charte E — *« Je colle de la merde dans chaque champ (emoji, RTL, 2 k caractères, `;`). »*

Stop quand le timer sonne. Ne pas « juste 5 minutes de plus ».

---

## 15. Template de bug (un ticket = un problème)

```
Titre : [S#][écran] résultat observé
Sev / Pri : S2 / P1
Build : 1.1.0+3 / commit / OS / device
Préconditions :
Steps :
  1.
  2.
Attendu :
Observé :
Fréquence : 1/1, 3/5, 1/10
Preuve : screenshot / vidéo / payload vCard
Workaround :
KB ? : nouveau | KB-torch | …
```

Règle Google : **pas** de « ça marche pas ». Une phrase, un résultat, un
environnement.

---

## 16. Bugs connus (ne pas re-ouvrir)

| ID | Sujet | Conduite |
|---|---|---|
| KB-torch | Torche Android parfois no-op | Noter modèle, ne pas S0 |
| KB-dark-persist | Dark mode hist. non persisté au kill | Vérifier ST-05 ; si toujours vrai → S2 assumé ou fixer |

Mettre à jour cette table quand un KB est fermé.

---

## 17. Feuille de sign-off

| | Android must | iPhone must |
|---|---|---|
| Smoke §5 | | |
| Regression §13 | | |
| Exploratoire (charte + durée) | | |
| S0 ouverts | | |
| S1 ouverts | | |
| Go / no-go | | |
| Testeur / date | | |

---

## 18. Ce que ce plan ne couvre pas

- Tests widget / unit → `flutter test` (obligatoire **avant** ce manuel).
- Captures store → `./scripts/capture_screenshots.sh`.
- Perf lab (systrace, 1000 cartes) → hors scope v1.1, noter en S3 si pain.
- Store listing / Capture d’écran marketing.

---

*Fin du plan. Prochaine révision : dès qu’un écran est ajouté ou qu’un KB
est fermé.*
