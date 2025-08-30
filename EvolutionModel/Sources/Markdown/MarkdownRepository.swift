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
    public func fetch(with proposal: Proposal.Snapshot) async throws -> Markdown.Snapshot {
        let proposalID = proposal.id
        let url = MarkdownURL(link: proposal.link).rawValue
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

    @discardableResult
    public func load(with proposal: Proposal.Snapshot) async throws -> Markdown.Snapshot? {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Markdown> { $0.proposalID == proposal.id }
        return try context.fetch(FetchDescriptor(predicate: predicate))
            .first
            .flatMap(Markdown.Snapshot.init(object:))
    }

    public func loadCount() -> Int {
        let context = ModelContext(modelContainer)
        let predicate = Predicate<Markdown>.true
        let count = try? context.fetchCount(FetchDescriptor(predicate: predicate))
        return count ?? 0
    }
}
