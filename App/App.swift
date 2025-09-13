import EvolutionModule
import SwiftUI

// MARK: - App

@main
/// Entry point for the Swift Evolution sample application.
struct App: SwiftUI.App {
    var body: some Scene {
        AppScene()
    }
}

// MARK: - Preview

#Preview(traits: .evolution) {
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
