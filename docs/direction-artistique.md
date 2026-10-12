# Direction Artistique — EZQRContact

**Nom de code :** ENCRE  
**Produit :** EZQRContact  
**Support :** application mobile native (Flutter, iOS + Android)  
**Version cible :** v1.1 → v2.0  
**Date :** 12 octobre 2026  
**Statut :** applicable — le design de l’app suit ce document

---

## Sommaire

0. [Comment on construit une DA mobile](#0-comment-on-construit-une-da-mobile)
1. [Brief](#1-brief)
2. [Diagnostic de l’existant](#2-diagnostic-de-lexistant)
3. [Promesse, personnalités, positionnement](#3-promesse-personnalités-positionnement)
4. [Concept créatif — ENCRE](#4-concept-créatif--encre)
5. [Moodboard et territoire visuel](#5-moodboard-et-territoire-visuel)
6. [Identité verbale](#6-identité-verbale)
7. [Identité visuelle](#7-identité-visuelle)
8. [Design tokens](#8-design-tokens)
9. [Composants](#9-composants)
10. [Navigation, grille, layout](#10-navigation-grille-layout)
11. [Motion](#11-motion)
12. [Application écran par écran](#12-application-écran-par-écran)
13. [Accessibilité](#13-accessibilité)
14. [Do / Don’t](#14-do--dont)
15. [Gouvernance](#15-gouvernance)

---

## 0. Comment on construit une DA mobile

Une **direction artistique** n’est pas une charte de couleurs. C’est le fil
conducteur qui orchestre **intention stratégique + expression visuelle +
comportement d’interface**, pour qu’un produit soit reconnaissable en une
seconde — y compris sur un écran de 6 pouces, en plein salon, d’une main.

Méthode utilisée ici, adaptée aux apps mobiles (synthèse des pratiques
studio 2025–2026 : brief → recherche → concept → moodboard → tokens →
composants → écrans → gouvernance) :

| Étape | Question | Livrable |
|---|---|---|
| 1. Analyse | Qui, pourquoi, dans quel contexte physique ? | Brief + personas |
| 2. Diagnostic | Qu’est-ce qui cloche visuellement aujourd’hui ? | Audit UI |
| 3. Concept | Quelle **idée** unique tient tout le reste ? | Nom de code + phrase |
| 4. Moodboard | Quelle matière, quelle lumière, quel registre ? | Planche + interdits |
| 5. Tokens | Quelles valeurs concrètes (couleur, type, espace) ? | Design tokens |
| 6. Composants | Comment ça se traduit en boutons, cartes, nav ? | UI kit |
| 7. Écrans | Chaque écran respecte-t-il le concept ? | Spec d’application |
| 8. Déploiement | Comment on empêche la dérive ? | Ce document + le code |

Trois documents souvent confondus, à ne pas mélanger :

- **Moodboard** — exploration. Ambiance, pas règles.
- **Brand board** — l’identité figée en une planche.
- **DA / charte** — le mode d’emploi. C’est ce fichier.

Sur mobile, une DA doit en plus trancher :

- **Zones du pouce** (nav bas, CTA à portée).
- **Contraste en extérieur** (salons, néons, soleil).
- **Mode sombre** comme variante de la même matière, pas un thème
  « gamer » collé après coup.
- **Cibles de tap ≥ 48 dp**.
- **Temps** : un échange de carte dure 10 secondes. L’UI ne doit pas
  théâtraliser, elle doit **tenir**.

---

## 1. Brief

### Produit

EZQRContact est l’app open source qui permet d’échanger des contacts
professionnels **en face-à-face**, via un QR encodant une vCard, **sans
compte, sans cloud, sans abonnement**.

Données locales. GDPR par absence. Gratuit. MIT.

### Contexte d’usage (le vrai)

Pas un canapé. Un **salon**, un **forum étudiant**, un **RDV B2B**, un
afterwork. Bruit, lumière pourrie, une main tenue, l’autre qui tend un
téléphone. 5 à 200 échanges par jour. Le geste doit être aussi simple
qu’une carte papier, et plus digne.

### Promesse

> Tes coordonnées, ta couleur, ton logo — dans le téléphone de l’autre.
> Rien ne transite. Rien n’est loué.

### Ce que la DA doit faire ressentir

| Valeur | Traduction visuelle |
|---|---|
| Local-first, privé | Matière **solide**, pas de dégradés « cloud », pas de glassmorphism |
| Professionnel | Typo éditoriale, marges, silence. Pas de fun gratuit |
| Tangible | Papier, encre, grain. La carte est un **objet** |
| Indépendant | Pas le bleu SaaS de Blinq / HiHello / LinkedIn |
| Rapide | Hiérarchie brutale. Une action primaire par écran |
| Mémorable | Une teinte que personne d’autre n’utilise : le **cuivre** |

### Ce que la DA ne doit pas faire

- Sembler une app QR générique (bleu Material + pills).
- Sembler un SaaS de carte digitale (gradient purple, 3D fake, illustrations
  stock de poignées de main).
- Sembler un outil développeur (terminal, zinc froid, tout en grisé).

---

## 2. Diagnostic de l’existant

Audit visuel de la v1 (captures `docs/screenshots/`) :

| Problème | Symptôme | Effet |
|---|---|---|
| **Deux marques en même temps** | Boutons bleu `#2563EB`, navbar violet `#6635BB` | L’app n’a pas de couleur |
| **Pills Material par défaut** | `ElevatedButton` full-width, radius 50 % | 2018, générique, « Flutter starter » |
| **Typo système brute** | Roboto / SF, aucun rythme | Zéro personnalité |
| **Fond blanc / noir purs** | `#FFFFFF` / quasi `#000` | Clinique, fatigue, pas de matière |
| **Cartes Material elevation 3** | Ombre grise, title en `text-muted` | Les contacts ont l’air désactivés |
| **Home = liste de 6 CTA identiques** | Aucune hiérarchie | On ne sait pas par où commencer |
| **Scanner = un bouton au milieu** | Écran vide | L’action la plus critique a l’air d’un placeholder |
| **Settings = encore des pills bleues** | Guide, thème, about au même poids | Options ≠ actions |
| **Pas de wordmark** | Titre « Actions QR » hardcodé | L’app n’a pas de visage |

Le produit a une idée forte (la carte vivante, la config visuelle
préservée). L’UI actuelle **ne raconte pas cette idée**. Elle raconte
« j’ai généré un QR ».

---

## 3. Promesse, personnalités, positionnement

### Personnalités (depuis le product brief)

1. **Commercial B2B** — 5–15 RDV / semaine. 10 secondes chrono.
2. **Exposant** — 50–200 scans / jour. Grouper, exporter, ne rien perdre.
3. **Recruteur** — retrouver un visage 2 semaines plus tard.
4. **Freelance** — la carte doit **ressembler à sa marque**, pas à l’app.

Tous ont en commun : ils tendent un objet. La DA traite l’écran comme
**cet objet**.

### Positionnement visuel

```
froid, SaaS, cloud          EZQR Contact           analogique luxe
Blinq / HiHello  ----------●------------------  letterpress / meishi
bleu, gradient, 3D          ENCRE                 papier, cuivre, silence
```

On n’est pas un luxe inaccessible (pas de noir/or Popl). On n’est pas un
outil geek. On est **la carte de visite bien imprimée, version téléphone**.

### Archétype de marque

**L’artisan précis.** Pas le magicien. Pas le corporate. Quelqu’un qui
coupe juste, encadre juste, n’ajoute rien.

---

## 4. Concept créatif — ENCRE

> **La carte de visite n’a pas disparu. Elle a changé de support.**

**ENCRE** est le nom de code de la DA.

L’encre, c’est :

- ce qui **reste** (local-first, pas un flux) ;
- ce qui **s’imprime** (identité visuelle préservée au scan — le
  différentiateur produit) ;
- ce qui est **matériel** (papier, grain, pression letterpress) ;
- ce qui est **définitif** (un contact, pas un lead dans un CRM cloud).

Le QR n’est plus un gadget technique. C’est le **sceau** de la carte —
l’équivalent contemporain d’un tampon cire, d’un coin letterpress.

Tout le système visuel descend de cette phrase :

- fonds = **papier**, jamais blanc optique ;
- texte = **encre chaude**, jamais noir froid ;
- accent = **cuivre**, la couleur d’une encre métallique ;
- secondaire = **marine**, l’encre d’architecte ;
- cartes UI = **cartes**, ratio, coin, ombre de feuille ;
- motion = **pression**, pas rebond de jeu.

---

## 5. Moodboard et territoire visuel

### Planche d’atmosphère

![Carte letterpress, encre cuivre, papier ivoire, lumière de fin
d’après-midi — le geste que l’app remplace.](da/hero-encre.jpg)

### Brand board

![Spécimen d’identité EZQR Contact : wordmark, papier, encre, cuivre,
marine.](da/brand-board.jpg)

### Mots-clés du territoire

`papier ivoire` · `letterpress` · `cuivre brûlé` · `encre chaude` ·
`meishi` · `sceau QR` · `silence` · `objet` · `salon, pas canapé` ·
`précis` · `local`

### Références (registre, pas copies)

| Référence | Ce qu’on prend | Ce qu’on laisse |
|---|---|---|
| Carte letterpress (Feld, Moo Luxe) | Grain, pression, coins 3 mm | Le fétichisme print |
| Meishi japonaise | Précision, deux mains, respect | L’ornement |
| Muji / papier washi | Neutre chaud, marges | Le sans-marque total |
| Polaroid d’un bureau | Lumière réelle, objets | La nostalgie Instagram |
| Architecture d’intérieur 1970s | Teal profond, cuivre, bois | L’orange kitsch |
| Apps : Things 3, Before, Slow | Typo, calme, matière | Le luxe payant |

### Interdits d’ambiance

- Néon, cyberpunk, glassmorphism, mesh gradient.
- Illustrations stock (poignée de main, avatars 3D, confettis).
- Bleu `#2563EB` et ses cousins « trust SaaS ».
- Violet Material.
- Noir pur `#000` et blanc pur `#FFF` en aplat d’écran.
- Emojis dans l’UI chrome (ok dans le contenu utilisateur).
- Micro-animations « bounce » / scale 1.1.

---

## 6. Identité verbale

La DA visuelle sans voix, c’est un costume. Ton de l’app :

| Axe | On est | On n’est pas |
|---|---|---|
| Température | Direct, chaleureux | Corporate, ni « cool » |
| Longueur | Une phrase. Un verbe. | Tutoriels, adverbes |
| Tutoiement FR | Tu | Vous (trop banque) |
| EN | You, short | « Simply », « seamlessly » |

### Vocabulaire

**On dit** : carte, contact, scan, échange, salon, local, chez toi.  
**On ne dit pas** : lead, pipeline, sync cloud, workspace, magic, boom.

### Microcopy type

| Situation | Phrase |
|---|---|
| Home, tagline | Échangez. Sans cloud. |
| Empty collection | Aucune carte encore. Scannez-en une. |
| Scan OK | Carte enregistrée. |
| Permission caméra | La caméra sert uniquement à lire un QR. Rien n’est envoyé. |
| CTA principal | Créer ma carte / Scanner |
| CTA secondaire | Plus tard / Collection |

Les titres d’écran sont des **noms** (Collection, Événements, Options),
pas des verbes marketing.

---

## 7. Identité visuelle

### 7.1 Wordmark

```
EZQR          ← Outfit ExtraBold, tracking serré, ENCRE
Contact       ← Fraunces Italic, optical display, même ligne
     ⌜⌝       ← marque QR : trois coins finder, CUIVRE
```

- Jamais d’ombre sur le wordmark.
- Jamais d’outline.
- Le monogramme QR (trois coins) peut vivre seul, 16–24 dp, cuivre.
- Surplus : ne pas écrire « Easy QR Contact App » dans l’UI. Le produit
  s’appelle **EZQR Contact**.

### 7.2 Palette

Noms de couleur = matière, pas fonction. Les rôles sémantiques sont dans
les tokens (§8).

#### Jour — papier

| Nom | Hex | Rôle |
|---|---|---|
| **Papier** | `#F4EFE6` | Fond d’écran |
| **Carte** | `#FFFCF7` | Surface élevée (cards, champs, nav) |
| **Sable** | `#EBE4D8` | Surface tertiaire, chips off |
| **Encre** | `#1A1612` | Texte primaire |
| **Cendre** | `#6F675C` | Texte secondaire, icons off |
| **Cuivre** | `#C45C26` | Accent, CTA, sélection |
| **Cuivre clair** | `#FFF8F0` | Texte sur cuivre |
| **Marine** | `#1F3D4D` | Secondaire, titres H2, info |
| **Ligne** | `#DDD4C6` | Hairline, bordure |
| **Vert encre** | `#3D6B4F` | Succès |
| **Rouge cachet** | `#B42318` | Danger, suppression |

#### Nuit — encre

Même système, lumière inversée. Le cuivre **s’éclaircit** pour garder le
contraste, le papier devient un brun-nuit chaud (pas un zinc froid).

| Nom | Hex | Rôle |
|---|---|---|
| **Nuit** | `#141210` | Fond |
| **Carte nuit** | `#1E1B18` | Surface |
| **Sable nuit** | `#2A2622` | Surface tertiaire |
| **Ivoire** | `#F3EDE4` | Texte primaire |
| **Cendre nuit** | `#A89F93` | Texte secondaire |
| **Cuivre nuit** | `#E07A3D` | Accent |
| **Encre sur cuivre** | `#1A1612` | Texte sur CTA |
| **Marine nuit** | `#8BB8C9` | Secondaire |
| **Ligne nuit** | `#3A342E` | Hairline |
| **Vert nuit** | `#7BC49A` | Succès |
| **Rouge nuit** | `#F97066` | Danger |

#### Règles d’usage

1. **Un seul cuivre par écran** comme action. Le reste est encre, marine
   ou cendre.
2. Le cuivre n’est **jamais** un fond d’écran. C’est une encre, pas un
   mur.
3. Marine ne concurrence pas le cuivre : titres de section, états
   « info », icônes secondaires.
4. Interdiction des dégradés cuivre→marine. Les deux encres ne se
   mélangent pas.
5. Les photos de profil restent des photos. Pas de duotone de marque.

### 7.3 Typographie

Deux familles, un rôle chacune. Jamais une troisième.

| Rôle | Famille | Graisses | Usage |
|---|---|---|---|
| **Display** | **Fraunces** (optical, soft) | 600, italic 500 | Titres d’onboarding, tagline home, nom sur une carte |
| **UI** | **Outfit** | 400, 500, 600, 700, 800 | Tout le reste : labels, boutons, nav, champs |

Fraunces apporte le **papier** (serif doux, un peu letterpress).  
Outfit apporte la **précision** (géométrique, lisible à 12 sp, moderne).

Échelle (sp, à multiplier par le textScaler système) :

| Token | Famille | Size | Weight | Line | Tracking | Usage |
|---|---|---|---|---|---|---|
| `display` | Fraunces | 32 | 600 | 1.15 | −0.5 | Onboarding, hero |
| `headline` | Fraunces | 22 | 600 | 1.25 | −0.3 | Nom d’une carte, dialog title |
| `title` | Outfit | 18 | 700 | 1.25 | −0.3 | AppBar, card title |
| `body` | Outfit | 15 | 400 | 1.45 | 0 | Paragraphes, listes |
| `body-em` | Outfit | 15 | 600 | 1.45 | 0 | Labels de champ, list tile |
| `caption` | Outfit | 12 | 500 | 1.35 | 0.2 | Meta, dates, hints |
| `overline` | Outfit | 11 | 600 | 1.2 | 1.4 | Titres de section, en petites capitales |
| `button` | Outfit | 15 | 600 | 1.2 | 0.2 | CTA |
| `tab` | Outfit | 11 | 600 | 1.1 | 0.3 | Navbar |

Fraunces **jamais** en dessous de 18 sp. En dessous, Outfit.

### 7.4 Formes

Les coins d’une carte de visite : ~3 mm. Sur mobile, ça donne une
famille **modérée**, ni squircle iOS, ni pill Material.

| Token | dp | Usage |
|---|---|---|
| `r-xs` | 6 | Chips, badges |
| `r-sm` | 10 | Inputs, petits boutons icon |
| `r-md` | 14 | Boutons, tiles |
| `r-lg` | 18 | Cards, nav flottante |
| `r-xl` | 24 | Sheets, dialogs |
| `r-full` | 999 | Avatars, FAB, pastilles |

**Interdit :** `BorderRadius.circular(999)` sur un bouton d’action
pleine largeur (les pills actuelles).

### 7.5 Élévation et matière

Pas d’`elevation` Material (teinte violette, ombre sale). Des ombres
**encre**, très transparentes, comme une feuille sur une autre.

| Niveau | Ombre (jour) | Bordure |
|---|---|---|
| Flat | aucune | hairline `Ligne` |
| Rest | `0 1 2 rgba(26,22,18,.04)` + `0 4 12 rgba(26,22,18,.06)` | hairline |
| Float | `0 8 24 rgba(26,22,18,.10)` | hairline |
| Pressed | ombre rest, translateY +1 | hairline |

Nuit : mêmes recettes, alpha × 1.6, ombre noire.

Chaque carte a **toujours** une hairline. L’ombre seule ne suffit pas
(surtout en dark).

### 7.6 Iconographie

- Material Symbols / Material Icons **Rounded**, optical size 24.
- Trait visuel : filled pour l’état actif, outlined pour le repos.
- Couleur : cendre au repos, cuivre si sélection / action primaire,
  marine si info, rouge cachet si destructif.
- Pas de Font Awesome dans le chrome de l’app (réservé aux réseaux
  sociaux dans À propos).
- Marque QR maison (trois coins) pour le wordmark uniquement.

### 7.7 Imagerie

- Photos de profil : carré 1:1, radius `r-sm`, jamais cercle obligatoire
  (un cercle, c’est un avatar de réseau social ; un carré légèrement
  arrondi, c’est une photo de carte).
- Logos de carte : contain, fond carte, pas de recadrage agressif.
- Pas d’illustration décorative. Un empty state = icône dans un carré
  sable + 2 lignes de texte + un CTA. Point.

---

## 8. Design tokens

Source de vérité code : `lib/colors.dart` + `lib/theme/tokens.dart`.
Toute valeur magique dans un widget est une violation de DA.

### 8.1 Couleur (clés `currentColors`)

Compatibilité v1 conservée (`bg`, `surface`, `text`, `text-muted`,
`button-color`, `popup-*`) et étendue :

| Clé | Jour | Nuit |
|---|---|---|
| `bg` | `#F4EFE6` | `#141210` |
| `surface` | `#FFFCF7` | `#1E1B18` |
| `surface-raised` | `#EBE4D8` | `#2A2622` |
| `text` | `#1A1612` | `#F3EDE4` |
| `text-muted` | `#6F675C` | `#A89F93` |
| `button-color` | `#C45C26` | `#E07A3D` |
| `on-button` | `#FFF8F0` | `#1A1612` |
| `navy` | `#1F3D4D` | `#8BB8C9` |
| `border` | `#DDD4C6` | `#3A342E` |
| `success` | `#3D6B4F` | `#7BC49A` |
| `danger` | `#B42318` | `#F97066` |
| `popup-background` | `#FFFCF7` | `#1E1B18` |
| `popup-text` | `#1A1612` | `#F3EDE4` |
| `popup-h1` | `#1A1612` | `#F3EDE4` |
| `popup-h2` | `#1F3D4D` | `#8BB8C9` |
| `shadow` | `#1A1612` | `#000000` |

Le lerp 300 ms déjà en place dans `DarkModeProvider` s’applique à **toutes**
ces clés. Le passage jour ↔ nuit est une **fondu d’encres**, pas un
flash.

### 8.2 Espacement (grille 4)

`4, 8, 12, 16, 20, 24, 32, 40, 48, 64`

| Token | dp | Usage |
|---|---|---|
| `s-1` | 4 | Gutters internes fins |
| `s-2` | 8 | Entre icône et label |
| `s-3` | 12 | Padding de chip, gap de grille |
| `s-4` | 16 | Padding de card, marge d’écran latérale |
| `s-5` | 20 | Padding de page |
| `s-6` | 24 | Entre sections |
| `s-8` | 32 | Après un hero |
| `s-10` | 40 | Marge basse au-dessus de la nav |

Marge écran : **20 dp**. Jamais 40 dp « pour aérer » (la home actuelle
gaspille la largeur).

### 8.3 Tap target

Minimum **48 × 48 dp**. Les icon buttons de la card (view, QR, delete)
passent à 48, même si l’icône reste 22.

### 8.4 Durées

| Token | ms | Courbe | Usage |
|---|---|---|---|
| `t-micro` | 120 | ease-out | Press scale |
| `t-fast` | 200 | ease-out | Couleur, fade |
| `t-med` | 300 | ease-in-out-cubic | Thème, expand card |
| `t-page` | 400 | ease-in-out | PageView onboarding |

Press : scale **0.98**, jamais 1.1.

---

## 9. Composants

### 9.1 Bouton primaire — `AppButton.primary`

- Fond cuivre, texte `on-button`, radius `r-md`, hauteur 52.
- Icon leading 20 dp, gap 8.
- Press : scale 0.98 + assombrissement 6 %.
- Un seul par écran. C’est **l’encre**.

### 9.2 Bouton secondaire — `AppButton.secondary`

- Fond transparent, hairline `border`, texte `text`.
- Même hauteur, même radius.
- Pour « Plus tard », « Collection », « Annuler fort ».

### 9.3 Bouton ghost

- Pas de bord, texte marine ou encre, pour actions tertiaires.

### 9.4 Action tile (home)

Carte `surface` + hairline + ombre rest.  
À gauche : carré 44×44, radius `r-sm`, fond cuivre 12 %, icône cuivre.  
Titre Outfit 600 15. Sous-titre caption cendre. Chevron cendre.  
Featured (VCard, Scanner) : hauteur ~88, sous-titre visible.  
Secondaire : grille 2×2, plus compacte.

### 9.5 Paper card

Le composant de base de toute liste (contacts, events, settings groups).

- Fond `surface`, radius `r-lg`, hairline, ombre rest.
- Padding interne 16.
- Titre en `text` (jamais `text-muted` — bug v1).
- Expand : fade 300 ms, pas d’accordéon violent.

### 9.6 AppBar

- Fond `bg`, **aucune élévation**, hairline bas 1 px `border`.
- Titre Outfit 700 18, encre.
- Icons 24, encre.
- Home : wordmark à la place du titre.

### 9.7 Navbar

Barre **flottante**, pas collée bord à bord.

- Conteneur `surface`, radius `r-lg`, hairline, ombre float.
- Marge 16 / 12 bas, hauteur interne 64, SafeArea.
- 4 items : Accueil, Collection, Historique, Options.
- Actif : icône filled cuivre + label encre + tic cuivre 16×2 sous
  l’icône.
- Inactif : outlined, cendre.
- **Plus jamais de violet.**

### 9.8 Champs

- Fond `surface`, radius `r-sm`, bord `border`.
- Focus : bord cuivre 1.5 px, pas d’ombre colorée Material.
- Label Outfit 12 cendre → encre au focus.
- Fill toujours, jamais underline seul.

### 9.9 Switch — `AppSwitch`

- Track off : `surface-raised`.
- Track on : **cuivre**.
- Thumb blanc/ivoire, icône check/close 14.
- C’est le même composant qu’en v1, recoloré.

### 9.10 Banner événement

- Plus un aplat bleu full-bleed.
- Bandeau `navy`, texte ivoire, radius 0 (il est sticky, c’est une
  **barre d’atelier**, pas une card). Icône event 16. Chevron.
- En dark : marine nuit, texte encre.

### 9.11 FAB

- Cuivre, icône `on-button`, radius `r-md` (squircle, pas cercle).
- Un seul : export PDF sur Collection.

### 9.12 Chips filtre (événements)

- Off : fond sable, texte encre, radius `r-xs`.
- On : fond cuivre, texte `on-button`.
- Hauteur 32, padding H 12.

### 9.13 Dialog / sheet

- Fond `popup-background`, radius `r-xl` haut (sheet) ou tout (dialog).
- Titre Fraunces 22 ou Outfit 18 selon la longueur.
- Actions : secondaire à gauche, primaire cuivre à droite.
- Guide markdown : H1 encre, H2 marine, body encre. Plus le markdown
  « Word 2003 ».

### 9.14 Empty state

Carré sable 72×72, icône 32 cendre, titre Outfit 600, body caption,
CTA secondaire. Centré, max-width 280.

### 9.15 Toast

`toastification` conservé. Fond encre, texte ivoire, radius `r-md`.
Succès : tic vert encre. Erreur : rouge cachet. Jamais un toast blanc
illisible.

---

## 10. Navigation, grille, layout

### Grille

- 1 colonne, padding 20.
- 2 colonnes pour les tiles secondaires home, gap 12.
- Largeur max de contenu : 600 (tablette) — centré.

### Bottom nav — 4 onglets, inchangés fonctionnellement

| Index | Route | Label | Icône |
|---|---|---|---|
| 0 | `/options` | Accueil | `home_rounded` |
| 1 | `/collection` | Collection | `style_rounded` |
| 2 | `/history` | Historique | `history_rounded` |
| 3 | `/settings` | Options | `settings_rounded` |

La DA **ne casse pas** l’IA v1. Elle la habille. (La spec UX v2
« Ma Carte / Scanner / Contacts / Plus » reste une cible d’architecture,
pas de ce sprint visuel.)

### Hiérarchie d’un écran type

```
[ AppBar wordmark / titre ]
[ Banner événement si actif ]
[ Hero ou search — 0 ou 1 ]
[ Contenu ]
[ CTA primaire s’il est unique et critique ]
[ Navbar flottante ]
```

---

## 11. Motion

Principe : **pression d’un tampon**, pas ressort.

- Page : fade + 8 dp slide up, 400 ms.
- Expand card : size + fade, 300 ms cubic.
- Thème : lerp couleurs 300 ms (déjà là) — on le garde, c’est très
  « encre qui change ».
- Tap : scale 0.98 / 120 ms.
- Haptic : `mediumImpact` au scan réussi (déjà là) — c’est le tampon
  qui pose. On le garde.
- Interdit : bounce, elastic, rotation décorative, Lottie de confettis.

---

## 12. Application écran par écran

### 12.1 Onboarding

Fond papier. Skip en caption, en haut à droite.  
Icône 72 dans un carré sable radius 18, cuivre.  
Titre Fraunces 32, centré. Body Outfit 15 cendre, max 2 lignes.  
Dots : cuivre (actif, 16×6 pill) / sable (inactif, 6×6).  
Dernier écran : CTA primaire « Créer ma carte ».

### 12.2 Accueil (`/options`)

C’est la **devanture**.

```
EZQR Contact                    [marque QR]
Échangez. Sans cloud.
Vos cartes restent sur ce téléphone.

┌─────────────────────────────────────┐
│ [🪪]  Carte VCard                 › │
│       Créez votre carte de visite   │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [📷]  Scanner                     › │
│       Capturez un contact           │
└─────────────────────────────────────┘

AUSSI
┌──────────────┐  ┌──────────────┐
│ Simple QR    │  │ Importer     │
└──────────────┘  └──────────────┘
┌──────────────┐  ┌──────────────┐
│ Contacts tel │  │ Événements   │
└──────────────┘  └──────────────┘
```

Plus de 6 pills identiques. VCard et Scanner sont **au-dessus**, ce sont
les deux gestes du produit.

### 12.3 Scanner

Écran papier. Une paper card centrée : icône scanner 48, titre, une
phrase (« Cadrez le QR. Rien n’est envoyé. »), CTA primaire pleine
largeur. Plus un bouton perdu au milieu du blanc.

### 12.4 Import image

Même structure que Scanner, icône `image_outlined`.

### 12.5 Générateur VCard / Simple

AppBar titre. Champs paper. Section « Apparence » en overline marine.  
Le color swatch : 36×36, radius 10, hairline.  
Submit : `AppButton.primary` « Générer la carte ».  
Le punch scale 1.1 du `AnimatedSubmitButton` est retiré au profit du
0.98 DA.

### 12.6 Collection

Search paper. Chips événements. Liste de paper cards.  
Empty : icône style, « Aucune carte encore. », CTA Scanner.  
FAB export : cuivre squircle.

Titre de card : **encre bold**, plus jamais muted. Photo carrée radius
8. Chevron cendre.

### 12.7 Résultat de scan

C’est **la carte capturée** — le différentiateur.  
Paper card, bandeau haut 8 dp dans la **couleur de l’émetteur**
(`visual_config`). Nom en Fraunces 22. Méta Outfit.  
CTA primaire : Ajouter aux contacts. Secondaire : Voir la collection.

### 12.8 Événements

Liste paper. Badge « Actif » cuivre. Empty + CTA créer.  
FAB extended cuivre « Nouvel événement ». Dialog paper.

### 12.9 Historique (corbeille)

Même liste, meta « Supprimé le » en rouge cachet 12. Empty calme, pas
de CTA agressif.

### 12.10 Options

Groupes paper, plus de pills.

```
APPARENCE
  Langue            [FR ▾]
  Mode sombre       [switch]
  Guide             ›
  À propos          ›

VCARD
  Format vCard 4.0  [switch]

ÉCHANGE
  Proposer ma carte [switch]
```

### 12.11 PDF export

Liste + checkbox cuivre. Barre bas paper : chips layout + CTA cuivre.

### 12.12 Guide (dialog)

Paper, radius 24, markdown recalé sur la typo DA. Bouton Fermer ghost.

---

## 13. Accessibilité

- Contraste **WCAG AA** minimum sur texte et CTA. Cuivre `#C45C26` sur
  `#FFF8F0` ≥ 4.5:1 (texte bouton 15/600). Encre sur papier = AAA.
- Dynamic Type : toutes les tailles passent par `Theme.textTheme` donc
  par `MediaQuery.textScaler`. Fraunces plafonnée : au-delà de 1.4×,
  bascule visuelle acceptable (clip plutôt que overflow hide).
- Tap ≥ 48 dp.
- Semantics déjà présentes (`semantics.*`) : on les conserve, on n’en
  casse aucune.
- Daltonisme : l’information ne repose jamais sur le cuivre seul
  (icône + label).
- Réduction de motion : le lerp de thème reste (c’est de la couleur,
  pas du mouvement de layout). Les scale press se désactivent si
  `disableAnimations`.

---

## 14. Do / Don’t

### Do

- Fond papier. Texte encre. Un CTA cuivre.
- Hairline sur chaque carte.
- Fraunces pour un **nom** et un **hero**. Outfit partout ailleurs.
- Carré légèrement arrondi pour les photos.
- Navbar flottante, 4 items, cuivre = actif.
- Empty states secs, un verbe.
- Garder le haptic du scan.

### Don’t

- Bleu Material, violet navbar, pills full-radius.
- Fond blanc `#FFF` ou noir `#000`.
- Deux CTA cuivre sur le même écran.
- Fraunces en caption ou en bouton.
- Dégradé, glow, glass, Lottie.
- Titre de contact en `text-muted`.
- `Colors.blue` / `Colors.green` hardcodés sur les avatars.
- Scale 1.1 « punch » au tap.
- Écran vide avec un seul bouton orphelin.

---

## 15. Gouvernance

| Quoi | Où |
|---|---|
| Ce document | `docs/direction-artistique.md` |
| Tokens couleur | `lib/colors.dart` |
| Spacing, radius, motion | `lib/theme/tokens.dart` |
| ThemeData | `lib/theme/app_theme.dart` |
| Typo | `lib/theme/typography.dart` |
| Composants | `lib/components/app_button.dart`, `action_tile.dart`, `empty_state.dart`, `section_label.dart`, `paper_card.dart` |
| Fonts | `assets/fonts/` (Outfit, Fraunces, SIL OFL) |

**Règle Dart :** aucune condition ternaire `cond ? a : b`. Utiliser
`if` / `else` (instruction ou collection-if). `??`, `?.` et les types
nullables (`String?`) restent autorisés. Dart n’a pas de lint
`no_ternary` natif : la règle est dans `analysis_options.yaml` et
enforcée par `test/lint/no_ternary_test.dart`.

**Règle affichage :** un `return` de `build` ne contient que des
widgets / composants. Aucun algorithme, aucun IIFE `() { ... }()`.
L’algo se calcule **au-dessus du return**, ou **dans un composant**.
Collection-if de widgets autorisée. Voir
`test/lint/no_iife_in_display_test.dart`.

**Règle :** une nouvelle couleur, une nouvelle fonte, un nouveau radius
= une PR qui met à jour **ce fichier d’abord**, le token ensuite, le
widget en dernier. Jamais l’inverse.

**Revue :** tout écran nouveau se relit avec la checklist :

1. Est-ce que ça ressemble à une carte posée sur du papier ?
2. Y a-t-il **un** cuivre ?
3. Le nom d’une personne est-il en Fraunces ou en Outfit 700, donc
   **lisible comme un nom** ?
4. Est-ce utilisable d’une main, en extérieur ?

Si non, ce n’est pas ENCRE. Donc ce n’est pas EZQR Contact.

---

*Fin de la direction artistique. Toute l’UI de l’app doit pouvoir se
lire comme une carte bien imprimée.*
