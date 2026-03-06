import Foundation
import Testing
@testable import KiroMcpManager

@Suite struct QuickAddPresetsTests {
    @Test func hasAtLeastOnePreset() {
        #expect(!quickAddPresets.isEmpty)
    }

    @Test func bedrockPresetRequiredFieldKeys() {
        let preset = quickAddPresets[0]
        let keys = preset.requiredFields.map { $0.key }
        #expect(keys.contains("serverName"))
        #expect(keys.contains("gatewayURL"))
        #expect(keys.contains("awsProfile"))
        #expect(keys.contains("awsRegion"))
    }

    @Test func bedrockPresetProducesCorrectServer() {
        let preset = quickAddPresets[0]
        let inputs: [String: String] = [
            "serverName": "test-gateway",
            "gatewayURL": "https://my-gateway.example.com",
            "awsProfile": "dev",
            "awsRegion": "us-east-1"
        ]
        let server = preset.buildServer(inputs)

        #expect(server.fields["command"] == .string("uvx"))
        #expect(server.fields["disabled"] == .bool(false))
        #expect(server.fields["type"] == .string("stdio"))

        if case .array(let args) = server.fields["args"] {
            #expect(args.count == 2)
            #expect(args[0] == .string("mcp-proxy-for-aws@latest"))
            #expect(args[1] == .string("https://my-gateway.example.com"))
        } else {
            #expect(Bool(false), "Expected args to be an array")
        }

        if case .object(let env) = server.fields["env"] {
            #expect(env["AWS_PROFILE"] == .string("dev"))
            #expect(env["AWS_REGION"] == .string("us-east-1"))
        } else {
            #expect(Bool(false), "Expected env to be an object")
        }
    }

    @Test func bedrockPresetUsesDefaultValues() {
        let preset = quickAddPresets[0]
        let inputs: [String: String] = [
            "serverName": "test",
            "gatewayURL": "https://example.com"
        ]
        let server = preset.buildServer(inputs)

        if case .object(let env) = server.fields["env"] {
            #expect(env["AWS_PROFILE"] == .string("default"))
            #expect(env["AWS_REGION"] == .string("eu-west-1"))
        } else {
            #expect(Bool(false), "Expected env to be an object")
        }
    }

    @Test func bedrockPresetName() {
        let preset = quickAddPresets[0]
        #expect(preset.name == "Bedrock AgentCore Gateway")
    }
}
