# Guide utilisateur EZQRContact

Échange de contacts en local, sur Android et iOS. Tes cartes restent sur
ce téléphone. Rien n'est envoyé, sauf une photo compressée (URL) pour que
le QR reste scannable.

L'app parle français ou anglais (Réglages). Version anglaise :
[user-guide.md](user-guide.md).

## Premier lancement

1. Trois écrans d'accueil. Tu peux passer.
2. Sur **Accueil**, trois pastilles (créer, scanner, collection). Tu
   peux passer. Relance depuis **Réglages → Lire le guide**.
3. Tu arrives sur **Accueil**.

## Créer ta carte

1. Accueil → **VCard QR code**.
2. Au minimum un nom. Téléphone, e-mail, org, poste, adresses sont
   facultatifs.
3. Optionnel : photo, couleur, logo, mise en page.
4. Générer. La carte est dans **Collection**.

Le QR encode une vCard (3.0 par défaut). Le destinataire n'a pas besoin
de cette app : l'appareil photo iPhone ou Android suffit.

**Photo :** un portrait brut dans le QR le rend illisible. En ligne,
l'app héberge un petit JPEG et écrit `PHOTO;VALUE=URI:`. Hors ligne, le
QR est du texte seulement.

La **vCard 4.0** se coche dans Réglages. Garde 3.0 sauf si tu sais que
l'autre téléphone la lit.

## QR simple

Accueil → **Simple QR code**. Texte ou URL. Stocké dans Collection.

## Scanner une carte

1. Accueil → **Scanner un QR** → **Scanner**.
2. Autorise la caméra. Lampe et bascule d'objectif sont sur des pastilles
   cuivre.
3. Une vCard ouvre l'écran résultat et enregistre la carte.
4. Si **Proposer ma carte en retour** est allumé (Réglages), tu peux
   renvoyer la tienne.

## Import depuis une capture

Accueil → **Importer un QR** → choisis une image. Décodeur ML Kit puis
ZXing (recadrage, redressement). Utile pour un QR à l'écran d'un PC ou
sur un badge.

## Importer les contacts du téléphone

Accueil → **Importer un contact**, ou Collection → **Tout importer**.

Les homonymes déjà dans Collection sont ignorés. Chaque contact devient
une carte **dans l'app**. Le carnet OS n'est pas obligatoire.

## Collection

Barre du bas **Collection**. Recherche, ouvrir une carte pour partager
ou supprimer.

**Multi-sélection :** reste appuyé **plus de deux secondes**. Des cases
apparaissent. Tout sélectionner, supprimer (confirmation) ou exporter la
sélection (même zip que Tout exporter). Retour ou la croix quitte le
mode.

**Tout exporter** écrit `ezqr_collection.zip` à la racine du zip :

- `contacts.vcf` pour les vCards
- `text_<id>_<slug>.txt` et `.png` pour les QR texte
- `index.txt`

## Historique

Barre du bas **Historique**. Cartes supprimées (soft delete). Surtout
lecture.

## Réglages

- Mode sombre
- vCard 4.0
- Proposer ma carte en retour
- Langue
- Lire le guide (relance les pastilles sur Accueil)
- Liens du projet

## Vie privée

| Donnée | Où |
|---|---|
| Cartes, historique | SQLite `qr_app.db` sur l'appareil |
| Langue, onboarding, interrupteurs | SharedPreferences |
| Contacts OS | Écrits **seulement** si tu autorises Contacts. Refus : le QR in-app existe quand même |
| Hébergement photo | Seulement si tu ajoutes une photo **et** que le téléphone est en ligne |

Pas de compte. Désinstaller l'app efface la base locale.

Politique : [PRIVACY.md](../../PRIVACY.md). L'hébergement photo
(catbox.moe, puis 0x0.st) n'a lieu que si tu ajoutes une photo et que
le téléphone est en ligne.

## Dépannage

**QR illisible.** Allège la carte (enlève la photo, ou passe hors ligne).
Reste en vCard 3.0. Imprime plus grand.

**Import galerie vide.** Recadre le code, ou passe par Scanner. Photo
d'écran : vise de face.

**Pas dans le carnet du téléphone.** Réglages OS → app → Contacts. Régénère,
ou ouvre la carte et enregistre.

**Le zip n'a pas les QR texte.** Utilise **Tout exporter** (ou l'export de
sélection).

## Installer

Sources : [README](../../README.md). APK : GitHub Releases sur un tag
`v*.*.*`.
