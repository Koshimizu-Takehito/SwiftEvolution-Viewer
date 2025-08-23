import Foundation
import SwiftData

// MARK: - MarkdownRepository

@ModelActor
public actor MarkdownRepository {
    @discardableResult
    public func fetch(proposal: Proposal.Snapshot) async throws -> Markdown.Snapshot {
        try await fetch(proposalID: proposal.id, url: MarkdownURL(link: proposal.link))
    }

    private func fetch(proposalID: String, url: MarkdownURL) async throws -> Markdown.Snapshot {
        let url = url.rawValue
        let (data, _) = try await URLSession.shared.data(from: url)
        let text = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "'", with: #"\'"#)
        let context = ModelContext(modelContainer)
        let markdown = Markdown(url: url, proposalID: proposalID, text: text)
        try context.transaction {
            context.insert(markdown)
        }
        return markdown.snapshot
    }
}
