import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// Main entry view that displays the list of proposals and their details.
@MainActor
public struct ContentView {
    @Environment(\.horizontalSizeClass) private var horizontal

    @Environment(ContentViewModel.self) private var viewModel

    /// Current tint color of the navigation bar.
    @State private var tint: Color?

    private var mode: ProposalListMode

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
                ProposalListView($proposal, mode: mode, status: filter)
                    .environment(\.horizontalSizeClass, horizontal)
            } detail: {
                // Detail view
                if let proposal {
                    ContentDetailView(
                        proposal: proposal,
                        horizontal: horizontal,
                        accentColor: detailTint
                    )
                    .id(proposal.id)
                }
            }
            if let progress = viewModel.downloadProgress {
                DownloadProgressView(progress: progress)
                    .frame(maxWidth: 375)
            }
        }
        .tint(barTint)
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
