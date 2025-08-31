import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ListView

/// Displays a list of proposals and manages selection state.
struct ProposalListView: View {
    @Environment(\.horizontalSizeClass) private var horizontal
    @Binding var selection: Proposal.Snapshot?
    @Query private var proposals: [Proposal]

    init(
        selection: Binding<Proposal.Snapshot?>,
        status: [Proposal.Status.State: Bool],
        isBookmarked: Bool
    ) {
        _selection = selection
        _proposals = Query(status, isBookmarked: isBookmarked)
    }

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
}

#Preview(traits: .evolution) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}
