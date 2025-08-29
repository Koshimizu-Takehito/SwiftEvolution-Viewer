import EvolutionModel
import SwiftData
import SwiftUI

extension Query<Proposal, [Proposal]> {
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
    public static func predicate(states: [Proposal.Status.State : Bool], isBookmarked: Bool) -> Predicate<Proposal> {
        let states = Set(states.filter { $0.value}.keys.map(\.rawValue))
        return #Predicate { proposal in
            states.contains(proposal.status.state) && (proposal.bookmark != nil) == isBookmarked
        }
    }
}
