import SwiftUI

/// A reusable view that displays an error message with an optional retry button.
public struct ErrorView: View {
    /// The error to present to the user.
    public var error: Error?
    /// Action executed when the user chooses to retry.
    public var retry: (() -> Void)?

    public init(error: Error? = nil, retry: (() -> Void)? = nil) {
        self.error = error
        self.retry = retry
    }

    public var body: some View {
        Group {
            if let error {
                ContentUnavailableView {
                    switch error {
                    case is URLError:
                        Label("Connection issue", systemImage: "wifi.slash")
                    default:
                        Label("Error", systemImage: "exclamationmark.triangle")
                    }
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    if let retry {
                        Button("Retry", action: retry)
                    }
                }
            }
        }
        .animation(.default, value: error as? NSError)
    }
}

extension ErrorView {
    /// Convenience initializer that triggers a `UUID`-based refresh when retrying.
    public init(error: (any Error)? = nil, _ retry: Binding<UUID?>) {
        self.init(error: error) {
            retry.wrappedValue = UUID()
        }
    }
}

#Preview {
    let error = URLError(.notConnectedToInternet, userInfo: [
        NSLocalizedDescriptionKey: "インターネット接続がオフラインのようです。"
    ])
    return ErrorView(error: error, retry: { })
}
