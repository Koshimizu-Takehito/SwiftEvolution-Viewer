import EvolutionModel
import EvolutionUI
import SwiftUI

// MARK: -
/// SplitView の Detail View
///
/// Detail View 側のナビゲーションスタックの管理を行う
struct ContentDetailView: View {
    /// 詳細画面のNavigationPath
    @State private var detailPath = NavigationPath()
    /// 表示する値
    let proposal: Proposal.Snapshot
    /// 水平サイズクラス
    let horizontal: UserInterfaceSizeClass?
    /// アクセントカラー（ ナビゲーションスタックにスタックされるごとに変更する ）
    @Binding var accentColor: Color?

    /// ModelContext
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack(path: $detailPath) {
            // Root
            detail(proposal: proposal)
        }
        .navigationDestination(for: Proposal.Snapshot.self) { proposal in
            // Destination
            detail(proposal: proposal)
        }
    }

    func detail(proposal: Proposal.Snapshot) -> some View {
        ProposalDetailView(path: $detailPath, proposal: proposal, modelContainer: context.container)
            .onChange(of: accentColor(proposal), initial: true) { _, color in
                accentColor = color
            }
    }

    func accentColor(_ proposal: Proposal.Snapshot) -> Color {
        Proposal.Status.State(proposal: proposal)?.color ?? .darkText
    }
}

#Preview(traits: .proposal) {
    ContentDetailView(
        proposal: .init(
            id: "SE-0418",
            link: "0418-inferring-sendable-for-methods.md",
            status: .init(state: ".accepted"),
            title: "Inferring Sendable for methods and key path literals"
        ),
        horizontal: .compact,
        accentColor: .constant(.green)
    )
}
