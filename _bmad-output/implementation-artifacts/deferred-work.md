# Deferred Work

Liste centralisée des findings reportés depuis les code reviews BMAD. À traiter
dans une story dédiée ou en cleanup global quand bandwidth.

---

## Deferred from: code review of story-0.1 (2026-05-06)

- **README.md no trailing newline** `[README.md:8]` — Le fichier `README.md` ne
  finit pas par un newline (LF). Pré-existant (déjà dans le repo avant le
  commit `628d42b`). Bonne pratique POSIX. Sera résolu naturellement lors de
  la réécriture complète du README en story E0.2.
