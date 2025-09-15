import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ListView

/// Displays a list of proposals and manages selection state.
@MainActor
struct ProposalListView {
    @Environment(\.horizontalSizeClass) private var horizontal
    @Binding var selection: Proposal.Snapshot?
    @Query private var proposals: [Proposal]
    var query: ProposalQuery

    init(_ selection: Binding<Proposal.Snapshot?>, query: ProposalQuery) {
        _selection = selection
        _proposals = Query(query)
        self.query = query
    }
}

extension ProposalListView: View {
    var body: some View {
        List(selection: $selection) {
            ForEach(proposals) { proposal in
                NavigationLink(value: Proposal.Snapshot(object: proposal)) {
                    ProposalListCell(proposal: proposal)
                }
                .contextMenu { BookmarkMenu(proposal: proposal) }
            }
        }
        .overlay {
            emptyView
        }
        .animation(.default, value: proposals)
        .tint(.darkText.opacity(0.2))
        .navigationTitle(navigationTitle)
        .onAppear(perform: selectFirstItem)
        .toolbar { toolbar }
    }

    /// Selects the first proposal when running on larger displays.
    func selectFirstItem() {
        #if os(macOS)
            if selection == nil, let proposal = proposals.first {
                selection = .init(object: proposal)
            }
        #elseif os(iOS)
            // Provide an initial selection when the split view is displayed side-by-side.
            if horizontal == .regular, selection == nil, let proposal = proposals.first {
                selection = .init(object: proposal)
            }
        #endif
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        switch query.mode {
        case .all:
            ToolbarItem {
                Menu("Sort", systemImage: "arrow.trianglehead.swap") {
                    Picker(selection: query.$sortKey) {
                        ForEach(ProposalSortKey.allCases) { sortKey in
                            Text(String(describing: sortKey))
                                .tag(sortKey)
                        }
                    } label: {
                        Text(String(describing: query.sortKey))
                    }
                }
            }
            ToolbarItem {
                ProposalStatusPicker()
                    .tint(.darkText)
            }
        case .bookmark, .search:
            ToolbarItem {}
        }
    }

    private var navigationTitle: LocalizedStringResource {
        switch query.mode {
        case .all:
            "Swift Evolution"
        case .bookmark:
            "Bookmark"
        case .search:
            "Search"
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        switch query.mode {
        case .bookmark where proposals.isEmpty:
            ContentUnavailableView(
                "No bookmarked proposals",
                systemImage: "bookmark",
                description: Text("Bookmark proposals you care about to see them here.")
            )
        default:
            EmptyView()
        }
    }
}

#Preview(traits: .evolution) {
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
