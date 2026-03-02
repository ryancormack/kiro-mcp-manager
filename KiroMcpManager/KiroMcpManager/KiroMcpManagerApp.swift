import SwiftUI

@main
struct KiroMcpManagerApp: App {
    @State private var manager = MCPConfigManager()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(manager: manager)
        } label: {
            Text("K")
        }
        .menuBarExtraStyle(.window)
    }
}
