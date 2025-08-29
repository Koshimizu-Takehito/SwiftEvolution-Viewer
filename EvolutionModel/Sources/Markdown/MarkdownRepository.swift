import Foundation
import SwiftData

// MARK: - MarkdownRepository

/// Handles network retrieval and persistence of proposal markdown files.
@ModelActor
public actor MarkdownRepository {
    /// Downloads and stores the markdown for the given proposal.
    /// - Parameter proposal: The proposal whose markdown should be fetched.
    /// - Returns: A snapshot of the stored markdown content.
    @discardableResult
    public func fetch(proposal: Proposal.Snapshot) async throws -> Markdown.Snapshot {
        try await fetch(proposalID: proposal.id, url: MarkdownURL(link: proposal.link))
    }

    /// Fetches markdown from the provided URL and persists it.
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
