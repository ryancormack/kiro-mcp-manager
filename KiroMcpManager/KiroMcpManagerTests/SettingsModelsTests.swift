import Foundation
import Testing
@testable import KiroMcpManager

@Suite struct SettingsModelsTests {

    @Test func knownSettingsIsNotEmpty() {
        #expect(!knownSettings.isEmpty)
    }

    @Test func settingKeysAreUnique() {
        let keys = knownSettings.map { $0.key }
        let unique = Set(keys)
        #expect(keys.count == unique.count, "Duplicate setting keys: \(duplicates(in: keys))")
    }

    @Test func everySettingCategoryIsRegistered() {
        let registered = Set(settingCategories)
        for setting in knownSettings {
            #expect(registered.contains(setting.category),
                    "Setting \(setting.key) uses unregistered category '\(setting.category)'")
        }
    }

    @Test func settingCategoriesHasNoDuplicates() {
        #expect(settingCategories.count == Set(settingCategories).count)
    }

    @Test func everyRegisteredCategoryIsUsed() {
        let used = Set(knownSettings.map { $0.category })
        for category in settingCategories {
            #expect(used.contains(category), "Category '\(category)' has no settings")
        }
    }

    @Test func pickerSettingsHaveOptions() {
        for setting in knownSettings where setting.type == .picker {
            #expect(!setting.options.isEmpty, "Picker '\(setting.key)' has no options")
        }
    }

    @Test func stringArraySettingsHavePresets() {
        // The two knowledge pattern settings rely on presets in the UI.
        for setting in knownSettings where setting.type == .stringArray {
            #expect(!setting.presets.isEmpty, "String-array setting '\(setting.key)' has no presets")
        }
    }

    @Test func everySettingHasLabelAndHint() {
        for setting in knownSettings {
            #expect(!setting.label.isEmpty, "Setting '\(setting.key)' has empty label")
            #expect(!setting.hint.isEmpty, "Setting '\(setting.key)' has empty hint")
        }
    }

    private func duplicates(in keys: [String]) -> [String] {
        var seen = Set<String>()
        var dupes = Set<String>()
        for key in keys {
            if !seen.insert(key).inserted { dupes.insert(key) }
        }
        return Array(dupes).sorted()
    }
}
