import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

/// Coordinates fetching proposal metadata and markdown content for the
/// ``ContentView``.
@Observable
@MainActor
final class ContentViewModel {
    private let proposalRepository: ProposalRepository
    private let markdownRepository: MarkdownRepository

    /// All loaded proposals from storage.
    private var proposals: [Proposal] = [] {
        didSet {
            Task { [self] in
                await fetchMarkdowns()
            }
        }
    }
    /// Error encountered when attempting to fetch proposals.
    private(set) var fetchError: Error?
    /// Progress information for background markdown downloads.
    private(set) var downloadProgress: DownloadProgress?

    /// Creates a model bound to the shared `ModelContainer`.
    init(modelContainer: ModelContainer) {
        self.proposalRepository = ProposalRepository(modelContainer: modelContainer)
        self.markdownRepository = MarkdownRepository(modelContainer: modelContainer)
        proposals = proposalRepository.load()
    }

    /// Retrieves the list of proposals from the remote feed and stores them.
    func fetchProposals() async {
        fetchError = nil
        do {
            // Load proposal list data.
            proposals = try await proposalRepository.fetch()
        } catch {
            if proposals.isEmpty {
                fetchError = error
            }
        }
    }

    /// Loads and caches markdown documents for each proposal, updating the
    /// ``downloadProgress`` as items are fetched.
    func fetchMarkdowns() async {
        let total = proposals.count
        let currentCount = await markdownRepository.loadCount()
        downloadProgress = DownloadProgress(total: total, current: currentCount)
        await withThrowingTaskGroup { group in
            for proposal in proposals {
                if (try? markdownRepository.load(with: proposal)) == nil {
                    let proposalID = proposal.proposalID
                    let link = proposal.link
                    group.addTask {
                        try await self.fetch(with: proposalID, link: link)
                    }
                }
            }
        }
        downloadProgress?.current = total
    }

    /// Downloads markdown for a single proposal and advances the progress
    /// counter.
    private func fetch(with proposalID: String, link: String) async throws {
        try await markdownRepository.fetch(with: proposalID, link: link)
        downloadProgress?.current += 1
    }
}
