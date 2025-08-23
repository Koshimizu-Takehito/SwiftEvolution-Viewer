import Foundation
import SwiftData

// MARK: - Bookmark

@Model
public final class Bookmark {
    #Unique<Bookmark>([\.proposalID])
    @Attribute(.unique) public private(set) var proposalID: String
    @Attribute(.unique) public private(set) var proposal: Proposal
    public var updateAt: Date

    init(proposal: Proposal) {
        self.proposal = proposal
        self.proposalID = proposal.proposalID
        self.updateAt = .now
    }
}

// MARK: - Snapshot

public extension Bookmark {
    struct Snapshot: Hashable, Codable, Sendable {
        public var persistentModelID: PersistentIdentifier?
        public var proposalID: String
        public var proposal: Proposal.Snapshot
        public var updateAt: Date

        init(object: Bookmark) {
            persistentModelID = object.persistentModelID
            proposalID = object.proposalID
            proposal = Proposal.Snapshot(object: object.proposal)
            updateAt = object.updateAt
        }
    }
}
