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

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
    static var supportedModes: IntentModes { .foreground }

    @Parameter(title: "Active Reviews") var proposal: ProposalEntity

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

    nonisolated init(model: Proposal) {
        self.id = .init(rawValue: model.proposalID)
        self.proposalId = model.proposalID
        self.title = model.title
    }
}

// MARK: - ProposalQuery

struct ProposalQuery: EntityQuery {
    private let repository = ProposalRepository(
        modelContainer: EnvironmentResolver.modelContainer()
    )

    @MainActor
    func entities(for identifiers: [ProposalID]) async throws -> [ProposalEntity] {
        let ids = identifiers.map(\.id)
        return repository.find(by: ids).map(ProposalEntity.init(model:))
    }

    @MainActor
    func suggestedEntities() async throws -> [ProposalEntity] {
        activeReviews()
    }

    @MainActor
    func defaultResult() async -> ProposalEntity? {
        activeReviews().last
    }

    @MainActor
    private func activeReviews() -> [ProposalEntity] {
        repository.load(predicate: .states(.activeReview))
            .map(ProposalEntity.init(model:))
    }
}

// MARK: - ProposalID

nonisolated
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
