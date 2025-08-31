import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// Main entry view that displays the list of proposals and their details.
@MainActor
public struct ContentView {
    @Environment(\.horizontalSizeClass) private var horizontal

    /// Model context used to access persistent data.
    @Environment(\.modelContext) private var context

    @State private var viewModel: ContentViewModel

    /// Current tint color of the navigation bar.
    @State private var tint: Color?

    /// Indicates whether the list is filtered to bookmarked proposals.
    @AppStorage("isBookmarked") private var isBookmarked = false

    /// Trigger used to re-fetch proposal data.
    @State private var refresh: UUID?

    /// All loaded proposals from storage.
    @Query private var allProposals: [Proposal]

    /// Currently selected status filter.
    @StatusFilter private var filter

    /// Cached proposals that have been bookmarked.
    @State private var bookmarks: [Proposal] = []

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
        _viewModel = State(wrappedValue: ContentViewModel(modelContainer: modelContainer))
    }
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        ZStack(alignment: .bottom) {
            NavigationSplitView {
                // List view
                ProposalListView(
                    selection: $proposal,
                    status: filter,
                    isBookmarked: !bookmarks.isEmpty && isBookmarked
                )
                .environment(\.horizontalSizeClass, horizontal)
                .overlay { ErrorView(error: viewModel.fetchError, $refresh) }
                .toolbar { toolbar }
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
        .animation(.default, value: bookmarks)
        .onChange(of: allProposals.filter { $0.bookmark != nil }, initial: true) {
            bookmarks = $1
        }
    }

    /// Toolbar content for the proposal list view.
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if !bookmarks.isEmpty {
            ToolbarItem {
                BookmarkButton(isBookmarked: $isBookmarked)
                    .disabled(bookmarks.isEmpty)
                    .opacity(bookmarks.isEmpty ? 0 : 1)
                    .onChange(of: bookmarks.isEmpty) { _, isEmpty in
                        if isEmpty {
                            isBookmarked = false
                        }
                    }
                    .tint(.darkText)
            }
        }
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            ToolbarSpacer()
        }
        if !allProposals.isEmpty {
            ToolbarItem {
                ProposalStatusPicker()
                    .tint(.darkText)
            }
        }
    }
}

#Preview(traits: .proposal) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview("Assistive access", traits: .proposal, .assistiveAccess) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}
