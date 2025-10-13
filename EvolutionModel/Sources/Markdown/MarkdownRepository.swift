import Foundation
import SwiftData

// MARK: - MarkdownRepository

/// Handles network retrieval and persistence of proposal markdown files.
@ModelActor
public actor MarkdownRepository {
    /// Returns the number of markdown files currently stored.
    public func loadCount() -> Int {
        let predicate = Predicate<Markdown>.true
        let count = try? modelContext.fetchCount(FetchDescriptor(predicate: predicate))
        return count ?? 0
    }
}

@MainActor
extension MarkdownRepository {
    /// Downloads and stores the markdown for the given proposal.
    @discardableResult
    public func fetch(with proposalID: String, link: String) async throws -> Markdown {
        let url = MarkdownURL(link: link).rawValue
        let (data, _) = try await URLSession.shared.data(from: url)
        let text = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "'", with: #"\'"#)
        let context = modelContainer.mainContext
        let markdown = Markdown(url: url, proposalID: proposalID, text: text)
        try context.transaction {
            context.insert(markdown)
        }
        return markdown
    }

    /// Loads the stored markdown for the specified proposal, if available.
    /// - Parameter proposal: The proposal whose markdown should be looked up.
    /// - Returns: A ``Markdown`` when the markdown exists in storage.
    public func load(with proposal: Proposal) throws -> Markdown? {
        let proposalID = proposal.proposalID
        let predicate = #Predicate<Markdown> { $0.proposalID == proposalID }
        return try modelContainer.mainContext.fetch(FetchDescriptor(predicate: predicate))
            .first
    }
}
