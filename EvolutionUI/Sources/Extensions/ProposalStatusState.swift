import EvolutionModel
import SwiftUI

extension ReviewState {
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
        case .unknown:
            .gray
        }
    }
}

extension EnvironmentValues {
    /// Environment value storing the set of currently selected proposal states.
    @Entry public var selectedStatus: Set<ReviewState> = .init(ReviewState.allCases)
}
