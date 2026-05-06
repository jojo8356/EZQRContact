---
project_name: EZQRContact
user_name: Johan
date: 2026-05-06
type: product-brief
status: draft
input_documents:
  - _bmad-output/project-context.md
  - _bmad-output/planning-artifacts/research/domain-pro-contact-exchange-research-2026-05-06.md
  - Docstring-Discord-tuto.md
  - TDL.txt
---

# Product Brief: EZQRContact

## Executive Summary

EZQRContact est une application mobile cross-platform (Flutter, Android + iOS),
opensource sous licence MIT, qui permet à un professionnel d'échanger ses
coordonnées en face-à-face via un QR code personnalisé sans compte, sans cloud
et sans abonnement. Elle vise les commerciaux B2B, exposants en salon,
recruteurs et freelances qui rencontrent 5 à 200 personnes par semaine en
événementiel ou en RDV, et qui en ont marre soit de la carte papier (88%
jetée en moins d'une semaine), soit des SaaS de digital business cards
payants (HiHello, Blinq, Popl) qui imposent un compte, un abonnement et un
profil hébergé chez eux.

L'app se distingue par 4 mécaniques uniques dans l'opensource mobile :
échange réciproque (le scan d'un QR provoque automatiquement le retour de
sa propre carte), export PDF des contacts captés (utile post-salon), capture
de la config visuelle du QR scanné (préserve l'identité graphique de
l'expéditeur, feature inédite), et embedding photo de profil dans la VCard.

Pourquoi maintenant : marché digital business card en croissance à 12.2%
CAGR (217 M$ en 2026 → 576 M$ en 2033), aucun concurrent opensource n'est
mobile native (les 5 alternatives identifiées sont toutes web/PWA).
Architecture local-first qui rend l'app compliant GDPR par construction
(pas de pipeline de data tiers, pas de DPA à signer).

## The Problem

**Friction quotidienne du pro qui networke** :
- La carte papier est jetée en moyenne dans la semaine (88% selon Wave Connect).
  100 milliards produites par an dans le monde.
- L'échange manuel (saisie au clavier) tue la conversion : 92% des pros font un
  follow-up post-event mais 34% disent que rien ne sort de la rencontre, faute
  de continuité.
- Les SaaS digital business card payants (8 à 15 $/mois) imposent un compte,
  un profil cloud, et un lock-in (Blinq 2.5M users, HiHello, Popl). Sortir
  ses données est rarement supporté proprement.
- Les apps NFC (Mobilo, Linq) imposent l'achat d'une carte physique avant
  même d'avoir un compte.
- Les opensources existants (EnBizCard, Swiish, OwnCardly, SmartVCard) sont
  tous web/PWA, donc pas de friction-zero "sortir mon tel et boom QR".
- Côté utilisateur final qui scanne, vCard 4.0 est silently broken sur de
  nombreux iOS/Android (FossifyOrg/Contacts #210 documente l'erreur, iCloud
  rejette les X-properties, perte de 90% des contacts à l'import dans
  certains cas).

**Conséquence** : le pro qui veut un échange propre et rapide en face-à-face
n'a pas d'option opensource mobile native, et les options payantes sont
verrouillées.

## The Solution

EZQRContact rend l'échange aussi rapide qu'un AirDrop, sans contrainte
d'écosystème :

1. **Génération QR perso instantanée** depuis ses infos saisies une fois.
2. **Scan QR + sauvegarde directe dans le tel** (compat vCard 3.0, dans la
   prochaine version, qui couvre iCloud / Google / Outlook / Android / iPhone).
3. **Échange réciproque optionnel** : quand A scanne le QR de B, l'app peut
   pousser le QR de A vers B en retour (pattern QRCodeChimp + Whova,
   adapté local-first).
4. **Capture de la config visuelle** du QR scanné : couleur, logo, layout de
   la card → quand B scanne A, B sauvegarde non seulement les infos mais
   aussi "comment A se présente". Aucun concurrent ne le fait.
5. **Photo de profil embarquée** dans la VCard (vCard 3.0 PHOTO;ENCODING=b
   format, square 256x256 ou 720x720 selon device, JPEG recommandé).
6. **Export PDF** d'un set de contacts captés (use case "rapport post-salon"
   à envoyer au CRM ou à l'équipe).

Toute la donnée reste sur le tel. Pas de compte, pas de pipeline cloud, pas
de DPA, pas d'abonnement.

## What Makes This Different

| vs alternative | Ce que EZQRContact apporte |
|---|---|
| Cartes papier | Pas perdues, sauvegardée dans le tel, photo intégrée |
| Blinq / HiHello / Popl (SaaS) | Gratuit, no-account, opensource, pas de lock-in cloud |
| Mobilo / Linq (NFC + carte) | Pas d'achat hardware, marche avec n'importe quel tel à caméra |
| EnBizCard / OwnCardly / Swiish (OS web) | Mobile native installable (vs profil web hébergé) |
| LinkedIn QR | Stocke un vrai contact dans le tel, pas un push vers LinkedIn |

**Différenciateurs uniques (zéro concurrent en opensource mobile)** :
- Local-first by design.
- Capture de la config visuelle du QR scanné (innovation).
- Export PDF natif depuis le tel.
- Compat vCard 3.0 universelle (la majorité des opensource ne formate pas
  proprement les photos selon les specs vCard 3.0).

## Who This Serves

### Persona 1 — Le Commercial B2B (priorité haute)
- 5-15 RDV par semaine, agenda chargé.
- Veut échanger en moins de 10 secondes, retrouver le contact ensuite, et
  pouvoir l'exporter dans son CRM en bulk après une journée.
- Frictions : carte papier perdue, saisie manuelle, lock-in du SaaS d'équipe.
- Critère de succès : un follow-up envoyé dans les 24-48h post-rencontre
  (Momencio 2025 : 32% de ROI en plus avec capture lead structurée).

### Persona 2 — L'Exposant en salon (priorité haute)
- 50-200 contacts captés par jour pendant 2-3 jours d'événement.
- Veut un export propre en fin de journée pour envoyer aux collègues ou
  importer dans HubSpot.
- Frictions : badges scan SaaS coûteux, données enfermées chez l'organisateur,
  follow-up loupé (34% des leads salons ne convertissent pas).
- Critère de succès : avoir un PDF/CSV des contacts du jour, sans login,
  sans transit cloud, en 30 secondes.

### Persona 3 — Le Recruteur / Talent acquisition
- Forums étudiants, salons recrutement, meetups tech.
- Veut capter rapidement candidat avec photo, LinkedIn, tel sans pinger
  LinkedIn (qui prend la main sur la conversation).
- Critère de succès : retrouver visuellement le candidat 2 semaines après le
  forum (d'où la photo profil dans la VCard et la config visuelle préservée).

### Persona 4 — Le Freelance / Consultant indépendant
- Afterworks, conférences, BNI, networking events.
- Veut une carte qui reflète son identité visuelle perso (couleurs, logo).
- Critère de succès : un QR qui ressemble à sa marque perso, pas un QR
  générique noir et blanc.

## Adoption Path

**Comment ils découvrent EZQRContact**
1. **Bouche à oreille en événement** : un user fait scanner son QR à un
   collègue, qui demande "c'est quoi ton app ?". Référence comme premier
   driver pour la majorité des digital business cards (Wave Connect 2026).
2. **Post Discord / forum dev FR** : le draft de `Docstring-Discord-tuto.md`
   prévoit un post sur les serveurs Flutter/dev FR.
3. **GitHub stars / awesome-flutter** : contribution à la liste
   `awesome-flutter` une fois la v1.1 sortie (release Play Store + iOS).
4. **SEO opensource** : page GitHub bien faite avec README structuré, mots-clés
   "open source digital business card mobile", "GDPR-compliant vCard app".
5. **Bouche à oreille étudiant** : Johan en école → forums étudiants /
   salons recrutement → utilisation par les pairs → effet boule de neige.

**Pourquoi ils l'installent**
- Pas de compte = pas de friction de signup (gros différenciateur vs Blinq).
- Gratuit complet (pas de tier Pro).
- "Local-first" / "no cloud" rassure les profils qui savent ce que ça veut
  dire (devs, consultants, recruteurs sensibilisés RGPD).

**Pourquoi ils restent**
- L'app marche offline → pas de friction sur place dans un salon en sous-sol
  ou en zone wifi merdique.
- Export PDF immédiat = ROI tangible dans la journée.
- Capture de la config visuelle = "feel personnel" qu'aucun concurrent
  n'offre.

## Showcase technique pour CV

Le projet est conçu pour être **un projet portfolio crédible côté
recruteur tech** (alternance, stage, premier CDI). Ce qui est valorisable :

- **Cross-platform Flutter mobile production-ready** : Android + iOS, app
  releasable sur les stores. Recruteurs valorisent les projets qui ont
  shippé (Indeed/Enhancv 2026 : "track record of shipping apps that
  perform well").
- **Stack moderne et choix justifiés** : Dart 3.x sound null-safety,
  provider/singleton statique, sqflite (avec migration Drift documentée
  dans le `project-context.md`), build_runner code generation prévu.
- **Persistance locale complexe** : 2 tables, soft-delete, requêtes typées,
  migration de schéma planifiée — sujets discutés en entretien.
- **Format métier non trivial** : génération vCard 3.0/4.0 conforme RFC,
  parsing inverse, sanitization (anti-injection format).
- **Architecture local-first / privacy-by-design** : argument différenciant
  côté recruteur "tu sais raisonner sur des contraintes RGPD réelles".
- **Métriques GitHub publiables** : nombre de stars, releases, contributeurs
  externes, downloads Play Store. À mettre directement sur le CV
  (StandoutCV : "quantify outcomes").
- **Documentation pro** : README structuré + project-context.md + brief
  + research = preuve qu'on sait raisonner produit, pas juste coder.

Phrase type CV : *"App mobile Flutter cross-platform opensource (MIT), 1k+
stars GitHub, 5k+ téléchargements Play Store. Architecture local-first
(SQLite + sqflite), génération vCard 3.0 conforme RFC 6350, code
generation Drift planifiée, conformité GDPR by design."*

## Success Criteria

### Métriques d'usage (validables à 6 mois)
- 500+ téléchargements Play Store cumulés
- 50+ stars GitHub
- 3+ contributeurs externes (PRs mergées)
- 1 release toutes les 2-4 semaines (cadence Smaug/Alexandrie comme
  benchmark : 15+ releases / 6 mois)

### Métriques produit (validables côté retours users)
- 95%+ d'imports vCard réussis sur iOS et Android (vs vCard 4.0 actuel
  qui silently fail). Mesurable via une feature de test in-app.
- Feature "config visuelle préservée" utilisée dans 30%+ des scans (signal
  d'engagement émotionnel).
- 0 régression sur les use cases existants (carte perso, scan, export).

### Métriques CV (validables côté Johan)
- Au moins 2 mentions du projet dans des forums dev FR / dev.to / LinkedIn
  externes à Johan.
- Au moins 1 entretien stage/alternance où le projet a été un sujet de
  discussion concret.

## Scope (V2.0 — version cible post-research)

### In scope
- **P0** : migration vCard 4.0 → 3.0 (ou dual mode toggleable).
- **P1** : feature "scan QR → garde la config visuelle" (différenciateur
  unique).
- **P1** : photo de profil dans la VCard (avec resize 720x720 max,
  JPEG, ENCODING=b, conforme vCard 3.0 spec).
- **P1** : export PDF d'un set de contacts captés (filtre par date /
  événement).
- **P2** : échange réciproque (le scan déclenche un retour-de-QR optionnel,
  toggleable).
- **P2** : tag/groupement "événement" (regroupe les contacts captés un
  jour donné sous un nom de salon).
- **Migration sqflite → Drift** (déjà documentée dans project-context).
- **Migration flutter_lints → very_good_analysis** (déjà documentée).
- **LICENSE MIT + README structuré + screenshots** (pré-requis Discord post).

### Out of scope explicite
- Hardware NFC (terrain de Popl/Mobilo/Linq, capital-intensif).
- CRM intégré (Mobilo le fait, pas notre segment).
- Analytics dashboard SaaS (besoin enterprise).
- Sync cloud / multi-device (casse le pitch local-first).
- Account / signup (casse le pitch no-friction).
- Apple Wallet / Google Wallet integration (P3, post-v2.0 si signal
  utilisateur).
- AR / blockchain / voice (gimmicks marketing, pas core).

## Vision (12-24 mois)

EZQRContact devient **la référence opensource mobile native** pour l'échange
de contacts pro en face-à-face en Europe francophone, puis EU élargie.

Tracking de la vision :
- 5k+ stars GitHub à 24 mois (benchmark Alexandrie a fait 1k+ en 18 mois,
  EZQRContact peut viser plus avec un positionnement plus B2B).
- Présence dans `awesome-flutter` et listes "GDPR-friendly tools".
- Adoption par 1+ équipe commerciale pro (preuve d'usage réel hors étudiants).
- Possible spinoff : un companion CLI/desktop pour import en masse vers CRM
  (HubSpot, Notion, Pipedrive) sans passer par un cloud tiers.

Si Johan veut un jour monétiser, l'angle "version équipe avec dashboard local
cross-device via WebRTC peer-to-peer" serait le seul à étudier sans casser
le pitch local-first. Reste hors scope V2.

---

## Sources de grounding

Ce brief s'appuie sur les artefacts BMAD :
- `project-context.md` (état stack/code actuel, contraintes Android/iOS)
- `research/domain-pro-contact-exchange-research-2026-05-06.md` (marché,
  concurrents, frictions vCard, GDPR events)

Études de cas web (2026) consultées pour ce brief :
- [Whova QR Contact Exchange](https://whova.com/blog/whovas-qr-codes-now-enable-easy-contact-exchange-attendees/) — pattern réciproque
- [QRCodeChimp Contact Exchange Form](https://www.qrcodechimp.com/collect-contacts-with-contact-exchange-form/) — UX swap auto
- [LinkedIn QR Codes Marketing Dive](https://www.marketingdive.com/news/linkedin-adds-qr-codes-for-offline-networking/526843/)
- [Trade Show Lead Capture Workflow — aicardvault](https://aicardvault.com/blog/trade-show-lead-capture-workflow/)
- [Exhibition Lead Retrieval Guide 2026 — Eventrize](https://www.eventrize.com/exhibition-lead-retrieval-guide-2026.html)
- [QR Code Business Cards 2026 Guide — Supercode](https://www.supercode.com/blog/why-qr-code-business-cards-are-a-must)
- [vCard Photo Specs Skycore](https://www.skycore.com/help/best-practices-generating-vcards/)
- [Resizing images for vCard on Android — Ken Fallon](https://kenfallon.com/resizing-images-for-vcard-on-android/)
- [Hidden Challenges of vCards with Photos — webdeveloper.today](https://www.webdeveloper.today/2025/09/the-hidden-challenges-of-vcards-with.html)
- [Top 10 Flutter Projects for Developer CV — DEV](https://dev.to/dhruvjoshi9/top-10-impressive-flutter-projects-to-skyrocket-your-developer-cv-4b1g)
- [Mobile Application Developer Resume 2026 — Enhancv](https://enhancv.com/resume-examples/mobile-application-developer/)
- [Flutter Developer Resume Sample — DevsData](https://devsdata.com/resumes/flutter/flutter-developer-resume-sample/)
