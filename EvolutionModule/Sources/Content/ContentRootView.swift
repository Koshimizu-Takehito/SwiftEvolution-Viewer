import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

public enum ContentRootTab: String, CaseIterable, Sendable {
    case proposal, bookmark, search

    public static var `default`: Self { .proposal }

    var role: TabRole? {
        switch self {
        case .proposal, .bookmark:
            nil
        case .search:
            .search
        }
    }
}

public struct ContentRootView: View {
    @Environment(ContentViewModel.self) private var viewModel
    @AppStorage("ContentRootView.selection") private var selection: ContentRootTab = .default

    /// Trigger used to re-fetch proposal data.
    @State private var refresh: UUID?

    @State private var searchText = ""

    public init() {}

    public var body: some View {
        TabView(selection: $selection) {
            ForEach(ContentRootTab.allCases, id: \.self) { tab in
                Tab(value: tab, role: tab.role) {
                    content(for: tab)
                } label: {
                    label(for: tab)
                }
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

private extension ContentRootView {
    @ViewBuilder
    func content(for tab: ContentRootTab) -> some View {
        switch tab {
        case .proposal:
            ContentView()
        case .bookmark:
            ContentView(mode: .bookmark)
        case .search:
            ContentView(mode: .search(searchText))
                .searchable(text: $searchText)
        }
    }

    @ViewBuilder
    func label(for tab: ContentRootTab) -> some View {
        switch tab {
        case .proposal:
            Label("Proposal", systemImage: "swift")
        case .bookmark:
            Label("Bookmark", systemImage: "bookmark")
        case .search:
            Label("Search", systemImage: "magnifyingglass")
        }
    }
}

// MARK: - Preview

#Preview(traits: .evolution) {
    @Previewable @Environment(\.modelContext) var context
    ContentRootView()
        .environment(\.colorScheme, .dark)
}
