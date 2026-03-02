---
id: KIRO-001
title: Allow a user to see the Tools available through each active MCP server
status: Done
assignee: []
created_date: '2026-03-02 22:46'
updated_date: '2026-03-02 23:24'
labels: []
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
As a User I want to be able to expand the name of the MCP server and see the Tools the server exposes.

This will allow a user to enable/disable specific tools. Docs for disabled tools are available here, https://kiro.dev/docs/cli/mcp/configuration/#disabling-specific-tools
A user should be able to disable specific tools via the Menu Bar UI we have
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A user is able to disable specific tools
- [x] #2 A user is able to enable a specific tool that had previously been disabled
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Summary

### Approach
Since the app runs in a macOS sandbox, we cannot spawn MCP server processes to auto-discover tools. Instead, the UI shows currently disabled tools from the config and allows manual entry of tool names to disable.

### Changes Made

1. **McpModels.swift** - Added `disabledTools` support to `McpServer`:
   - `disabledTools` computed property to read the array from config
   - `setDisabledTools(_:)` method to update the array (removes key if empty)
   - `isToolDisabled(_:)` helper to check if a specific tool is disabled

2. **MenuContentView.swift** - Updated UI with expandable server rows:
   - Every server row has a chevron to expand/collapse the tools section
   - Shows "No tools disabled" when `disabledTools` is empty
   - Lists disabled tools with red X icon and "Enable" button
   - Text field + "Add" button to disable a tool by name

3. **MCPConfigManager.swift** - Added tool management:
   - `tools` dictionary maps server names to their disabled tools
   - `toggleTool(serverName:tool:)` removes a tool from `disabledTools` (re-enables it)
   - `addDisabledTool(serverName:tool:)` adds a tool to `disabledTools`

### How It Works

1. Click chevron next to any server to expand
2. See list of currently disabled tools (or "No tools disabled")
3. To disable a tool: type the tool name in the text field, click "Add"
4. To re-enable a tool: click "Enable" next to the disabled tool
5. Changes are saved to `~/.kiro/settings/mcp.json`

### Limitation
Users must know the tool name (run `/mcp` in Kiro CLI to see available tools) since auto-discovery is blocked by the macOS sandbox.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
### Technical Notes

- Attempted MCP server JSON-RPC querying but macOS sandbox blocks process spawning
- "Broken pipe" errors occurred when trying to communicate with spawned processes
- Kiro CLI doesn't appear to log MCP tools to a file we could read
- Final solution: manual tool entry with display of currently disabled tools
<!-- SECTION:NOTES:END -->
