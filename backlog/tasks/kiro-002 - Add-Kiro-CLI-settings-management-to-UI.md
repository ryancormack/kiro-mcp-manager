---
id: KIRO-002
title: Add Kiro CLI settings management to UI
status: In Progress
assignee: []
created_date: '2026-03-02 23:35'
updated_date: '2026-03-03 09:46'
labels:
  - feature
  - ui
dependencies: []
documentation:
  - 'https://kiro.dev/docs/cli/reference/settings/'
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extend the menu bar app to manage Kiro CLI settings (`~/.kiro/settings.json`) in addition to MCP server configuration.

Currently the app only manages `~/.kiro/settings/mcp.json`. Users should also be able to view and modify common Kiro CLI settings without editing JSON by hand.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 App reads and writes ~/.kiro/settings.json
- [ ] #2 Settings are displayed in a dedicated section of the menu
- [ ] #3 Boolean settings show as toggles (on/off)
- [ ] #4 String settings are editable via text input
- [ ] #5 Number settings are editable via text/stepper input
- [ ] #6 Changes persist to settings.json immediately
- [ ] #7 Existing settings values are preserved when modifying others
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

1. Create `SettingsManager.swift` - reads/writes `~/.kiro/settings.json`, reuses bookmark from MCP config (same parent folder)
2. Create `SettingsModels.swift` - define known settings with types (bool/string/number) and metadata
3. Create `SettingsView.swift` - collapsible section in menu with appropriate controls per type
4. Update `MenuContentView.swift` - add Settings section above MCP servers
5. Update `MCPConfigManager` - share bookmark access for settings.json (same ~/.kiro/settings/ folder)
<!-- SECTION:PLAN:END -->
