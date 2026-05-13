# Release Process

Step-by-step guide for releasing a new version of EZQRContact.

## Prerequisites

- Android keystore configured in GitHub Secrets:
  - `KEYSTORE_BASE64`: Base64-encoded `.jks` keystore file
  - `KEY_ALIAS`: Key alias inside the keystore
  - `KEY_PASSWORD`: Key password
  - `STORE_PASSWORD`: Keystore password
- Flutter stable SDK installed locally
- Write access to the repository

## Release Steps

### 1. Bump the version

In `pubspec.yaml`, update `version`:

```yaml
version: X.Y.Z+BUILD
```

### 2. Update changelog (optional)

Add a `## vX.Y.Z` section to `CHANGELOG.md` if present.

### 3. Commit the bump

```bash
git add pubspec.yaml
git commit -m "chore(release): vX.Y.Z"
```

### 4. Create and push the tag

```bash
git tag vX.Y.Z
git push origin main --tags
```

The `release.yml` GitHub Actions workflow triggers automatically on `v*.*.*` tags.

### 5. Verify CI

Check the Actions tab on GitHub:

- `flutter analyze` must pass
- `flutter test` must pass
- APK build must succeed
- GitHub Release created with the APK attached

### 6. Test the APK

Download the APK from the GitHub Release and install on a test device.

### 7. Google Play — upload to internal track

1. Open [Google Play Console](https://play.google.com/console)
2. Select EZQRContact → Release → Internal testing
3. Upload the APK from the GitHub Release
4. Add release notes
5. Roll out to internal track

### 8. Promote to production

After internal testing passes:

1. Promote from Internal → Closed testing → Open testing → Production
2. Set rollout percentage (recommend 20% → 50% → 100% over a few days)

### 9. iOS (via Xcode/Transporter)

1. `flutter build ipa --release`
2. Open Xcode → Organizer → Distribute App
3. Or use Transporter.app to upload the IPA
4. Submit for review on App Store Connect
