---
id: KIRO-004.06
title: Create Homebrew Cask formula
status: Done
assignee: []
created_date: '2026-03-03 21:33'
updated_date: '2026-03-05'
labels: []
dependencies:
  - KIRO-004.05
parent_task_id: KIRO-004
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a Homebrew Cask formula so users can install with `brew install --cask kiro-mcp-manager`.

Options:
1. Create a tap repository (homebrew-kiro-mcp-manager) with the formula
2. Submit to homebrew-cask (requires app to be notable/popular)

Start with option 1 (personal tap) for immediate use. The formula should point to GitHub Releases.

Formula needs: app name, version, SHA256, download URL, app target name.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Homebrew Cask formula exists in a tap repository
- [x] #2 Users can install with brew install --cask command
- [x] #3 Formula points to GitHub Releases download URL
- [x] #4 Formula includes correct SHA256 checksum
- [x] #5 README documents tap and install command
<!-- AC:END -->
