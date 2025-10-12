import Foundation
import SwiftData

// MARK: - ProposalRepository

/// Retrieves and persists proposal metadata from the Swift Evolution feed.
@ModelActor
public actor ProposalRepository: Observable {
    /// Top-level structure of the `evolution.json` feed.
    private struct V1: Decodable {
        /// All proposals listed in the feed.
        let proposals: [Proposal.Snapshot]
    }

    /// Location of the JSON feed describing all proposals.
    private var url: URL {
        URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json")!
    }

    /// Downloads the proposal feed and stores the results.
    /// - Returns: An array of stored proposal snapshots.
    @discardableResult
    public func fetch(sortBy sortDescriptor: [SortDescriptor<Proposal>] = [.proposalID]) async throws -> [Proposal.Snapshot] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let snapshots = try JSONDecoder().decode(V1.self, from: data).proposals
        let context = modelContext
        try context.transaction {
            snapshots.forEach { proposal in
                if let object = try? context.fetch(.id(proposal.id)).first {
                    object.update(with: proposal)
                } else {
                    context.insert(Proposal(snapshot: proposal))
                }
            }
        }
        return try context.fetch(FetchDescriptor(predicate: .true, sortBy: sortDescriptor))
            .compactMap(Proposal.Snapshot.init)
    }

    /// Finds a proposal by its identifier if it exists in storage.
    /// - Parameter proposalID: The proposal identifier to search for.
    public func find(by proposalID: String) -> Proposal.Snapshot? {
        try? modelContext
            .fetch(.id(proposalID))
            .first
            .flatMap(Proposal.Snapshot.init(object:))
    }

    public func find(by proposalIDs: some Sequence<String>) -> [Proposal.Snapshot] {
        let results = try? modelContext
            .fetch(.ids(proposalIDs))
            .compactMap(Proposal.Snapshot.init(object:))
        return results ?? []
    }

    /// Loads any proposals already stored in the local database.
    /// - Parameter sortDescriptor: Ordering to apply to the returned results.
    /// - Returns: An array of proposal snapshots from persistent storage.
    public func load(
        predicate: Predicate<Proposal> = .true,
        sortBy sortDescriptor: [SortDescriptor<Proposal>] = [.proposalID]
    ) -> [Proposal.Snapshot] {
        do {
            return try modelContext
                .fetch(FetchDescriptor(predicate: predicate, sortBy: sortDescriptor))
                .compactMap(Proposal.Snapshot.init(object:))
        } catch {
            return []
        }
    }
}
