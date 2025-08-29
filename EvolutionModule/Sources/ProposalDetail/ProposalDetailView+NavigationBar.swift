import EvolutionUI
import SwiftUI

// MARK: - ProposalDetailView.NavigationBar

extension ProposalDetailView {
    @MainActor
    struct NavigationBar {
        /// ViewModel
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
            Button("翻訳", systemImage: "character.bubble") {
                Task { try await viewModel.translate() }
            }
        } else {
            ZStack {
                Button("翻訳", systemImage: "character.bubble") {}
                    .hidden()
                ProgressView()
            }
        }
    }
}
