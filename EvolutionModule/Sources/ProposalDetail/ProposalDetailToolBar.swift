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
                if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
                    TranslateButton(isTranslating: viewModel.translating, action: viewModel.translate)
                }
            }
        }
    }
}
