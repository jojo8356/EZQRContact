## What

<!-- 1–3 sentences. Link the issue if there is one. -->

## How to test

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

<!-- Extra device steps if you touched camera, contacts, or files. -->

## Checklist

- [ ] No `cond ? a : b` in Dart (`test/lint/no_ternary_test.dart`)
- [ ] `build` returns are widget trees only
- [ ] New logic has a test under `test/`
- [ ] Docs updated if the user-facing flow changed
