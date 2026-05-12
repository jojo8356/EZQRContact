**Titre** : EZQRContact

**Description** : Application mobile open-source (Flutter) qui génère des QR codes vCard à partager — scannez le QR d'un contact pour l'importer directement dans votre app Contacts, sans friction.

**Objectif** : Simplifier l'échange de contacts en remplaçant les cartes de visite papier par un QR code généré depuis le téléphone, compatible iOS, Android et Outlook.

**Ce que je recherche** : testeurs sur iOS et Android pour valider l'import vCard sur différentes apps Contacts (iPhone, Google, Outlook), et retours de devs Flutter sur la gestion vCard.

---

Refactor génération vCard

La génération de QR contact était le coeur de l'app, mais le format produit cassait silencieusement sur certains clients. Cette semaine, réécriture complète du pipeline vCard pour une compatibilité universelle.

Changements
- **vCard 3.0 strict** : le format par défaut est maintenant du vCard 3.0 conforme RFC 2426 — CRLF strict entre chaque ligne, line folding à 75 octets (UTF-8-aware), syntaxe `TEL;TYPE=WORK,VOICE:` compatible iPhone Contacts, Google Contacts et Outlook. Avant, les QR générés s'importaient parfois mal sur iOS.
- **Toggle vCard 4.0** : un toggle dans les paramètres permet de basculer en vCard 4.0 (RFC 6350) pour les utilisateurs qui veulent le format moderne. La préférence est persistée entre les redémarrages.
- **Parser dual-version** : `VCard.parse()` détecte automatiquement la version (2.1 / 3.0 / 4.0) et s'adapte — syntaxe `TYPE=` différente, line unfolding RFC 6350 (lignes de continuation). Un QR généré par iPhone s'importe maintenant correctement dans l'app.
- **Sanitisation renforcée** : `VCard.clean()` élimine désormais les caractères qui cassaient le format — `;` (éclatement de champ), `\r`/`\n` (injection de nouvelle ligne vCard), contrôles C0, DEL, surrogates non appairés, points de code non-caractères.

En chiffres
3 stories · 42 nouveaux tests · 3 formats vCard supportés (2.1, 3.0, 4.0) · 18 cas de sanitisation couverts

Repo : https://github.com/jojo8356/EZQRContact
