**Titre** : EZQRContact

**Description** : Application mobile open-source (Flutter) qui génère des QR codes vCard à partager — scannez le QR d'un contact pour l'importer directement dans votre app Contacts, sans friction.

**Objectif** : Simplifier l'échange de contacts en remplaçant les cartes de visite papier par un QR code généré depuis le téléphone, compatible iOS, Android et Outlook.

**Ce que je recherche** : retours sur l'expérience utilisateur, testeurs sur iOS ou Android, et avis de développeurs Flutter sur les choix techniques.

---

Fondations V2 posées

Pas de nouvelles features visibles pour l'instant, mais c'est volontaire : cette semaine c'était refonte technique complète avant d'ajouter quoi que ce soit.

Changements
- **sqflite -> Drift** : toute la persistance est maintenant type-safe via ORM codegen. L'ancien `db.dart` (~410 lignes de SQL raw) a été supprimé. Migration auto v1 -> v2 avec backup des données existantes
- **Lint strict** : passage de `flutter_lints` à `very_good_analysis` — ruleset ~2x plus exigeant. `flutter analyze` -> 0 issue
- **Conventional Commits** : hook Git (commitlint + husky) actif — les commits "wip" ou "fix bug" sont maintenant rejetés automatiquement
- **i18n corrigé** : le choix de langue FR/EN est maintenant persisté entre les redémarrages. Avant, la locale du téléphone écrasait le choix manuel à chaque kill de l'app
- **CI GitHub Actions** : chaque push et chaque PR déclenche analyze + tests automatiquement. Badge dans le README

En chiffres
0 -> 47 tests automatisés · 8 stories · ~410 lignes de code legacy supprimées · CI < 4 min par run

Repo : https://github.com/jojo8356/EZQRContact
