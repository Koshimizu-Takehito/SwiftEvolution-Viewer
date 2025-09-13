import EvolutionUI
import SwiftUI

// MARK: - AppScene

/// Root scene for the application that wires up model containers and commands.
@MainActor
public struct AppScene {
    @State private var modelContainer = EnvironmentResolver.modelContainer()

    /// Creates the scene with the provided root content view.
    public init() { }
}

// MARK: - Scene

extension AppScene: Scene {
    /// Body of the SwiftUI scene that hosts the app's content and commands.
    public var body: some Scene {
        WindowGroup {
            ContentRootView()
                .modifier(EnvironmentResolver(modelContainer))
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

#Preview(traits: .evolution) {
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
