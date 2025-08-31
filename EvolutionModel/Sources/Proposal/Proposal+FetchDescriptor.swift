import Foundation
import SwiftData

extension FetchDescriptor<Proposal> {
    /// Convenience helper for building a descriptor that looks up a proposal by ID.
    static func id(_ proposalID: String) -> Self {
        FetchDescriptor(predicate: #Predicate<Proposal> {
            $0.proposalID == proposalID
        })
    }
}
