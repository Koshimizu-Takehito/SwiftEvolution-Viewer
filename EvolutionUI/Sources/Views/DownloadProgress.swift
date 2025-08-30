import SwiftUI

// MARK: - DownloadProgressView

public struct DownloadProgress: Hashable, Sendable {
    public var total: Int
    public var current: Int

    public init(total: Int, current: Int) {
        self.total = total
        self.current = current
    }
}

public struct DownloadProgressView: View {
    private var progress: DownloadProgress

    private var total: Int {
        progress.total
    }
    private var current: Int {
        progress.current
    }

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
                .progressViewStyle(.linear)
                .padding(.horizontal)
                .animation(.snappy, value: ratio)
            Spacer(minLength: 0)
                .frame(height: 10)
        }
        .fallbackGlassEffect(shape: .rect(cornerRadius: 18))
        .opacity(opacity)
        .animation(opacity == 0 ? .snappy.delay(0.5) : .snappy, value: opacity)
        .padding(.horizontal, 30)
        .tint(.blue)
    }

    var description: LocalizedStringResource {
        let len = String(total).count
        return "データ取得中... ( \(String(format: "%0\(len)ld", current)) / \(total) )"
    }

    var ratio: Double {
        Double(current) / Double(total)
    }

    var opacity: Double {
        ratio > 0.0 && ratio < 1.0 ? 1.0 : 0.0
    }
}
