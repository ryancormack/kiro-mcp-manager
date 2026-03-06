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
    let isOptional: Bool

    init(key: String, label: String, placeholder: String, defaultValue: String, isOptional: Bool = false) {
        self.key = key
        self.label = label
        self.placeholder = placeholder
        self.defaultValue = defaultValue
        self.isOptional = isOptional
    }
}

let quickAddPresets: [QuickAddPreset] = [
    QuickAddPreset(
        name: "Bedrock AgentCore Gateway",
        description: "Connect to AWS Bedrock AgentCore Gateway via mcp-proxy-for-aws",
        requiredFields: [
            PresetField(key: "serverName", label: "Server Name", placeholder: "my-agent-gateway", defaultValue: ""),
            PresetField(key: "gatewayURL", label: "Gateway URL", placeholder: "https://your-agentcore-gateway-url", defaultValue: ""),
            PresetField(key: "awsProfile", label: "AWS Profile", placeholder: "default", defaultValue: "", isOptional: true),
            PresetField(key: "awsRegion", label: "AWS Region", placeholder: "eu-west-1", defaultValue: "", isOptional: true)
        ],
        buildServer: { inputs in
            var fields: [String: AnyCodableValue] = [
                "command": .string("uvx"),
                "args": .array([
                    .string("mcp-proxy-for-aws@latest"),
                    .string(inputs["gatewayURL"] ?? "")
                ]),
                "disabled": .bool(false),
                "type": .string("stdio")
            ]

            let awsProfile = (inputs["awsProfile"] ?? "").trimmingCharacters(in: .whitespaces)
            let awsRegion = (inputs["awsRegion"] ?? "").trimmingCharacters(in: .whitespaces)
            var env: [String: AnyCodableValue] = [:]
            if !awsProfile.isEmpty {
                env["AWS_PROFILE"] = .string(awsProfile)
            }
            if !awsRegion.isEmpty {
                env["AWS_REGION"] = .string(awsRegion)
            }
            if !env.isEmpty {
                fields["env"] = .object(env)
            }

            return McpServer(fields: fields)
        }
    )
]
