import EvolutionModel
import SwiftData
import SwiftUI

struct EnvironmentResolver: ViewModifier {
    static func modelContainer(isStoredInMemoryOnly: Bool = false) -> ModelContainer {
        try! ModelContainer(
            for: Proposal.self, Markdown.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        )
    }

    var modelContainer: ModelContainer

    init(_ modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func body(content: Content) -> some View {
        content
            .modelContainer(modelContainer)
            .environment(ContentViewModel(modelContainer: modelContainer))
    }
}
