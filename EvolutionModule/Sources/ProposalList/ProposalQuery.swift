import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ProposalQuery

@MainActor
struct ProposalQuery: DynamicProperty {
    /// Currently selected status filter.
    @StatusFilter var reviewStates: [ReviewState : Bool]

    @SceneStorage var sortKey: ProposalSortKey = .proposalID

    var mode: ProposalListMode = .all
}

private extension ProposalQuery {
    var filter: Predicate<Proposal> {
        let states = Set(reviewStates.lazy.filter(\.value).map(\.key.rawValue))
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
            return text.isEmpty ? Predicate.true : #Predicate { proposal in
                proposal.title.contains(text) ||
                proposal.proposalID.contains(text) ||
                proposal.status.state.title.contains(text)
            }
        }
    }

    var sort: [SortDescriptor<Proposal>] {
        switch sortKey {
        case .proposalID:
            return [SortDescriptor(\.proposalID, order: .reverse)]
        case .reviewStatus:
            return [
                SortDescriptor(\.status.state.order),
                SortDescriptor(\.status.version.code, order: .reverse),
                SortDescriptor(\.proposalID, order: .reverse)
            ]
        }
    }
}

extension Query<Proposal, [Proposal]> {
    init(_ query: ProposalQuery) {
        self = Query(filter: query.filter, sort: query.sort)
    }
}
