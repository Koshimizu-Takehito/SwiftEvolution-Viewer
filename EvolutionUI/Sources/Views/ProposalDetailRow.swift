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

    /// Markdownのヘッダー行からHTMLのidスラッグを作る
    /// - Parameters:
    ///   - line: 例: "### `~Copyable` as logical negation"
    ///   - includeHash: 先頭に `#` を付ける（デフォルト true）
    /// - Returns: 例: "#copyable-as-logical-negation"
    private nonisolated static func htmlID(fromMarkdownHeader line: String, includeHash: Bool = true) -> String {
        // 1) 先頭の見出しマーカーを除去（0〜3個の空白 + #1〜6 + 空白）
        let headerPattern = #"^\s{0,3}#{1,6}\s+"#
        let textStart = line.replacingOccurrences(
            of: headerPattern,
            with: "",
            options: .regularExpression
        )

        // 2) バッククォートとかっこを除去（中身は残す）
        var s = textStart.replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        // 3) Unicode正規化（ローマ字化→ダイアクリティカル除去）
        //    例: "Café" -> "Cafe", 日本語は toLatin でローマ字化される場合あり
        if let latin = s.applyingTransform(.toLatin, reverse: false) {
            s = latin
        }
        s = s.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )

        // 4) 小文字化
        s = s.lowercased()

        // 5) 許可しない文字をハイフンに置換（英数以外はまとめて-）
        //    連続する非英数字は1つのハイフンに圧縮
        s = s.replacingOccurrences(
            of: #"[^a-z0-9]+"#,
            with: "-",
            options: .regularExpression
        )

        // 6) 前後のハイフンをトリム
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        // 7) 空ならフォールバック
        if s.isEmpty { s = "section" }

        return includeHash ? "#\(s)" : s
    }
}
