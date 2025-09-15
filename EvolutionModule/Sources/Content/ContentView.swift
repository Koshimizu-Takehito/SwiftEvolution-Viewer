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

    /// Proposal currently selected in the list view.
    @State private var selection: Proposal.Snapshot?

    var query: ProposalQuery

    public init(mode: ProposalListMode = .all) {
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
                    ProposalListView($selection, query: query)
                        .navigationDestination(for: Proposal.Snapshot.self) { proposal in
                            // Destination
                            detail(proposal: proposal)
                        }
                        .onChange(of: selection) { _, selection in
                            if let selection {
                                navigationPath.append(selection)
                            }
                        }
                        .onAppear {
                            selection = nil
                        }
                }
            default:
                NavigationSplitView {
                    // List view
                    ProposalListView($selection, query: query)
                        .environment(\.horizontalSizeClass, horizontalSizeClass)
                } detail: {
                    // Detail view
                    if let selection {
                        NavigationStack(path: $navigationPath) {
                            detail(proposal: selection)
                        }
                        .navigationDestination(for: Proposal.Snapshot.self) { proposal in
                            // Destination
                            detail(proposal: proposal)
                        }
                        .id(selection.id)
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
        ProposalDetailView($navigationPath, proposal: proposal, modelContainer: context.container)
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
