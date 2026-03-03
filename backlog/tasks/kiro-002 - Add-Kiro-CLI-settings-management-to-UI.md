---
id: KIRO-002
title: Add Kiro CLI settings management to UI
status: Done
assignee: []
created_date: '2026-03-02 23:35'
updated_date: '2026-03-03 09:48'
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
- [x] #1 App reads and writes ~/.kiro/settings.json
- [x] #2 Settings are displayed in a dedicated section of the menu
- [x] #3 Boolean settings show as toggles (on/off)
- [x] #4 String settings are editable via text input
- [x] #5 Number settings are editable via text/stepper input
- [x] #6 Changes persist to settings.json immediately
- [x] #7 Existing settings values are preserved when modifying others
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
## Summary
Added Kiro CLI settings management to the menu bar UI.

## Changes
- `SettingsModels.swift` - Defines 18 known settings across 6 categories (Privacy, Chat, Features, Knowledge, API, MCP) with type metadata
- `SettingsManager.swift` - Reads/writes `~/.kiro/settings.json`, reuses the existing security-scoped bookmark
- `SettingsView.swift` - Collapsible category UI with appropriate controls per type (toggles for bools, text fields for strings/numbers)
- `MenuContentView.swift` - Added expandable "Settings" section above MCP servers
- `KiroMcpManagerApp.swift` - Instantiates and passes SettingsManager

## UI Design
- Settings appear as a collapsible section at the top of the menu
- Categories (Privacy, Chat, Features, etc.) expand to show individual settings
- Boolean settings use toggle switches
- String/number settings use inline text fields that save on blur or Enter
<!-- SECTION:FINAL_SUMMARY:END -->
