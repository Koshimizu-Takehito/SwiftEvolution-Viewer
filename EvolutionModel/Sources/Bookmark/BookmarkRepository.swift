import Foundation
import SwiftData

// MARK: - BookmarkRepository

/// Provides data access for ``Bookmark`` objects stored in `SwiftData`.
///
/// All methods run on the actor's isolated model container to ensure safe
/// access from concurrent contexts.
@ModelActor
public actor BookmarkRepository: Observable {}

@MainActor
extension BookmarkRepository {
    /// Adds or removes a bookmark for the given proposal.
    /// - Parameters:
    ///   - id: proposal id.
    ///   - isBookmarked: Pass `true` to add a bookmark, or `false` to remove it.
    public func update(id: String, isBookmarked: Bool) throws {
        if isBookmarked {
            try add(id: id)
        } else {
            try delete(id: id)
        }
    }

    /// Inserts a new bookmark if one does not already exist.
    private func add(id: String) throws {
        let context = modelContainer.mainContext
        let predicate = #Predicate<Proposal> { $0.proposalID == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        let proposal = try context.fetch(descriptor).first
        try context.transaction {
            if let proposal, proposal.bookmark == nil {
                context.insert(Bookmark(proposal: proposal))
            }
        }
    }

    /// Deletes an existing bookmark for the given proposal.
    private func delete(id: String) throws {
        let descriptor = FetchDescriptor(
            predicate: #Predicate<Bookmark> {
                $0.proposalID == id
            }
        )
        let context = modelContainer.mainContext
        try context.transaction {
            try context.fetch(descriptor).forEach { object in
                context.delete(object)
            }
        }
    }

    /// Loads a bookmark for the specified proposal identifier.
    /// - Parameter proposalID: The identifier of the proposal to look up.
    /// - Returns: A ``Bookmark`` if one exists, otherwise `nil`.
    public func load(proposalID: String) -> Bookmark? {
        return try? modelContainer.mainContext
            .fetch(.init(predicate: #Predicate<Bookmark> { $0.proposalID == proposalID }))
            .first
    }
}
