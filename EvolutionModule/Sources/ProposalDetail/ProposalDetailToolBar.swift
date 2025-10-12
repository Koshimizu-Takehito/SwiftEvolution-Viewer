import EvolutionUI
import SwiftUI

// MARK: - ProposalDetailToolBar

/// Toolbar content used within ``ProposalDetailView``.
struct ProposalDetailToolBar: ToolbarContent {
    /// Backing view model for the proposal detail screen.
    @Bindable var viewModel: ProposalDetailViewModel

    var body: some ToolbarContent {
        ToolbarItem {
            Menu("Menu", systemImage: "ellipsis") {
                OpenSafariButton(proposal: viewModel.proposal)
                BookmarkButton(isBookmarked: $viewModel.isBookmarked)
                TranslateButton(isTranslating: viewModel.translating, action: viewModel.translate)
            }
        }
    }
}
