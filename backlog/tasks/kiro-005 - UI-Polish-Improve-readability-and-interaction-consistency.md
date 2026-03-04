---
id: KIRO-005
title: UI Polish - Improve readability and interaction consistency
status: To Do
assignee: []
created_date: '2026-03-04 21:16'
updated_date: '2026-03-04 21:16'
labels:
  - ui
  - polish
  - ux
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The current UI has several usability issues that make it feel clunky and hard to use. This task addresses readability, interaction consistency, and overall polish across both MCP and Settings tabs.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 MCP server rows are fully clickable to expand (not just the small chevron)
- [ ] #2 Settings and MCP tabs have consistent interaction patterns
- [ ] #3 Text is readable without straining (larger fonts, better contrast)
- [ ] #4 Text input fields have adequate width for content
- [ ] #5 Touch targets meet minimum size guidelines (~44pt)
- [ ] #6 Visual hierarchy is clear between categories, items, and controls
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Issues Identified

1. **MCP chevron hard to click** - Only the 12pt chevron icon is clickable, not the full row
2. **Inconsistent interaction** - Settings categories use full-row clickable buttons, MCP servers don't
3. **Small fonts** - Heavy use of `.font(.caption)` makes text hard to read
4. **Low contrast** - Overuse of `.foregroundStyle(.secondary)` reduces readability
5. **Cramped text inputs** - String fields are 100pt, number fields 60pt - too narrow
6. **Small touch targets** - Buttons and toggles are undersized

## Planned Changes

### 1. Make MCP server rows fully clickable (ServerRow)
- Wrap the entire HStack in a Button with `.contentShape(Rectangle())`
- Match the pattern used in CategoryRow for Settings
- Keep the toggle separate so it doesn't trigger expand

### 2. Increase font sizes
- Change `.font(.caption)` to `.font(.callout)` for labels and content
- Use `.font(.body)` for primary text (server names, category names)
- Keep `.font(.caption)` only for truly secondary info (server type badges)

### 3. Improve text contrast
- Remove unnecessary `.foregroundStyle(.secondary)` from primary labels
- Use `.secondary` only for hints and truly supplementary text

### 4. Widen text input fields
- String fields: 100pt → 140pt
- Number fields: 60pt → 80pt
- Tool name field: expand to fill available space

### 5. Increase padding and spacing
- Row vertical padding: 6pt → 10pt
- Better spacing between elements

### 6. Increase overall width
- Frame width: 280pt → 320pt to accommodate larger text and inputs

## Files to Modify
- `MenuContentView.swift` - ServerRow, ToolRow, MCPServersView
- `SettingsView.swift` - SettingRow, StringSettingControl, NumberSettingControl
<!-- SECTION:PLAN:END -->
