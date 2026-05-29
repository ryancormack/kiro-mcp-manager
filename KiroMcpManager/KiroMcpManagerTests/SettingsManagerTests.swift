import Foundation
import Testing
@testable import KiroMcpManager

@Suite struct SettingsManagerTests {

    // MARK: - getBool

    @Test func getBoolReturnsValueWhenBool() {
        let manager = SettingsManager(values: ["flag": .bool(true)])
        #expect(manager.getBool(for: "flag") == true)
    }

    @Test func getBoolReturnsNilForNonBool() {
        let manager = SettingsManager(values: ["flag": .string("true")])
        #expect(manager.getBool(for: "flag") == nil)
    }

    @Test func getBoolReturnsNilWhenMissing() {
        let manager = SettingsManager(values: [:])
        #expect(manager.getBool(for: "absent") == nil)
    }

    // MARK: - getString

    @Test func getStringReturnsValueWhenString() {
        let manager = SettingsManager(values: ["model": .string("claude")])
        #expect(manager.getString(for: "model") == "claude")
    }

    @Test func getStringReturnsNilForNonString() {
        let manager = SettingsManager(values: ["model": .int(1)])
        #expect(manager.getString(for: "model") == nil)
    }

    // MARK: - getNumber (Int and Double both coerce to Double)

    @Test func getNumberReturnsDoubleFromInt() {
        let manager = SettingsManager(values: ["timeout": .int(30)])
        #expect(manager.getNumber(for: "timeout") == 30.0)
    }

    @Test func getNumberReturnsDoubleFromDouble() {
        let manager = SettingsManager(values: ["ratio": .double(3.5)])
        #expect(manager.getNumber(for: "ratio") == 3.5)
    }

    @Test func getNumberReturnsNilForNonNumber() {
        let manager = SettingsManager(values: ["ratio": .string("3.5")])
        #expect(manager.getNumber(for: "ratio") == nil)
    }

    // MARK: - getStringArray

    @Test func getStringArrayReturnsStrings() {
        let manager = SettingsManager(values: ["patterns": .array([.string("*.rs"), .string("*.py")])])
        #expect(manager.getStringArray(for: "patterns") == ["*.rs", "*.py"])
    }

    @Test func getStringArrayFiltersNonStringEntries() {
        let manager = SettingsManager(values: ["patterns": .array([.string("*.rs"), .int(42), .bool(true)])])
        #expect(manager.getStringArray(for: "patterns") == ["*.rs"])
    }

    @Test func getStringArrayReturnsEmptyWhenMissing() {
        let manager = SettingsManager(values: [:])
        #expect(manager.getStringArray(for: "patterns") == [])
    }

    @Test func getStringArrayReturnsEmptyForNonArray() {
        let manager = SettingsManager(values: ["patterns": .string("*.rs")])
        #expect(manager.getStringArray(for: "patterns") == [])
    }

    // MARK: - getValue

    @Test func getValueReturnsUnderlyingValue() {
        let manager = SettingsManager(values: ["x": .int(7)])
        #expect(manager.getValue(for: "x") == .int(7))
        #expect(manager.getValue(for: "missing") == nil)
    }

    // MARK: - getModelDefaults

    @Test func getModelDefaultsParsesEffortPerModel() {
        let manager = SettingsManager(values: [
            "chat.modelDefaults": .object([
                "claude-sonnet": .object(["effort": .string("high")]),
                "claude-haiku": .object(["effort": .string("low")])
            ])
        ])
        let defaults = manager.getModelDefaults(for: "chat.modelDefaults")
        #expect(defaults["claude-sonnet"] == "high")
        #expect(defaults["claude-haiku"] == "low")
        #expect(defaults.count == 2)
    }

    @Test func getModelDefaultsIgnoresMalformedEntries() {
        let manager = SettingsManager(values: [
            "chat.modelDefaults": .object([
                "good": .object(["effort": .string("high")]),
                "noEffortKey": .object(["other": .string("x")]),
                "notAnObject": .string("oops"),
                "effortNotString": .object(["effort": .int(5)])
            ])
        ])
        let defaults = manager.getModelDefaults(for: "chat.modelDefaults")
        #expect(defaults == ["good": "high"])
    }

    @Test func getModelDefaultsReturnsEmptyWhenMissingOrWrongType() {
        #expect(SettingsManager(values: [:]).getModelDefaults(for: "chat.modelDefaults").isEmpty)
        #expect(SettingsManager(values: ["chat.modelDefaults": .string("nope")]).getModelDefaults(for: "chat.modelDefaults").isEmpty)
    }
}
