import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

/// Convenience trait for previews that require proposal data.
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor public static var proposal: Self = .modifier(ProposalPreviewModifier())
}

/// Injects in-memory proposal data into SwiftUI previews.
struct ProposalPreviewModifier: PreviewModifier {
    public static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer(
            for: Proposal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        try context.transaction {
            context.insert(Proposal.fake0418)
            context.insert(Proposal.fake0465)
        }
        return container
    }

    public func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

private extension Proposal {
    static var fake0418: Self {
        self.init(
            snapshot: .init(
                id: "SE-0418",
                link: "0418-inferring-sendable-for-methods.md",
                status: Status.init(state: ".accepted"),
                title: "Inferring Sendable for methods and key path literals"
            )
        )
    }

    static var fake0465: Self {
        self.init(
            snapshot: .init(
                id: "SE-0465",
                link: "0465-nonescapable-stdlib-primitives.md",
                status: Status.init(state: ".implemented"),
                title: "Standard Library Primitives for Nonescapable Types"
            )
        )
    }
}

extension Binding<NavigationPath> {
    static var fake: Self {
        .constant(Value())
    }
}

extension Binding where Value: ExpressibleByNilLiteral {
    static var fake: Self {
        .constant(nil)
    }
}
