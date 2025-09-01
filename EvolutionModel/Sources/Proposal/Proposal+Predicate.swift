import Foundation

public extension Predicate<Proposal> {
    static func filter(_ states: [Proposal.Status.State: Bool], _ isBookmarked: Bool) -> Predicate<Proposal> {
        let states = Set(states.filter { $0.value }.keys.map(\.rawValue))
        /// Predicate limiting results to the selected states and optional bookmark filter.
        let predicate = #Predicate<Proposal> { proposal in
            states.contains(proposal.status.state) && (!isBookmarked || (proposal.bookmark != nil))
        }
        return predicate
    }
}
