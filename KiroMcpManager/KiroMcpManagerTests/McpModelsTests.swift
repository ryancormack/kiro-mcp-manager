import Foundation
import Testing
@testable import KiroMcpManager

@Suite struct AnyCodableValueTests {
    @Test func decodesString() throws {
        let json = #""hello""#
        let value = try JSONDecoder().decode(AnyCodableValue.self, from: Data(json.utf8))
        #expect(value == .string("hello"))
    }

    @Test func decodesInt() throws {
        let json = "42"
        let value = try JSONDecoder().decode(AnyCodableValue.self, from: Data(json.utf8))
        #expect(value == .int(42))
    }

    @Test func decodesBool() throws {
        let json = "true"
        let value = try JSONDecoder().decode(AnyCodableValue.self, from: Data(json.utf8))
        #expect(value == .bool(true))
    }

    @Test func decodesNull() throws {
        let json = "null"
        let value = try JSONDecoder().decode(AnyCodableValue.self, from: Data(json.utf8))
        #expect(value == .null)
    }

    @Test func decodesArray() throws {
        let json = #"[1, "two", true]"#
        let value = try JSONDecoder().decode(AnyCodableValue.self, from: Data(json.utf8))
        #expect(value == .array([.int(1), .string("two"), .bool(true)]))
    }

    @Test func decodesObject() throws {
        let json = #"{"key": "value"}"#
        let value = try JSONDecoder().decode(AnyCodableValue.self, from: Data(json.utf8))
        #expect(value == .object(["key": .string("value")]))
    }

    @Test func roundTripsAllTypes() throws {
        let original: AnyCodableValue = .object([
            "string": .string("test"),
            "int": .int(123),
            "double": .double(3.14),
            "bool": .bool(false),
            "null": .null,
            "array": .array([.int(1), .int(2)])
        ])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AnyCodableValue.self, from: data)
        #expect(decoded == original)
    }
}

@Suite struct McpServerTests {
    @Test func isDisabledReturnsFalseByDefault() throws {
        let json = #"{"command": "node"}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.isDisabled == false)
    }

    @Test func isDisabledReturnsTrueWhenSet() throws {
        let json = #"{"command": "node", "disabled": true}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.isDisabled == true)
    }

    @Test func isLocalWhenHasCommand() throws {
        let json = #"{"command": "node", "args": ["server.js"]}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.isLocal == true)
        #expect(server.isRemote == false)
        #expect(server.serverType == "Local")
    }

    @Test func isRemoteWhenHasUrl() throws {
        let json = #"{"url": "https://example.com/mcp"}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.isLocal == false)
        #expect(server.isRemote == true)
        #expect(server.serverType == "Remote")
    }

    @Test func disabledToolsReturnsEmptyByDefault() throws {
        let json = #"{"command": "node"}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.disabledTools == [])
    }

    @Test func disabledToolsReturnsArray() throws {
        let json = #"{"command": "node", "disabledTools": ["tool1", "tool2"]}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.disabledTools == ["tool1", "tool2"])
    }

    @Test func isToolDisabledChecksArray() throws {
        let json = #"{"command": "node", "disabledTools": ["blocked"]}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        #expect(server.isToolDisabled("blocked") == true)
        #expect(server.isToolDisabled("allowed") == false)
    }

    @Test func setDisabledUpdatesField() throws {
        let json = #"{"command": "node"}"#
        var server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        server.setDisabled(true)
        #expect(server.isDisabled == true)
        server.setDisabled(false)
        #expect(server.isDisabled == false)
    }

    @Test func setDisabledToolsUpdatesField() throws {
        let json = #"{"command": "node"}"#
        var server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        server.setDisabledTools(["a", "b"])
        #expect(server.disabledTools == ["a", "b"])
    }

    @Test func setDisabledToolsRemovesFieldWhenEmpty() throws {
        let json = #"{"command": "node", "disabledTools": ["tool"]}"#
        var server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        server.setDisabledTools([])
        #expect(server.fields["disabledTools"] == nil)
    }

    @Test func initWithFieldsStdio() {
        let server = McpServer(fields: [
            "command": .string("node"),
            "args": .array([.string("server.js")]),
            "disabled": .bool(false)
        ])
        #expect(server.isLocal == true)
        #expect(server.isRemote == false)
        #expect(server.isDisabled == false)
        #expect(server.serverType == "Local")
    }

    @Test func initWithFieldsHTTP() {
        let server = McpServer(fields: [
            "url": .string("https://example.com/mcp"),
            "disabled": .bool(false)
        ])
        #expect(server.isLocal == false)
        #expect(server.isRemote == true)
        #expect(server.serverType == "Remote")
    }

    @Test func roundTripsProgrammaticServer() throws {
        let server = McpServer(fields: [
            "command": .string("uvx"),
            "args": .array([.string("mcp-proxy@latest")]),
            "env": .object(["KEY": .string("value")]),
            "disabled": .bool(false),
            "type": .string("stdio")
        ])
        let encoded = try JSONEncoder().encode(server)
        let decoded = try JSONDecoder().decode(McpServer.self, from: encoded)
        #expect(decoded.fields["command"] == .string("uvx"))
        #expect(decoded.fields["type"] == .string("stdio"))
        #expect(decoded.fields["disabled"] == .bool(false))
        #expect(decoded.isLocal == true)
        if case .array(let args) = decoded.fields["args"] {
            #expect(args.count == 1)
            #expect(args[0] == .string("mcp-proxy@latest"))
        } else {
            #expect(Bool(false), "Expected args to be an array")
        }
        if case .object(let env) = decoded.fields["env"] {
            #expect(env["KEY"] == .string("value"))
        } else {
            #expect(Bool(false), "Expected env to be an object")
        }
    }

    @Test func preservesUnknownFields() throws {
        let json = #"{"command": "node", "customField": "preserved", "nested": {"a": 1}}"#
        let server = try JSONDecoder().decode(McpServer.self, from: Data(json.utf8))
        let encoded = try JSONEncoder().encode(server)
        let decoded = try JSONDecoder().decode(McpServer.self, from: encoded)
        #expect(decoded.fields["customField"] == .string("preserved"))
        #expect(decoded.fields["nested"] == .object(["a": .int(1)]))
    }
}

@Suite struct McpConfigTests {
    @Test func parsesMultipleServers() throws {
        let json = #"""
        {
            "mcpServers": {
                "local-server": {"command": "node", "args": ["index.js"]},
                "remote-server": {"url": "https://api.example.com"}
            }
        }
        """#
        let config = try JSONDecoder().decode(McpConfig.self, from: Data(json.utf8))
        #expect(config.mcpServers.count == 2)
        #expect(config.mcpServers["local-server"]?.isLocal == true)
        #expect(config.mcpServers["remote-server"]?.isRemote == true)
    }

    @Test func roundTripsConfig() throws {
        let json = #"""
        {
            "mcpServers": {
                "test": {"command": "echo", "disabled": true, "disabledTools": ["x"]}
            }
        }
        """#
        let original = try JSONDecoder().decode(McpConfig.self, from: Data(json.utf8))
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(McpConfig.self, from: encoded)
        #expect(decoded.mcpServers["test"]?.isDisabled == true)
        #expect(decoded.mcpServers["test"]?.disabledTools == ["x"])
    }

    @Test func initWithMcpServersDict() throws {
        let server = McpServer(fields: ["command": .string("node")])
        let config = McpConfig(mcpServers: ["test-server": server])
        #expect(config.mcpServers.count == 1)
        #expect(config.mcpServers["test-server"]?.isLocal == true)
    }
}
