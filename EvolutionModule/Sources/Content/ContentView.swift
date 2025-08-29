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

    /// Current tint color of the navigation bar.
    @State private var tint: Color?

    /// Indicates whether the list is filtered to bookmarked proposals.
    @AppStorage("isBookmarked") private var isBookmarked = false

    /// Error produced when fetching proposals.
    @State private var fetchError: Error?

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

    private var detailTint: Binding<Color?> {
        switch horizontal {
        case .compact:
            return $tint
        default:
            return .constant(nil)
        }
    }

    private var barTint: Color? {
        switch horizontal {
        case .compact:
            return tint ?? .darkText
        default:
            return .darkText
        }
    }

    public init() {}
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        NavigationSplitView {
            // List view
            ProposalListView(
                selection: $proposal,
                status: filter,
                isBookmarked: !bookmarks.isEmpty && isBookmarked
            )
            .environment(\.horizontalSizeClass, horizontal)
            .overlay { ErrorView(error: fetchError, $refresh) }
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
        .tint(barTint)
        .task(id: refresh) {
            fetchError = nil
            do {
                try await ProposalRepository(modelContainer: context.container).fetch()
            } catch {
                if allProposals.isEmpty {
                    fetchError = error
                }
            }
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
        ToolbarSpacer()
        if !allProposals.isEmpty {
            ToolbarItem {
                ProposalStatusPicker()
                    .tint(.darkText)
            }
        }
    }
}

#Preview(traits: .proposal) {
    ContentView()
        .environment(\.colorScheme, .dark)
}

#Preview("Assistive access", traits: .proposal, .assistiveAccess) {
    ContentView()
        .environment(\.colorScheme, .dark)
}
