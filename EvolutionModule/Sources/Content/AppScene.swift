import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - AppScene

/// Root scene for the application that wires up model containers and commands.
@MainActor
public struct AppScene<Content: View> {
    private var content: () -> Content

    /// Creates the scene with the provided root content view.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

// MARK: - Scene

extension AppScene: Scene {
    /// Body of the SwiftUI scene that hosts the app's content and commands.
    public var body: some Scene {
        WindowGroup {
            content()
                .modelContainer(
                    for: [Bookmark.self, Markdown.self, Proposal.self]
                )
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
    ContentView()
        .environment(\.colorScheme, .dark)
}
