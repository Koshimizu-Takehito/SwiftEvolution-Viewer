import Foundation
import SwiftData

public extension SortDescriptor<Proposal> {
    /// Sorts proposals by identifier in descending order.
    static var proposalID: Self {
        SortDescriptor(\Proposal.proposalID, order: .reverse)
    }
}
