import AppKit
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class MCPConfigManager {
    private(set) var servers: [(name: String, server: McpServer)] = []
    private(set) var errorMessage: String?
    private(set) var hasBookmark: Bool = false

    private let bookmarkKey = "mcpConfigBookmark"

    init() {
        hasBookmark = UserDefaults.standard.data(forKey: bookmarkKey) != nil
    }

    // MARK: - File Access

    func requestFileAccess() {
        let panel = NSOpenPanel()
        panel.title = "Select your Kiro MCP config file"
        panel.message = "Grant access to ~/.kiro/settings/mcp.json"
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
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

    private func resolveBookmark() -> URL? {
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
                // Re-create bookmark
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

    // MARK: - Read / Write

    func loadConfig() {
        guard let url = resolveBookmark() else {
            servers = []
            if errorMessage == nil { errorMessage = "No file access granted" }
            return
        }

        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access file"
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(McpConfig.self, from: data)
            servers = config.mcpServers
                .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
                .map { (name: $0.key, server: $0.value) }
            errorMessage = nil
        } catch {
            servers = []
            errorMessage = "No MCP config found — configure servers in ~/.kiro/settings/mcp.json"
        }
    }

    func toggleServer(name: String) {
        guard let url = resolveBookmark() else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            var config = try JSONDecoder().decode(McpConfig.self, from: data)
            guard var server = config.mcpServers[name] else { return }
            server.setDisabled(!server.isDisabled)
            config.mcpServers[name] = server

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let newData = try encoder.encode(config)
            try newData.write(to: url)

            loadConfig()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }

    func openInEditor() {
        guard let url = resolveBookmark() else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        NSWorkspace.shared.open(url)
    }
}
