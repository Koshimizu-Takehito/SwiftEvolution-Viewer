import EvolutionModel
import Foundation

extension Predicate<Proposal> {
    static func predicate(_ mode: ProposalListMode, _ states: [Proposal.Status.State: Bool]) -> Predicate<Proposal> {
        let states = Set(states.filter { $0.value }.keys.map(\.rawValue))
        /// Predicate limiting results to the selected states and optional bookmark filter.
        switch mode {
        case .all:
            return #Predicate { proposal in
                states.contains(proposal.status.state)
            }
        case .bookmark:
            return #Predicate { proposal in
                states.contains(proposal.status.state) && (proposal.bookmark != nil)
            }
        }
    }
}
