---
id: KIRO-006
title: Add unit tests for core logic
status: In Progress
assignee: []
created_date: '2026-03-04 21:54'
updated_date: '2026-03-04 21:55'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add unit tests for the application's core business logic to improve code quality and catch regressions. The app currently has no test coverage.

Core logic to test:
- **McpModels.swift**: `AnyCodableValue` encoding/decoding, `McpServer` properties (isDisabled, isLocal, isRemote, disabledTools), `McpConfig` parsing
- **SettingsModels.swift**: `SettingDefinition` structure, category grouping
- **MCPConfigManager.swift**: Config parsing, server toggling logic, tool enable/disable logic, environment variable expansion
- **SettingsManager.swift**: Settings value get/set operations, type conversions (getBool, getString, getNumber)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 XCTest target added to Xcode project
- [ ] #2 Tests for AnyCodableValue JSON round-trip encoding/decoding
- [ ] #3 Tests for McpServer computed properties (isDisabled, isLocal, isRemote, serverType, disabledTools)
- [ ] #4 Tests for McpConfig parsing from JSON
- [ ] #5 Tests for environment variable expansion in MCPConfigManager
- [ ] #6 Tests pass in CI (GitHub Actions)
<!-- AC:END -->
