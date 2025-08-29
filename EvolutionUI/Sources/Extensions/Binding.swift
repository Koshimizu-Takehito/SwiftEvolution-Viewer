import EvolutionModel
import SwiftUI

extension Binding<Set<Proposal.Status.State>> {
    public func isOn(_ state: Proposal.Status.State) -> Binding<Bool> {
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
