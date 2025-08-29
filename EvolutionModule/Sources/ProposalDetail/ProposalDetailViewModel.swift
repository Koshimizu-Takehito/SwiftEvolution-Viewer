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
    /// プロポーザル
    private let proposal: Proposal.Snapshot
    /// 表示用のコンテンツ（マークダウンを解析した結果）
    private(set) var items: [ProposalDetailRow] = []
    /// マークダウン取得エラー
    private(set) var fetcherror: Error?
    /// 翻訳中
    var translating: Bool = false

    /// 画面のタイトル
    var title: String {
        proposal.title
    }

    var tint: Color? {
        Proposal.Status.State(proposal: proposal)?.color
    }

    /// ブックマークの状態
    var isBookmarked: Bool = false {
        didSet {
            Task { await save(isBookmarked: isBookmarked) }
        }
    }

    /// ModelContext
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

    /// マークダウンテキストを取得
    func loadMarkdown() async {
        fetcherror = nil
        do {
            let repository = MarkdownRepository(modelContainer: modelContainer)
            let markdown = try await repository.fetch(proposal: proposal)
            items = [ProposalDetailRow](markdown: markdown)
        } catch let error as URLError where error.code == URLError.cancelled {
            return
        } catch is CancellationError {
            return
        } catch {
            fetcherror = error
        }
    }

    func loadBookmark() async {
        let repository = BookmarkRepository(modelContainer: modelContainer)
        isBookmarked = (await repository.load(proposalID: proposal.id) != nil)
    }


    /// 当該プロポーザルのブックマークの有無を保存
    private func save(isBookmarked: Bool) async {
        let repository = BookmarkRepository(modelContainer: modelContainer)
        try? await repository.update(proposal: proposal, isBookmarked: isBookmarked)
    }

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
    enum URLAction {
        case scrollTo(id: String)
        case showDetail(Proposal.Snapshot)
        case open(URL)
    }

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
