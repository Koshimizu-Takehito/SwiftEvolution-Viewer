import SwiftUI

// MARK: - Color
#if os(macOS)
    /// Alias to `NSColor` for cross-platform code sharing.
public typealias UIColor = NSColor
    extension UIColor {
        /// Default tint color equivalent for macOS.
        static var tintColor: UIColor {
            controlTextColor.usingColorSpace(.extendedSRGB)!
        }

        /// Background color matching the system window background.
        public static var systemBackground: UIColor {
            windowBackgroundColor.usingColorSpace(.extendedSRGB)!
        }

        /// Secondary background color used for grouped content areas.
        public static var secondarySystemBackground: UIColor {
            windowBackgroundColor.usingColorSpace(.extendedSRGB)!
        }

        /// Label color in the extended sRGB color space.
        public static var label: UIColor {
            labelColor.usingColorSpace(.extendedSRGB)!
        }
    }

    extension NSView {
        /// Convenience property to bridge AppKit and UIKit background colors.
        public var backgroundColor: UIColor? {
            get {
                (layer?.backgroundColor).flatMap(UIColor.init(cgColor:))
            }
            set {
                layer?.backgroundColor = newValue?.cgColor
            }
        }
    }
#endif
