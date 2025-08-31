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
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            ToolbarSpacer()
            ToolbarItem {
                translateButton()
            }
        }
    }
}

extension ProposalDetailView.NavigationBar {
    @ViewBuilder
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    /// Button that toggles translation of the proposal's markdown content.
    /// Displays a progress indicator while translation is in progress.
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
