import AppIntents
import EvolutionModel
import EvolutionModule
import SwiftData
import SwiftUI

// MARK: - AppShortcutsProvider

struct AppShortcutsProvider: AppIntents.AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor { .orange }

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ProposalIntent(),
            phrases: ["\(.applicationName)で検索する"],
            shortTitle: "Active Reviews",
            systemImageName: "swift"
        )
    }
}

// MARK: - ProposalIntent

struct ProposalIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Proposal" }
    static var openAppWhenRun: Bool { true }
    static var supportedModes: IntentModes { .foreground }

    @Parameter(title: "Active Reviews") var proposal: ProposalEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults.standard
        let tab = ContentRootTab.proposal.rawValue
        defaults.set(tab, forKey: "ContentRootView.selection")
        defaults.set(proposal.proposalId, forKey: "ContentView.\(ProposalListMode.all).selectedId")
        return .result()
    }
}

// MARK: - ProposalEntity

struct ProposalEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Active Reviews"
    static let defaultQuery = ProposalQuery()

    var id: ProposalID
    @Property(title: "Id") var proposalId: String
    @Property(title: "Title") var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(proposalId) \(title)")
    }

    nonisolated init(model: Proposal.Snapshot) {
        self.id = .init(rawValue: model.id)
        self.proposalId = model.id
        self.title = model.title
    }
}

// MARK: - ProposalQuery

struct ProposalQuery: EntityQuery {
    private let repository = ProposalRepository(
        modelContainer: EnvironmentResolver.modelContainer()
    )

    @concurrent func entities(for identifiers: [ProposalID]) async throws -> [ProposalEntity] {
        let ids = identifiers.map(\.id)
        return await repository.find(by: ids).map(ProposalEntity.init(model:))
    }

    @concurrent func suggestedEntities() async throws -> [ProposalEntity] {
        await activeReviews()
    }

    @concurrent func defaultResult() async -> ProposalEntity? {
        await activeReviews().last
    }

    private func activeReviews() async -> [ProposalEntity] {
        await repository.load(predicate: .states(.activeReview))
            .map(ProposalEntity.init(model:))
    }
}

// MARK: - ProposalID

struct ProposalID: EntityIdentifierConvertible, RawRepresentable, Hashable, Identifiable, Sendable, CustomStringConvertible {
    var rawValue: String

    var id: String { rawValue }

    var description: String { rawValue }

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    var entityIdentifierString: String {
        rawValue
    }

    static func entityIdentifier(for identifier: String) -> ProposalID? {
        self.init(rawValue: identifier)
    }
}
