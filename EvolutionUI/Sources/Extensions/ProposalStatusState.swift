import EvolutionModel
import SwiftUI

extension Proposal.Status.State {
    /// Display color associated with each proposal status.
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

    /// `UIColor` variant used for UIKit-based components.
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
    /// Human-readable string for the optional status.
    public var label: String {
        switch self {
        case .some(let state):
            String(describing: state)
        case .none:
            String()
        }
    }

    /// Fallback color when a status may be `nil`.
    public var color: Color {
        switch self {
        case .some(let state):
            state.color
        case .none:
                .gray
        }
    }

    /// Fallback `UIColor` when a status may be `nil`.
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
    /// Environment value storing the set of currently selected proposal states.
    @Entry public var selectedStatus: Set<Proposal.Status.State> = .init(Proposal.Status.State.allCases)
}
