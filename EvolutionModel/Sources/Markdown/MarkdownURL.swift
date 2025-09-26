import Foundation

/// Converts proposal links into URLs that point directly to raw markdown files.
struct MarkdownURL: RawRepresentable, Codable, Hashable, Sendable {
    /// The fully qualified URL of the markdown document.
    let rawValue: URL

    /// Directly wraps an existing markdown URL.
    /// - Parameter rawValue: Fully qualified URL to a markdown document.
    init(rawValue: URL) {
        self.rawValue = rawValue
    }

    /// Creates a ``MarkdownURL`` from an existing GitHub page URL by converting
    /// it to the corresponding `raw.githubusercontent.com` location.
    /// - Parameter url: Standard GitHub URL to a markdown file.
    init(url: URL) {
        let host = "raw.githubusercontent.com"
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        component.host = host
        component.path = component.path.replacingOccurrences(of: "/blob", with: "")
        self.rawValue = component.url!
    }

    /// Creates a ``MarkdownURL`` for a proposal using its link value from the
    /// proposal feed.
    /// - Parameter link: The path portion of the proposal URL.
    init(link: String) {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "raw.githubusercontent.com"
        component.path = "/swiftlang/swift-evolution/main/proposals/\(link)"
        self.rawValue = component.url!
    }
}
