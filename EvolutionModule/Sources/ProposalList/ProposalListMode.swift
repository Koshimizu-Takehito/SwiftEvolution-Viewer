import Foundation

public enum ProposalListMode: Hashable, Sendable {
    case all
    case bookmark
    case search(String)
}
