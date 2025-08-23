import Foundation
import SwiftData

// MARK: - ProposalRepository

@ModelActor
public actor ProposalRepository {
    /// Top-level structure of the `evolution.json` feed.
    private struct V1: Decodable {
        /// All proposals listed in the feed.
        let proposals: [Proposal.Snapshot]
    }

    /// Location of the JSON feed describing all proposals.
    private var url: URL {
        URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json")!
    }

    @discardableResult
    public func fetch() async throws -> [Proposal.Snapshot] {
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
        return try context.fetch(FetchDescriptor(predicate: .true))
            .compactMap(Proposal.Snapshot.init)
    }

    public func find(by proposalID: String) -> Proposal.Snapshot? {
        try? ModelContext(modelContainer)
            .fetch(.id(proposalID))
            .first
            .flatMap(Proposal.Snapshot.init(object:))
    }
}

private extension FetchDescriptor<Proposal> {
    static func id(_ proposalID: String) -> Self {
        FetchDescriptor(predicate: #Predicate<Proposal> {
            $0.proposalID == proposalID
        })
    }
}
