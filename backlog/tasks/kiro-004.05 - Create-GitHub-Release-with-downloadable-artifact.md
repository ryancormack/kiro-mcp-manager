---
id: KIRO-004.05
title: Create GitHub Release with downloadable artifact
status: Done
assignee: []
created_date: '2026-03-03 21:33'
updated_date: '2026-03-03 21:35'
labels: []
dependencies:
  - KIRO-004.04
parent_task_id: KIRO-004
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extend the release workflow to create a GitHub Release with the signed/notarized app as a downloadable .zip artifact.

The workflow should:
- Create a .zip of the signed .app bundle
- Create a GitHub Release using the tag
- Upload the .zip as a release asset
- Generate SHA256 checksum for the artifact (needed for Homebrew)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 GitHub Release is created automatically on tag push
- [x] #2 Release includes downloadable .zip with the signed app
- [x] #3 Release includes SHA256 checksum file
- [x] #4 Release uses tag name as version
<!-- AC:END -->
