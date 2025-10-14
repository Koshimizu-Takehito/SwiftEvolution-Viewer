import EvolutionModel
import SwiftUI

public struct BookmarkMenu: View {
    @Environment(BookmarkRepository.self) private var repository
    /// Proposal to be presented.
    private let proposal: Proposal

    private var isBookmarked: Bool {
        proposal.bookmark != nil
    }

    public init(proposal: Proposal) {
        self.proposal = proposal
    }

    public var body: some View {
        let isBookmarked = isBookmarked
        let text = isBookmarked ? "Remove Bookmark" : "Add Bookmark"
        Button(action: toggle) {
            Label(text, systemImage: "bookmark")
        }
        .symbolVariant(isBookmarked ? .none : .fill)
        .tint(ReviewState(proposal: proposal).color)
    }

    func toggle() {
        // Toggle Bookmark
        try? repository.update(id: proposal.proposalID, isBookmarked: !isBookmarked)
    }
}

public struct OpenSafariButton: View {
    @Environment(\.openURL) private var openURL

    private let proposal: Proposal

    public init(proposal: Proposal) {
        self.proposal = proposal
    }

    public var body: some View {
        Button("Open Safari", systemImage: "safari") {
            openURL(GithubURL(link: proposal.link).rawValue)
        }
        .tint(ReviewState(proposal: proposal).color)
    }
}
