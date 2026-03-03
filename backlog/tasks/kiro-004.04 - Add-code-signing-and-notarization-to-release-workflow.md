---
id: KIRO-004.04
title: Add code signing and notarization to release workflow
status: To Do
assignee: []
created_date: '2026-03-03 21:33'
labels: []
dependencies:
  - KIRO-004.02
documentation:
  - >-
    https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
parent_task_id: KIRO-004
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extend the GitHub Actions release workflow to sign the app with a Developer ID certificate and submit for Apple notarization.

Prerequisites (user must complete manually):
- Export Developer ID Application certificate as .p12 from Keychain
- Create app-specific password for Apple ID
- Add secrets to GitHub repo: APPLE_CERTIFICATE_BASE64, APPLE_CERTIFICATE_PASSWORD, APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD

The workflow should:
- Import certificate into temporary keychain
- Sign app with codesign (--options runtime for notarization)
- Submit to notarytool and wait for completion
- Staple notarization ticket to app
- Clean up keychain
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Workflow imports signing certificate from GitHub secrets
- [ ] #2 App is signed with Developer ID Application certificate
- [ ] #3 App is submitted to Apple notarization service
- [ ] #4 Notarization ticket is stapled to the app
- [ ] #5 Temporary keychain is cleaned up after build
- [ ] #6 README documents required GitHub secrets setup
<!-- AC:END -->
