import Foundation
import Markdown
import Translation

extension Locale.Language {
    /// English language code.
    public static var english: Self { .init(identifier: "en") }
    /// Japanese language code.
    public static var japanese: Self { .init(identifier: "ja") }
}

/// Utility that prints internal links found in markdown documents.
public struct LinkReader: MarkupWalker {
    public mutating func visitLink(_ link: Link) {
        guard let components = URLComponents(string: link.destination!) else {
            return
        }

        switch (components.host, components.scheme, components.path) {
        case (nil, nil, "") where components.fragment?.isEmpty == false:
            if let text = link.children.lazy.compactMap({ $0 as? Text }).first.map(\.plainText) {
                print("🐰 \(text) 🦁 \(link.destination ?? "")")
            }
        default:
            break
        }
        defaultVisit(link)
    }

    public init() {}
}

/// Performs translation of markdown content between locales.
public actor MarkdownTranslator {
    private typealias Rewriter = TranslatingMarkupRewriter
    private var source: Locale.Language
    private var target: Locale.Language

    /// Creates a translator specifying source and target languages.
    public init(source: Locale.Language = .english, target: Locale.Language = .japanese) {
        self.source = source
        self.target = target
    }

    /// Returns the translated markdown as a single string.
    public func translate(markdown: String) async throws -> String {
        let document = Document(parsing: markdown)
        var rewriter = MarkupTranslator(source: source, target: target)
        return try await rewriter.visit(document)?.format() ?? ""
    }

    /// Streams translated markdown as it is produced.
    public func translate(markdown: String) -> AsyncThrowingStream<String, any Error> {
        AsyncThrowingStream { continuation in
            Task.detached(priority: .medium) { [self] in
                let document = Document(parsing: markdown)
                var rewriter = await TranslatingMarkupRewriter(
                    root: document,
                    source: source,
                    target: target
                ) { markdown in
                    continuation.yield(markdown)
                }
                do {
                    try await rewriter.visit(document)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

/// Synchronously rewrites markup by translating each text fragment.
public struct MarkupTranslator: AsyncMarkupRewriter {
    private let translator: TranslationSession

    public init(source: Locale.Language, target: Locale.Language) {
        self.translator = TranslationSession(installedSource: source, target: target)
    }

    public mutating func visitText(_ text: Text) async throws -> (any Markup)? {
        try await Text(translator.translate(text.string).targetText)
    }
}

/// Asynchronously rewrites markup and notifies a callback with each replacement.
struct TranslatingMarkupRewriter: AsyncMarkupRewriter {
    private let translator: TranslationSession

    private var root: Markup {
        didSet {
            onReplace?(root.format())
        }
    }

    private let onReplace: ((String) -> Void)?

    init(
        root: Markup,
        source: Locale.Language,
        target: Locale.Language,
        onReplace: ((String) -> Void)? = nil
    ) {
        self.translator = TranslationSession(installedSource: source, target: target)
        self.root = root
        self.onReplace = onReplace
    }

    mutating func visitText(_ text: Text) async throws -> (any Markup)? {
        let translated = try await Text(translator.translate(text.string).targetText)
        root = replace(in: root, original: text, translated: translated)
        return translated
    }

    private mutating func replace(in markup: Markup, original: Markup, translated: Markup) -> Markup
    {
        switch (markup, original) {
        case (let lhs as Text, let rhs as Text) where lhs.string == rhs.string:
            translated
        default:
            // Traverse child nodes and attempt replacement recursively
            markup.withUncheckedChildren(
                markup.children.map {
                    replace(in: $0, original: original, translated: translated)
                }
            )
        }
    }
}

// MARK: - AsyncMarkupVisitor

protocol AsyncMarkupVisitor: MarkupVisitor {
    mutating func defaultVisit(_ markup: AsyncMarkup) async throws -> Result
    mutating func visit(_ markup: AsyncMarkup) async throws -> Result
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) async throws -> Result
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) async throws -> Result
    mutating func visitCustomBlock(_ customBlock: CustomBlock) async throws -> Result
    mutating func visitDocument(_ document: Document) async throws -> Result
    mutating func visitHeading(_ heading: Heading) async throws -> Result
    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) async throws -> Result
    mutating func visitHTMLBlock(_ html: HTMLBlock) async throws -> Result
    mutating func visitListItem(_ listItem: ListItem) async throws -> Result
    mutating func visitOrderedList(_ orderedList: OrderedList) async throws -> Result
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) async throws -> Result
    mutating func visitParagraph(_ paragraph: Paragraph) async throws -> Result
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) async throws -> Result
    mutating func visitInlineCode(_ inlineCode: InlineCode) async throws -> Result
    mutating func visitCustomInline(_ customInline: CustomInline) async throws -> Result
    mutating func visitEmphasis(_ emphasis: Emphasis) async throws -> Result
    mutating func visitImage(_ image: Image) async throws -> Result
    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) async throws -> Result
    mutating func visitLineBreak(_ lineBreak: LineBreak) async throws -> Result
    mutating func visitLink(_ link: Link) async throws -> Result
    mutating func visitSoftBreak(_ softBreak: SoftBreak) async throws -> Result
    mutating func visitStrong(_ strong: Strong) async throws -> Result
    mutating func visitText(_ text: Text) async throws -> Result
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) async throws -> Result
    mutating func visitTable(_ table: Table) async throws -> Result
    mutating func visitTableHead(_ tableHead: Table.Head) async throws -> Result
    mutating func visitTableBody(_ tableBody: Table.Body) async throws -> Result
    mutating func visitTableRow(_ tableRow: Table.Row) async throws -> Result
    mutating func visitTableCell(_ tableCell: Table.Cell) async throws -> Result
    mutating func visitSymbolLink(_ symbolLink: SymbolLink) async throws -> Result
    mutating func visitInlineAttributes(_ attributes: InlineAttributes) async throws -> Result
    mutating func visitDoxygenDiscussion(_ doxygenDiscussion: DoxygenDiscussion) async throws
        -> Result
    mutating func visitDoxygenNote(_ doxygenNote: DoxygenNote) async throws -> Result
    mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) async throws -> Result
    mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) async throws -> Result
}

extension AsyncMarkupVisitor {
    @discardableResult mutating func visit(_ markup: AsyncMarkup) async throws -> Result {
        try await markup.accept(&self)
    }
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) async throws -> Result {
        try await defaultVisit(blockQuote)
    }
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) async throws -> Result {
        try await defaultVisit(codeBlock)
    }
    mutating func visitCustomBlock(_ customBlock: CustomBlock) async throws -> Result {
        try await defaultVisit(customBlock)
    }
    mutating func visitDocument(_ document: Document) async throws -> Result {
        try await defaultVisit(document)
    }
    mutating func visitHeading(_ heading: Heading) async throws -> Result {
        try await defaultVisit(heading)
    }
    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) async throws -> Result {
        try await defaultVisit(thematicBreak)
    }
    mutating func visitHTMLBlock(_ html: HTMLBlock) async throws -> Result {
        try await defaultVisit(html)
    }
    mutating func visitListItem(_ listItem: ListItem) async throws -> Result {
        try await defaultVisit(listItem)
    }
    mutating func visitOrderedList(_ orderedList: OrderedList) async throws -> Result {
        try await defaultVisit(orderedList)
    }
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) async throws -> Result {
        try await defaultVisit(unorderedList)
    }
    mutating func visitParagraph(_ paragraph: Paragraph) async throws -> Result {
        try await defaultVisit(paragraph)
    }
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) async throws -> Result {
        try await defaultVisit(blockDirective)
    }
    mutating func visitInlineCode(_ inlineCode: InlineCode) async throws -> Result {
        try await defaultVisit(inlineCode)
    }
    mutating func visitCustomInline(_ customInline: CustomInline) async throws -> Result {
        try await defaultVisit(customInline)
    }
    mutating func visitEmphasis(_ emphasis: Emphasis) async throws -> Result {
        try await defaultVisit(emphasis)
    }
    mutating func visitImage(_ image: Image) async throws -> Result {
        try await defaultVisit(image)
    }
    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) async throws -> Result {
        try await defaultVisit(inlineHTML)
    }
    mutating func visitLineBreak(_ lineBreak: LineBreak) async throws -> Result {
        try await defaultVisit(lineBreak)
    }
    mutating func visitLink(_ link: Link) async throws -> Result {
        try await defaultVisit(link)
    }
    mutating func visitSoftBreak(_ softBreak: SoftBreak) async throws -> Result {
        try await defaultVisit(softBreak)
    }
    mutating func visitStrong(_ strong: Strong) async throws -> Result {
        try await defaultVisit(strong)
    }
    mutating func visitText(_ text: Text) async throws -> Result {
        try await defaultVisit(text)
    }
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) async throws -> Result {
        try await defaultVisit(strikethrough)
    }
    mutating func visitTable(_ table: Table) async throws -> Result {
        try await defaultVisit(table)
    }
    mutating func visitTableHead(_ tableHead: Table.Head) async throws -> Result {
        try await defaultVisit(tableHead)
    }
    mutating func visitTableBody(_ tableBody: Table.Body) async throws -> Result {
        try await defaultVisit(tableBody)
    }
    mutating func visitTableRow(_ tableRow: Table.Row) async throws -> Result {
        try await defaultVisit(tableRow)
    }
    mutating func visitTableCell(_ tableCell: Table.Cell) async throws -> Result {
        try await defaultVisit(tableCell)
    }
    mutating func visitSymbolLink(_ symbolLink: SymbolLink) async throws -> Result {
        try await defaultVisit(symbolLink)
    }
    mutating func visitInlineAttributes(_ attributes: InlineAttributes) async throws -> Result {
        try await defaultVisit(attributes)
    }
    mutating func visitDoxygenDiscussion(_ doxygenDiscussion: DoxygenDiscussion) async throws
        -> Result
    {
        try await defaultVisit(doxygenDiscussion)
    }
    mutating func visitDoxygenNote(_ doxygenNote: DoxygenNote) async throws -> Result {
        try await defaultVisit(doxygenNote)
    }
    mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) async throws -> Result {
        try await defaultVisit(doxygenParam)
    }
    mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) async throws -> Result {
        try await defaultVisit(doxygenReturns)
    }
}

// MARK: - AsyncMarkupWalker

protocol AsyncMarkupWalker: AsyncMarkupVisitor, MarkupWalker {}

extension AsyncMarkupWalker {
    mutating func descendInto(_ markup: AsyncMarkup) async throws {
        for child in markup.children {
            if let child = child as? AsyncMarkup {
                try await visit(child)
            } else {
                visit(child)
            }
        }
    }
    mutating func defaultVisit(_ markup: AsyncMarkup) async throws {
        try await descendInto(markup)
    }
}

extension HTMLFormatter: AsyncMarkupWalker {}
extension MarkupFormatter: AsyncMarkupWalker {}

// MARK: - AsyncMarkupRewriter

protocol AsyncMarkupRewriter: AsyncMarkupVisitor, MarkupRewriter {}

extension AsyncMarkupRewriter {
    public mutating func defaultVisit(_ markup: AsyncMarkup) async throws -> Markup? {
        var newChildren: [any Markup] = []
        for child in markup.children {
            if let visited = try await transform(child) {
                newChildren.append(visited)
            }
        }
        return markup.withUncheckedChildren(newChildren)
    }

    private mutating func transform(_ child: any Markup) async throws -> (any Markup)? {
        if let child = child as? (any AsyncMarkup) {
            try await visit(child)
        } else {
            visit(child)
        }
    }
}

// MARK: - AsyncMarkup

protocol AsyncMarkup: Markup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result
}

// MARK: - AsyncMarkup

extension BlockDirective: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitBlockDirective(self)
    }
}
extension BlockQuote: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitBlockQuote(self)
    }
}
extension CodeBlock: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitCodeBlock(self)
    }
}
extension CustomBlock: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitCustomBlock(self)
    }
}
extension CustomInline: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitCustomInline(self)
    }
}
extension Document: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitDocument(self)
    }
}
extension DoxygenDiscussion: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitDoxygenDiscussion(self)
    }
}
extension DoxygenNote: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitDoxygenNote(self)
    }
}
extension DoxygenParameter: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitDoxygenParameter(self)
    }
}
extension DoxygenReturns: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitDoxygenReturns(self)
    }
}
extension Emphasis: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitEmphasis(self)
    }
}
extension HTMLBlock: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitHTMLBlock(self)
    }
}
extension Heading: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitHeading(self)
    }
}
extension Image: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitImage(self)
    }
}
extension InlineAttributes: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitInlineAttributes(self)
    }
}
extension InlineCode: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitInlineCode(self)
    }
}
extension InlineHTML: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitInlineHTML(self)
    }
}
extension LineBreak: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitLineBreak(self)
    }
}
extension Link: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitLink(self)
    }
}
extension ListItem: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitListItem(self)
    }
}
extension OrderedList: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitOrderedList(self)
    }
}
extension Paragraph: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitParagraph(self)
    }
}
extension SoftBreak: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitSoftBreak(self)
    }
}
extension Strikethrough: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitStrikethrough(self)
    }
}
extension Strong: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitStrong(self)
    }
}
extension SymbolLink: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitSymbolLink(self)
    }
}
extension Table: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitTable(self)
    }
}
extension Table.Body: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitTableBody(self)
    }
}
extension Table.Cell: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitTableCell(self)
    }
}
extension Table.Head: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitTableHead(self)
    }
}
extension Table.Row: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitTableRow(self)
    }
}
extension Text: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitText(self)
    }
}
extension ThematicBreak: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitThematicBreak(self)
    }
}
extension UnorderedList: AsyncMarkup {
    func accept<V: AsyncMarkupVisitor>(_ visitor: inout V) async throws -> V.Result {
        try await visitor.visitUnorderedList(self)
    }
}
