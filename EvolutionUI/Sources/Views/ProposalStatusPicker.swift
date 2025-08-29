import EvolutionModel
import Observation
import SwiftUI

/// Toolbar button that allows users to filter proposals by status.
public struct ProposalStatusPicker: View {
    @State private var showPopover = false
    @StatusFilter private var filter

    public init() {}

    public var body: some View {
        Button(
            action: {
                showPopover.toggle()
            },
            label: {
                Image(systemName: iconName)
                    .imageScale(.large)
            }
        )
        .popover(isPresented: $showPopover) {
            VStack {
                FlowLayout(alignment: .leading, spacing: 8) {
                    ForEach(filter.keys.sorted(by: <)) { option in
                        Toggle(option.description, isOn: $filter(option))
                            .toggleStyle(.button)
                            .tint(option.color)
                    }
                }
                Divider()
                    .padding(.vertical)
                HStack {
                    Spacer()
                    Button("Select All") {
                        let allCases = Proposal.Status.State.allCases
                        filter = .init(uniqueKeysWithValues: allCases.map { ($0, true) })
                    }
                    .disabled(filter.values.allSatisfy(\.self))
                    Spacer()
                    Button("Deselect All") {
                        filter = [:]
                    }
                    .disabled(filter.values.allSatisfy { !$0 })
                    Spacer()
                }
            }
            .animation(.default, value: filter)
            .frame(idealWidth: 240)
            .padding()
            .presentationCompactAdaptation(.popover)
            .tint(Color.blue)
        }
    }

    /// Icon name reflecting whether filters are active.
    var iconName: String {
        filter.values.allSatisfy(\.self)
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
    }
}

#Preview {
    ProposalStatusPicker()
}
