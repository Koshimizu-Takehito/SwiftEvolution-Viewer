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

    @Query(filter: .predicate(mode, status), sort: \.proposalID, order: .reverse)
    private var proposals: [Proposal]

    private var hasBookmark: Bool {
        proposals.contains { $0.bookmark != nil }
    }
}

extension ProposalListView {
    @TaskLocal private static var mode: ProposalListMode = .all
    @TaskLocal private static var status: [Proposal.Status.State: Bool] = [:]

    init(_ selection: Binding<Proposal.Snapshot?>, mode: ProposalListMode, status: [Proposal.Status.State: Bool]) {
        self = Self.$status.withValue(status) {
            Self.$mode.withValue(mode) {
                Self.init(selection: selection)
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
        .animation(.default, value: proposals)
        .tint(.darkText.opacity(0.2))
        .navigationTitle("Swift Evolution")
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
            ProposalStatusPicker()
                .tint(.darkText)
        }
    }
}

#Preview(traits: .evolution) {
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
