import AppKit
import Foundation

@Observable
final class SettingsManager {
    private(set) var values: [String: AnyCodableValue] = [:]
    private(set) var errorMessage: String?
    
    private let settingsFileName = "cli.json"
    private let bookmarkKey = "mcpDirBookmark" // Reuse same bookmark as MCP config
    
    var hasBookmark: Bool {
        UserDefaults.standard.data(forKey: bookmarkKey) != nil
    }

    init() {}

    /// Creates a manager seeded with in-memory values. Used by tests to exercise
    /// the pure accessors without requiring file-system access.
    init(values: [String: AnyCodableValue]) {
        self.values = values
    }

    private func resolveDirectory() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                let newData = try url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(newData, forKey: bookmarkKey)
            }
            return url
        } catch {
            errorMessage = "Bookmark error: \(error.localizedDescription)"
            return nil
        }
    }
    
    private func withSettingsURL<T>(_ body: (URL) throws -> T) -> T? {
        guard let dir = resolveDirectory() else { return nil }
        guard dir.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access folder"
            return nil
        }
        defer { dir.stopAccessingSecurityScopedResource() }
        // cli.json is in ~/.kiro/settings/ (same folder as mcp.json)
        let settingsURL = dir.appendingPathComponent(settingsFileName)
        return try? body(settingsURL)
    }
    
    func loadSettings() {
        let outcome: Result<[String: AnyCodableValue], Error>? = withSettingsURL { url in
            do {
                guard FileManager.default.fileExists(atPath: url.path) else { return .success([:]) }
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([String: AnyCodableValue].self, from: data)
                return .success(decoded)
            } catch {
                return .failure(error)
            }
        }

        switch outcome {
        case .success(let decoded):
            values = decoded
            errorMessage = nil
        case .failure(let error):
            values = [:]
            errorMessage = "Could not parse \(settingsFileName): \(error.localizedDescription)"
        case .none:
            values = [:]
            // No bookmark / access failure. Preserve any errorMessage set by resolveDirectory.
        }
    }
    
    func getValue(for key: String) -> AnyCodableValue? {
        values[key]
    }
    
    func getBool(for key: String) -> Bool? {
        if case .bool(let v) = values[key] { return v }
        return nil
    }
    
    func getString(for key: String) -> String? {
        if case .string(let v) = values[key] { return v }
        return nil
    }
    
    func getNumber(for key: String) -> Double? {
        switch values[key] {
        case .int(let v): return Double(v)
        case .double(let v): return v
        default: return nil
        }
    }
    
    func getStringArray(for key: String) -> [String] {
        guard case .array(let items) = values[key] else { return [] }
        return items.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
    }
    
    func setValue(_ value: AnyCodableValue, for key: String) {
        let outcome: Result<Void, Error>? = withSettingsURL { url in
            do {
                var current: [String: AnyCodableValue] = [:]
                if FileManager.default.fileExists(atPath: url.path) {
                    let data = try Data(contentsOf: url)
                    current = try JSONDecoder().decode([String: AnyCodableValue].self, from: data)
                }
                current[key] = value

                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                try encoder.encode(current).write(to: url)
                return .success(())
            } catch {
                return .failure(error)
            }
        }

        switch outcome {
        case .success:
            loadSettings()
        case .failure(let error):
            errorMessage = "Failed to update \(settingsFileName): \(error.localizedDescription)"
        case .none:
            break // withSettingsURL has already set errorMessage describing the access failure.
        }
    }
    
    func setBool(_ value: Bool, for key: String) {
        setValue(.bool(value), for: key)
    }
    
    func setString(_ value: String, for key: String) {
        setValue(.string(value), for: key)
    }
    
    func setNumber(_ value: Int, for key: String) {
        setValue(.int(value), for: key)
    }
    
    func setStringArray(_ value: [String], for key: String) {
        setValue(.array(value.map { .string($0) }), for: key)
    }
    
    func deleteValue(for key: String) {
        let outcome: Result<Void, Error>? = withSettingsURL { url in
            do {
                guard FileManager.default.fileExists(atPath: url.path) else { return .success(()) }
                let data = try Data(contentsOf: url)
                var current = try JSONDecoder().decode([String: AnyCodableValue].self, from: data)
                current.removeValue(forKey: key)

                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                try encoder.encode(current).write(to: url)
                return .success(())
            } catch {
                return .failure(error)
            }
        }

        switch outcome {
        case .success:
            loadSettings()
        case .failure(let error):
            errorMessage = "Failed to update \(settingsFileName): \(error.localizedDescription)"
        case .none:
            break // withSettingsURL has already set errorMessage describing the access failure.
        }
    }
    
    // MARK: - Model Defaults
    
    func getModelDefaults(for key: String) -> [String: String] {
        guard case .object(let obj) = values[key] else { return [:] }
        var result: [String: String] = [:]
        for (model, value) in obj {
            if case .object(let inner) = value,
               case .string(let effort) = inner["effort"] {
                result[model] = effort
            }
        }
        return result
    }
    
    func setModelDefaults(_ defaults: [String: String], for key: String) {
        var obj: [String: AnyCodableValue] = [:]
        for (model, effort) in defaults {
            obj[model] = .object(["effort": .string(effort)])
        }
        if obj.isEmpty {
            deleteValue(for: key)
        } else {
            setValue(.object(obj), for: key)
        }
    }
    
    func openInEditor() {
        withSettingsURL { url in
            NSWorkspace.shared.open(url)
        }
    }
}
