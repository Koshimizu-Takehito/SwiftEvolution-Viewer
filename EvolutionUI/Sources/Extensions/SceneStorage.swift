import SwiftUI

extension SceneStorage where Value: RawRepresentable, Value.RawValue == String {
    /// Convenience initializer that uses the type name as the storage key.
    public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, String(describing: Value.self))
    }
}
