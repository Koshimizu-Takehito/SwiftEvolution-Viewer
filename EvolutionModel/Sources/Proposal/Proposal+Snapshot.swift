import Foundation
import SwiftData

// MARK: - Snapshot

extension Proposal {
    /// Immutable view of a ``Proposal`` used for value semantics.
    public struct Snapshot: Hashable, Codable, Sendable {
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
            id = object.proposalID
            link = object.link
            status = .init(object.status)
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
            self.status = .init(status)
            self.title = title
        }
    }
}

extension Proposal.Snapshot {
    /// Metadata describing the review lifecycle of a proposal.
    public struct Status: Codable, Hashable, Sendable {
        /// Raw state string such as "activeReview" or "accepted".
        public var state: String
        /// Version of Swift in which the change shipped, if any.
        public var version: String?
        /// The end date for the proposal's review period.
        public var end: String?
        /// The start date for the proposal's review period.
        public var start: String?

        /// Creates a new status description.
        public init(state: String, version: String? = nil, end: String? = nil, start: String? = nil) {
            self.state = state
            self.version = version
            self.end = end
            self.start = start
        }

        public init(_ status: Proposal.Status) {
            self.state = status.state.rawValue
            self.version = status.version.rawValue
            self.end = status.end
            self.start = status.start
        }
    }
}
