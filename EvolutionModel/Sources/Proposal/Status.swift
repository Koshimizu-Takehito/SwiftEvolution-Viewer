import Foundation

// MARK: - Status

public extension Proposal {
    /// Metadata describing the review lifecycle of a proposal.
    struct Status: Codable, Hashable, Sendable {
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
    }
}

// MARK: - State

public extension Proposal.Status {
    /// Enumerates the standardized set of review states a proposal may be in.
    enum State: String, Codable, Hashable, CaseIterable, Sendable, Identifiable, CustomStringConvertible, Comparable {
        case accepted
        case activeReview
        case implemented
        case previewing
        case rejected
        case returnedForRevision
        case withdrawn

        /// Conformance to `Identifiable`.
        public var id: String { rawValue }

        /// Human-friendly name displayed to users.
        public var description: String {
            switch self {
            case .accepted:
                "Accepted"
            case .activeReview:
                "Active Review"
            case .implemented:
                "Implemented"
            case .previewing:
                "Previewing"
            case .rejected:
                "Rejected"
            case .returnedForRevision:
                "Returned"
            case .withdrawn:
                "Withdrawn"
            }
        }

        /// Initializes from a ``Proposal`` model if the state string matches a known case.
        public init?(proposal: Proposal) {
            self.init(rawValue: proposal.status.state)
        }

        /// Initializes from a ``Proposal/Snapshot`` if the state string matches a known case.
        public init?(proposal: Proposal.Snapshot) {
            self.init(rawValue: proposal.status.state)
        }

        /// Provides ordering for states based on their declaration order.
        public static func < (lhs: Self, rhs: Self) -> Bool {
            Index(state: lhs) < Index(state: rhs)
        }
    }
}

public extension Proposal.Status.State {
    /// Helper enum used to establish a sort order for ``Proposal.Status.State`` values.
    enum Index: Int, Comparable {
        case accepted
        case activeReview
        case implemented
        case previewing
        case rejected
        case returnedForRevision
        case withdrawn

        /// Converts a state into its corresponding index value.
        public init(state: Proposal.Status.State) {
            self = unsafeBitCast(state, to: Index.self)
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
