import MarkdownUI
import Splash
import SwiftUI

/// Displays a stylized code block with copy-to-clipboard support.
public struct MyCodeBlock: View {
    /// Current color scheme used to select the syntax highlighting theme.
    @Environment(\.colorScheme) private var colorScheme
    @State private var copied: CopiedCode?

    var configuration: CodeBlockConfiguration

    public init(configuration: CodeBlockConfiguration) {
        self.configuration = configuration
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

    public var body: some View {
        VStack(spacing: 0) {
            headerView()

            Divider()

            ScrollView(.horizontal) {
                configuration.label
                    .relativeLineSpacing(.em(0.25))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding()
            }
        }
        .background {
            Color(.secondarySystemBackground)
        }
        .clipShape(.rect(cornerRadius: 8))
        .markdownMargin(top: .zero, bottom: .em(0.8))
        .preference(key: CopiedCode.self, value: copied)
    }

    @ViewBuilder
    func headerView() -> some View {
        HStack {
            Text(configuration.language ?? "plain text")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(Color(theme.plainTextColor))
            Spacer()

            Button {
                copyToClipboard(configuration.content)
            } label: {
                Image(systemName: "clipboard")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background {
            Color(theme.backgroundColor)
        }
    }

    private func copyToClipboard(_ string: String) {
        #if os(macOS)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(string, forType: .string)
        #elseif os(iOS)
            UIPasteboard.general.string = string
        #endif
        copied = CopiedCode(code: string)
    }
}

/// Represents a block of code that was copied to the clipboard.
public struct CopiedCode: PreferenceKey, Hashable, Identifiable {
    public var id = UUID()
    public var code: String

    public init(id: UUID = UUID(), code: String) {
        self.id = id
        self.code = code
    }

    public static var defaultValue: CopiedCode? { nil }

    public static func reduce(value: inout CopiedCode?, nextValue: () -> CopiedCode?) {
        value = nextValue()
    }
}

extension View {
    public func onCopyToClipboard(perform: @escaping (_ code: CopiedCode) async -> Void)
        -> some View
    {
        onPreferenceChange(CopiedCode.self) { code in
            if let code {
                Task {
                    await perform(code)
                }
            }
        }
    }
}
