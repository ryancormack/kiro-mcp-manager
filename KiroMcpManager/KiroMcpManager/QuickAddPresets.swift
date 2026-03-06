import Foundation

struct QuickAddPreset: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let description: String
    let requiredFields: [PresetField]
    let buildServer: @Sendable ([String: String]) -> McpServer
}

struct PresetField: Identifiable, Sendable {
    let id = UUID()
    let key: String
    let label: String
    let placeholder: String
    let defaultValue: String
}

let quickAddPresets: [QuickAddPreset] = [
    QuickAddPreset(
        name: "Bedrock AgentCore Gateway",
        description: "Connect to AWS Bedrock AgentCore Gateway via mcp-proxy-for-aws",
        requiredFields: [
            PresetField(key: "serverName", label: "Server Name", placeholder: "my-agent-gateway", defaultValue: ""),
            PresetField(key: "gatewayURL", label: "Gateway URL", placeholder: "https://your-agentcore-gateway-url", defaultValue: ""),
            PresetField(key: "awsProfile", label: "AWS Profile", placeholder: "default", defaultValue: "default"),
            PresetField(key: "awsRegion", label: "AWS Region", placeholder: "eu-west-1", defaultValue: "eu-west-1")
        ],
        buildServer: { inputs in
            McpServer(fields: [
                "command": .string("uvx"),
                "args": .array([
                    .string("mcp-proxy-for-aws@latest"),
                    .string(inputs["gatewayURL"] ?? "")
                ]),
                "disabled": .bool(false),
                "env": .object([
                    "AWS_PROFILE": .string(inputs["awsProfile"] ?? "default"),
                    "AWS_REGION": .string(inputs["awsRegion"] ?? "eu-west-1")
                ]),
                "type": .string("stdio")
            ])
        }
    )
]
