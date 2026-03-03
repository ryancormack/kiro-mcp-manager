---
name: update-settings-ui
description: Update the Settings UI to match Kiro CLI's available settings. Use when syncing settings, updating settings UI, or checking for new Kiro CLI settings.
---

## Purpose

Keep `KiroMcpManager/KiroMcpManager/SettingsModels.swift` in sync with the settings available in Kiro CLI.

## Workflow

1. **Fetch the latest settings documentation**
   - URL: https://kiro.dev/docs/cli/reference/settings/
   - Extract all settings from the tables in these sections:
     - Telemetry and privacy
     - Chat interface
     - Knowledge base
     - Key bindings
     - Feature toggles
     - API and service
     - Model context protocol (MCP)

2. **Read the current settings**
   - File: `KiroMcpManager/KiroMcpManager/SettingsModels.swift`
   - Parse the `knownSettings` array to get existing setting keys

3. **Compare and identify gaps**
   - List settings in docs but not in `SettingsModels.swift`
   - List settings in `SettingsModels.swift` but not in docs (may be deprecated)

4. **Update SettingsModels.swift**
   - Add missing settings with:
     - `key`: The setting key from docs (e.g., `chat.defaultModel`)
     - `label`: Human-readable label derived from the key
     - `type`: `.bool`, `.string`, or `.number` based on the Type column
     - `category`: Map to existing categories (Privacy, Chat, Features, Knowledge, API, MCP)
     - `hint`: Use the Description from the docs
   - Preserve all existing settings
   - Keep settings grouped by category

5. **Report changes**
   - List added settings
   - List potentially deprecated settings (in code but not in docs)
   - Confirm the file compiles after changes

## Category mapping

| Docs Section | Category |
|--------------|----------|
| Telemetry and privacy | Privacy |
| Chat interface | Chat |
| Knowledge base | Knowledge |
| Key bindings | Chat |
| Feature toggles | Features |
| API and service | API |
| Model context protocol (MCP) | MCP |

## Type mapping

| Docs Type | Swift Type |
|-----------|------------|
| boolean | .bool |
| string | .string |
| number | .number |
| char | .string |
| array | (skip - not supported in UI) |

## Example addition

If docs show a new setting:
```
Setting: chat.newFeature
Type: boolean
Description: Enable the new feature
```

Add to `knownSettings`:
```swift
SettingDefinition(key: "chat.newFeature", label: "New Feature", type: .bool, category: "Chat", hint: "Enable the new feature"),
```
