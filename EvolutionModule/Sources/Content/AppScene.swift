import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - AppScene

@MainActor
public struct AppScene<Content: View> {
    private var content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

// MARK: - Scene

extension AppScene: Scene {
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
