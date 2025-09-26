import Foundation

public struct GithubURL: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: URL

    public init(rawValue: URL) {
        self.rawValue = rawValue
    }

    public init(link: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = "/swiftlang/swift-evolution/blob/main/proposals"
        rawValue = components.url!.appending(path: link)
    }
}
