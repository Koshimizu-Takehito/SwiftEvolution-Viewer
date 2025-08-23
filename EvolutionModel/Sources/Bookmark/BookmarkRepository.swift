import Foundation
import SwiftData

// MARK: - BookmarkRepository

@ModelActor
public actor BookmarkRepository {
    public func snapshots() -> [Bookmark.Snapshot] {
        let modelContext = ModelContext(modelContainer)
        let result = try? modelContext.fetch(FetchDescriptor<Bookmark>(predicate: .true))
        return result?.map(Bookmark.Snapshot.init) ?? []
    }

    public func load(proposalID: String) -> Bookmark.Snapshot? {
        let descriptor = FetchDescriptor(predicate: #Predicate<Bookmark> {
            $0.proposalID == proposalID
        })
        let object = try? ModelContext(modelContainer)
            .fetch(descriptor)
            .first
        return object.flatMap(Bookmark.Snapshot.init(object:))
    }

    public func update(proposal: Proposal.Snapshot, isBookmarked: Bool) throws {
        if isBookmarked {
            try add(proposal: proposal)
        } else {
            try delete(proposal: proposal)
        }
    }

    private func add(proposal: Proposal.Snapshot) throws {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Proposal> { $0.proposalID == proposal.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        let proposal = try context.fetch(descriptor).first
        try context.transaction {
            if let proposal, proposal.bookmark == nil {
                context.insert(Bookmark(proposal: proposal))
            }
        }
    }

    private func delete(proposal: Proposal.Snapshot) throws {
        let descriptor = FetchDescriptor(predicate: #Predicate<Bookmark> {
            $0.proposalID == proposal.id
        })
        let context = ModelContext(modelContainer)
        try context.transaction {
            try context.fetch(descriptor).forEach { object in
                context.delete(object)
            }
        }
    }
}
