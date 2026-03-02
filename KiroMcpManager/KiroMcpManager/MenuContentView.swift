import SwiftUI

struct MenuContentView: View {
    @Bindable var manager: MCPConfigManager

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
            } else if let error = manager.errorMessage {
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
                    ServerRow(name: entry.name, server: entry.server) {
                        manager.toggleServer(name: entry.name)
                    }
                }
            }

            Divider().padding(.vertical, 4)

            HStack {
                Button("Edit Config…") {
                    manager.openInEditor()
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
            if manager.hasBookmark { manager.loadConfig() }
        }
    }
}

private struct ServerRow: View {
    let name: String
    let server: McpServer
    let onToggle: () -> Void

    var body: some View {
        HStack {
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
    }
}
