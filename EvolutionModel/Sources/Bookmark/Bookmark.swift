import Foundation
import SwiftData

// MARK: - Bookmark

/// Stores a user's bookmarked proposal for quick access.
///
/// The model keeps track of the associated `Proposal` and when the
/// bookmark was last updated. Each bookmark is uniquely identified by the
/// proposal's identifier.
@Model
public final class Bookmark {
    #Unique<Bookmark>([\.proposalID])

    /// Unique identifier for the bookmarked proposal.
    @Attribute(.unique) public private(set) var proposalID: String

    /// The proposal associated with this bookmark.
    @Attribute(.unique) public private(set) var proposal: Proposal

    /// Timestamp indicating when the bookmark was last modified.
    public var updatedAt: Date

    /// Creates a new bookmark for the given proposal.
    init(proposal: Proposal) {
        self.proposal = proposal
        self.proposalID = proposal.proposalID
        self.updatedAt = .now
    }
}

// MARK: - Snapshot

public extension Bookmark {
    /// Immutable representation of a ``Bookmark`` used for transferring data
    /// across concurrency domains or persisting to disk.
    struct Snapshot: Hashable, Codable, Sendable {
        /// Identifier of the stored model object, if available.
        public var persistentModelID: PersistentIdentifier?

        /// Unique identifier for the bookmarked proposal.
        public var proposalID: String

        /// Lightweight snapshot of the associated proposal.
        public var proposal: Proposal.Snapshot

        /// Timestamp indicating the last update to the bookmark.
        public var updatedAt: Date

        /// Creates a snapshot from a managed ``Bookmark`` instance.
        init(object: Bookmark) {
            persistentModelID = object.persistentModelID
            proposalID = object.proposalID
            proposal = Proposal.Snapshot(object: object.proposal)
            updatedAt = object.updatedAt
        }
    }
}
