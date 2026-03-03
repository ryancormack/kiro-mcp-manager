import SwiftUI

struct MenuContentView: View {
    @Bindable var manager: MCPConfigManager
    @Bindable var settingsManager: SettingsManager
    
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !manager.hasBookmark {
                Text("Grant access to your MCP config file")
                    .font(.caption)
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
                .padding(.vertical, 8)
                
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
        .frame(width: 280)
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
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(12)
        } else if manager.servers.isEmpty {
            Text("No MCP servers configured")
                .font(.caption)
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
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .frame(width: 12)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name).fontWeight(.medium)
                    Text(server.serverType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { !server.isDisabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    if disabledTools.isEmpty {
                        Text("No tools disabled")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(disabledTools, id: \.self) { tool in
                            ToolRow(tool: tool, onRemove: { onToggleTool(tool) })
                        }
                    }

                    HStack(spacing: 4) {
                        TextField("Tool name to disable", text: $newToolName)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                        Button("Add") {
                            onAddTool(newToolName)
                            newToolName = ""
                        }
                        .disabled(newToolName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .font(.caption)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 12)
                .padding(.leading, 12)
                .padding(.bottom, 8)
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
                .font(.caption)
            Text(tool)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Enable") {
                onRemove()
            }
            .font(.caption)
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 2)
    }
}
