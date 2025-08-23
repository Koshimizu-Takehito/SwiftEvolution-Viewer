import MarkdownUI
import Splash
import SwiftUI

/// マークダウンの設定
public struct MarkdownStyleModifier: ViewModifier {
    /// ColorScheme
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public func body(content: Content) -> some View {
        content
            .markdownBulletedListMarker(.customCircle)
            .markdownNumberedListMarker(.customDecimal)
            .markdownTextStyle(\.code) {
                FontFamilyVariant(.monospaced)
                FontSize(.em(0.85))
                ForegroundColor(Color(UIColor.label))
                BackgroundColor(Color(UIColor.label).opacity(0.2))
            }
            .markdownBlockStyle(\.blockquote) { configuration in
                configuration.label
                    .padding()
                    .markdownTextStyle {
                        FontCapsVariant(.lowercaseSmallCaps)
                        FontWeight(.semibold)
                        BackgroundColor(nil)
                    }
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color(UIColor.tintColor))
                            .frame(width: 4)
                    }
                    .background(Color(UIColor.tintColor).opacity(0.5))
            }
            .markdownBlockStyle(\.codeBlock) {
                MyCodeBlock(configuration: $0)
            }
            .markdownCodeSyntaxHighlighter(.splash(theme: theme))
    }

    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch colorScheme {
        case .dark:
            return .wwdc18(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }
}
