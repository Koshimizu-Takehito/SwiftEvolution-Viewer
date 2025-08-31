import EvolutionModel
import EvolutionUI
import SwiftUI

// MARK: -

/// Detail side of the split view that manages its own navigation stack.
struct ContentDetailView: View {
    /// Navigation path for presenting nested proposal details.
    @State private var detailPath = NavigationPath()

    /// The proposal to display.
    let proposal: Proposal.Snapshot

    /// Horizontal size class of the surrounding environment.
    let horizontal: UserInterfaceSizeClass?

    /// Accent color used for the navigation bar, updated for each pushed view.
    @Binding var accentColor: Color?

    /// Model context used to load additional data.
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack(path: $detailPath) {
            // Root
            detail(proposal: proposal)
        }
        .navigationDestination(for: Proposal.Snapshot.self) { proposal in
            // Destination
            detail(proposal: proposal)
        }
    }

    /// Builds the actual detail view for a proposal.
    func detail(proposal: Proposal.Snapshot) -> some View {
        ProposalDetailView(path: $detailPath, proposal: proposal, modelContainer: context.container)
            .onChange(of: accentColor(proposal), initial: true) { _, color in
                accentColor = color
            }
    }

    /// Determines the accent color based on the proposal's status.
    func accentColor(_ proposal: Proposal.Snapshot) -> Color {
        Proposal.Status.State(proposal: proposal)?.color ?? .darkText
    }
}

#Preview(traits: .evolution) {
    ContentDetailView(
        proposal: .init(
            id: "SE-0418",
            link: "0418-inferring-sendable-for-methods.md",
            status: .init(state: ".accepted"),
            title: "Inferring Sendable for methods and key path literals"
        ),
        horizontal: .compact,
        accentColor: .constant(.green)
    )
}
