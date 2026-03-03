---
id: KIRO-003
title: Create update-settings-ui skill to sync settings with Kiro CLI
status: Done
assignee: []
created_date: '2026-03-03 10:04'
updated_date: '2026-03-03 10:07'
labels:
  - feature
  - skill
dependencies: []
documentation:
  - 'https://kiro.dev/docs/cli/skills/'
  - 'https://kiro.dev/docs/cli/reference/settings/'
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a local Agent Skill that keeps the Settings UI in sync with Kiro CLI's available settings.

Kiro CLI updates regularly and adds new settings. This skill will allow running a simple command to update `SettingsModels.swift` with any new or changed settings from the official documentation.

The skill should:
1. Fetch the latest settings from https://kiro.dev/docs/cli/reference/settings/
2. Compare with current settings in `SettingsModels.swift`
3. Add any missing settings with appropriate type, category, and hint
4. Report what was added/changed
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Skill lives in .kiro/skills/update-settings-ui/SKILL.md
- [x] #2 Skill activates when user says 'update settings ui' or similar
- [x] #3 Skill instructions guide Kiro to fetch settings docs and update SettingsModels.swift
- [x] #4 Skill preserves existing settings and only adds new ones
- [x] #5 Skill includes reference to the settings documentation URL
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
## Summary
Created the `update-settings-ui` Agent Skill to keep the Settings UI in sync with Kiro CLI.

## Changes
- Created `.kiro/skills/update-settings-ui/SKILL.md`

## Skill Details
- Activates on phrases like "update settings ui", "sync settings", "check for new settings"
- Guides Kiro through a 5-step workflow:
  1. Fetch latest settings from docs
  2. Read current SettingsModels.swift
  3. Compare and identify gaps
  4. Update the file with missing settings
  5. Report what changed
- Includes category and type mapping tables
- Preserves existing settings while adding new ones
<!-- SECTION:FINAL_SUMMARY:END -->
