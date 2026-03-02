import AppKit
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class MCPConfigManager {
    private(set) var servers: [(name: String, server: McpServer)] = []
    private(set) var tools: [String: [String]] = [:]
    private(set) var errorMessage: String?
    private(set) var hasBookmark: Bool = false

    private let bookmarkKey = "mcpDirBookmark"
    private let configFileName = "mcp.json"

    init() {
        hasBookmark = UserDefaults.standard.data(forKey: bookmarkKey) != nil
    }

    // MARK: - File Access

    func requestFileAccess() {
        let panel = NSOpenPanel()
        panel.title = "Select your Kiro MCP settings folder"
        panel.message = "Select the folder containing mcp.json (usually ~/.kiro/settings)"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".kiro/settings")

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let bookmark = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
            hasBookmark = true
            loadConfig()
        } catch {
            errorMessage = "Failed to create bookmark: \(error.localizedDescription)"
        }
    }

    private func resolveDirectory() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                let newData = try url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(newData, forKey: bookmarkKey)
            }
            return url
        } catch {
            errorMessage = "Bookmark error: \(error.localizedDescription)"
            hasBookmark = false
            return nil
        }
    }

    private func withConfigURL<T>(_ body: (URL) throws -> T) -> T? {
        guard let dir = resolveDirectory() else {
            if errorMessage == nil { errorMessage = "No file access granted" }
            return nil
        }
        guard dir.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access folder"
            return nil
        }
        defer { dir.stopAccessingSecurityScopedResource() }
        let fileURL = dir.appendingPathComponent(configFileName)
        return try? body(fileURL)
    }

    // MARK: - Read / Write

    func loadConfig() {
        let result = withConfigURL { url -> Result<[(name: String, server: McpServer)], Error> in
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(McpConfig.self, from: data)
            let sorted = config.mcpServers
                .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
                .map { (name: $0.key, server: $0.value) }
            return .success(sorted)
        }

        switch result {
        case .success(let list):
            servers = list
            errorMessage = nil
            discoverTools()
        default:
            servers = []
            tools = [:]
            if errorMessage == nil {
                errorMessage = "No MCP config found — configure servers in ~/.kiro/settings/mcp.json"
            }
        }
    }

    func toggleServer(name: String) {
        withConfigURL { url in
            let data = try Data(contentsOf: url)
            var config = try JSONDecoder().decode(McpConfig.self, from: data)
            guard var server = config.mcpServers[name] else { return }
            server.setDisabled(!server.isDisabled)
            config.mcpServers[name] = server

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(config).write(to: url)
        }
        loadConfig()
    }

    func toggleTool(serverName: String, tool: String) {
        withConfigURL { url in
            let data = try Data(contentsOf: url)
            var config = try JSONDecoder().decode(McpConfig.self, from: data)
            guard var server = config.mcpServers[serverName] else { return }

            var disabled = server.disabledTools
            if let idx = disabled.firstIndex(of: tool) {
                disabled.remove(at: idx)
            } else {
                disabled.append(tool)
            }
            server.setDisabledTools(disabled)
            config.mcpServers[serverName] = server

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(config).write(to: url)
        }
        loadConfig()
    }

    func openInEditor() {
        withConfigURL { url in
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Tool Discovery

    private func discoverTools() {
        tools = [:]
        // Only show tools that are already disabled in config
        // (since we can't query MCP servers from sandbox)
        for (name, server) in servers {
            let disabled = server.disabledTools
            if !disabled.isEmpty {
                tools[name] = disabled.sorted()
            }
        }
    }

    private func extractEnv(from server: McpServer) -> [String: String] {
        guard case .object(let obj) = server.fields["env"] else { return [:] }
        var result: [String: String] = [:]
        for (k, v) in obj {
            if case .string(let s) = v {
                result[k] = expandEnvVar(s)
            }
        }
        return result
    }

    private func expandEnvVar(_ value: String) -> String {
        let pattern = #"\$\{([^}]+)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return value }
        var result = value
        let matches = regex.matches(in: value, range: NSRange(value.startIndex..., in: value))
        for match in matches.reversed() {
            guard let varRange = Range(match.range(at: 1), in: value),
                  let fullRange = Range(match.range, in: value) else { continue }
            let varName = String(value[varRange])
            let envValue = ProcessInfo.processInfo.environment[varName] ?? ""
            result.replaceSubrange(fullRange, with: envValue)
        }
        return result
    }

    func addDisabledTool(serverName: String, tool: String) {
        let trimmed = tool.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        withConfigURL { url in
            let data = try Data(contentsOf: url)
            var config = try JSONDecoder().decode(McpConfig.self, from: data)
            guard var server = config.mcpServers[serverName] else { return }

            var disabled = server.disabledTools
            if !disabled.contains(trimmed) {
                disabled.append(trimmed)
                server.setDisabledTools(disabled)
                config.mcpServers[serverName] = server

                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                try encoder.encode(config).write(to: url)
            }
        }
        loadConfig()
    }
}
