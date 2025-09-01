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

    @Binding
    var isBookmarked: Bool

    @Query(filter: .filter(status, isBookmarked), sort: \.proposalID, order: .reverse)
    private var proposals: [Proposal]

    private var hasBookmark: Bool {
        proposals.contains { $0.bookmark != nil }
    }
}

extension ProposalListView {
    @TaskLocal private static var status: [Proposal.Status.State: Bool] = [:]
    @TaskLocal private static var isBookmarked: Bool = false

    init(_ selection: Binding<Proposal.Snapshot?>, isBookmarked: Binding<Bool>, status: [Proposal.Status.State: Bool]) {
        self = Self.$status.withValue(status) {
            Self.$isBookmarked.withValue(isBookmarked.wrappedValue) {
                Self.init(selection: selection, isBookmarked: isBookmarked)
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
        if hasBookmark {
            ToolbarItem {
                BookmarkButton(isBookmarked: $isBookmarked)
                    .tint(.darkText)
            }
        }
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            ToolbarSpacer()
        }
        ToolbarItem {
            ProposalStatusPicker()
                .tint(.darkText)
        }
    }
}

#Preview(traits: .evolution) {
    @Previewable @Environment(\.modelContext) var context
    ContentView(modelContainer: context.container)
        .environment(\.colorScheme, .dark)
}
