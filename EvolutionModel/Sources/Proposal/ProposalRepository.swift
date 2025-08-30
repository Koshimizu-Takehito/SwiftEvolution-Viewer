import Foundation
import SwiftData

// MARK: - ProposalRepository

/// Retrieves and persists proposal metadata from the Swift Evolution feed.
@ModelActor
public actor ProposalRepository: Sendable {
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
        let context = ModelContext(modelContainer)
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
        try? ModelContext(modelContainer)
            .fetch(.id(proposalID))
            .first
            .flatMap(Proposal.Snapshot.init(object:))
    }

    public func load(sortBy sortDescriptor: [SortDescriptor<Proposal>] = [.proposalID]) -> [Proposal.Snapshot] {
        do {
            return try ModelContext(modelContainer)
                .fetch(FetchDescriptor(predicate: .true, sortBy: sortDescriptor))
                .compactMap(Proposal.Snapshot.init(object:))
        } catch {
            return []
        }
    }
}

public extension SortDescriptor<Proposal> {
    static var proposalID: Self {
        SortDescriptor(\Proposal.proposalID, order: .reverse)
    }
}

private extension FetchDescriptor<Proposal> {
    /// Convenience helper for building a descriptor that looks up a proposal by ID.
    static func id(_ proposalID: String) -> Self {
        FetchDescriptor(predicate: #Predicate<Proposal> {
            $0.proposalID == proposalID
        })
    }
}
