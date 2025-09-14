import EvolutionModel
import Foundation

extension Predicate<Proposal> {
    static func predicate(_ mode: ProposalListMode, _ states: [ReviewState: Bool]) -> Predicate<Proposal> {
        let states = Set(states.lazy.filter(\.value).map(\.key.rawValue))
        /// Predicate limiting results to the selected states and optional bookmark filter.
        switch mode {
        case .all:
            return #Predicate { proposal in
                states.contains(proposal.status.state.rawValue)
            }
        case .bookmark:
            return #Predicate { proposal in
                states.contains(proposal.status.state.rawValue) && (proposal.bookmark != nil)
            }
        case .search(let text):
            return text.isEmpty ? Predicate<Proposal>.true : #Predicate { proposal in
                proposal.title.contains(text) ||
                proposal.proposalID.contains(text) ||
                proposal.status.state.title.contains(text)
            }
        }
    }
}
