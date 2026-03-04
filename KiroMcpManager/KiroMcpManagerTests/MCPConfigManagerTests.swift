import Testing
@testable import KiroMcpManager

@Suite struct MCPConfigManagerTests {
    @Test func expandEnvVarReturnsPlainText() {
        let manager = MCPConfigManager()
        #expect(manager.expandEnvVar("plain text") == "plain text")
    }

    @Test func expandEnvVarExpandsKnownVariable() {
        let manager = MCPConfigManager()
        // HOME is always set on macOS
        let result = manager.expandEnvVar("${HOME}/test")
        #expect(result.contains("/test"))
        #expect(!result.contains("${HOME}"))
    }

    @Test func expandEnvVarReplacesUnknownWithEmpty() {
        let manager = MCPConfigManager()
        let result = manager.expandEnvVar("prefix-${UNLIKELY_VAR_12345}-suffix")
        #expect(result == "prefix--suffix")
    }

    @Test func expandEnvVarHandlesMultipleVariables() {
        let manager = MCPConfigManager()
        let result = manager.expandEnvVar("${HOME}:${PATH}")
        #expect(!result.contains("${HOME}"))
        #expect(!result.contains("${PATH}"))
    }
}
