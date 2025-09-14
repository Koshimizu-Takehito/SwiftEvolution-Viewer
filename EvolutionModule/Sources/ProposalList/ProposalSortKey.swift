import EvolutionModel
import EvolutionUI
import Foundation
import SwiftData

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

    var descriptors: [SortDescriptor<Proposal>] {
        switch self {
        case .proposalID:
            return [SortDescriptor(\.proposalID, order: .reverse)]
        case .reviewStatus:
            return [
                SortDescriptor(\.status.state.order),
                SortDescriptor(\.status.version.code, order: .reverse),
                SortDescriptor(\.proposalID, order: .reverse)
            ]
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
