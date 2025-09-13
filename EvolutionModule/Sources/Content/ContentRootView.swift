import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

public struct ContentRootView: View {
    @Environment(ContentViewModel.self) private var viewModel

    /// Trigger used to re-fetch proposal data.
    @State private var refresh: UUID?

    @State private var searchText = ""

    public init () {}

    public var body: some View {
        TabView {
            Tab("Proposal", systemImage: "swift") {
                ContentView()
            }
            Tab("Bookmark", systemImage: "bookmark") {
                ContentView(mode: .bookmark)
            }
            Tab(role: .search) {
                ContentView(mode: .search(searchText))
                    .searchable(text: $searchText)
            }
        }
        .overlay {
            ErrorView(error: viewModel.fetchError, $refresh)
        }
        .task(id: refresh) {
            await viewModel.fetchProposals()
        }
        .tint(.orange)
    }
}

// MARK: - Preview

#Preview(traits: .evolution) {
    @Previewable @Environment(\.modelContext) var context
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
