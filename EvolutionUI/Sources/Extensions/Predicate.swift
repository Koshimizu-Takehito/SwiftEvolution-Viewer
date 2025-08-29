import EvolutionModel
import SwiftData
import SwiftUI

extension Query<Proposal, [Proposal]> {
    /// Builds a query that filters proposals by status and bookmark state.
    public static func query(status: [Proposal.Status.State : Bool], isBookmarked: Bool) -> Query {
        Query(
            filter: .predicate(states: status, isBookmarked: isBookmarked),
            sort: \.proposalID,
            order: .reverse,
            animation: .default
        )
    }
}

extension Predicate<Proposal> {
    /// Predicate that matches proposals with the selected states and bookmark preference.
    public static func predicate(states: [Proposal.Status.State : Bool], isBookmarked: Bool) -> Predicate<Proposal> {
        let states = Set(states.filter { $0.value}.keys.map(\.rawValue))
        return #Predicate { proposal in
            states.contains(proposal.status.state) && (proposal.bookmark != nil) == isBookmarked
        }
    }
}
