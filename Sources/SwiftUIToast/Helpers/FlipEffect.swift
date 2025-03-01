import SwiftUI

/// Effect modifier for 3D rotation
///
/// This modifier applies a 3D rotation effect to any view, allowing
/// for animated flipping transitions along a specified axis.
struct FlipEffect: ViewModifier {
    /// The rotation angle in degrees
    var angle: Double

    /// The axis of rotation as X and Y components
    var axis: (x: CGFloat, y: CGFloat)

    /// Applies the 3D rotation effect to the content
    /// - Parameter content: The view to modify
    /// - Returns: The modified view with 3D rotation applied
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: axis.x, y: axis.y, z: 0),
                anchor: .center,
                perspective: 0.3
            )
    }
}
