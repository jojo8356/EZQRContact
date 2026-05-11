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
pnpm install        # installs commitlint + husky Git hook
flutter run
```

Requirements:

- Flutter SDK `^3.8.1`
- Android SDK with `compileSdkVersion = 35`
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

A `commitlint` Git hook enforces this format on every commit. It is
installed automatically the first time you run `pnpm install` at the
repo root (see the `.husky/commit-msg` hook + `.commitlintrc.json` +
`package.json` devDependencies). Rejected messages print the rule
that failed and exit non-zero, blocking the commit.

The hook also runs during interactive rebases. If you ever need to
preserve a non-conforming legacy message (for example when re-applying
an old `Revert "..."` commit), bypass it with:

```bash
git commit --no-verify -m "<your message>"
```

Use `--no-verify` only for revert / rebase scenarios — never as a
shortcut for skipping the linter on regular work.

## How to run tests

Run the full test suite with:

```bash
flutter test
```

The v1 codebase has a minimal test surface. The v2 roadmap (epics E1, E2,
and E3) includes a major test push using `mocktail` and
`sqflite_common_ffi`. If your PR introduces new logic, please add at least
one unit test next to it under `test/<mirror-of-lib-path>/`.

## Code style

This project currently uses [`flutter_lints`](https://pub.dev/packages/flutter_lints).
Migration to [`very_good_analysis`](https://pub.dev/packages/very_good_analysis)
is planned for v2 (story E1-2).

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

## License

By contributing, you agree that your contributions will be licensed under
the [MIT License](LICENSE).
