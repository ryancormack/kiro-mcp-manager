---
id: KIRO-003
title: Create update-settings-ui skill to sync settings with Kiro CLI
status: In Progress
assignee: []
created_date: '2026-03-03 10:04'
updated_date: '2026-03-03 10:06'
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
- [ ] #1 Skill lives in .kiro/skills/update-settings-ui/SKILL.md
- [ ] #2 Skill activates when user says 'update settings ui' or similar
- [ ] #3 Skill instructions guide Kiro to fetch settings docs and update SettingsModels.swift
- [ ] #4 Skill preserves existing settings and only adds new ones
- [ ] #5 Skill includes reference to the settings documentation URL
<!-- AC:END -->
