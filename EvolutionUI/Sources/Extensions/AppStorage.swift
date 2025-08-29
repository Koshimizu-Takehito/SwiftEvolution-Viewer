import SwiftUI

extension AppStorage where Value: RawRepresentable, Value.RawValue == String {
    /// Convenience initializer that uses the type name as the storage key.
    public init(wrappedValue: Value, store: UserDefaults? = nil) {
        self.init(
            wrappedValue: wrappedValue,
            String(describing: Value.self),
            store: store
        )
    }
}
