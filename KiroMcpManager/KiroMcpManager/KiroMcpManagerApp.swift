import SwiftUI

@main
struct KiroMcpManagerApp: App {
    @State private var manager = MCPConfigManager()
    @State private var settingsManager = SettingsManager()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(manager: manager, settingsManager: settingsManager)
        } label: {
            Text("K")
        }
        .menuBarExtraStyle(.window)
    }
}
