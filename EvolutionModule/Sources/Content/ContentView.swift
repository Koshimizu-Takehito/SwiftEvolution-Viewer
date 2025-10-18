import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// Main entry view that displays the list of proposals and their details.
@MainActor
public struct ContentView {
    /// Navigation path for presenting nested proposal details.
    @State private var navigationPath = NavigationPath()

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Model context used to load additional data.
    @Environment(\.modelContext) private var context

    /// ViewModel
    @Environment(ContentViewModel.self) private var viewModel

    /// Currently selected status filter.
    @StatusFilter private var filter

    @SceneStorage private var sortKey: ProposalSortKey = .proposalID

    var query: ProposalQuery

    @AppStorage private var selectedId: String?

    public init(mode: ProposalListMode = .all) {
        self._selectedId = AppStorage("ContentView.\(mode).selectedId")
        query = ProposalQuery(mode: mode)
    }
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        ZStack(alignment: .bottom) {
            switch horizontalSizeClass {
            case .compact:
                NavigationStack(path: $navigationPath) {
                    ProposalListView(query: query)
                        .navigationDestination(for: String.self) { selectedId in
                            // Destination
                            detail(selectedId: selectedId)
                        }
                        .navigationDestination(for: Proposal.self) { proposal in
                            // Destination
                            detail(selectedId: proposal.proposalID)
                        }
                        .onChange(of: selectedId, initial: true) { _, newValue in
                            if let newValue {
                                navigationPath.append(newValue)
                                selectedId = nil
                            }
                        }
                }

            default:
                NavigationSplitView {
                    // List view
                    ProposalListView($selectedId, query: query)
                        .environment(\.horizontalSizeClass, horizontalSizeClass)
                } detail: {
                    // Detail view
                    if let selectedId {
                        NavigationStack(path: $navigationPath) {
                            detail(selectedId: selectedId)
                        }
                        .navigationDestination(for: Proposal.self) { proposal in
                            // Destination
                            detail(selectedId: selectedId)
                        }
                        .id(selectedId)
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
    @ViewBuilder
    func detail(selectedId: String) -> some View {
        let proposal = try? context
            .fetch(.id(selectedId))
            .first
        if let proposal {
            ProposalDetailView($navigationPath, proposal: proposal, modelContainer: context.container)
        }
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
