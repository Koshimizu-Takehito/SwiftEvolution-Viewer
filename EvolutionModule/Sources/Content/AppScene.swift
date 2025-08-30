import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - AppScene

/// Root scene for the application that wires up model containers and commands.
@MainActor
public struct AppScene {
    @State private var modelContainer = try! ModelContainer(
        for: Bookmark.self, Markdown.self, Proposal.self
    )

    /// Creates the scene with the provided root content view.
    public init() { }
}

// MARK: - Scene

extension AppScene: Scene {
    /// Body of the SwiftUI scene that hosts the app's content and commands.
    public var body: some Scene {
        WindowGroup {
            ContentView(modelContainer: modelContainer)
                .modelContainer(modelContainer)
        }
        .commands {
            FilterCommands()
        }
        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}

// MARK: - Preview

#Preview(traits: .proposal) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}
