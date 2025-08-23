import EvolutionModel
import SwiftUI

extension Proposal.Status.State {
    public var color: Color {
        switch self {
        case .accepted:
            .green
        case .activeReview:
            .orange
        case .implemented:
            .blue
        case .previewing:
            .mint
        case .rejected:
            .red
        case .returnedForRevision:
            .purple
        case .withdrawn:
            .gray
        }
    }

    public var tintColor: UIColor {
        switch self {
        case .accepted:
            .systemGreen
        case .activeReview:
            .systemOrange
        case .implemented:
            .systemBlue
        case .previewing:
            .systemMint
        case .rejected:
            .systemRed
        case .returnedForRevision:
            .systemPurple
        case .withdrawn:
            .systemRed
        }
    }
}

extension Proposal.Status.State? {
    public var label: String {
        switch self {
        case .some(let state):
            String(describing: state)
        case .none:
            String()
        }
    }

    public var color: Color {
        switch self {
        case .some(let state):
            state.color
        case .none:
                .gray
        }
    }

    public var tintColor: UIColor {
        switch self {
        case .some(let state):
            state.tintColor
        case .none:
            .gray
        }
    }
}

extension EnvironmentValues {
    @Entry public var selectedStatus: Set<Proposal.Status.State> = .init(Proposal.Status.State.allCases)
}
