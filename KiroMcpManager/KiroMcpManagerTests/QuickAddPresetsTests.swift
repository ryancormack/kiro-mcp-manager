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

        let awsProfileField = preset.requiredFields.first { $0.key == "awsProfile" }
        let awsRegionField = preset.requiredFields.first { $0.key == "awsRegion" }
        #expect(awsProfileField?.isOptional == true)
        #expect(awsRegionField?.isOptional == true)

        let serverNameField = preset.requiredFields.first { $0.key == "serverName" }
        let gatewayURLField = preset.requiredFields.first { $0.key == "gatewayURL" }
        #expect(serverNameField?.isOptional == false)
        #expect(gatewayURLField?.isOptional == false)
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

    @Test func bedrockPresetOmitsEnvWhenNoAwsFieldsProvided() {
        let preset = quickAddPresets[0]
        let inputs: [String: String] = [
            "serverName": "test",
            "gatewayURL": "https://example.com"
        ]
        let server = preset.buildServer(inputs)

        #expect(server.fields["env"] == nil)
        #expect(server.fields["command"] == .string("uvx"))
        #expect(server.fields["type"] == .string("stdio"))
    }

    @Test func bedrockPresetIncludesOnlyProfileWhenRegionEmpty() {
        let preset = quickAddPresets[0]
        let inputs: [String: String] = [
            "serverName": "test",
            "gatewayURL": "https://example.com",
            "awsProfile": "staging",
            "awsRegion": ""
        ]
        let server = preset.buildServer(inputs)

        if case .object(let env) = server.fields["env"] {
            #expect(env["AWS_PROFILE"] == .string("staging"))
            #expect(env["AWS_REGION"] == nil)
        } else {
            #expect(Bool(false), "Expected env to be an object with only AWS_PROFILE")
        }
    }

    @Test func bedrockPresetIncludesOnlyRegionWhenProfileEmpty() {
        let preset = quickAddPresets[0]
        let inputs: [String: String] = [
            "serverName": "test",
            "gatewayURL": "https://example.com",
            "awsProfile": "",
            "awsRegion": "ap-southeast-1"
        ]
        let server = preset.buildServer(inputs)

        if case .object(let env) = server.fields["env"] {
            #expect(env["AWS_PROFILE"] == nil)
            #expect(env["AWS_REGION"] == .string("ap-southeast-1"))
        } else {
            #expect(Bool(false), "Expected env to be an object with only AWS_REGION")
        }
    }

    @Test func bedrockPresetName() {
        let preset = quickAddPresets[0]
        #expect(preset.name == "Bedrock AgentCore Gateway")
    }
}
