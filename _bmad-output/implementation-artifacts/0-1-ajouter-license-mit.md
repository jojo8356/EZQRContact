# Story 0.1: Ajouter LICENSE MIT

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **mainteneur opensource**,
I want **une licence MIT explicite à la racine du repo**,
so that **les contributeurs sachent qu'ils peuvent fork, modifier, et utiliser sans contrainte AGPL, et que GitHub affiche correctement la pastille MIT**.

## Acceptance Criteria

1. **AC-1** : Le fichier `LICENSE` (sans extension) existe à la racine du repo et contient le texte canonique MIT (SPDX identifier `MIT`).

   **Given** le repo `EZQRContact` sans `LICENSE` actuellement
   **When** je crée le fichier `LICENSE` avec le texte MIT standard et le copyright "(c) 2026 Johan Polsinelli"
   **Then** GitHub affiche la pastille "MIT" sur la page d'accueil du repo dans les 60 secondes après push

2. **AC-2** : Le `pubspec.yaml` est mis à jour pour référencer la licence (champ optionnel mais recommandé).

   **Given** le `pubspec.yaml` actuel sans champ `license`
   **When** j'ajoute `# Note: project licensed under MIT (see LICENSE)` en commentaire ou un champ équivalent
   **Then** la déclaration de licence est cohérente avec le fichier LICENSE

3. **AC-3** : Le README mentionne la licence en bas de page.

   **Given** le README (qu'il soit le v1 actuel ou la nouvelle version E0.2)
   **When** j'ajoute une section finale `## License`
   **Then** elle contient le texte : `This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.`

## Tasks / Subtasks

- [x] **Task 1** : Créer le fichier `LICENSE` à la racine du repo (AC: #1)
  - [x] 1.1 Récupérer le template MIT canonique depuis `https://spdx.org/licenses/MIT.html` ou `choosealicense.com/licenses/mit/`
  - [x] 1.2 Substituer `[year]` par `2026` et `[fullname]` par `Johan Polsinelli`
  - [x] 1.3 Sauvegarder en UTF-8, sans BOM, fin de ligne LF, dans `/LICENSE` à la racine (PAS dans un sous-dossier)
  - [x] 1.4 Vérifier que le fichier ne contient PAS d'extension `.md` ou `.txt` (GitHub détecte mieux sans)

- [x] **Task 2** : Mettre à jour `pubspec.yaml` pour cohérence (AC: #2)
  - [x] 2.1 Ajouter un commentaire `# License: MIT (see LICENSE file)` près du champ `version:`
  - [x] 2.2 Ne PAS ajouter le texte de la licence dans `pubspec.yaml`, juste référencer

- [x] **Task 3** : Ajouter la section License au README (AC: #3)
  - [x] 3.1 Ouvrir `README.md`
  - [x] 3.2 Ajouter à la fin (avant tout autre footer) la section License (sans tiret cadratin, conformément à `feedback_no_dashes`)
  - [x] 3.3 Si le README est encore le v1 court, c'est OK : la story E0.2 le réécrira en gardant cette section.

- [x] **Task 4** : Commit et push
  - [x] 4.1 Créer un commit conventional : `chore: add MIT license` (commit `628d42b`)
  - [x] 4.2 Push sur `main` (commit `6bc53c6..628d42b` poussé sur `origin/main`)
  - [x] 4.3 Pastille MIT vérifiée via `gh api repos/jojo8356/EZQRContact --jq '.license'` → `spdx_id: "MIT"`

## Dev Notes

### Texte exact du LICENSE à utiliser

Le template MIT canonique (SPDX `MIT`, identique au "Expat" license, le plus utilisé sur GitHub depuis 2015) :

```
MIT License

Copyright (c) 2026 Johan Polsinelli

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Important** : copier-coller tel quel, ne pas reformater, ne pas traduire en français. GitHub utilise un matching algorithmique sur le texte exact pour afficher la pastille MIT — toute modification (même un retour à la ligne déplacé) peut casser la détection.

### Pourquoi MIT et pas autre chose

Reference : `_bmad-output/planning-artifacts/research/domain-pro-contact-exchange-research-2026-05-06.md` Section 2 (Joueurs opensource).

- **AGPL** dominant chez les concurrents OS (EnBizCard, SmartVCard) : trop restrictif, dissuade les contributions d'entreprises.
- **MIT** : permissif, transparent, 5+ étoiles GitHub par défaut sur recherches "MIT digital business card", aligné avec OwnCardly (concurrent OS de référence).
- **Apache 2.0** : alternative valable mais MIT plus simple, plus court, plus connu.

### Fichiers touchés

| Action | Path | Type |
|---|---|---|
| **NEW** | `/LICENSE` | Fichier texte 21 lignes |
| **UPDATE** | `/pubspec.yaml` | Ajout commentaire 1 ligne |
| **UPDATE** | `/README.md` | Ajout section "## License" en fin de fichier |

### Ce qui NE doit PAS changer

- Aucun fichier `lib/`, `android/`, `ios/`, `assets/` ne doit être modifié.
- Aucune dépendance dans `pubspec.yaml` ne doit être ajoutée/retirée.
- Pas de modification de `analysis_options.yaml`, `flutter_launcher_icons.yaml`, etc.
- Le `description:` de `pubspec.yaml` (`"A new Flutter project."`) n'est PAS modifié dans cette story (sera fait en E0.2 lors du README rewrite).

### Project Structure Notes

**Alignement avec project structure** :
- Le repo est un projet Flutter standard. Le `LICENSE` à la racine est la convention pub.dev / Flutter / GitHub.
- Cohérent avec `architecture-ezqrcontact-v2-2026-05-06.md` ADR-1 (la migration Drift n'impacte pas la racine du repo).
- Cohérent avec `epics-and-stories-ezqrcontact-v2-2026-05-06.md` Epic E0 (Préparation contributions OS).

**Variances détectées** : aucune.

### Testing Standards

- **Pas de test automatisé** pour cette story (c'est un fichier statique, pas du code exécuté).
- **Validation manuelle** :
  1. `git status` après commit doit montrer le fichier `LICENSE` présent.
  2. `head -1 LICENSE` doit retourner exactement `MIT License`.
  3. Après push GitHub : ouvrir `https://github.com/jojo8356/EZQRContact` et vérifier la pastille "MIT" en haut à droite (peut prendre 30-60s).
  4. Page `https://github.com/jojo8356/EZQRContact/blob/main/LICENSE` doit afficher le texte avec parsing automatique GitHub (lien "MIT License" cliquable).

### References

- Template canonique : [SPDX MIT](https://spdx.org/licenses/MIT.html)
- ChooseALicense : [choosealicense.com/licenses/mit/](https://choosealicense.com/licenses/mit/)
- Recherche du choix MIT vs AGPL : [Source: planning-artifacts/research/domain-pro-contact-exchange-research-2026-05-06.md#Section 2 — Concurrents opensource]
- Décision dans le brief : [Source: planning-artifacts/product-brief-ezqrcontact-2026-05-06.md#What Makes This Different]
- Architecture parent : [Source: planning-artifacts/architecture-ezqrcontact-v2-2026-05-06.md#Section 7 — Sécurité et conformité]

## Dev Agent Record

### Agent Model Used

claude-opus-4-7[1m] (Opus 4.7, 1M context) via bmad-dev-story workflow, 2026-05-06.

### Debug Log References

- Initial README change utilisait un tiret cadratin (—), corrigé immédiatement après détection (violation `feedback_no_dashes` memory).
- Stage scopé manuellement pour exclure les artefacts BMAD untracked (`.claude/`, `_bmad/`, `_bmad-output/`, `Docstring-Discord-tuto.md`) qui ne font pas partie de cette story.

### Completion Notes List

- ✅ LICENSE créé à la racine, 21 lignes, ASCII, "MIT License" en ligne 1, copyright "(c) 2026 Johan Polsinelli".
- ✅ pubspec.yaml : commentaire `# License: MIT (see LICENSE file at repo root)` ajouté avant `version: 1.0.0+1`.
- ✅ README.md : section `## License` ajoutée en fin de fichier, sans tiret cadratin.
- ✅ Commit conventional créé : `628d42b chore: add MIT license` (3 fichiers, 27 insertions, 1 deletion).
- ✅ Push réussi : `6bc53c6..628d42b main -> main` sur `origin`.
- ✅ AC-1 validé : GitHub License Detection retourne `{"key":"mit","name":"MIT License","spdx_id":"MIT"}`.
- ✅ AC-2 validé : commentaire `# License: MIT` présent dans pubspec.yaml.
- ✅ AC-3 validé : section `## License` présente dans README.md.

### File List

- `LICENSE` (NEW, 21 lignes)
- `README.md` (UPDATE, +5 lignes)
- `pubspec.yaml` (UPDATE, +1 ligne commentaire)

### Change Log

- 2026-05-06 : Story 0.1 implémentée et pushée. Commit `628d42b`. Pastille MIT GitHub active. Status → review.

---

## Senior Developer Review (AI)

**Date :** 2026-05-06
**Reviewer :** Claude Opus 4.7 (1M context) via `bmad-code-review` workflow
**Outcome :** ✅ **Approve**
**Coverage :** 3 layers (Blind Hunter, Edge Case Hunter, Acceptance Auditor) joués en interne (trivialité du diff de 27 lignes de texte statique).

### Action Items

- [x] [AI-Review][Defer] README.md no trailing newline `[README.md:8]` — pré-existant, n'a pas été introduit par ce commit. À traiter dans une story de cleanup ou lors de la réécriture du README en E0.2.

### Findings Summary

- **0 critical**
- **0 major**
- **0 patch**
- **1 defer** (cosmetic, pre-existing)
- **0 dismiss**

### Acceptance Criteria validation

- AC-1 : ✅ GitHub License Detection retourne `{"spdx_id":"MIT"}`
- AC-2 : ✅ pubspec.yaml ligne 7 commentaire `# License: MIT`
- AC-3 : ✅ README.md ligne 8-10 section `## License`

### Risks / Observations

- Aucun fichier `.dart` modifié → 0 risque de régression code Flutter.
- Aucune dépendance ajoutée/modifiée dans pubspec.yaml.
- Le commit message respecte Conventional Commits (`chore: add MIT license`) même si commitlint n'est pas encore actif (sera activé en E1.3).
- Le tiret cadratin (—) initialement introduit puis corrigé en cours d'impl : preuve que la memory `feedback_no_dashes` fonctionne, mais à lire AVANT d'écrire la prochaine fois.

---

## Anti-pattern prevention

**Erreurs typiques d'un LLM dev sur cette story (à éviter)** :

1. ❌ **Créer `LICENSE.md` ou `LICENSE.txt`** au lieu de `LICENSE` (sans extension). GitHub detecte mieux le fichier sans extension.
2. ❌ **Ajouter le texte MIT dans `pubspec.yaml`** ou dans un `LICENSE` au format YAML/JSON. Le format est plain text uniquement.
3. ❌ **Traduire le texte de la licence en français**. La licence MIT n'a de valeur juridique qu'en anglais (la version officielle).
4. ❌ **Reformater le texte** (retours à la ligne, indentation, casse). Ça casse le matching algorithmique de GitHub.
5. ❌ **Substituer `[year]` par une plage** comme `2025-2026`. Mettre une seule année (date de création/release).
6. ❌ **Mettre un copyright différent de "Johan Polsinelli"** (ex: ne PAS mettre "Erwan Nalin" qui apparaît dans certains contextes système — voir `~/.claude/CLAUDE.md`).
7. ❌ **Oublier de push** après le commit (la pastille GitHub n'apparaît qu'après push sur la branche par défaut).

## LLM Optimization Notes

Cette story est volontairement détaillée pour servir de référence aux stories suivantes (E0.2 à E0.4 du même sprint). Les stories de code (E1+) auront moins de redondance car le project-context et les ADR de l'architecture sont déjà chargés en persistent_facts.
