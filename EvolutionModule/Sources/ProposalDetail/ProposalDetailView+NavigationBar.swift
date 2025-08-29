import EvolutionUI
import SwiftUI

// MARK: - ProposalDetailView.NavigationBar

extension ProposalDetailView {
    @MainActor
    /// Toolbar content used within ``ProposalDetailView``.
    struct NavigationBar {
        /// Backing view model for the proposal detail screen.
        @Bindable var viewModel: ProposalDetailViewModel
    }
}

extension ProposalDetailView.NavigationBar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            BookmarkButton(isBookmarked: $viewModel.isBookmarked)
        }
        ToolbarSpacer()
        ToolbarItem {
            translateButton()
        }
    }
}

extension ProposalDetailView.NavigationBar {
    @ViewBuilder
    fileprivate func translateButton() -> some View {
        if !viewModel.translating {
            Button("Translate", systemImage: "character.bubble") {
                Task { try await viewModel.translate() }
            }
        } else {
            ZStack {
                Button("Translate", systemImage: "character.bubble") {}
                    .hidden()
                ProgressView()
            }
        }
    }
}
