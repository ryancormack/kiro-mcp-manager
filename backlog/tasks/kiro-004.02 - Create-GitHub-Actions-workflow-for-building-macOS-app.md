---
id: KIRO-004.02
title: Create GitHub Actions workflow for building macOS app
status: Done
assignee: []
created_date: '2026-03-03 21:33'
updated_date: '2026-03-03 21:35'
labels: []
dependencies: []
documentation:
  - >-
    https://docs.github.com/en/actions/use-cases-and-examples/building-and-testing/building-and-testing-swift
parent_task_id: KIRO-004
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a GitHub Actions workflow that triggers on version tags (v*) and builds the Xcode project on a macOS runner.

The workflow should:
- Checkout code
- Extract version from tag
- Build release configuration using xcodebuild
- Archive the .app bundle
- Upload as workflow artifact (signing comes in next task)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Workflow file exists at .github/workflows/release.yml
- [x] #2 Workflow triggers only on tags matching v*
- [x] #3 Workflow builds the app in Release configuration
- [x] #4 Built .app is uploaded as artifact
<!-- AC:END -->
