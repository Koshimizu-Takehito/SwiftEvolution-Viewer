import Foundation

// MARK: - State

/// Enumerates the standardized set of review states a proposal may be in.
public enum ReviewState: String, Codable, Hashable, CaseIterable, Sendable, Identifiable, CustomStringConvertible, Comparable {
    case activeReview
    case accepted
    case implemented
    case previewing
    case rejected
    case returnedForRevision
    case withdrawn
    case unknown

    /// Conformance to `Identifiable`.
    public var id: String { rawValue }

    /// Human-friendly name displayed to users.
    public var description: String {
        switch self {
        case .activeReview:
            "Active Review"
        case .accepted:
            "Accepted"
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
        case .unknown:
            "Unknown"
        }
    }

    public var order: Int {
        switch self {
        case .activeReview:
            0
        case .accepted:
            1
        case .implemented:
            2
        case .previewing:
            3
        case .rejected:
            4
        case .returnedForRevision:
            5
        case .withdrawn:
            6
        case .unknown:
            Int.max
        }
    }

    /// Initializes from a ``Proposal`` model if the state string matches a known case.
    public init(proposal: Proposal) {
        self = ReviewState.init(rawValue: proposal.status.state.rawValue) ?? .unknown
    }

    /// Initializes from a ``Proposal/Snapshot`` if the state string matches a known case.
    public init(proposal: Proposal.Snapshot) {
        self = ReviewState.init(rawValue: proposal.status.state) ?? .unknown
    }

    /// Provides ordering for states based on their declaration order.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.order < rhs.order
    }
}
