import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

@Observable
@MainActor
final class ContentViewModel {
    @ObservationIgnored private let modelContainer: ModelContainer
    @ObservationIgnored private let proposalRepository: ProposalRepository
    @ObservationIgnored private let markdownRepository: MarkdownRepository

    /// All loaded proposals from storage.
    private(set) var proposals: [Proposal.Snapshot] = [] {
        didSet {
            Task { [self] in
                await fetchMarkdowns()
            }
        }
    }
    private(set) var fetchError: Error?
    private(set) var downloadProgress: DownloadProgress?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.proposalRepository = ProposalRepository(modelContainer: modelContainer)
        self.markdownRepository = MarkdownRepository(modelContainer: modelContainer)
        Task { proposals = await proposalRepository.load() }
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
                if (try? await markdownRepository.load(with: proposal)) == nil {
                    group.addTask { [self] in
                        try await fetch(with: proposal)
                    }
                }
            }
        }
        downloadProgress?.current = total
    }

    private func fetch(with proposal: Proposal.Snapshot) async throws {
        try await markdownRepository.fetch(with: proposal)
        downloadProgress?.current += 1
    }
}
