import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// ContentView
@MainActor
public struct ContentView {
    @Environment(\.horizontalSizeClass) private var horizontal
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// ナビゲーションバーの現在の色合い
    @State private var tint: Color?
    /// ブックマークでのフィルタ有無
    @AppStorage("isBookmarked") private var isBookmarked = false
    /// リスト取得エラー
    @State private var fetcherror: Error?
    /// リスト再取得トリガー
    @State private var refresh: UUID?
    /// すべてのプロポーザル
    @Query private var allProposals: [Proposal]
    /// 選択中のステータス
    @StatusFilter private var filter

    /// すべてのブックマーク
    @State private var bookmarks: [Proposal] = []
    /// リスト画面で選択された詳細画面のコンテンツ
    @State private var proposal: Proposal.Snapshot?

    private var detailTint: Binding<Color?> {
        switch horizontal {
        case .compact:
            return $tint
        default:
            return .constant(nil)
        }
    }

    private var barTint: Color? {
        switch horizontal {
        case .compact:
            return tint ?? .darkText
        default:
            return .darkText
        }
    }

    public init() {}
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        NavigationSplitView {
            // リスト画面
            ProposalListView(
                selection: $proposal,
                status: filter,
                isBookmarked: !bookmarks.isEmpty && isBookmarked
            )
            .environment(\.horizontalSizeClass, horizontal)
            .overlay { ErrorView(error: fetcherror, $refresh) }
            .toolbar { toolbar }
        } detail: {
            // 詳細画面
            if let proposal {
                ContentDetailView(
                    proposal: proposal,
                    horizontal: horizontal,
                    accentColor: detailTint
                )
                .id(proposal)
            }
        }
        .tint(barTint)
        .task(id: refresh) {
            fetcherror = nil
            do {
                try await ProposalRepository(modelContainer: context.container).fetch()
            } catch {
                if allProposals.isEmpty {
                    fetcherror = error
                }
            }
        }
        .animation(.default, value: bookmarks)
        .onChange(of: allProposals.filter { $0.bookmark != nil }, initial: true) {
            bookmarks = $1
        }
    }

    /// ツールバー
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if !bookmarks.isEmpty {
            ToolbarItem {
                BookmarkButton(isBookmarked: $isBookmarked)
                    .disabled(bookmarks.isEmpty)
                    .opacity(bookmarks.isEmpty ? 0 : 1)
                    .onChange(of: bookmarks.isEmpty) { _, isEmpty in
                        if isEmpty {
                            isBookmarked = false
                        }
                    }
                    .tint(.darkText)
            }
        }
        ToolbarSpacer()
        if !allProposals.isEmpty {
            ToolbarItem {
                ProposalStatusPicker()
                    .tint(.darkText)
            }
        }
    }
}

#Preview(traits: .proposal) {
    ContentView()
        .environment(\.colorScheme, .dark)
}

#Preview("Assistive access", traits: .proposal, .assistiveAccess) {
    ContentView()
        .environment(\.colorScheme, .dark)
}
