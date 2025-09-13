import SwiftData
import SwiftUI

/// Injects in-memory proposal data into SwiftUI previews.
struct EvolutionPreviewModifier: PreviewModifier {
    public static func makeSharedContext() throws -> ModelContainer {
        EnvironmentResolver.modelContainer(isStoredInMemoryOnly: true)
    }

    public func body(content: Content, context modelContainer: ModelContainer) -> some View {
        content
            .modifier(EnvironmentResolver(modelContainer))
    }
}
