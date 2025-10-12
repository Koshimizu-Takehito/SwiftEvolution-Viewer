import EvolutionModule
import SwiftUI

// MARK: - App

/// Entry point for the Swift Evolution sample application.
@main
struct App: SwiftUI.App {

    init() {
        AppShortcutsProvider.updateAppShortcutParameters()
    }

    var body: some Scene {
        AppScene()
    }
}

// MARK: - Preview

#Preview(traits: .evolution) {
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
