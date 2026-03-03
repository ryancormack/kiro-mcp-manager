---
id: KIRO-004.01
title: Configure Xcode project versioning from git tags
status: To Do
assignee: []
created_date: '2026-03-03 21:33'
labels: []
dependencies: []
parent_task_id: KIRO-004
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure the Xcode project so that version numbers are derived from git tags during CI builds. This ensures the app's version (shown in About, Finder, etc.) matches the release tag.

MARKETING_VERSION should match the tag (e.g., 1.0.0 from v1.0.0).
CURRENT_PROJECT_VERSION should be a build number (can use commit count or CI run number).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Xcode project builds successfully with version derived from git tag
- [ ] #2 App bundle shows correct version in Finder Get Info
- [ ] #3 Build script or CI step extracts version from tag and injects into build
<!-- AC:END -->
