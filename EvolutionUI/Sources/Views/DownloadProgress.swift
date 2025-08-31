import SwiftUI

// MARK: - DownloadProgressView

/// Represents the current state of a multi-item download operation.
public struct DownloadProgress: Hashable, Sendable {
    /// Total number of items expected to be downloaded.
    public var total: Int
    /// Number of items that have finished downloading.
    public var current: Int

    /// Creates a new progress value.
    /// - Parameters:
    ///   - total: The total number of items to be fetched.
    ///   - current: The number of items already fetched.
    public init(total: Int, current: Int) {
        self.total = total
        self.current = current
    }
}

/// A heads-up display that shows the progress of downloading proposal markdown.
public struct DownloadProgressView: View {
    /// Backing progress value that drives the view.
    private var progress: DownloadProgress

    /// Total number of items expected.
    private var total: Int {
        progress.total
    }
    /// Number of items retrieved so far.
    private var current: Int {
        progress.current
    }

    /// Creates a new progress view for the given state.
    public init(progress: DownloadProgress) {
        self.progress = progress
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
                .frame(height: 10)
            Text(description)
                .font(.footnote)
                .monospacedDigit()
                .contentTransition(.interpolate)
                .animation(.snappy, value: description)
            Spacer(minLength: 0)
                .frame(height: 10)
            ProgressView(value: ratio)
                .animation(.snappy, value: ratio)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            Spacer(minLength: 0)
                .frame(height: 10)
        }
        .padding(.horizontal, 18)
        .fallbackGlassEffect(shape: .rect(cornerRadius: 18))
        .opacity(opacity)
        .animation(opacity == 0 ? .snappy.delay(0.5) : .snappy, value: opacity)
        .padding(30)
        .tint(.blue)
    }

    /// Text describing the current progress in a localized format.
    var description: LocalizedStringResource {
        let digits = String(abs(total)).count
        return "Downloading... ( \(String(format: "%0\(digits)ld", current)) / \(total) )"
    }

    /// Ratio of completed items to total items.
    var ratio: Double {
        let ratio = Double(current) / Double(total)
        return min(max(ratio, 0), 1)
    }

    /// Opacity used to hide the view when no download is in progress.
    var opacity: Double {
        ratio > 0.0 && ratio < 1.0 ? 1.0 : 0.0
    }
}

#Preview {
    @Previewable @State
    var state: (viewId: UUID, progress: DownloadProgress)
        = (.init(), .init(total: 100, current: 0))
    ZStack(alignment: .bottom) {
        Color.blue.mix(with: .mint, by: 0.5).opacity(0.5)
        DownloadProgressView(progress: state.progress)
    }
    .task {
        for i in 0...100 {
            state.progress.current = i
            try? await Task.sleep(for: .microseconds(100000))
        }
        try? await Task.sleep(for: .microseconds(1000000))
        state = (.init(), .init(total: 100, current: 0))
    }
    .id(state.viewId)
}
