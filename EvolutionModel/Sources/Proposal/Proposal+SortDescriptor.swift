import Foundation
import SwiftData

public extension SortDescriptor<Proposal> {
    static var proposalID: Self {
        SortDescriptor(\Proposal.proposalID, order: .reverse)
    }
}
