import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ListView

struct ProposalListView: View {
    @Environment(\.horizontalSizeClass) private var horizontal
    @Binding var selection: Proposal.Snapshot?
    @Query private var proposals: [Proposal]
    let status: [Proposal.Status.State : Bool]

    init(
        selection: Binding<Proposal.Snapshot?>,
        status: [Proposal.Status.State : Bool],
        isBookmarked: Bool
    ) {
        self.status = status
        _selection = selection
        _proposals = .query(
            status: status,
            isBookmarked: isBookmarked
        )
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
        .animation(.default, value: status)
        .navigationTitle("Swift Evolution")
        .onAppear(perform: selectFirstItem)
    }

    func selectFirstItem() {
        #if os(macOS)
            if selection == nil, let proposal = proposals.first {
                selection = Markdown(proposal: .init(proposal))
            }
        #elseif os(iOS)
            /// SplitView　が画面分割表示の場合に、初期表示を与える
            if horizontal == .regular, selection == nil, let proposal = proposals.first {
                selection = .init(object: proposal)
            }
        #endif
    }
}

#Preview(traits: .proposal) {
    ContentView()
        .environment(\.colorScheme, .dark)
}
