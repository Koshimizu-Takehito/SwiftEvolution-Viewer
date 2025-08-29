import Foundation
import SwiftData

// MARK: - BookmarkRepository

/// Provides data access for ``Bookmark`` objects stored in `SwiftData`.
///
/// All methods run on the actor's isolated model container to ensure safe
/// access from concurrent contexts.
@ModelActor
public actor BookmarkRepository {
    /// Returns all stored bookmarks as immutable snapshots.
    public func snapshots() -> [Bookmark.Snapshot] {
        let modelContext = ModelContext(modelContainer)
        let result = try? modelContext.fetch(FetchDescriptor<Bookmark>(predicate: .true))
        return result?.map(Bookmark.Snapshot.init) ?? []
    }

    /// Loads a bookmark for the specified proposal identifier.
    /// - Parameter proposalID: The identifier of the proposal to look up.
    /// - Returns: A ``Bookmark/Snapshot`` if one exists, otherwise `nil`.
    public func load(proposalID: String) -> Bookmark.Snapshot? {
        let descriptor = FetchDescriptor(predicate: #Predicate<Bookmark> {
            $0.proposalID == proposalID
        })
        let object = try? ModelContext(modelContainer)
            .fetch(descriptor)
            .first
        return object.flatMap(Bookmark.Snapshot.init(object:))
    }

    /// Adds or removes a bookmark for the given proposal.
    /// - Parameters:
    ///   - proposal: Snapshot of the proposal to modify.
    ///   - isBookmarked: Pass `true` to add a bookmark, or `false` to remove it.
    public func update(proposal: Proposal.Snapshot, isBookmarked: Bool) throws {
        if isBookmarked {
            try add(proposal: proposal)
        } else {
            try delete(proposal: proposal)
        }
    }

    /// Inserts a new bookmark if one does not already exist.
    private func add(proposal: Proposal.Snapshot) throws {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Proposal> { $0.proposalID == proposal.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        let proposal = try context.fetch(descriptor).first
        try context.transaction {
            if let proposal, proposal.bookmark == nil {
                context.insert(Bookmark(proposal: proposal))
            }
        }
    }

    /// Deletes an existing bookmark for the given proposal.
    private func delete(proposal: Proposal.Snapshot) throws {
        let descriptor = FetchDescriptor(predicate: #Predicate<Bookmark> {
            $0.proposalID == proposal.id
        })
        let context = ModelContext(modelContainer)
        try context.transaction {
            try context.fetch(descriptor).forEach { object in
                context.delete(object)
            }
        }
    }
}
