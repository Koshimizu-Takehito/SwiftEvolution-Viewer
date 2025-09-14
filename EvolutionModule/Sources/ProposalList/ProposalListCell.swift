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
                        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
                            ConcentricRectangle(corners: .fixed(8))
                                .stroke()
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke()
                        }
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
        let state = ReviewState(proposal: proposal)
        return (String(describing: state), state.color)
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
