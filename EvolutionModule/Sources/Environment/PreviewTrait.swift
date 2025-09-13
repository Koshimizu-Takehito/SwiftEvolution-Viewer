import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

/// Convenience trait for previews that require proposal data.
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor public static var evolution: Self = .modifier(EvolutionPreviewModifier())
}
