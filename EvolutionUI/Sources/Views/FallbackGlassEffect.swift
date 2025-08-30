import SwiftUI

public struct FallbackGlassEffect<S: Shape>: ViewModifier {
    var shape: S

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            content.glassEffect(in: shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }
}

public extension View {
    func fallbackGlassEffect<S: Shape>(shape: S) -> some View {
        modifier(FallbackGlassEffect(shape: shape))
    }
}
