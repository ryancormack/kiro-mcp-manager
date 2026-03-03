---
id: KIRO-004
title: Automated Release Pipeline for macOS Distribution
status: To Do
assignee: []
created_date: '2026-03-03 21:32'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Set up a complete release pipeline to build, sign, notarize, and distribute the Kiro MCP Manager app via GitHub Releases and Homebrew Cask.

Users should be able to install with `brew install --cask kiro-mcp-manager` and have the app "just work" without Gatekeeper warnings.

The pipeline should trigger on git tags (e.g., `v1.0.0`) and automatically produce signed, notarized release artifacts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pushing a version tag (e.g., v1.0.0) triggers an automated build and release
- [ ] #2 Released app is code-signed with Developer ID certificate
- [ ] #3 Released app is notarized by Apple
- [ ] #4 GitHub Release is created with downloadable artifact
- [ ] #5 Homebrew Cask formula exists for easy installation
- [ ] #6 README documents installation and release process
<!-- AC:END -->
