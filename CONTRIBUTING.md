# Contributing to EZQRContact

Thanks for your interest in EZQRContact. This is a solo project (Johan,
student in BUT Info Nice), so any contribution from a bug report to a full
feature is genuinely appreciated. This guide tells you how to get set up,
where to find a starter task, and how to send a clean PR.

## How to set up locally

See the [Install / Quickstart](README.md#install--quickstart) section of the
README for the full setup. In short:

```bash
git clone https://github.com/jojo8356/EZQRContact.git
cd EZQRContact
flutter pub get
dart run build_runner build --delete-conflicting-outputs
pnpm install        # installs commitlint + husky Git hook
flutter test
flutter run
```

Requirements:

- Flutter SDK `>=3.47.0`
- Android SDK with `compileSdk = 37`
- Xcode 15+ for iOS builds (Mac only)
- Node.js 18+ and [pnpm](https://pnpm.io) (only for the commit-msg
  Git hook; no application code uses Node)

## Pull request workflow

1. Open or pick an existing issue, ideally one tagged `good first issue` if
   it is your first PR. Comment on the issue to claim it.
2. Fork the repo and clone your fork locally.
3. Create a branch named `feat/<short-name>` for a new feature or
   `fix/<issue-number>` for a bug fix.
4. Make your changes, run `flutter analyze` and `flutter test` locally.
5. Commit using the Conventional Commits format (see below).
6. Push to your fork and open a Pull Request against `main`.
7. Wait for review. Reviews are usually within a few days.

## Commit message convention

This project follows [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/).

Format:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

Common types:

- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation only
- `style`: formatting, no logic change
- `refactor`: neither a feature nor a bug fix
- `test`: adding or fixing tests
- `chore`: build, deps, configs
- `perf`: performance improvement
- `ci`: CI pipeline

Examples for this project:

```
feat(vcard): support NICKNAME field in parser
fix(db): avoid duplicates when cloning a VCard
chore(deps): bump permission_handler from 12.0.1 to 12.1.0
docs(readme): add screenshots from v2 release
```

Rules enforced by `@commitlint/config-conventional` (most common):

- Header (first line): max 72 characters, no trailing period.
- Body lines: max 100 characters each.
- Type: must be one of the list above.
- `Merge branch ...` and `Revert "..."` auto-messages are ignored
  by default — no need for `--no-verify` on those.

A `commitlint` Git hook enforces these rules on every commit. It is
installed automatically the first time you run `pnpm install` at the
repo root (see the `.husky/commit-msg` hook + `.commitlintrc.json` +
`package.json` devDependencies). Rejected messages print the rule
that failed and exit non-zero, blocking the commit.

**Verify the hook is active** after `pnpm install` with:

```bash
ls .husky/_/commit-msg   # husky shim, must exist
```

If the file is missing, re-run `pnpm install` or `pnpm exec husky init`.

The hook runs during `git commit --amend` and during `reword` steps of
interactive rebases. If you need to bypass it for a one-off legacy
fixup, use:

```bash
git commit --no-verify -m "<your message>"
```

Use `--no-verify` only for revert / rebase scenarios — never as a
shortcut for skipping the linter on regular work.

**GUI Git clients** (Tower, GitHub Desktop, IntelliJ, VS Code commit UI)
sometimes launch with a minimal `PATH` that doesn't include `pnpm`,
causing the hook to fail with `pnpm: command not found`. If this happens,
either commit from a terminal where `pnpm` is on `PATH`, or configure
your client to source your shell profile (`~/.zshrc` / `~/.bashrc`).
Run `corepack enable` once to make `pnpm` available system-wide via
Node's Corepack shim — recommended for Node 20+.

## How to run tests

Generate Drift (`lib/data/db/database.g.dart`) then run tests:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter pub get
flutter test
```

`test/flutter_test_config.dart` boots sqflite FFI and silences Drift's
multi-instance warning. Data tests open an **in-memory** DB with
`openTestDb()` from `test/helpers/test_db.dart` — never the on-device
`qr_app.db`.

Art direction (ENCRE) is locked by `test/theme/encre_da_test.dart` and the
widget tests under `test/components/` (AppButton, AppSwitch, PaperCard,
Navbar, …). After a visual change, run at least:

```bash
flutter test test/theme test/components
```

Pump UI under `encreApp()` from `test/helpers/encre.dart` — never the
default Material starter theme (blue seed, pills, Roboto).

If your PR introduces new logic, add at least one test next to it under
`test/<mirror-of-lib-path>/`. Device flows (camera, contacts, gallery)
belong in `integration_test/` plus a script under `scripts/` when they
must run on a phone.

README screenshots: `./scripts/capture_screenshots.sh` (seeds demo
contacts, then `adb screencap`). User-facing copy: `docs/help/`.

## Code style

This project uses [`very_good_analysis`](https://pub.dev/packages/very_good_analysis)
plus two house rules enforced by tests (no ternary, pure display returns).

Before opening a PR:

```bash
flutter analyze
```

Fix all reported warnings, or suppress with `// ignore:` and a clear
justification comment.

## Looking for something to do?

If you want to contribute but do not know where to start, browse the
[Good First Issues](https://github.com/jojo8356/EZQRContact/contribute) page.
Each issue has a clear scope estimate and the skills you need.

Other ways to help:

- Star the repo
- Try the app and report bugs via issues
- Suggest features via issues
- Add a translation in `assets/langs/` (current: French, English)

## No ternary operators

House rule: **do not use `cond ? a : b`**. Dart has no native `no_ternary`
lint (`unneeded_ternary` / `prefer_if_widgets` do not exist in the SDK).
We enable `prefer_if_elements_to_conditional_expressions` and enforce the
full ban in `test/lint/no_ternary_test.dart`.

Use `if` / `else` (statements or collection-if). Null-aware `??`, `?.`,
`?[` and nullable types (`String?`) are fine.

```dart
// Bad
final color = selected ? copper : muted;
child: loading ? const Spinner() : body,

// Good
late final Color color;
if (selected) {
  color = copper;
} else {
  color = muted;
}

child: Builder(
  builder: (context) {
    if (loading) return const Spinner();
    return body;
  },
)

children: [
  if (loading) const Spinner() else body,
]
```

## Pure display returns

A `build` (or builder) **return is a widget tree**, not a place for
algorithms. No IIFE `() { ... }()` inside the tree. Compute values
above the `return`, or extract a component.

Allowed in the tree: widgets, components, collection-if of widgets,
event callbacks (`onPressed: () { ... }`).

Enforced by `test/lint/no_iife_in_display_test.dart`.

```dart
// Bad — algorithm in the display return
return Scaffold(
  body: () {
    if (loading) return const Spinner();
    return list;
  }(),
);

// Good — algorithm above the return
Widget body = list;
if (loading) {
  body = const Spinner();
}
return Scaffold(body: body);

// Good — algorithm inside a component
return Scaffold(body: HistoryBody(loading: loading, items: items));
```

## License

By contributing, you agree that your contributions will be licensed under
the [MIT License](LICENSE) and that you will follow the
[Code of Conduct](CODE_OF_CONDUCT.md).
