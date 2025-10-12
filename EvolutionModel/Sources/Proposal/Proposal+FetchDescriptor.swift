import Foundation
import SwiftData

extension FetchDescriptor<Proposal> {
    /// Convenience helper for building a descriptor that looks up a proposal by ID.
    public static func id(_ proposalID: String) -> Self {
        FetchDescriptor(predicate: #Predicate<Proposal> {
            $0.proposalID == proposalID
        })
    }

    public static func ids(_ proposalIDs: some Sequence<String>) -> Self {
        FetchDescriptor(predicate: .ids(proposalIDs))
    }
}

extension Predicate<Proposal> {
    public static func ids(_ ids: some Sequence<String>) -> Predicate<Proposal> {
        let ids = Set(ids)
        return #Predicate {
            ids.contains($0.proposalID)
        }
    }

    public static func ids(_ ids: String...) -> Predicate<Proposal> {
        self.ids(ids)
    }

    public static func states(_ states: some Sequence<ReviewState> = ReviewState.allCases) -> Predicate<Proposal> {
        let states = Set(states.map(\.rawValue))
        return #Predicate {
            states.contains($0.status.state.rawValue)
        }
    }

    public static func states(_ states: ReviewState...) -> Predicate<Proposal> {
        self.states(states)
    }
}
