import EvolutionModel
import EvolutionUI
import Markdown
import MarkdownUI
import Observation
import SafariServices
import Splash
import SwiftData
import SwiftUI

// MARK: - ProposalDetailView

/// Displays the full markdown contents of a single Swift Evolution proposal
/// and manages navigation to related proposals or sections within the
/// document.
@MainActor
struct ProposalDetailView {
    /// Navigation path for pushing additional proposal details.
    @Binding var path: NavigationPath

    /// Backing view model that loads markdown content.
    @State private var viewModel: ProposalDetailViewModel

    /// Trigger used to re-fetch markdown data.
    @State private var refresh: UUID?

    /// Recently copied code block to show in the HUD.
    @State private var copied: CopiedCode?

    /// Action used to open URLs from markdown links.
    @Environment(\.openURL) private var openURL

    init(path: Binding<NavigationPath>, proposal: Proposal.Snapshot, modelContainer: ModelContainer) {
        _path = path
        _viewModel = State(
            wrappedValue: ProposalDetailViewModel(
                proposal: proposal,
                modelContainer: modelContainer
            )
        )
    }
}

// MARK: - View

extension ProposalDetailView: View {
    var body: some View {
        ScrollViewReader { proxy in
            List {
                let items = viewModel.items
                ForEach(items) { item in
                    MarkdownUI.Markdown(item.markup)
                }
                .modifier(MarkdownStyleModifier())
                .opacity(items.isEmpty ? 0 : 1)
                .animation(viewModel.translating ? nil : .default, value: items)
                .environment(\.openURL, openURLAction(with: proxy))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .onCopyToClipboard { code in
                    withAnimation { copied = code }
                    try? await Task.sleep(for: .seconds(1))
                    withAnimation { copied = nil }
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 1)
        }
        .toolbar {
            NavigationBar(viewModel: viewModel)
        }
        .overlay {
            ErrorView(error: viewModel.fetchError) {
                refresh = .init()
            }
        }
        .overlay {
            CopiedHUD(copied: copied)
        }
        .task(id: refresh) {
            guard refresh != nil else { return }
            await viewModel.loadMarkdown()
        }
        .navigationTitle(viewModel.title)
        .iOSNavigationBarTitleDisplayMode(.inline)
        .tint(viewModel.tint)
    }
}

extension ProposalDetailView {
    /// Creates an ``OpenURLAction`` that interprets links inside the markdown
    /// content and routes them to the appropriate destination.
    fileprivate func openURLAction(with proxy: ScrollViewProxy) -> OpenURLAction {
        OpenURLAction { url in
            Task {
                switch await viewModel.makeURLAction(url: url) {
                case .scrollTo(let id):
                    withAnimation { proxy.scrollTo(id, anchor: .top) }
                case .showDetail(let proposal):
                    path.append(proposal)
                case .open:
                    showSafariView(url: url)
                }
            }
            return .discarded
        }
    }

    /// Presents web content in `SFSafariViewController` when available.
    @MainActor
    fileprivate func showSafariView(url: URL) {
        guard url.scheme?.contains(/^https?$/) == true else { return }
        #if os(macOS)
            NSWorkspace.shared.open(url)
        #elseif os(iOS)
            let safari = SFSafariViewController(url: url)
            UIApplication.shared
                .connectedScenes
                .lazy
                .compactMap { $0 as? UIWindowScene }
                .first?
                .keyWindow?
                .rootViewController?
                .show(safari, sender: self)
        #endif
    }
}

#Preview(traits: .proposal) {
    @Previewable @Environment(\.modelContext) var context
    NavigationStack {
        ProposalDetailView.init(
            path: .fake,
            proposal: .init(
                id: "SE-0418",
                link: "0418-inferring-sendable-for-methods.md",
                status: .init(state: ".accepted"),
                title: "Inferring Sendable for methods and key path literals"
            ),
            modelContainer: context.container
        )
    }
    .colorScheme(.dark)
}
