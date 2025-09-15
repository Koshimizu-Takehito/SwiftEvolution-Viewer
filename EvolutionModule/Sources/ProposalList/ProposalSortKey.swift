import Foundation

enum ProposalSortKey: String, Hashable, Sendable, CaseIterable, CustomStringConvertible, Identifiable {
    case proposalID
    case reviewStatus

    var id: String {
        rawValue
    }

    var description: String {
        switch self {
        case .proposalID:
            "Proposal ID"
        case .reviewStatus:
            "Review status"
        }
    }

    mutating func toggle() {
        switch self {
        case .proposalID:
            self = .reviewStatus
        case .reviewStatus:
            self = .proposalID
        }
    }
}
