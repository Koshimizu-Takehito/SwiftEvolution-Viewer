import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - Cell

/// Displays summary information for a proposal in the list view.
struct ProposalListCell: View {
    /// Proposal to be presented.
    let proposal: Proposal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let label = label
            HStack {
                // Status label
                Text(label.text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay {
                        ConcentricRectangle(corners: .fixed(8))
                            .stroke()
                    }
                    .foregroundStyle(label.color)
                // Bookmark indicator
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(label.color)
                    .opacity(proposal.bookmark != nil ? 1 : 0)
                    .animation(.default, value: proposal.bookmark)
            }
            // Title
            Text(title)
                .lineLimit(nil)  // Required on macOS to allow multiline titles
        }
        #if os(macOS)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        #endif
    }

    /// Text and color pair representing the proposal's status.
    private var label: (text: String, color: Color) {
        let state = Proposal.Status.State(proposal: proposal)
        return (state.label, state.color)
    }

    /// Combined identifier and title string.
    private var title: AttributedString {
        let id = AttributedString(
            proposal.proposalID,
            attributes: .init().foregroundColor(.secondary)
        )
        let markdownTitle = try? AttributedString(markdown: proposal.title)
        let title =
            markdownTitle
            ?? AttributedString(proposal.title, attributes: .init().foregroundColor(.primary))
        return id + " " + title
    }
}
