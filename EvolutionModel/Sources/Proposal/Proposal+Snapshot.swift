import Foundation
import SwiftData

// MARK: - Snapshot

extension Proposal {
    /// Immutable view of a ``Proposal`` used for value semantics.
    struct Snapshot: Hashable, Codable, Sendable {
        /// Unique proposal identifier such as "SE-0001".
        var id: String
        /// Path to the proposal's markdown on GitHub.
        var link: String
        /// Current review status.
        var status: Status
        /// Proposal title.
        var title: String
    }
}

extension Proposal.Snapshot {
    /// Metadata describing the review lifecycle of a proposal.
    struct Status: Codable, Hashable, Sendable {
        /// Raw state string such as "activeReview" or "accepted".
        var state: String
        /// Version of Swift in which the change shipped, if any.
        var version: String?
        /// The end date for the proposal's review period.
        var end: String?
        /// The start date for the proposal's review period.
        var start: String?
    }
}
