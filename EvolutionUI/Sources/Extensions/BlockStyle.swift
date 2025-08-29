import Markdown
import MarkdownUI
import Splash
import SwiftData
import SwiftUI

@MainActor
extension BlockStyle where Configuration == ListMarkerConfiguration {
    /// A list marker that displays a small filled circle.
    public static var customCircle: Self {
        BlockStyle { _ in
            Circle()
                .frame(width: 6, height: 6)
                .relativeFrame(minWidth: .zero, alignment: .trailing)
        }
    }

    /// A list marker that renders ordered list numbers with monospaced digits.
    public static var customDecimal: Self {
        BlockStyle { configuration in
            Text("\(configuration.itemNumber).")
                .monospacedDigit()
                .relativeFrame(minWidth: .zero, alignment: .trailing)
        }
    }
}
