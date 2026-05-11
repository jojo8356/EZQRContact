# Flutter test — benchmark perf

**Date :** 2026-05-11
**Machine :** 4 cores CPU (Linux)
**Suite :** 47 tests répartis sur 5 fichiers `_test.dart`

## Mesures

| Stratégie | Wall time | Gain vs baseline |
|---|---|---|
| `flutter test test/` (baseline) | 9.94s | — |
| `flutter test --no-pub test/` | 9.21s | -7% |
| `flutter test --concurrency=4 test/` | 8.94s | -10% |
| `flutter test --no-pub --concurrency=4 test/` | 8.89s | -11% |
| **`flutter test test/all_tests_test.dart` (1 fichier consolidé)** | **5.32s** | **-46%** |

Le fichier consolidé importait les 5 entry points et appelait chaque `main()` séquentiellement. Il n'est PAS versionné — recréable à la demande.

## Pourquoi c'est lent

Bottleneck = **compilation Dart par fichier `_test.dart`**, pas pub ni parallélisation.

- Chaque fichier `_test.dart` coûte ~3-7s à compiler + spawn d'isolate.
- 5 fichiers × ~3-7s ÷ concurrency=2 (default = moitié des cores) ≈ 7-17s théorique, ~9s mesuré.
- Tests eux-mêmes : 0-3s (Drift in-memory + provider).

`--no-pub` skip seulement la résolution deps (~0.5s, déjà cached). `--concurrency` plafonné par # cores (4 ici) et par le nombre de fichiers (5).

La consolidation supprime 4 compiles sur 5 → 5s presque tout en compile du fichier unique.

## Quand utiliser quoi

| Besoin | Commande |
|---|---|
| Dev itératif sur 1 sujet | `flutter test test/providers/lang_provider_test.dart` (4-6s) |
| Full suite avant push | créer `test/all_tests_test.dart` ad-hoc → `flutter test test/all_tests_test.dart` (5s) |
| Run par défaut | `flutter test test/` (10s) |

## Trade-off de la consolidation

- **Pour** : -46% sur full suite.
- **Contre** : un seul fichier de résultat → moins de filtre par fichier (mais `--name` reste dispo) ; ajout/suppression de fichier de test demande de maintenir l'index. Pour 5 fichiers c'est trivial ; au-delà de 20 ça devient du bruit.

## Pistes non explorées

- **`dart test`** direct (au lieu de `flutter test`) sur les tests qui n'utilisent pas `TestWidgetsFlutterBinding` — gain potentiel ~30% pour les tests Drift purs. Setup non-trivial.
- **Sharding CI** `--total-shards N --shard-index M` : utile si plusieurs runners GitHub Actions parallèles (story 1-5 / 8-1).
- **Désactiver `checkIntrinsicSizes`** via binding custom : pertinent uniquement avec une grosse suite de widget tests, pas le cas ici.

## Sources

- [flutter/flutter#168268 — test concurrency and performance is very low](https://github.com/flutter/flutter/issues/168268)
- [flutter/flutter#69429 — Make tests compile and run faster](https://github.com/flutter/flutter/issues/69429)
- [Akhmat Sultanov — Speeding up unit & widget test run on CI](https://medium.com/@akhmat-s/flutter-testing-speeding-up-unit-widget-test-run-on-ci-504524a9ac25)
- [DeKu — Improve test execution speed with concurrency option](https://deku.posstree.com/en/flutter/test/concurrency/)
