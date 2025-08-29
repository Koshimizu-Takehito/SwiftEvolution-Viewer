import Markdown
import EvolutionModel
import Foundation

/// A single row of formatted markdown in the proposal detail screen.
public struct ProposalDetailRow: Hashable, Identifiable {
    /// Identifier used for navigation and hashing.
    public var id: String
    /// HTML markup representing the row's contents.
    public var markup: String

    public init(id: String, markup: String) {
        self.id = id
        self.markup = markup
    }
}

extension [ProposalDetailRow] {
    /// Creates an array of rows by parsing the proposal's markdown document.
    public init(markdown: Markdown.Snapshot) {
        let markdownString = markdown.text ?? ""
        let document = Document(parsing: markdownString)
        var idCount = [String: Int]()
        self = document.children.enumerated().map { offset, content -> ProposalDetailRow in
            if let heading = content as? Heading {
                let heading = heading.format()
                let id = Self.htmlID(fromMarkdownHeader: heading)
                let count = idCount[id]
                let _ = {
                    idCount[id] = (count ?? 0) + 1
                }()
                return ProposalDetailRow(id: count.map { "\(id)-\($0)" } ?? id, markup: heading)
            } else {
                return ProposalDetailRow(id: "\(offset)", markup: content.format())
            }
        }
    }

    /// Generates an HTML `id` slug from a Markdown heading line.
    /// - Parameters:
    ///   - line: Example: "### `~Copyable` as logical negation"
    ///   - includeHash: Whether to prefix the slug with `#` (default is `true`).
    /// - Returns: Example: "#copyable-as-logical-negation"
    private nonisolated static func htmlID(fromMarkdownHeader line: String, includeHash: Bool = true) -> String {
        // 1) Remove leading heading markers (0-3 spaces + 1-6 # characters + space)
        let headerPattern = #"^\s{0,3}#{1,6}\s+"#
        let textStart = line.replacingOccurrences(
            of: headerPattern,
            with: "",
            options: .regularExpression
        )

        // 2) Remove backticks and parentheses but keep contents
        var s = textStart.replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        // 3) Unicode normalization (Romanization followed by diacritic removal)
        //    e.g., "Café" -> "Cafe"; Japanese may be romanized with `toLatin`
        if let latin = s.applyingTransform(.toLatin, reverse: false) {
            s = latin
        }
        s = s.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )

        // 4) Lowercase all characters
        s = s.lowercased()

        // 5) Replace disallowed characters with a hyphen
        //    Consecutive non-alphanumerics are collapsed into a single hyphen
        s = s.replacingOccurrences(
            of: #"[^a-z0-9]+"#,
            with: "-",
            options: .regularExpression
        )

        // 6) Trim leading and trailing hyphens
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        // 7) Fallback if the result is empty
        if s.isEmpty { s = "section" }

        return includeHash ? "#\(s)" : s
    }
}
