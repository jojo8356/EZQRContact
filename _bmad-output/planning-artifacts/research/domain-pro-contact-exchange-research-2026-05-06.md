---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments: ['_bmad-output/project-context.md', 'Docstring-Discord-tuto.md', 'TDL.txt']
workflowType: 'research'
lastStep: 6
research_type: 'domain'
research_topic: 'Échange de contacts professionnels en face-à-face — pratiques, outils, frictions'
research_goals: 'Grounder le Product Brief de EZQRContact sur des données du secteur (marché digital business cards, concurrents, frictions vCard, contextes pro)'
user_name: 'Johan'
date: '2026-05-06'
web_research_enabled: true
source_verification: true
---

# Research Report: Échange de contacts professionnels (B2B / networking pro)

**Date :** 2026-05-06
**Auteur :** Johan
**Type de recherche :** Domain
**Projet cible :** EZQRContact (app Flutter, opensource, repositionnement pro)

---

## Research Overview

### Méthodologie
Recherche conduite via 7 requêtes web ciblées sur Q2 2026, croisant 4 angles :
- Taille et croissance du marché digital business card
- Concurrents commerciaux (Blinq, HiHello, Popl, Mobilo, Linq)
- Concurrents opensource (EnBizCard, Swiish, OwnCardly, SmartVCard, arpixnet)
- Frictions techniques (vCard 4.0 vs 3.0) et réglementaires (GDPR events)

### Question centrale
Comment les pros échangent leurs contacts en 2026, quels segments sont les plus actifs, quelles frictions persistent, et où EZQRContact peut se positionner ?

### Output attendu
Données chiffrées + segments cibles + positionnement différenciateur, en input du Product Brief (`bmad-product-brief`).

---

## 1. Domain Analysis : taille et dynamique du marché

### Marché global digital business card

| Métrique | Valeur | Source |
|---|---|---|
| Taille marché 2026 | **217-238 M$** | Mordor Intelligence, market.us |
| Projection 2033 | **576 M$** | SkyQuest |
| CAGR 2026-2033 | **12.2%** | SkyQuest, market.us |
| CAGR 2023-2032 (Allied) | **12.6%** | Allied Market Research |
| Part Amérique du Nord | **46.2%** du marché global | Verified Market Reports |

**Lecture** : marché en croissance soutenue à 2 chiffres, alimenté par 3 moteurs convergents :
- Décès lent de la carte papier (88% jetées en 1 semaine, 100 milliards produites/an, taux d'impression chuté de 70% post-COVID).
- Adoption pro (37% des SMB et 23% des individuels utilisent du digital en 2024, vs 16% en 2020).
- Préférence utilisateur (88% des pros préfèrent digital sur papier).

### Adoption par segment

- **Commerciaux B2B** : "fastest adopters" selon les enquêtes Popl/HiHello. Logique : ils rencontrent le plus de monde et ont besoin de follow-up rapide.
- **Recruteurs / event pros** : segment dédié chez Mobilo (lead tracking dashboards, automated workflows).
- **PME / petits cabinets** : 37% adoption.
- **Individuels** : 23% adoption (segment encore mou côté digital).
- **Salons / conférences** : ROI moyen de **20.98$ par 1$ dépensé**, cost per lead salon **$112 vs $259** en field sales.

### Pain points utilisateur quantifiés

- **92% des pros font un follow-up** après rencontre événementielle.
- **34% disent que rien n'en sort** (le contact échangé ne convertit pas en relation).
- **88% des cartes papier jetées en 1 semaine** : la friction n'est pas l'échange, c'est la pérennité.
- **45% des users de cartes digitales** citent la facilité de share/save comme raison primaire d'adoption.
- **20% sont motivés par l'écologie**.

---

## 2. Competitive Landscape

### Joueurs commerciaux (top 5 par adoption)

| Outil | Modèle | Prix | Points forts | Faiblesses |
|---|---|---|---|---|
| **Blinq** | App + web profil | 9.99$/mois | 2.5M users, 4.9★, simple/rapide, leader app store | Peu de fonctions avancées |
| **HiHello** | App + enterprise | 8$/mois (Pro), gratuit limité | SOC 2 Type II, GDPR, CCPA, SSO/SAML/SCIM | Complexe, scan limité à 5/mois en gratuit |
| **Popl** | App + NFC merch | 7.99-14.99$/mois | Lead capture event-oriented, NFC tags/wristbands | Free plan limité à 5 contacts |
| **Mobilo** | NFC card + dashboard | 4$/user/mois (teams) | Tracking, follow-up auto, salespeople-focused | Achat carte obligatoire avant compte |
| **Linq** | NFC card | Variable | "Tap to share" branding | Requiert carte physique, gaps compatibilité NFC |

**Observations clés**
- Tous **payants** (le free tier est volontairement bridé).
- Tous **dépendent d'un cloud** (profil hébergé chez le SaaS, pas portable).
- Tous **demandent un compte** avant de pouvoir partager.
- Beaucoup **vendent du hardware NFC** (Popl, Mobilo, Linq) → friction d'achat.
- HiHello = seul à pousser sérieusement la conformité enterprise (SOC 2, SSO).

### Joueurs opensource (concurrents directs d'EZQRContact)

| Projet | Stack | Licence | Approche |
|---|---|---|---|
| **EnBizCard** | HTML statique + Docker | AGPL | Self-hosted web, vCard exportable |
| **Swiish** | Web + PWA | (à vérifier) | QR + PWA, self-hostable |
| **OwnCardly** | Web | **MIT** | Drag-drop canvas, local-first guest mode |
| **SmartVCard** | HTML | AGPL | Fork EnBizCard, simple |
| **arpixnet/digital-business-card** | Nuxt 3 + Tailwind 4 + PrimeVue 4 | (à vérifier) | Web responsive moderne, vCard + QR + PWA |

**Observations critiques**
- **100% de l'opensource est web/PWA**. Aucun concurrent opensource n'est une **app mobile native**.
- **EZQRContact = unique en son genre** dans l'opensource : Flutter cross-platform Android/iOS, app installable sur le tel.
- Aucun ne propose de **scanner un QR pour récupérer config visuelle de l'autre** (la feature 3 de Johan est un blue ocean).
- Aucun ne propose **export PDF** des contacts collectés (la feature 2 idem).
- AGPL est dominant côté opensource → si tu choisis MIT, tu deviens **plus permissif** que la majorité (avantage adoption, surtout par des entreprises qui évitent AGPL).

---

## 3. Regulatory Focus : GDPR events + vCard format

### GDPR pour échange de contacts en événementiel

Cadre 2026 (event marketing) :
- **Consent explicite, spécifique, séparé** des conditions générales requis pour les attendees EU.
- **Data Processing Agreements** obligatoires si partage avec sponsors/partenaires.
- **Opt-in proactif** pour communications marketing post-event.
- **Withdrawable** facilement.

**Implication EZQRContact** :
- Architecture **local-first** = exemption quasi totale de la friction GDPR (les données restent sur les téléphones, pas de processeur tiers).
- Génération QR offline = pas de transit cloud = pas de DPA à signer.
- C'est un **argument de vente** (et un argument CV) : "privacy by design", "GDPR compliant by absence".

### Friction vCard format (action critique recommandée)

**Problème central** : EZQRContact génère du **vCard 4.0** (vu dans `lib/tools/vcard.dart` : `BEGIN:VCARD / VERSION:4.0`).

**Réalité du terrain** :
- vCard **3.0 est le SEUL format universellement supporté** (iCloud, Google, Outlook, Android, iPhone).
- vCard **4.0** silently fail sur certains iPhones et Androids (selon l'année du device et l'app contacts).
- iCloud **rejette les X-properties** custom utilisées par v4.0.
- Outlook rejette certaines propriétés v4.0.
- Bug GitHub `FossifyOrg/Contacts #210` : "Contact App fails to import *.vcf v4.0 vCard file contents".
- Issues import sur Android avec NullPointer (un user a perdu 90% de ses 4000 contacts à l'import).

**Recommandation actionnable** :
- **Migrer EZQRContact vers vCard 3.0 par défaut** (ou supporter les deux avec un toggle).
- C'est probablement la **première bug-source silencieuse** de l'app actuelle (les users qui scannent et ça "marche pas" mais on sait pas pourquoi).

---

## 4. Technical Trends : NFC vs QR vs Wallet

### Méthodes d'échange en 2026

| Méthode | Hardware requis | Universel | Friction | Adoption |
|---|---|---|---|---|
| **QR code écran-à-caméra** | Aucun | ✅ tous smartphones | Aucune | Standard de fait |
| **NFC tap (carte/téléphone)** | Carte NFC ou tel compatible | ⚠️ iOS récent ok, Android variable | Hardware à acheter/porter | Popl, Mobilo, Linq pushent fort |
| **Apple Wallet / Google Wallet** | iOS/Android récent | ⚠️ écosystème-dépendant | Setup utilisateur | En croissance |
| **AirDrop / Quick Share** | iOS-iOS / Android-Android | ❌ pas cross-platform | Pas universel | Pratique mais limité |
| **LinkedIn QR** | LinkedIn app | ✅ très répandu | Push vers LinkedIn (pas un contact tel) | Très utilisé en pratique |
| **Email / SMS / link** | Aucun | ✅ | Friction de saisie | Fallback universel |

### Tendances 2025-2026

- **AR integration** mentionnée (Mordor) — gimmick, pas core.
- **Voice-enabled cards** — gadget.
- **Blockchain verification** des credentials — pas de traction réelle.
- **Apple Wallet integration** = vraie tendance de fond. Stocker le QR dans Wallet pour l'avoir accessible offline.
- **PWA support** côté web → moindre intérêt pour une app native comme EZQRContact.

### Le QR reste roi du face-à-face cross-platform

Pour un échange face-à-face universel sans hardware additionnel et sans appartenance écosystème :
**QR code = solution gagnante**. C'est exactement le pari d'EZQRContact, et c'est validé par les data du marché.

---

## 5. Synthèse pour EZQRContact

### Validations du positionnement

✅ **Marché en croissance** : 12.2% CAGR jusqu'à 2033, le timing est bon.
✅ **Pas de concurrent opensource mobile native** : niche réelle dans l'opensource (concurrents = web/PWA).
✅ **QR est le bon support** : universel, sans hardware, plus simple que NFC.
✅ **Local-first / offline = différenciateur GDPR** : argument fort pour le segment pro EU.

### Risques à connaître

⚠️ **vCard 4.0 actuel = bug silencieux probable** chez tes users (compat iOS/Android cassée). Action : passer à vCard 3.0 (ou dual-mode).
⚠️ **Concurrence SaaS lourde** (Blinq 2.5M users, HiHello SOC 2). Pas un combat à mener sur les features, à mener sur la philosophie (gratuit, opensource, no-account, local-first).
⚠️ **Feature gap** : pas de NFC hardware → tu perds le segment "carte physique tap-to-share" (Popl/Mobilo/Linq). Décision OK si tu vises les pros qui veulent du digital pur.
⚠️ **Naming** : "EZQRContact" est descriptif mais peu mémorable. À envisager un rebranding plus évocateur (ex: "TapCard", "CartPro", "Vouch", etc.) si tu pousses sur LinkedIn / hunt / showcase CV.

### Personas pros prioritaires (basé sur les data)

**1. Le Commercial B2B (priorité #1)**
- Use case : 5-15 rencontres / semaine en RDV ou événements.
- Besoin clé : échanger vite, retrouver le contact ensuite, follow-up.
- Frictions actuelles : carte papier perdue, saisie manuelle, GDPR pour CRM lead capture.
- Ce qu'EZQRContact apporte : QR perso instant, scan retour-vers-tel, export PDF post-event pour CRM.

**2. L'Exposant en salon (priorité #2)**
- Use case : 50-200 contacts par jour pendant 2-3 jours d'événement.
- Besoin clé : capter en masse, post-event re-contacter sans perdre l'info.
- Frictions actuelles : badge scan SaaS coûteux, données enfermées chez l'organisateur.
- Ce qu'EZQRContact apporte : export PDF jour-par-jour, contacts dans son tel directement, RGPD-clean.

**3. Le Recruteur / Talent acquisition (priorité #3)**
- Use case : forums étudiants, salons recrutement, meetups.
- Besoin clé : capter candidat profil + photo + LinkedIn + tel sans pinger LinkedIn.
- Ce qu'EZQRContact apporte : photo profil dans VCard (feature 4 de Johan), partage rapide.

**4. Le Freelance / Consultant indépendant (priorité #4)**
- Use case : afterworks, conférences, BNI, networking events.
- Besoin clé : carte qui reflète son identité visuelle perso (la feature "config QR same authenticity" de Johan = très alignée).
- Ce qu'EZQRContact apporte : design custom de la card visuelle.

### Différenciateurs à pousser sur le post Discord / README / CV

1. **Local-first / offline** : aucune dépendance cloud, pas de compte requis.
2. **Opensource MIT** : permissif, contribuable, transparent (vs AGPL des concurrents OS web).
3. **Mobile native Flutter** : seul opensource qui s'installe sur le tel (vs web/PWA).
4. **Privacy-first / GDPR-native** : pas de DPA, pas de pipeline data tiers.
5. **Gratuit complet** : pas de "Pro tier" caché (vs HiHello/Blinq/Popl).
6. **Feature unique : capture de la config visuelle du QR scanné** (rétention de l'identité visuelle de l'expéditeur, feature 3) → personne d'autre ne fait ça dans l'opensource.

### Features prioritaires (basées sur signal marché)

| Priorité | Feature | Justification data |
|---|---|---|
| **P0 (critique)** | Migration vCard 4.0 → 3.0 (ou dual) | Compat universelle = condition sine qua non |
| **P1** | Export PDF des contacts (feature 2 Johan) | Use case "exposant salon" et "follow-up post-event" |
| **P1** | Photo de profil dans VCard (feature 4 Johan) | Use case "recruteur/talent acq" et "design pro" |
| **P1** | Capture config visuelle du QR scanné (feature 3 Johan) | Différenciateur unique, 0 concurrent |
| **P2** | Partage carte perso à d'autres (feature 1 Johan) | Pattern standard, déjà partiellement présent |
| **P2** | Apple Wallet / Google Wallet integration | Tendance forte 2026, friction utilisateur réduite |
| **P3** | Mode "événement" avec tag/groupement de contacts captés | Use case salon, simple à coder |
| **P3** | Export CSV pour CRM | Power users / commerciaux |

### Hors scope explicite (ne pas faire)

❌ Hardware NFC → terrain de Popl/Mobilo/Linq, capital intensif.
❌ CRM intégré → Mobilo le fait mieux, hors scope opensource solo.
❌ Analytics dashboard → besoin enterprise, pas le segment.
❌ Sync cloud / multi-device → casse le pitch "local-first".
❌ Account / signup → casse le pitch "no friction".

---

## 6. Inputs pour le Product Brief (CB) suivant

À utiliser quand `bmad-product-brief` reprendra :

- **Persona principal** : Commercial B2B / Exposant salon (priorité #1 et #2).
- **Value prop 1 phrase** : "L'app mobile opensource qui échange un contact pro complet en un scan, sans compte, sans cloud, sans abonnement".
- **Antagonistes positionnement** : Blinq (simplicité mais SaaS), HiHello (enterprise mais payant), Popl (NFC mais lock-in hardware).
- **Unique selling point** : seul opensource mobile native + capture config visuelle du QR scanné.
- **First action critique** : migrer vCard 4.0 → 3.0 (sinon les users actuels ont des bugs silencieux).
- **Métriques de succès CV-friendly** : stars GitHub, releases Play Store, downloads, contributions externes.

---

## Sources

### Marché et statistiques
- [Digital Business Card Market — Mordor Intelligence](https://www.mordorintelligence.com/industry-reports/digital-business-card-market)
- [Digital Business Card Market market.us](https://market.us/report/digital-business-card-market/)
- [Digital Business Card Statistics — qrcodechimp](https://www.qrcodechimp.com/digital-business-card-statistics/)
- [50 Digital Business Card Statistics 2026 — DBC](https://www.digitalbusinesscard.com/blog/digital-business-card-statistics)
- [Digital Business Card Market — Allied Market Research](https://www.alliedmarketresearch.com/digital-business-card-market-A108801)
- [Digital Business Card Market 2025-2032 — SkyQuest](https://www.skyquestt.com/report/digital-business-card-market)
- [Are Business Cards Still Relevant — Wave Connect](https://wavecnct.com/blogs/are-business-cards-still-relevant)

### Concurrents
- [Top 6 Digital Business Cards 2026 — Blinq](https://blinq.me/blog/best-digital-business-card)
- [Best Digital Business Cards 2026 — Lynkle](https://lynkle.com/resources/best-digital-business-cards-in-2026)
- [HiHello vs Popl vs Blinq — Mobilo](https://www.mobilocard.com/post/hihello-digital-business-card)
- [Top Companies Digital Business Card Market — OpenPR](https://www.openpr.com/news/4419115/top-companies-in-the-digital-business-card-market-hihello)

### Opensource
- [EnBizCard GitHub](https://github.com/vishnuraghavb/EnBizCard)
- [Swiish GitHub](https://github.com/MrCrin/swiish/)
- [SmartVCard GitHub](https://github.com/ziageek/smartvcard)
- [OwnCardly article](https://earezki.com/ai-news/2026-04-19-every-digital-business-card-tool-sucks-so-i-built-my-own-and-open-sourced-it/)
- [arpixnet/digital-business-card GitHub](https://github.com/arpixnet/digital-business-card)
- [GitHub topics: digital-business-card](https://github.com/topics/digital-business-card)

### vCard format
- [VCF Common Import Errors — CorrectVCF](https://correctvcf.com/help/vcf-common-import-errors/)
- [The sad story of vCard format — Alessandro Rossini](https://alessandrorossini.org/the-sad-story-of-the-vcard-format-and-its-lack-of-interoperability/)
- [vCard 3.0 vs 4.0 Google Groups](https://groups.google.com/g/axchinorthnet/c/2WvcZvNnbQc)
- [FossifyOrg/Contacts issue #210](https://github.com/FossifyOrg/Contacts/issues/210)

### GDPR et événementiel
- [GDPR for Events Cvent](https://www.cvent.com/en/blog/events/gdpr-events-guide)
- [GDPR Compliance for Events — GDPR Local](https://gdprlocal.com/gdpr-compliance-for-events/)
- [Event Lead Generation Strategies — bookyourdata](https://www.bookyourdata.com/blog/event-lead-generation)
- [Event Marketing Statistics 2026 — Wave Connect](https://wavecnct.com/blogs/news/event-marketing-statistics)
- [Onsite Event Experience Trends 2026 — Bizzabo](https://www.bizzabo.com/blog/event-technology-trends-2026)
