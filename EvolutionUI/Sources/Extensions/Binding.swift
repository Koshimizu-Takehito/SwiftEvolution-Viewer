import EvolutionModel
import SwiftUI

extension Binding<Set<ReviewState>> {
    /// Creates a binding that reflects whether the specified state is contained in the set.
    /// - Parameter state: The proposal status to monitor.
    public func isOn(_ state: ReviewState) -> Binding<Bool> {
        Binding<Bool> {
            wrappedValue.contains(state)
        } set: { isOn in
            if isOn {
                wrappedValue.insert(state)
            } else {
                wrappedValue.remove(state)
            }
        }
    }
}
