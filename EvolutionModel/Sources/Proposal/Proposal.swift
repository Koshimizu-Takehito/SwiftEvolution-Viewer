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
    @Attribute(.unique, .spotlight) public var proposalID: String

    /// URL path to the proposal's markdown file on GitHub.
    public private(set) var link: String

    /// Human-readable proposal title.
    @Attribute(.spotlight) public private(set) var title: String

    // MARK: Relationship

    /// Reference to any bookmark associated with this proposal.
    @Relationship(deleteRule: .cascade, inverse: \Bookmark.proposal)
    public var bookmark: Bookmark?

    /// The current review status details.
    @Relationship(deleteRule: .cascade)
    public private(set) var status: Status

    // MARK: init

    /// Creates a managed proposal instance from a snapshot.
    required init(snapshot: Snapshot) {
        self.proposalID = snapshot.id
        self.link = snapshot.link
        self.status = Proposal.Status(snapshot.status)
        self.title = snapshot.title.trimmingCharacters(in: .whitespaces)
    }

    /// Updates the stored data using a more recent snapshot.
    @discardableResult
    func update(with snapshot: Snapshot) -> Self {
        guard proposalID == snapshot.id else {
            return self
        }
        self.link = snapshot.link
        self.status = .init(snapshot.status)
        self.title = snapshot.title.trimmingCharacters(in: .whitespaces)
        return self
    }
}

// MARK: - Relationship

extension Proposal {
    /// Metadata describing the review lifecycle of a proposal.
    @Model
    public final class Status {
        /// Raw state string such as "activeReview" or "accepted".
        @Relationship(deleteRule: .cascade)
        public private(set) var state: State
        /// Version of Swift in which the change shipped, if any.
        @Relationship(deleteRule: .cascade)
        public private(set) var version: Version
        /// The end date for the proposal's review period.
        public private(set) var end: String?
        /// The start date for the proposal's review period.
        public private(set) var start: String?

        /// Creates a new status description.
        public init(state: String, version: String? = nil, end: String? = nil, start: String? = nil) {
            self.state = State(rawValue: state)
            self.version = Version(rawValue: version)
            self.end = end
            self.start = start
        }

        init(_ status: Proposal.Snapshot.Status) {
            self.state = State(rawValue: status.state)
            self.version = Version(rawValue: status.version)
            self.end = status.end
            self.start = status.start
        }
    }

    @Model
    public final class State {
        public private(set) var rawValue: String
        public private(set) var title: String
        public private(set) var order: Int

        public init(rawValue: String) {
            let state = ReviewState(rawValue: rawValue) ?? .unknown
            self.rawValue = rawValue
            self.order = state.order
            self.title = state.description
        }
    }

    @Model
    public final class Version {
        public private(set) var rawValue: String?
        public private(set) var code: Int64

        public init(rawValue: String?) {
            self.rawValue = rawValue
            self.code = Version.makeCode(rawValue)
        }

        private static func makeCode(_ value: String?) -> Int64 {
            let value = value?.trimmingCharacters(in: .whitespaces)
            guard let value, !value.isEmpty else {
                return 0
            }
            var numbers = value.split(separator: ".").map(String.init).compactMap(Int.init).reversed().map(\.self)
            if numbers.isEmpty {
                return Int64.max
            }
            let major = numbers.popLast() ?? 0
            let minor = numbers.popLast() ?? 0
            let patch = numbers.popLast() ?? 0
            return (Int64(major) << 32) | (Int64(minor) << 16) | Int64(patch)
        }
    }
}
