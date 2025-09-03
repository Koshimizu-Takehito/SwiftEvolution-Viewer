import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// Main entry view that displays the list of proposals and their details.
@MainActor
public struct ContentView {
    @Environment(\.horizontalSizeClass) private var horizontal

    @State private var viewModel: ContentViewModel

    /// Current tint color of the navigation bar.
    @State private var tint: Color?

    /// Indicates whether the list is filtered to bookmarked proposals.
    @AppStorage("showsBookmark") private var showsBookmark = false

    /// Trigger used to re-fetch proposal data.
    @State private var refresh: UUID?

    /// Currently selected status filter.
    @StatusFilter private var filter

    /// Proposal currently selected in the list view.
    @State private var proposal: Proposal.Snapshot?

    /// Tint color applied to the detail view's navigation elements on compact
    /// devices. On larger screens a constant value is used instead.
    private var detailTint: Binding<Color?> {
        switch horizontal {
        case .compact:
            return $tint
        default:
            return .constant(nil)
        }
    }

    /// Tint applied to the navigation bar. Falls back to the system dark text
    /// color when no custom tint is active.
    private var barTint: Color? {
        switch horizontal {
        case .compact:
            return tint ?? .darkText
        default:
            return .darkText
        }
    }

    /// Creates the view, injecting the shared model container used by child
    /// views and the view model.
    public init(modelContainer: ModelContainer) {
        viewModel = ContentViewModel(modelContainer: modelContainer)
    }
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        ZStack(alignment: .bottom) {
            NavigationSplitView {
                // List view
                ProposalListView($proposal, isBookmarked: $showsBookmark, status: filter)
                    .environment(\.horizontalSizeClass, horizontal)
                    .overlay {
                        ErrorView(error: viewModel.fetchError, $refresh)
                    }
            } detail: {
                // Detail view
                if let proposal {
                    ContentDetailView(
                        proposal: proposal,
                        horizontal: horizontal,
                        accentColor: detailTint
                    )
                    .id(proposal)
                }
            }
            if let progress = viewModel.downloadProgress {
                DownloadProgressView(progress: progress)
                    .frame(maxWidth: 375)
            }
        }
        .tint(barTint)
        .task(id: refresh) {
            await viewModel.fetchProposals()
        }
    }
}

#Preview(traits: .evolution) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}
