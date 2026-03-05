# Releasing

This document describes how to cut a new release of Kiro MCP Manager.

## Prerequisites

### One-time setup (Apple Developer)

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
2. Create a "Developer ID Application" certificate in the Apple Developer portal
3. Download and install the certificate in Keychain Access
4. Export the certificate as a .p12 file:
   - Open Keychain Access
   - Find "Developer ID Application: Your Name"
   - Right-click → Export
   - Save as .p12 with a strong password

### One-time setup (GitHub Secrets)

Add these secrets to your GitHub repository (Settings -> Secrets and variables -> Actions):

| Secret | Description |
|--------|-------------|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded .p12 certificate (`base64 -i certificate.p12`) |
| `APPLE_CERTIFICATE_PASSWORD` | Password used when exporting the .p12 |
| `APPLE_DEVELOPER_NAME` | Your name as it appears on the certificate (e.g., "Ryan Cormack") |
| `APPLE_ID` | Your Apple ID email |
| `APPLE_TEAM_ID` | Your 10-character Team ID (find in Apple Developer portal) |
| `APPLE_APP_PASSWORD` | App-specific password from [appleid.apple.com](https://appleid.apple.com) |

To create an app-specific password:
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in -> Security -> App-Specific Passwords
3. Generate a new password for "GitHub Actions"

### One-time setup (Homebrew Tap)

The release workflow automatically updates the Homebrew Cask formula after each release. This requires:

1. **Create the tap repository**: Create a public GitHub repository named `ryancormack/homebrew-kiro-mcp-manager`. It can start empty; the workflow will push the `Casks/` directory automatically.

2. **Create a Personal Access Token**: Generate a GitHub PAT with `repo` scope that has push access to the `ryancormack/homebrew-kiro-mcp-manager` repository.

3. **Add the `HOMEBREW_TAP_TOKEN` secret**: Go to your repository Settings -> Secrets and variables -> Actions, and add the PAT as a secret named `HOMEBREW_TAP_TOKEN`.

## Cutting a Release

1. Update `CHANGELOG.md` with the new version and release notes

2. Commit the changelog:
   ```bash
   git add CHANGELOG.md
   git commit -m "Prepare release v1.0.0"
   ```

3. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin main --tags
   ```

4. The GitHub Actions workflow will automatically:
   - Build the app
   - Sign it with your Developer ID certificate
   - Submit for Apple notarization
   - Create a GitHub Release with the signed DMG
   - Update the Homebrew Cask formula in the tap repository

## Homebrew Formula (Automated)

After the build job completes, the release workflow automatically:

1. Downloads the SHA256 checksum file from the GitHub Release
2. Generates an updated Homebrew Cask formula with the correct version and SHA256
3. Commits and pushes the formula to the `ryancormack/homebrew-kiro-mcp-manager` tap repository

No manual intervention is needed. If the `HOMEBREW_TAP_TOKEN` secret is not configured or the tap repository does not exist, the `update-homebrew` job will fail without affecting the release itself.

## Troubleshooting

### Notarization fails
- Check that your Apple Developer account is in good standing
- Verify the app-specific password is correct
- Check the notarization log: `xcrun notarytool log <submission-id> --apple-id ... --team-id ...`

### Signing fails
- Verify the certificate hasn't expired
- Check that APPLE_DEVELOPER_NAME matches exactly what's on the certificate
- Re-export the certificate and update the GitHub secret

### Build fails
- Check the Xcode version in the workflow matches what's available on the runner
- Verify the project builds locally with `xcodebuild`
