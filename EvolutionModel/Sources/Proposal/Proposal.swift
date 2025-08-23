import Foundation
import SwiftData

// MARK: - Proposal

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

    @Relationship(deleteRule: .cascade, inverse: \Bookmark.proposal)
    public var bookmark: Bookmark?

    public required init(snapshot: Snapshot) {
        self.proposalID = snapshot.id
        self.link = snapshot.link
        self.status = snapshot.status
        self.title = snapshot.title.trimmingCharacters(in: .whitespaces)
    }

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
    public struct Snapshot: Hashable, Codable, Sendable {
        public var persistentModelID: PersistentIdentifier?
        public var id: String
        public var link: String
        public var status: Status
        public var title: String

        public init(object: Proposal) {
            persistentModelID = object.persistentModelID
            id = object.proposalID
            link = object.link
            status = object.status
            title = object.title.trimmingCharacters(in: .whitespaces)
        }

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
