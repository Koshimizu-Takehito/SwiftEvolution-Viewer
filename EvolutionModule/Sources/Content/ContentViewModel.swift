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
            Task.detached { [self] in
                await self.fetchMarkdowns()
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

    /// プロポーザルの取得
    func fetchProposals() async {
        fetchError = nil
        do {
            // リストデータの取得
            proposals = try await proposalRepository.fetch()
        } catch {
            if proposals.isEmpty {
                fetchError = error
            }
        }
    }

    /// マークダウンの取得
    func fetchMarkdowns() async {
        let total = proposals.count
        let currentCount = await markdownRepository.loadCount()
        downloadProgress = DownloadProgress(total: total, current: currentCount)
        for proposal in proposals {
            if (try? await markdownRepository.load(with: proposal)) == nil {
                _ = try? await markdownRepository.fetch(with: proposal)
                try? await Task.sleep(for: .microseconds(20))
                downloadProgress?.current += 1
            }
        }
        downloadProgress?.current = total
    }
}
