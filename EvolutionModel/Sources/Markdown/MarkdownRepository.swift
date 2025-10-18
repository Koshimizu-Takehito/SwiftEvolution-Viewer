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
        try context.transaction {
            if let markdown = try? self.load(proposalID: proposalID, url: url) {
                if markdown.text != text {
                    markdown.text = text
                }
            } else {
                context.insert(Markdown(url: url, proposalID: proposalID, text: text))
            }
        }
        return try load(proposalID: proposalID, url: url)!
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

    private func load(proposalID: String, url: URL) throws -> Markdown? {
        let predicate = #Predicate<Markdown> { $0.proposalID == proposalID && $0.url == url }
        return try modelContainer.mainContext.fetch(FetchDescriptor(predicate: predicate))
            .first
    }
}
