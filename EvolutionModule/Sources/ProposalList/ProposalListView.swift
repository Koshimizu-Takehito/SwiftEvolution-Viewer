import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ListView

/// Displays a list of proposals and manages selection state.
@MainActor
struct ProposalListView {
    @Environment(\.horizontalSizeClass)
    private var horizontal

    @Binding
    var selection: Proposal.Snapshot?
    private let status: [ReviewState: Bool]
    private let mode: ProposalListMode

    @Query(
        filter: .predicate(mode, status),
        sort: [SortDescriptor(\.proposalID, order: .reverse)]
    )
    private var proposals: [Proposal]
}

extension ProposalListView {
    @TaskLocal private static var mode: ProposalListMode = .all
    @TaskLocal private static var status: [ReviewState: Bool] = [:]

    init(_ selection: Binding<Proposal.Snapshot?>, mode: ProposalListMode, status: [ReviewState: Bool]) {
        self = Self.$status.withValue(status) {
            Self.$mode.withValue(mode) {
                Self.init(selection: selection, status: status, mode: mode)
            }
        }
    }
}

extension ProposalListView: View {
    var body: some View {
        List(selection: $selection) {
            ForEach(proposals) { proposal in
                NavigationLink(value: Proposal.Snapshot(object: proposal)) {
                    ProposalListCell(proposal: proposal)
                }
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
        ToolbarItem {
            switch mode {
            case .all, .bookmark:
                ProposalStatusPicker()
                    .tint(.darkText)
            case .search:
                EmptyView()
            }
        }
    }

    private var navigationTitle: LocalizedStringResource {
        switch mode {
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
        switch mode {
        case .bookmark where proposals.isEmpty && !status.values.contains(false):
            ContentUnavailableView(
                "No bookmarks yet",
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
