import SwiftUI

/// Displays a transient heads-up display after code is copied to the clipboard.
public struct CopiedHUD: View {
    /// The most recently copied code snippet, if any.
    var copied: CopiedCode?
    /// Tracks the size of the foreground content.
    @State var size = CGSize(width: Double.infinity, height: .infinity)
    /// Tracks the size of the background container.
    @State var backgroundSize = CGSize(width: Double.infinity, height: .infinity)

    /// Creates a HUD for the given copied code snippet.
    public init(copied: CopiedCode? = nil) {
        self.copied = copied
    }

    public var body: some View {
        VStack(spacing: 0) {
            let imageEdge: CGFloat = min(backgroundSize.width / 3, backgroundSize.height / 3)
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .font(.title3)
                .frame(maxWidth: imageEdge, maxHeight: imageEdge)
                .padding()
            Text(copied != nil ? "Copied!" : "")
                .font(.title)
                .fontWeight(.bold)
                .contentTransition(.opacity)
                .animation(.default, value: copied)
        }
        .onGeometryChange(for: CGSize.self, of: \.size) { size = $1 }
        .frame(maxWidth: size.width, maxHeight: size.height)
        .padding()
        .fallbackGlassEffect(shape: .rect(cornerRadius: 18))
        .opacity(copied != nil ? 1 : 0)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.tint)
        .symbolEffect(.bounce, value: copied)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self, of: \.size) {
            backgroundSize = $1
        }
    }
}
