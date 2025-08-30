import SwiftUI

/// Applies a glass-like material, falling back to ``.ultraThinMaterial`` on
/// platforms where the native ``View.glassEffect(in:)`` modifier is
/// unavailable.
public struct FallbackGlassEffect<S: Shape>: ViewModifier {
    /// Shape that defines the region of the glass effect.
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
    /// Wraps the view in a platform-appropriate glass effect using the
    /// provided shape.
    /// - Parameter shape: The shape that bounds the glass effect.
    func fallbackGlassEffect<S: Shape>(shape: S) -> some View {
        modifier(FallbackGlassEffect(shape: shape))
    }
}
