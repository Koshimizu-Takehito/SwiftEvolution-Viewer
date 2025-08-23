import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - Cell

struct ProposalListCell: View {
    let proposal: Proposal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let label = label
            HStack {
                // ラベル
                Text(label.text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay {
                        ConcentricRectangle(corners: .fixed(8))
                            .stroke()
                    }
                    .foregroundStyle(label.color)
                // ブックマーク
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(label.color)
                    .opacity(proposal.bookmark != nil ? 1 : 0)
                    .animation(.default, value: proposal.bookmark)
            }
            // 本文
            Text(title)
                .lineLimit(nil)  // macOS でこの指定が必須
        }
        #if os(macOS)
            .padding(.top, 8)
            .padding(.leading, 4)
        #endif
    }

    private var label: (text: String, color: Color) {
        let state = Proposal.Status.State(proposal: proposal)
        return (state.label, state.color)
    }

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
