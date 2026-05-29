import Foundation
import Testing
@testable import KiroMcpManager

/// These tests cover the pure config read-modify-write semantics that
/// `MCPConfigManager` performs on disk. The manager's file-access layer
/// (security-scoped bookmarks / `NSOpenPanel`) is not unit-testable, so we
/// validate the transformations against `McpConfig` directly — the same logic
/// the manager applies inside `mutateConfig`.
@Suite struct MCPConfigMutationTests {

    // MARK: - Decode tolerance (regression: empty/minimal config must not throw)

    @Test func decodesEmptyObjectAsEmptyConfig() throws {
        let config = try JSONDecoder().decode(McpConfig.self, from: Data("{}".utf8))
        #expect(config.mcpServers.isEmpty)
    }

    @Test func decodesMissingMcpServersKeyWithOtherContent() throws {
        // A file that contains unrelated keys but no mcpServers should still load.
        let json = #"{"someOtherKey": true}"#
        let config = try JSONDecoder().decode(McpConfig.self, from: Data(json.utf8))
        #expect(config.mcpServers.isEmpty)
    }

    @Test func encodesEmptyConfigWithMcpServersKey() throws {
        let data = try JSONEncoder().encode(McpConfig(mcpServers: [:]))
        let decoded = try JSONDecoder().decode(McpConfig.self, from: data)
        #expect(decoded.mcpServers.isEmpty)
        let text = String(decoding: data, as: UTF8.self)
        #expect(text.contains("mcpServers"))
    }

    // MARK: - toggleServer

    @Test func toggleServerFlipsDisabledFlag() throws {
        var config = McpConfig(mcpServers: ["a": McpServer(fields: ["command": .string("node")])])

        // Apply the same transform toggleServer uses.
        toggleServer(&config, name: "a")
        #expect(config.mcpServers["a"]?.isDisabled == true)

        toggleServer(&config, name: "a")
        #expect(config.mcpServers["a"]?.isDisabled == false)
    }

    @Test func toggleServerLeavesOtherServersUntouched() throws {
        var config = McpConfig(mcpServers: [
            "a": McpServer(fields: ["command": .string("node")]),
            "b": McpServer(fields: ["url": .string("https://example.com")])
        ])
        toggleServer(&config, name: "a")
        #expect(config.mcpServers["a"]?.isDisabled == true)
        #expect(config.mcpServers["b"]?.isDisabled == false)
    }

    // MARK: - toggleTool

    @Test func toggleToolAddsThenRemoves() throws {
        var config = McpConfig(mcpServers: ["a": McpServer(fields: ["command": .string("node")])])

        toggleTool(&config, serverName: "a", tool: "dangerous")
        #expect(config.mcpServers["a"]?.disabledTools == ["dangerous"])

        toggleTool(&config, serverName: "a", tool: "dangerous")
        #expect(config.mcpServers["a"]?.disabledTools == [])
    }

    // MARK: - addServer / deleteServer

    @Test func addServerInsertsIntoEmptyConfig() throws {
        var config = McpConfig(mcpServers: [:])
        config.mcpServers["new"] = McpServer(fields: ["command": .string("node")])
        #expect(config.mcpServers.count == 1)
        #expect(config.mcpServers["new"]?.isLocal == true)
    }

    @Test func deleteServerRemovesEntry() throws {
        var config = McpConfig(mcpServers: [
            "a": McpServer(fields: ["command": .string("node")]),
            "b": McpServer(fields: ["url": .string("https://example.com")])
        ])
        config.mcpServers.removeValue(forKey: "a")
        #expect(config.mcpServers["a"] == nil)
        #expect(config.mcpServers.count == 1)
    }

    // MARK: - addDisabledTool semantics (no duplicates)

    @Test func addDisabledToolIsIdempotent() throws {
        var config = McpConfig(mcpServers: ["a": McpServer(fields: ["command": .string("node")])])
        addDisabledTool(&config, serverName: "a", tool: "x")
        addDisabledTool(&config, serverName: "a", tool: "x")
        #expect(config.mcpServers["a"]?.disabledTools == ["x"])
    }

    // MARK: - Helpers mirroring MCPConfigManager.mutateConfig transforms

    private func toggleServer(_ config: inout McpConfig, name: String) {
        guard var server = config.mcpServers[name] else { return }
        server.setDisabled(!server.isDisabled)
        config.mcpServers[name] = server
    }

    private func toggleTool(_ config: inout McpConfig, serverName: String, tool: String) {
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

    private func addDisabledTool(_ config: inout McpConfig, serverName: String, tool: String) {
        let trimmed = tool.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard var server = config.mcpServers[serverName] else { return }
        var disabled = server.disabledTools
        guard !disabled.contains(trimmed) else { return }
        disabled.append(trimmed)
        server.setDisabledTools(disabled)
        config.mcpServers[serverName] = server
    }
}
