# Tuto : Présenter EZQRContact sur un forum Discord

Document de travail. Analyse d'un post de référence (Alexandrie de Smaug6739)
puis application au cas EZQRContact.

## 1. Le post de référence (Alexandrie)

Lien thread : projet Alexandrie sur le serveur Discord de Smaug.

### Anatomie du message d'ouverture (7 briques)

1. **Hook social** : "je viens vous partager un projet que @Smaug mène depuis
   quelques années". Validation par un tiers, pas auto-promo. Effet bouche à
   oreille plus crédible.
2. **Phrase-claim 1 ligne** : "application web de prise de notes pour
   étudiants/devs/créateurs". Persona clair, pas de jargon.
3. **Problème résolu, concret** : interface jolie, documents bien formatés
   sans Word, gérer des centaines de docs, snippets/raccourcis pour aller
   vite. 4 douleurs, chacune adressée.
4. **Stack en 1 phrase** : vue/nuxt + go + minio. Assez pour intriguer un
   dev, pas trop pour endormir un user.
5. **CTA contributeurs** : "il est seul, suggestions/critiques bienvenues".
   Humilité + porte ouverte.
6. **Preuves visuelles + lien GitHub** : 2 screenshots + repo + microformule
   "une petite étoile aide à attirer d'autres contributeurs". Le pourquoi de
   l'étoile, pas juste la demande.
7. **Pourquoi je partage** : "j'ai trouvé le projet incroyable, j'ai décidé
   de contribuer". Motivation perso = filtre anti-spam.

### Phase 2 : garder le thread vivant

Le post n'est pas un one-shot. Smaug poste :
- Chaque release (8.0, 8.1, 8.3, 8.4, 8.5, 8.6, 8.7...) avec changelog FR/EN
- Articles dev.to techniques (gestion des données, permissions)
- Vidéos YouTube tierces (DB Tech)
- Milestones stars (700, 1000)
- Liens presse (Korben, LinkedIn)

C'est un **journal de bord public**. Chaque update ramène le thread en haut
du forum et entretient la curiosité.

## 2. Ce que les gens veulent vraiment entendre

Sources : guides open source FR/EN + doc Discord Forum Channels.

- **À qui ça sert** avant **comment c'est fait**. 5 secondes pour
  comprendre la valeur.
- **Un visuel qui prouve que ça existe**. Sans screenshot le post est mort.
  Discord met l'image en miniature de la card du forum.
- **Une porte d'entrée concrète** : "good first issue", "suggestions
  bienvenues", lien Discord/GitHub. Pas juste "venez contribuer".
- **L'humain derrière** : pourquoi tu l'as fait, statut (étudiant, solo,
  side-project). Les gens contribuent à des humains, pas à des repos.
- **Pas de survente** : "C'est mon premier projet en X" marche mieux que
  "le futur de Y".

## 3. Diagnostic EZQRContact

État actuel du repo (créé 2025-08-18, release v1.0.0 du 2025-11-01).

| Item | État | Bloquant ? |
|---|---|---|
| README | 6 lignes EN, fautes, pas de structure | Oui |
| Screenshots / démo | Aucun dans le repo | Oui |
| LICENSE | Absente | Oui (pas de contrib sans licence) |
| Topics GitHub | OK (flutter, qr-code, dart, mobile, contact) | Non |
| Release | v1.0.0 du 01/11/2025 | Non |
| Stars | 0 | Non, mais départ à zéro |
| Persona cible | Pas clair | Oui |

### À faire avant le post (1-2h)

1. Réécrire le README : titre, pitch 1 phrase, GIF/screenshots, "Why",
   features bullet, install, stack, license.
2. Ajouter 2-3 screenshots (création VCard, QR généré, scan d'image).
3. Ajouter LICENSE (MIT par défaut pour ouvrir aux contribs).

## 4. Draft du post (à utiliser après le ménage)

Première personne, projet jeune et solo. Pas de tirets cadratins, pas de
survente.

```
Salut tout le monde, je viens vous partager EZQRContact, un projet que je
développe en solo depuis cet été.

C'est une app mobile (Flutter) qui génère des QR codes à partir
d'informations personnelles. Concrètement tu crées une VCard (nom, tel,
adresse, email) et l'app produit un QR code que n'importe qui peut scanner
pour t'ajouter directement comme contact sur son tel. Comme un Snapcode,
mais pour échanger ses coordonnées en 2 secondes. Tu peux aussi générer un
QR code à partir d'une image (scan ou upload).

L'idée m'est venue parce que j'en ai eu marre de dicter mon numéro à
chaque rencontre pro/event/forum. Plutôt que d'utiliser un service tiers
qui stocke mes données, j'ai voulu une app locale qui fasse juste le job.

Stack: Flutter + Dart pour le cross-platform (Android/iOS). C'est mon
premier vrai projet mobile donc côté code y a sûrement à redire, et c'est
exactement pour ça que je le partage ici.

Actuellement la v1.0.0 est sortie. Je suis seul dessus et je cherche des
retours: critiques sur l'UX, suggestions de features, ou direct des
contributeurs si l'app vous parle. C'est un Flutter assez simple donc
parfait pour quelqu'un qui veut se faire la main sur du mobile.

GitHub: https://github.com/jojo8356/EZQRContact
(une petite étoile aide à attirer d'autres devs sur le projet)

[2-3 screenshots ici]

N'hésitez pas si vous avez des questions ou des idées de features.
```

## 5. Différences avec le post Alexandrie

- **Première personne** au lieu de tierce. Si possible, demande à un pote
  du serveur de poster pour toi : ça change tout en crédibilité.
- **Plus court** parce que projet plus petit. Adapte la longueur à la
  maturité.
- **"C'est mon premier projet mobile"** = invitation directe à la critique
  constructive. Les devs adorent répondre à ça.
- **Persona explicite** ("rencontres pro/event/forum") au lieu de
  générique. Choisis 1 use case fort.

## 6. Plan d'action

1. README + screenshots + LICENSE (1-2h)
2. Identifier 1 persona clair (étudiant qui networke en stage ?
   freelance en event ? le pitch change selon le cas)
3. Choisir 1 forum Discord pertinent (serveur dev FR, serveur Flutter FR,
   r/flutterdev en backup)
4. Lire les Post Guidelines + tags requis du forum AVANT de poster
5. Post → puis garder le thread vivant à chaque release (pattern Smaug)

## 7. Sources

- Forum Channels Discord blog : https://discord.com/blog/forum-channels-space-for-organized-conversation
- Forum Channels FAQ : https://support.discord.com/hc/en-us/articles/6208479917079
- Comment promouvoir son projet opensource : https://mawuen.github.io/2017/02/12/comment-promouvoir-son-projet-opensource/
- Lancer un projet Open Source (opensource.guide) : https://opensource.guide/starting-a-project/
- Sfeir : https://www.sfeir.dev/comment-contribuer-a-un-projet-open-source/
