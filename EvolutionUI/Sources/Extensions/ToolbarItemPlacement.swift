import SwiftUI

extension ToolbarItemPlacement {
    /// Toolbar placement used on the primary side of a split view.
    public static var content: Self {
        #if os(macOS)
            .automatic
        #elseif os(iOS)
            .topBarTrailing
        #endif
    }
}
