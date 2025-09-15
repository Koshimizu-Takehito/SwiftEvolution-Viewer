import Foundation

public enum ProposalListMode: Hashable, Sendable, RawRepresentable {
    case all
    case bookmark
    case search(String)

    public init(rawValue: String) {
        switch rawValue {
        case "all":
            self = .all
        case "bookmark":
            self = .bookmark
        case let text where text.hasPrefix("search:"):
            let query = String(text.dropFirst("search:".count))
            self = .search(query)
        default:
            fatalError("Unknown proposal list mode: \(rawValue)")
        }
    }

    public var rawValue: String {
        switch self {
        case .all:
            return "all"
        case .bookmark:
            return "bookmark"
        case .search(let query):
            return "search:\(query)"
        }
    }
}
