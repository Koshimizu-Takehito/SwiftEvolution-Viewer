import Foundation
import SwiftData

// MARK: - Markdown

/// Represents the markdown content for a specific Swift Evolution proposal.
///
/// Each instance tracks the remote source URL, the proposal identifier, and
/// optionally the fetched markdown text.
@Model
public final class Markdown {
    #Unique<Markdown>([\.url, \.proposalID])

    /// The remote URL pointing to the markdown file.
    @Attribute(.unique) public private(set) var url: URL

    /// The proposal identifier, such as "SE-0001".
    @Attribute(.unique) public private(set) var proposalID: String

    /// Raw markdown text, populated after the file is fetched.
    public var text: String?

    /// Creates a new markdown record.
    /// - Parameters:
    ///   - url: Location of the markdown file.
    ///   - proposalID: Identifier for the proposal this markdown belongs to.
    ///   - text: Optional markdown string if already loaded.
    init(url: URL, proposalID: String, text: String? = nil) {
        self.url = url
        self.proposalID = proposalID
        self.text = text
    }

    /// A snapshot representation of this model used for value semantics.
    public var snapshot: Snapshot {
        .init(object: self)
    }
}

public extension Markdown {
    /// Immutable representation of a ``Markdown`` model.
    struct Snapshot: Hashable, Codable, Sendable {
        /// Identifier of the underlying model object, if persisted.
        public var persistentModelID: PersistentIdentifier?

        /// Remote location of the markdown file.
        public var url: URL

        /// The related proposal's identifier.
        public var proposalID: String

        /// Markdown text if it has been fetched.
        public var text: String?

        /// Creates a snapshot from a ``Markdown`` instance.
        init(object: Markdown) {
            persistentModelID = object.persistentModelID
            url = object.url
            proposalID = object.proposalID
            text = object.text
        }
    }
}
