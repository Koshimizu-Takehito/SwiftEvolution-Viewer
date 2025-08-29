import Foundation
import SwiftData

// MARK: - Proposal

/// Represents a single Swift Evolution proposal.
///
/// Each proposal has an identifier, a link to its markdown content, a status,
/// and a human-readable title. Proposals may also be bookmarked by the user.
@Model
public final class Proposal {
    #Unique<Proposal>([\.proposalID])

    /// The proposal identifier, such as "SE-0001".
    @Attribute(.unique) public var proposalID: String

    /// URL path to the proposal's markdown file on GitHub.
    public private(set) var link: String

    /// The current review status details.
    public private(set) var status: Status

    /// Human-readable proposal title.
    public private(set) var title: String

    /// Reference to any bookmark associated with this proposal.
    @Relationship(deleteRule: .cascade, inverse: \Bookmark.proposal)
    public var bookmark: Bookmark?

    /// Creates a managed proposal instance from a snapshot.
    public required init(snapshot: Snapshot) {
        self.proposalID = snapshot.id
        self.link = snapshot.link
        self.status = snapshot.status
        self.title = snapshot.title.trimmingCharacters(in: .whitespaces)
    }

    /// Updates the stored data using a more recent snapshot.
    @discardableResult
    public func update(with snapshot: Snapshot) -> Self {
        guard proposalID == snapshot.id else {
            return self
        }
        self.link = snapshot.link
        self.status = snapshot.status
        self.title = snapshot.title.trimmingCharacters(in: .whitespaces)
        return self
    }
}

// MARK: - Snapshot

extension Proposal {
    /// Immutable view of a ``Proposal`` used for value semantics.
    public struct Snapshot: Hashable, Codable, Sendable {
        /// Identifier of the persisted model, if any.
        public var persistentModelID: PersistentIdentifier?

        /// Unique proposal identifier such as "SE-0001".
        public var id: String

        /// Path to the proposal's markdown on GitHub.
        public var link: String

        /// Current review status.
        public var status: Status

        /// Proposal title.
        public var title: String

        /// Creates a snapshot from a managed ``Proposal`` instance.
        public init(object: Proposal) {
            persistentModelID = object.persistentModelID
            id = object.proposalID
            link = object.link
            status = object.status
            title = object.title.trimmingCharacters(in: .whitespaces)
        }

        /// Creates a snapshot with the provided values.
        public init(
            id: String,
            link: String,
            status: Proposal.Status,
            title: String
        ) {
            self.id = id
            self.link = link
            self.status = status
            self.title = title
        }
    }
}
