import MarkdownUI
import Splash
import SwiftUI

public extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    /// Creates a Splash-based syntax highlighter with the given theme.
    static func splash(theme: Splash.Theme) -> Self {
        Self.init(theme: theme)
    }
}

/// Syntax highlighter leveraging the Splash library.
public struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let highlighter: SyntaxHighlighter<Format>

    public init(theme: Splash.Theme) {
        highlighter = SyntaxHighlighter(format: Format(theme: theme))
    }

    public func highlightCode(_ content: String, language: String?) -> Text {
        highlighter.highlight(content)
    }
}

extension SplashCodeSyntaxHighlighter {
    private struct Format: Splash.OutputFormat {
        private let theme: Splash.Theme

        init(theme: Splash.Theme) {
            self.theme = theme
        }

        func makeBuilder() -> Builder {
            Builder(theme: theme)
        }
    }

    private struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var string: AttributedString

        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.string = .init()
        }

        mutating func addToken(_ token: String, ofType type: TokenType) {
            var part = AttributedString(token)
            part.foregroundColor = theme.tokenColors[type] ?? theme.plainTextColor
            string += part
        }

        mutating func addPlainText(_ text: String) {
            var part = AttributedString(text)
            part.foregroundColor = theme.plainTextColor
            string += part
        }

        mutating func addWhitespace(_ whitespace: String) {
            string += AttributedString(whitespace)
        }

        func build() -> Text {
            Text(string)
        }
    }
}
