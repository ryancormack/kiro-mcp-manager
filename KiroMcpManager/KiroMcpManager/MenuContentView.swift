import SwiftUI

struct MenuContentView: View {
    @Bindable var manager: MCPConfigManager
    @Bindable var settingsManager: SettingsManager
    
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !manager.hasBookmark {
                Text("Grant access to your MCP config file")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(12)
                Button("Select mcp.json…") {
                    manager.requestFileAccess()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            } else {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    Text("MCP").tag(0)
                    Text("Settings").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                
                Divider()
                
                if selectedTab == 0 {
                    MCPServersView(manager: manager)
                } else {
                    SettingsSection(manager: settingsManager)
                        .padding(.top, 4)
                }
            }

            Divider().padding(.vertical, 4)

            HStack {
                if selectedTab == 0 {
                    Button("Edit Config…") {
                        manager.openInEditor()
                    }
                } else {
                    Button("Edit Settings…") {
                        settingsManager.openInEditor()
                    }
                    Button("Docs") {
                        NSWorkspace.shared.open(URL(string: "https://kiro.dev/docs/cli/reference/settings/")!)
                    }
                }
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(width: 320)
        .onAppear {
            if manager.hasBookmark {
                manager.loadConfig()
                settingsManager.loadSettings()
            }
        }
    }
}

private struct MCPServersView: View {
    @Bindable var manager: MCPConfigManager
    
    var body: some View {
        if let error = manager.errorMessage {
            Text(error)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(12)
        } else if manager.servers.isEmpty {
            Text("No MCP servers configured")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(12)
        } else {
            ForEach(manager.servers, id: \.name) { entry in
                ServerRow(
                    name: entry.name,
                    server: entry.server,
                    disabledTools: manager.tools[entry.name] ?? [],
                    onToggle: { manager.toggleServer(name: entry.name) },
                    onToggleTool: { tool in manager.toggleTool(serverName: entry.name, tool: tool) },
                    onAddTool: { tool in manager.addDisabledTool(serverName: entry.name, tool: tool) }
                )
            }
        }
    }
}

private struct ServerRow: View {
    let name: String
    let server: McpServer
    let disabledTools: [String]
    let onToggle: () -> Void
    let onToggleTool: (String) -> Void
    let onAddTool: (String) -> Void

    @State private var isExpanded = false
    @State private var newToolName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { isExpanded.toggle() }) {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.callout)
                            .frame(width: 16)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name).fontWeight(.medium)
                            Text(server.serverType)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Toggle("", isOn: Binding(
                    get: { !server.isDisabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    if disabledTools.isEmpty {
                        Text("No tools disabled")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(disabledTools, id: \.self) { tool in
                            ToolRow(tool: tool, onRemove: { onToggleTool(tool) })
                        }
                    }

                    HStack(spacing: 8) {
                        TextField("Tool name to disable", text: $newToolName)
                            .textFieldStyle(.roundedBorder)
                            .font(.callout)
                        Button("Add") {
                            onAddTool(newToolName)
                            newToolName = ""
                        }
                        .disabled(newToolName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 12)
                .padding(.leading, 16)
                .padding(.bottom, 10)
            }
        }
    }
}

private struct ToolRow: View {
    let tool: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red.opacity(0.7))
                .font(.callout)
            Text(tool)
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Enable") {
                onRemove()
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}
