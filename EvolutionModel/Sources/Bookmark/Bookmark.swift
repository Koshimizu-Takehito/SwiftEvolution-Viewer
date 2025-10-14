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
