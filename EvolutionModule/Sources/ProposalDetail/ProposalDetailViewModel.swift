import EvolutionModel
import EvolutionUI
import Foundation
import Markdown
import Observation
import SwiftData

import struct SwiftUI.Color

@Observable
@MainActor
final class ProposalDetailViewModel: Observable {
    /// The proposal being displayed.
    private let proposal: Proposal.Snapshot

    /// Parsed markdown content for presentation.
    private(set) var items: [ProposalDetailRow] = []

    /// Error that occurred while fetching markdown text.
    private(set) var fetchError: Error?

    /// Indicates whether markdown is currently being translated.
    var translating: Bool = false

    /// Title for the navigation bar.
    var title: String {
        proposal.title
    }

    /// Tint color based on the proposal's status.
    var tint: Color? {
        Proposal.Status.State(proposal: proposal)?.color
    }

    /// Bookmark state for the proposal.
    var isBookmarked: Bool = false {
        didSet {
            Task { await save(isBookmarked: isBookmarked) }
        }
    }

    /// Model container used to access repositories.
    @ObservationIgnored private let modelContainer: ModelContainer

    init(proposal: Proposal.Snapshot, modelContainer: ModelContainer) {
        self.proposal = proposal
        self.modelContainer = modelContainer
        Task {
            await loadMarkdown()
        }
        Task {
            await loadBookmark()
        }
    }

    /// Retrieves markdown text for the proposal.
    func loadMarkdown() async {
        fetchError = nil
        do {
            let repository = MarkdownRepository(modelContainer: modelContainer)
            let markdown = try await repository.fetch(proposal: proposal)
            items = [ProposalDetailRow](markdown: markdown)
        } catch let error as URLError where error.code == URLError.cancelled {
            return
        } catch is CancellationError {
            return
        } catch {
            fetchError = error
        }
    }

    /// Loads the current bookmark state from persistent storage.
    func loadBookmark() async {
        let repository = BookmarkRepository(modelContainer: modelContainer)
        isBookmarked = (await repository.load(proposalID: proposal.id) != nil)
    }

    /// Persists the bookmark state for this proposal.
    private func save(isBookmarked: Bool) async {
        let repository = BookmarkRepository(modelContainer: modelContainer)
        try? await repository.update(proposal: proposal, isBookmarked: isBookmarked)
    }

    /// Translates the markdown contents in place.
    func translate() async throws {
        if items.isEmpty || translating {
            return
        }
        translating = true; defer { translating = false }

        let translator = MarkdownTranslator()
        for (offset, item) in items.enumerated() {
            for try await result in await translator.translate(markdown: item.markup) {
                items[offset].markup = result
            }
        }
    }
}

extension ProposalDetailViewModel {
    /// Possible actions triggered by tapping a link within the markdown content.
    enum URLAction {
        case scrollTo(id: String)
        case showDetail(Proposal.Snapshot)
        case open(URL)
    }

    /// Determines the appropriate action for a tapped URL.
    func makeURLAction(url: URL) async -> URLAction {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .open(url)
        }
        switch (components.scheme, components.host, components.path) {
        case (_, "github.com", let path):
            guard let match = path.firstMatch(of: /^.+\/swift-evolution\/.*\/(\d+)-.*\.md/) else {
                break
            }
            return await makeMarkdown(id: match.1).map(URLAction.showDetail) ?? .open(url)

        case (nil, nil, "") where components.fragment?.isEmpty == false:
            return .scrollTo(id: url.absoluteString)

        case (nil, nil, let path):
            guard let match = path.firstMatch(of: /(\d+)-.*\.md$/) else {
                break
            }
            return await makeMarkdown(id: match.1).map(URLAction.showDetail) ?? .open(url)

        default:
            break
        }
        return .open(url)
    }

    private func makeMarkdown(id: some StringProtocol) async -> Proposal.Snapshot? {
        let repository = ProposalRepository(modelContainer: modelContainer)
        return await repository.find(by: "SE-\(String(id))")
    }
}
