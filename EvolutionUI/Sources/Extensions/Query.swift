import EvolutionModel
import SwiftData
import SwiftUI

extension Query<Proposal, [Proposal]> {
    /// Builds a query that filters proposals by status and bookmark state.
    public init(_ states: [Proposal.Status.State: Bool], isBookmarked: Bool) {
        let states = Set(states.filter { $0.value }.keys.map(\.rawValue))
        /// Predicate limiting results to the selected states and optional bookmark filter.
        let predicate = #Predicate<Proposal> { proposal in
            states.contains(proposal.status.state) && (!isBookmarked || (proposal.bookmark != nil))
        }
        self = Query(filter: predicate, sort: \.proposalID, order: .reverse, animation: .default)
    }
}
