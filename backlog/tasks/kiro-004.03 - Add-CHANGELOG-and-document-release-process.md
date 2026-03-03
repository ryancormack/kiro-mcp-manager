---
id: KIRO-004.03
title: Add CHANGELOG and document release process
status: In Progress
assignee: []
created_date: '2026-03-03 21:33'
updated_date: '2026-03-03 21:34'
labels: []
dependencies: []
parent_task_id: KIRO-004
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create CHANGELOG.md to track release notes and document the release process for maintainers.

CHANGELOG should follow Keep a Changelog format.

Documentation should cover:
- How to cut a new release (tag and push)
- Required GitHub secrets and how to set them up
- How to update the Homebrew formula after a release
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 CHANGELOG.md exists with Keep a Changelog format
- [ ] #2 README includes installation instructions via Homebrew
- [ ] #3 RELEASING.md (or README section) documents how to cut a release
- [ ] #4 GitHub secrets setup is documented
<!-- AC:END -->
