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
        let result: [String: AnyCodableValue]? = withSettingsURL { url -> [String: AnyCodableValue] in
            guard FileManager.default.fileExists(atPath: url.path) else { return [:] }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String: AnyCodableValue].self, from: data)
        }
        values = result ?? [:]
        errorMessage = nil
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
    
    func setValue(_ value: AnyCodableValue, for key: String) {
        withSettingsURL { url in
            var current: [String: AnyCodableValue] = [:]
            if FileManager.default.fileExists(atPath: url.path),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([String: AnyCodableValue].self, from: data) {
                current = decoded
            }
            current[key] = value
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(current).write(to: url)
        }
        loadSettings()
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
    
    func deleteValue(for key: String) {
        withSettingsURL { url in
            guard FileManager.default.fileExists(atPath: url.path),
                  let data = try? Data(contentsOf: url),
                  var current = try? JSONDecoder().decode([String: AnyCodableValue].self, from: data) else { return }
            current.removeValue(forKey: key)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(current).write(to: url)
        }
        loadSettings()
    }
    
    func openInEditor() {
        withSettingsURL { url in
            NSWorkspace.shared.open(url)
        }
    }
}
