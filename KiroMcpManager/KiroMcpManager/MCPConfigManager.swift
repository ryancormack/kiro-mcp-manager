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

    private enum ConfigLoadError: Error {
        case missingFile
        case decodingFailed(Error)
    }

    func loadConfig() {
        let outcome: Result<[(name: String, server: McpServer)], ConfigLoadError>? = withConfigURL { url in
            guard FileManager.default.fileExists(atPath: url.path) else {
                return .failure(.missingFile)
            }
            do {
                let data = try Data(contentsOf: url)
                let config = try JSONDecoder().decode(McpConfig.self, from: data)
                let sorted = config.mcpServers
                    .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
                    .map { (name: $0.key, server: $0.value) }
                return .success(sorted)
            } catch {
                return .failure(.decodingFailed(error))
            }
        }

        switch outcome {
        case .success(let list):
            servers = list
            errorMessage = nil
            discoverTools()
        case .failure(.missingFile):
            servers = []
            tools = [:]
            errorMessage = "No MCP config found — configure servers in ~/.kiro/settings/mcp.json"
        case .failure(.decodingFailed(let error)):
            servers = []
            tools = [:]
            errorMessage = "Could not parse \(configFileName): \(error.localizedDescription)"
        case .none:
            servers = []
            tools = [:]
            // withConfigURL has already set errorMessage describing the access failure.
        }
    }

    /// Reads the current config (tolerating a missing file), applies `transform`,
    /// writes the result back, and reloads. Any read/decode/write failure is
    /// surfaced via `errorMessage` instead of being silently discarded.
    private func mutateConfig(_ transform: (inout McpConfig) -> Void) {
        let outcome: Result<Void, Error>? = withConfigURL { url in
            do {
                var config: McpConfig
                if FileManager.default.fileExists(atPath: url.path) {
                    let data = try Data(contentsOf: url)
                    config = try JSONDecoder().decode(McpConfig.self, from: data)
                } else {
                    config = McpConfig(mcpServers: [:])
                }
                transform(&config)

                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                try encoder.encode(config).write(to: url)
                return .success(())
            } catch {
                return .failure(error)
            }
        }

        switch outcome {
        case .success:
            loadConfig()
        case .failure(let error):
            errorMessage = "Failed to update \(configFileName): \(error.localizedDescription)"
        case .none:
            break // withConfigURL has already set errorMessage describing the access failure.
        }
    }

    func toggleServer(name: String) {
        mutateConfig { config in
            guard var server = config.mcpServers[name] else { return }
            server.setDisabled(!server.isDisabled)
            config.mcpServers[name] = server
        }
    }

    func toggleTool(serverName: String, tool: String) {
        mutateConfig { config in
            guard var server = config.mcpServers[serverName] else { return }

            var disabled = server.disabledTools
            if let idx = disabled.firstIndex(of: tool) {
                disabled.remove(at: idx)
            } else {
                disabled.append(tool)
            }
            server.setDisabledTools(disabled)
            config.mcpServers[serverName] = server
        }
    }

    func addServer(name: String, server: McpServer) {
        mutateConfig { config in
            config.mcpServers[name] = server
        }
    }

    func deleteServer(name: String) {
        mutateConfig { config in
            config.mcpServers.removeValue(forKey: name)
        }
    }

    func serverExists(name: String) -> Bool {
        servers.contains { $0.name == name }
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

    func addDisabledTool(serverName: String, tool: String) {
        let trimmed = tool.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        mutateConfig { config in
            guard var server = config.mcpServers[serverName] else { return }

            var disabled = server.disabledTools
            guard !disabled.contains(trimmed) else { return }
            disabled.append(trimmed)
            server.setDisabledTools(disabled)
            config.mcpServers[serverName] = server
        }
    }
}
