import SwiftUI

#if os(macOS) || os(tvOS)
    /// Minimal shim for `NavigationBarItem` APIs on platforms that lack them.
    public struct NavigationBarItem {
        public enum TitleDisplayMode {
            case automatic
            case inline
            case large
        }
    }
#endif

extension View {
    @inline(__always)
    /// Cross-platform wrapper around `navigationBarTitleDisplayMode`.
    /// - Parameter displayMode: Desired title display mode on iOS.
    public func iOSNavigationBarTitleDisplayMode(_ displayMode: NavigationBarItem.TitleDisplayMode)
        -> some View
    {
        #if os(macOS) || os(tvOS)
            self
        #else
            navigationBarTitleDisplayMode(displayMode)
        #endif
    }
}
