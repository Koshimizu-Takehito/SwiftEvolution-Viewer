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

#Preview(traits: .proposal) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}
