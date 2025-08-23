import EvolutionModel
import SwiftUI

@MainActor
public struct FilterCommands {
    @StatusFilter private var filter
    @AppStorage("isBookmarked") private var isBookmarked: Bool = false

    public init() {}
}

extension FilterCommands: Commands {
    public var body: some Commands {
        CommandMenu("フィルタ") {
            Divider()
            Menu("レビューの状態") {
                ForEach(0..<3, id: \.self) { index in
                    let option = Proposal.Status.State.allCases[index]
                    Toggle(option.description, isOn: $filter(option))
                    Toggle(option.description, isOn: .constant(false))
                        .keyboardShortcut(.init(Character("\(index + 1)")), modifiers: [.command])
                }

                Divider()

                Button("すべて選択する") {
                    let allCases = Proposal.Status.State.allCases
                    filter = .init(uniqueKeysWithValues: allCases.map { ($0, true) })
                }
                .disabled(filter.values.allSatisfy(\.self))
                .keyboardShortcut("A", modifiers: [.command, .shift])

                Button("すべて非選択にする") {
                    filter = [:]
                }
                .disabled(filter.values.allSatisfy { !$0 })
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }
            Divider()

            Toggle("ブックマークのみ表示する", isOn: $isBookmarked)
                .keyboardShortcut("B", modifiers: [.command, .shift])
        }
    }
}
