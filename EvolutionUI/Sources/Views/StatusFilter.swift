import EvolutionModel
import SwiftUI

@propertyWrapper
/// Stores a mapping of proposal statuses to inclusion flags using `AppStorage`.
public struct StatusFilter: DynamicProperty {
    @AppStorage("accepted")
    private var accepted = true
    @AppStorage("activeReview")
    private var activeReview = true
    @AppStorage("implemented")
    private var implemented = true
    @AppStorage("previewing")
    private var previewing = true
    @AppStorage("rejected")
    private var rejected = true
    @AppStorage("returnedForRevision")
    private var returnedForRevision = true
    @AppStorage("withdrawn")
    private var withdrawn = true

    public init() {}

    public var wrappedValue: [ReviewState: Bool] {
        get {
            var values = [ReviewState: Bool]()
            values[.accepted] = accepted
            values[.activeReview] = activeReview
            values[.implemented] = implemented
            values[.previewing] = previewing
            values[.rejected] = rejected
            values[.returnedForRevision] = returnedForRevision
            values[.withdrawn] = withdrawn
            return values
        }
        nonmutating set {
            accepted = newValue[.accepted, default: false]
            activeReview = newValue[.activeReview, default: false]
            implemented = newValue[.implemented, default: false]
            previewing = newValue[.previewing, default: false]
            rejected = newValue[.rejected, default: false]
            returnedForRevision = newValue[.returnedForRevision, default: false]
            withdrawn = newValue[.withdrawn, default: false]
        }
    }

    /// Provides bindings to individual status flags.
    public var projectedValue: (_ status: ReviewState) -> (Binding<Bool>) {
        return { status in
            switch status {
            case .accepted:
                $accepted
            case .activeReview:
                $activeReview
            case .implemented:
                $implemented
            case .previewing:
                $previewing
            case .rejected:
                $rejected
            case .returnedForRevision:
                $returnedForRevision
            case .withdrawn:
                $withdrawn
            case .unknown:
                .constant(false)
            }
        }
    }
}
