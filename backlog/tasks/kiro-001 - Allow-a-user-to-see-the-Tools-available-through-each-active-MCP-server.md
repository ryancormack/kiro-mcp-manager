---
id: KIRO-001
title: Allow a user to see the Tools available through each active MCP server
status: Done
assignee: []
created_date: '2026-03-02 22:46'
updated_date: '2026-03-02 22:57'
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

### Changes Made

1. **McpModels.swift** - Added `disabledTools` support to `McpServer`:
   - `disabledTools` computed property to read the array from config
   - `setDisabledTools(_:)` method to update the array (removes key if empty)
   - `isToolDisabled(_:)` helper to check if a specific tool is disabled

2. **MenuContentView.swift** - Updated UI with expandable server rows:
   - `ServerRow` now shows a chevron disclosure indicator when tools are available
   - Clicking the chevron expands/collapses the tools list
   - `ToolRow` component shows each tool with a mini toggle switch
   - Disabled tools appear with secondary text color

3. **MCPConfigManager.swift** - Added tool discovery and toggle functionality:
   - `tools` dictionary maps server names to their available tools
   - `toggleTool(serverName:tool:)` adds/removes tools from `disabledTools` array
   - `discoverTools()` queries enabled local MCP servers via JSON-RPC
   - Uses MCP protocol's `tools/list` method to get available tools
   - Environment variable expansion for server config

### How It Works

1. When the menu opens, `loadConfig()` is called
2. For each enabled local server, the app spawns the MCP server process
3. Sends JSON-RPC `initialize` and `tools/list` requests
4. Parses the response to extract tool names
5. Tools appear in an expandable list under each server
6. Toggling a tool updates `disabledTools` in mcp.json
<!-- SECTION:PLAN:END -->
