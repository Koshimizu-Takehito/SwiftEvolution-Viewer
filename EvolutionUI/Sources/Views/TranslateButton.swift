import SwiftUI

/// Button that toggles translation of the proposal's markdown content.
/// Displays a progress indicator while translation is in progress.
public struct TranslateButton: View {
    private var isTranslating: Bool
    private var action: () async throws -> Void

    public init(isTranslating: Bool, action: @escaping () async throws -> Void) {
        self.isTranslating = isTranslating
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            if !isTranslating {
                Button("Translate", systemImage: "character.bubble") {
                    Task {
                        try await action()
                    }
                }
            } else {
                ZStack {
                    Button("Translate", systemImage: "character.bubble") {}
                        .hidden()
                    ProgressView()
                }
            }
        } else {
            EmptyView()
        }
    }
}
