import Foundation
import SwiftData

// MARK: - Markdown

@Model
public final class Markdown {
    #Unique<Markdown>([\.url, \.proposalID])
    /// The remote URL pointing to the markdown file.
    @Attribute(.unique) public private(set) var url: URL
    /// The proposal identifier, such as "SE-0001".
    @Attribute(.unique) public private(set) var proposalID: String
    /// Raw markdown text, populated after ``fetch()`` is called.
    public var text: String?

    init(url: URL, proposalID: String, text: String? = nil) {
        self.url = url
        self.proposalID = proposalID
        self.text = text
    }

    public var snapshot: Snapshot {
        .init(object: self)
    }
}

public extension Markdown {
    struct Snapshot: Hashable, Codable, Sendable {
        public var persistentModelID: PersistentIdentifier?
        public var url: URL
        public var proposalID: String
        public var text: String?

        init(object: Markdown) {
            persistentModelID = object.persistentModelID
            url = object.url
            proposalID = object.proposalID
            text = object.text
        }
    }
}
