import Foundation

// MARK: - AnyCodableValue

/// A type-erased Codable value that preserves any JSON structure during round-trip encoding.
enum AnyCodableValue: Codable, Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyCodableValue])
    case object([String: AnyCodableValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? container.decode(Int.self) {
            self = .int(v)
        } else if let v = try? container.decode(Double.self) {
            self = .double(v)
        } else if let v = try? container.decode(String.self) {
            self = .string(v)
        } else if let v = try? container.decode([AnyCodableValue].self) {
            self = .array(v)
        } else if let v = try? container.decode([String: AnyCodableValue].self) {
            self = .object(v)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        case .array(let v): try container.encode(v)
        case .object(let v): try container.encode(v)
        case .null: try container.encodeNil()
        }
    }
}

// MARK: - McpServer

/// Represents a single MCP server entry, preserving all fields for round-trip fidelity.
struct McpServer: Codable, Sendable {
    var fields: [String: AnyCodableValue]

    init(from decoder: Decoder) throws {
        fields = try [String: AnyCodableValue](from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try fields.encode(to: encoder)
    }

    var isDisabled: Bool {
        if case .bool(let v) = fields["disabled"] { return v }
        return false
    }

    mutating func setDisabled(_ value: Bool) {
        fields["disabled"] = .bool(value)
    }

    var isLocal: Bool { fields["command"] != nil }
    var isRemote: Bool { fields["url"] != nil }

    var serverType: String { isRemote ? "Remote" : "Local" }

    var disabledTools: [String] {
        guard case .array(let arr) = fields["disabledTools"] else { return [] }
        return arr.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
    }

    mutating func setDisabledTools(_ tools: [String]) {
        if tools.isEmpty {
            fields.removeValue(forKey: "disabledTools")
        } else {
            fields["disabledTools"] = .array(tools.map { .string($0) })
        }
    }

    func isToolDisabled(_ tool: String) -> Bool {
        disabledTools.contains(tool)
    }
}

// MARK: - McpConfig

/// Top-level config: `{ "mcpServers": { ... } }`
struct McpConfig: Codable, Sendable {
    var mcpServers: [String: McpServer]
}
