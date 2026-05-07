# Deferred Work

Liste centralisée des findings reportés depuis les code reviews BMAD. À traiter
dans une story dédiée ou en cleanup global quand bandwidth.

---

## Deferred from: code review of story-0.1 (2026-05-06)

- ~~**README.md no trailing newline** `[README.md:8]`~~ — **Résolu en story 0.2** (commit `ccd25da`). Le README réécrit finit par `0a` (LF).

## Deferred from: code review of story-0.2 (2026-05-07)

- **README.md links to CONTRIBUTING.md (file missing)** `[README.md:246]` — Le
  README mentionne `[CONTRIBUTING.md](CONTRIBUTING.md)` mais le fichier n'existe
  pas encore. Par design : sera créé en story E0.3
  (`0-3-ajouter-contributing-good-first-issues`). Lien GitHub affichera un 404
  jusqu'à la fermeture de cette story. Acceptable au stade actuel.
