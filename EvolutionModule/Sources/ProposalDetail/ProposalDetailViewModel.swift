import EvolutionModel
import EvolutionUI
import Foundation
import Markdown
import Observation
import SwiftData

import struct SwiftUI.Color

/// Manages loading, bookmarking, and translation for an individual proposal.
@Observable
@MainActor
final class ProposalDetailViewModel: Observable {
    private let markdownRepository: MarkdownRepository
    private let bookmarkRepository: BookmarkRepository
    private let proposalRepository: ProposalRepository

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
    var tint: Color {
        ReviewState(proposal: proposal).color
    }

    /// Bookmark state for the proposal.
    var isBookmarked: Bool = false {
        didSet {
            Task { await save(isBookmarked: isBookmarked) }
        }
    }

    /// Creates a view model for the provided proposal using the supplied
    /// `ModelContainer` to access repositories.
    init(proposal: Proposal.Snapshot, modelContainer: ModelContainer) {
        self.proposal = proposal
        self.markdownRepository = MarkdownRepository(modelContainer: modelContainer)
        self.bookmarkRepository = BookmarkRepository(modelContainer: modelContainer)
        self.proposalRepository = ProposalRepository(modelContainer: modelContainer)
        Task {
            await loadMarkdown()
            await fetchMarkdown()
        }
        Task {
            await loadBookmark()
        }
    }

    /// Loads cached markdown for the proposal if it has already been
    /// downloaded.
    func loadMarkdown() async {
        if let markdown = try? await markdownRepository.load(with: proposal) {
            items = [ProposalDetailRow](markdown: markdown)
        }
    }

    /// Retrieves markdown text for the proposal.
    func fetchMarkdown() async {
        fetchError = nil
        do {
            let markdown = try await markdownRepository.fetch(with: proposal)
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
        isBookmarked = (await bookmarkRepository.load(proposalID: proposal.id) != nil)
    }

    /// Persists the bookmark state for this proposal.
    private func save(isBookmarked: Bool) async {
        let repository = bookmarkRepository
        try? await repository.update(proposal: proposal, isBookmarked: isBookmarked)
    }

    /// Translates the markdown contents in place.
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
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
        await proposalRepository.find(by: "SE-\(String(id))")
    }
}
