# Kiro MCP Manager

A lightweight macOS menu bar app for managing your [Kiro CLI](https://kiro.dev/docs/cli/) MCP server configuration.

No more editing JSON by hand or trying to remember which servers are enabled. Just click the **K** in your menu bar.

![macOS](https://img.shields.io/badge/macOS-26.1+-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Why?

Kiro CLI uses MCP (Model Context Protocol) servers to extend its capabilities. The configuration lives in `~/.kiro/settings/mcp.json` — a JSON file you'd normally edit by hand.

This app puts that config in your menu bar so you can:

- **See all your MCP servers** at a glance
- **Check which are enabled or disabled**
- **See whether each server is local or remote**
- **Toggle servers on and off** with a single click
- **Open the config file** in your default editor when you need to make deeper changes

## Important: Kiro CLI doesn't hot-reload

Kiro CLI loads MCP servers when a session starts. If you toggle a server while a session is running, the change won't take effect until the next session.

The quickest way to pick up changes:

```bash
# Exit your current session, then resume it
kiro-cli chat --resume
```

## Installation

1. Clone this repo
2. Open `KiroMcpManager/KiroMcpManager.xcodeproj` in Xcode
3. Build and run (`Cmd+R`)
4. Look for the **K** in your menu bar

### First launch

The app runs in a sandbox for security. On first launch it will ask you to select your `mcp.json` file:

1. Click the **K** in the menu bar
2. Click **Select mcp.json…**
3. Navigate to `~/.kiro/settings/mcp.json` and select it

This grants the app read/write access to that single file. The permission is remembered across launches.

> **Tip:** Press `Cmd+Shift+.` in the file picker to show hidden files like `.kiro`.

## Usage

Click the **K** in your menu bar to see your servers:

- Each server shows its **name**, **type** (Local or Remote), and an **on/off toggle**
- Flip a toggle to set `"disabled": true` or `"disabled": false` in the config
- Click **Edit Config…** to open the JSON file in your default editor
- Click **Quit** to close the app

The server list refreshes every time you open the menu.

## How it works

- Reads and writes `~/.kiro/settings/mcp.json` (the [global Kiro MCP config](https://kiro.dev/docs/cli/mcp/configuration/))
- A server is **Local** if it has a `command` field, **Remote** if it has a `url` field
- Toggling a server sets the `disabled` field to `true` or `false` — all other config is preserved
- Uses macOS security-scoped bookmarks so the sandboxed app only has access to the one file you granted

## Requirements

- macOS 26.1+
- Xcode 26.1+

## License

MIT
