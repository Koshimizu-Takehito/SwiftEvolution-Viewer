import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// Main entry view that displays the list of proposals and their details.
@MainActor
public struct ContentView {
    /// Navigation path for presenting nested proposal details.
    @State private var detailPath = NavigationPath()

    @Environment(\.horizontalSizeClass) private var horizontal

    /// Model context used to load additional data.
    @Environment(\.modelContext) private var context

    /// ViewModel
    @Environment(ContentViewModel.self) private var viewModel

    private var mode: ProposalListMode

    /// Currently selected status filter.
    @StatusFilter private var filter

    /// Proposal currently selected in the list view.
    @State private var selection: Proposal.Snapshot?

    public init(mode: ProposalListMode = .all) {
        self.mode = mode
    }
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        ZStack(alignment: .bottom) {
            NavigationSplitView {
                // List view
                ProposalListView($selection, mode: mode, status: filter)
                    .environment(\.horizontalSizeClass, horizontal)
            } detail: {
                // Detail view
                if let selection {
                    NavigationStack(path: $detailPath) {
                        // Root
                        detail(proposal: selection)
                    }
                    .navigationDestination(for: Proposal.Snapshot.self) { proposal in
                        // Destination
                        detail(proposal: proposal)
                    }
                }
            }
            if let progress = viewModel.downloadProgress {
                DownloadProgressView(progress: progress)
                    .frame(maxWidth: 375)
            }
        }
        .tint(.darkText)
    }

    /// Builds the actual detail view for a proposal.
    func detail(proposal: Proposal.Snapshot) -> some View {
        ProposalDetailView(path: $detailPath, proposal: proposal, modelContainer: context.container)
    }
}

#Preview(traits: .evolution) {
    @Previewable @Environment(ContentViewModel.self) var viewModel
    ContentView()
        .environment(\.colorScheme, .dark)
        .task {
            await viewModel.fetchProposals()
        }
}
