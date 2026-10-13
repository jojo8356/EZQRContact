# Maintainer notes

Not for end users. Product docs live in [docs/help/](../help/).

| File | What |
|---|---|
| [manual-test.md](../manual-test.md) | Device checklist before a release |
| [qa/plan-tests-manuels.md](../qa/plan-tests-manuels.md) | QA plan |
| [direction-artistique.md](../direction-artistique.md) | ENCRE |
| [flutter-test-perf.md](flutter-test-perf.md) | Test runtime notes |
| [prd-torch-camera-bug.md](prd-torch-camera-bug.md) | Known torch / camera issue |

`TDL.txt` at the repo root is a 2025 alpha scratchpad. Do not treat it as the
roadmap.

To publish a branch as yourself only (strip `Co-authored-by: arena-agent`
trailers, set author/committer):

```bash
./scripts/claim_as_me.sh          # rewrite current branch
./scripts/claim_as_me.sh --push   # then force-with-lease that branch
```
