# Tests manuels — EZQRContact

Checklist device à exécuter avant chaque release ou après un merge touchant
un flux utilisateur. Les tests unitaires couvrent la logique pure ; ce document
couvre les interactions native (caméra, contacts, galerie, fichiers) que les
tests automatisés ne peuvent pas atteindre.

Plateforme cible : iOS 16+ et Android 13+. Signaler tout écart entre les deux.

---

## 1. Génération QR vCard (format 3.0 — défaut)

### 1.1 Cas nominal — tous les champs

1. Onglet **Créer** > **vCard**
2. Remplis :
   - Nom : `Dupont`, Prénom : `Marie`, Org : `Acme Corp`
   - Poste : `DT`, Tél pro : `+33 6 12 34 56 78`, Tél perso : `+33 1 23 45 67 89`
   - Email : `marie.dupont@acme.fr`, Adresse pro : `12 rue de la Paix, 75001 Paris`
3. Valide > QR généré
4. Scanne depuis l'app Contacts iOS/Android

**Attendu :** contact créé avec les 8 champs, aucun caractère parasite.

### 1.2 Vérification payload brut

1. Lis le QR via un lecteur tiers (iPhone Camera, Google Lens)
2. Copie le texte brut

**Attendu (structure minimale) :**
```
BEGIN:VCARD
VERSION:3.0
N:Dupont;Marie;;;
FN:Marie Dupont
TEL;TYPE=WORK,VOICE:+33 6 12 34 56 78
EMAIL;TYPE=INTERNET:marie.dupont@acme.fr
END:VCARD
```
Séparateurs de lignes CRLF. Lignes > 75 octets repliées avec `\r\n ` (espace).

### 1.3 Champs vides — uniquement nom + email

1. Remplis uniquement **Nom** : `Martin`, **Email** : `a@b.com`
2. Génère et importe

**Attendu :** `N:Martin;;;;` et `FN:Martin` présents, pas de ligne TEL/ORG/ADR.

### 1.4 Génération QR texte simple

1. Onglet **Créer** > **Simple**
2. Saisis une URL ou du texte quelconque
3. Génère

**Attendu :** QR visible, scanne et retourne le texte exact saisi.

---

## 2. Toggle vCard 4.0

### 2.1 Activer et vérifier le format

1. **Paramètres** > active le toggle **vCard 4.0**
2. Crée un QR vCard, lis le payload brut

**Attendu (différences vs 3.0) :**
```
VERSION:4.0
TEL;TYPE=work,voice;VALUE=uri:tel:+33612345678
EMAIL:marie.dupont@acme.fr
```
`TYPE=` en minuscules, `VALUE=uri:tel:` sur les numéros.

### 2.2 Persistance après kill de l'app

1. Toggle ON > force-quit > relance
2. Génère un QR

**Attendu :** format 4.0 toujours actif (toggle reste ON).

### 2.3 Retour à 3.0

1. Toggle OFF > génère un QR

**Attendu :** `VERSION:3.0`, `TEL;TYPE=WORK,VOICE:`.

---

## 3. Scanner QR par caméra

### 3.1 Scan vCard tierce source

1. Onglet **Scanner** > autorise la caméra
2. Scanne un QR vCard émis par iPhone Contacts / Google Contacts

**Attendu :** contact parsé et affiché, proposé à la sauvegarde.

### 3.2 Scan QR texte simple

1. Scanne un QR contenant du texte brut (URL, UUID…)

**Attendu :** texte affiché, sauvegardé comme SimpleQR.

### 3.3 Contrôles caméra

- Bouton **Retourner caméra** — bascule front/rear sans crash
- Bouton **Torche** — allume/éteint sans crash

---

## 4. Scanner QR depuis la galerie

### 4.1 Image contenant un QR vCard

1. Onglet **Importer image**
2. Sélectionne une image de galerie contenant un QR vCard

**Attendu :** contact parsé, sauvegardé, redirection vers la liste.

### 4.2 Image contenant un QR texte simple

1. Sélectionne une image contenant un QR avec du texte brut (URL, texte…)

**Attendu :** SimpleQR sauvegardé, redirection vers la liste.

### 4.3 Image sans QR code

1. Sélectionne une photo ordinaire (paysage, portrait…)

**Attendu :** SnackBar "Aucun QR code trouvé dans cette image" — aucun crash, aucune redirection.

### 4.4 Annulation du picker

1. Ouvre le picker > appuie sur Annuler sans sélectionner

**Attendu :** retour sur la page d'import, aucune action déclenchée.

---

## 5. Import depuis les contacts du téléphone

### 5.1 Flux nominal

1. Onglet **Créer** > **Importer contact**
2. Autorise l'accès contacts
3. Sélectionne 1 contact > valide

**Attendu :** contact apparu dans la liste principale avec nom, tél et email.

### 5.2 Import multiple

1. Répète en sélectionnant 3 contacts à la fois

**Attendu :** 3 entrées créées, aucun doublon.

### 5.3 Refus de permission

1. Révoque la permission contacts (Réglages > Confidentialité)
2. Tente d'importer

**Attendu :** message d'erreur ou dialog de permission — pas de crash.

---

## 6. Sauvegarde du QR en fichier PNG

1. Ouvre un QR existant > option **Enregistrer image**
2. Vérifie dans la galerie Photos/Fichiers

**Attendu :** fichier PNG présent, qualité 2048×2048, fond blanc.

---

## 7. Historique / corbeille

### 7.1 Suppression et vérification corbeille

1. Dans la liste principale, supprime un QR (swipe ou bouton)
2. Onglet **Historique**

**Attendu :** entrée supprimée visible dans l'historique avec type correct (`vcard` ou `simple`).

### 7.2 Mélange simple + vcard

1. Supprime 1 SimpleQR et 1 vCard
2. Vérifie l'historique

**Attendu :** les 2 entrées présentes, type affiché correctement pour chacune.

---

## 8. Guide first-run

### 8.1 Premier lancement

1. Désinstalle l'app ou efface les données
2. Relance l'app

**Attendu :** popup de guide affiché automatiquement.

### 8.2 Ne s'affiche plus

1. Ferme et relance l'app

**Attendu :** popup absent.

### 8.3 Accès depuis Paramètres

1. **Paramètres** > **Lire le guide**

**Attendu :** popup guide ouvert sans crash.

---

## 9. Paramètres — langue

### 9.1 Passage FR → EN

1. **Paramètres** > sélectionne **English**

**Attendu :** toute l'UI en anglais immédiatement (pas de redémarrage requis).

### 9.2 Persistance

1. Force-quit > relance

**Attendu :** langue EN toujours active.

### 9.3 Retour FR

1. Sélectionne **Français**

**Attendu :** UI en français, persisté après kill.

---

## 10. Paramètres — dark mode

### 10.1 Activation

1. **Paramètres** > active le dark mode

**Attendu :** fond sombre immédiat sur toutes les pages.

### 10.2 Persistance

> Le dark mode n'est pas persisté entre les sessions (valeur réinitialisée au
> démarrage). Ce test vérifie le comportement en session uniquement.

1. Active dark mode > navigue sur toutes les pages

**Attendu :** dark mode maintenu pendant toute la navigation de la session.

---

## 11. Sanitisation des saisies

### 11.1 Injection de point-virgule

1. Dans le formulaire vCard, saisir **Nom** : `Dupont;Injection`
2. Lire le payload brut du QR généré

**Attendu :** `N:DupontInjection;;;;` — le `;` est supprimé.

### 11.2 Injection de retour à la ligne

1. Coller via presse-papiers un nom avec `\n` (ex. `Acme\nCorp` dans Org)
2. Lire le payload brut

**Attendu :** `ORG:AcmeCorp` — CR et LF supprimés.

### 11.3 Champ vide après sanitisation

1. Saisir `;;;` dans le champ Nom
2. Génère et importe

**Attendu :** `N:;;;;`, aucun crash, contact importable.

---

## 12. Line folding — champs longs

1. Saisir dans Adresse pro :
   `Bâtiment Horizon, 250 avenue des Champs-Élysées, Bureau 42, 75008 Paris, France`
2. Générer le QR, lire le payload brut

**Attendu :** ligne `ADR` repliée avec `\r\n ` (continuation), aucun octet perdu.

3. Scanne ce QR depuis l'app (Import) ou Contacts iOS

**Attendu :** adresse reconstituée intégralement sans troncature.

---

## 13. Parser vCard — sources tierces

### 13.1 iCloud (vCard 3.0)

1. Exporte un contact depuis Contacts iOS (Partage > vCard)
2. Importe dans l'app

**Attendu :** tous les champs reconnus.

### 13.2 Google Contacts

1. Export Google > format vCard
2. Importe dans l'app

**Attendu :** mêmes règles.

### 13.3 vCard 2.1 legacy

Payload de test :
```
BEGIN:VCARD
VERSION:2.1
N:Doe;John;;;
FN:John Doe
TEL;WORK;VOICE:+1-555-555-5555
EMAIL;INTERNET:john@example.com
END:VCARD
```

**Attendu :** nom, tél et email reconnus, aucun crash.

---

## Tableau de résultats

| # | Cas | iOS | Android | Notes |
|---|-----|-----|---------|-------|
| 1.1 | Import vCard complet 3.0 | | | |
| 1.2 | Payload brut CRLF + folding | | | |
| 1.3 | Champs vides | | | |
| 1.4 | QR texte simple | | | |
| 2.1 | Format 4.0 activé | | | |
| 2.2 | Persistance toggle 4.0 | | | |
| 2.3 | Retour 3.0 | | | |
| 3.1 | Scan vCard tierce | | | |
| 3.2 | Scan texte simple | | | |
| 3.3 | Contrôles caméra | | | |
| 4 | Import galerie (bug connu) | N/A | N/A | cassé |
| 5.1 | Import contact nominal | | | |
| 5.2 | Import multiple | | | |
| 5.3 | Refus permission | | | |
| 6 | Sauvegarde PNG | | | |
| 7.1 | Corbeille vCard | | | |
| 7.2 | Corbeille mixte | | | |
| 8.1 | Guide first-run | | | |
| 8.2 | Guide non-répété | | | |
| 8.3 | Guide via paramètres | | | |
| 9.1 | Langue FR→EN | | | |
| 9.2 | Persistance langue | | | |
| 10.1 | Dark mode actif | | | |
| 11.1 | Injection `;` | | | |
| 11.2 | Injection `\n` | | | |
| 12 | Line folding round-trip | | | |
| 13.1 | Parser iCloud | | | |
| 13.3 | Parser vCard 2.1 | | | |
