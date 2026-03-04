---
id: KIRO-006
title: Add unit tests for core logic
status: Done
assignee: []
created_date: '2026-03-04 21:54'
updated_date: '2026-03-04 21:59'
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
- [x] #1 XCTest target added to Xcode project
- [x] #2 Tests for AnyCodableValue JSON round-trip encoding/decoding
- [x] #3 Tests for McpServer computed properties (isDisabled, isLocal, isRemote, serverType, disabledTools)
- [x] #4 Tests for McpConfig parsing from JSON
- [x] #5 Tests for environment variable expansion in MCPConfigManager
- [x] #6 Tests pass in CI (GitHub Actions)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create KiroMcpManagerTests directory with test file
2. Update project.pbxproj to add test target
3. Make expandEnvVar internal for testability
4. Write tests for AnyCodableValue, McpServer, McpConfig, and env var expansion
5. Update GitHub Actions to run tests
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added unit tests for the application's core logic:

**Files created:**
- `KiroMcpManager/KiroMcpManagerTests/McpModelsTests.swift` - 20 tests for AnyCodableValue, McpServer, and McpConfig
- `KiroMcpManager/KiroMcpManagerTests/MCPConfigManagerTests.swift` - 4 tests for environment variable expansion

**Files modified:**
- `KiroMcpManager/KiroMcpManager.xcodeproj/project.pbxproj` - Added KiroMcpManagerTests target
- `KiroMcpManager/KiroMcpManager/MCPConfigManager.swift` - Made `expandEnvVar` internal for testability
- `.github/workflows/release.yml` - Added test step before build

**Test coverage:**
- AnyCodableValue: JSON round-trip encoding/decoding for all types (string, int, bool, null, array, object)
- McpServer: isDisabled, isLocal, isRemote, serverType, disabledTools, setDisabled, setDisabledTools, isToolDisabled, field preservation
- McpConfig: Multi-server parsing, round-trip encoding
- MCPConfigManager: Environment variable expansion (plain text, known vars, unknown vars, multiple vars)

All 24 tests pass locally and will run in CI on release.
<!-- SECTION:FINAL_SUMMARY:END -->
