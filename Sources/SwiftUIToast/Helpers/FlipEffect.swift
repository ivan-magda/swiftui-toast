import SwiftUI

/// A view modifier that applies a 3D rotation effect for flip animations.
///
/// `FlipEffect` is used internally by ``ToastAnimation/flip(axis:duration:)`` to create
/// the rotating entrance and exit transitions. It wraps SwiftUI's `rotation3DEffect`
/// with a fixed perspective value optimized for toast flip animations.
///
/// The effect rotates the view around either the X or Y axis:
/// - **Y-axis rotation** (horizontal flip): The view rotates like a door opening
/// - **X-axis rotation** (vertical flip): The view rotates like a card flipping forward
///
/// - Note: This is an internal implementation detail. Use ``ToastAnimation/flip(axis:duration:)``
///   to create flip animations for toasts.
struct FlipEffect: ViewModifier {
    /// The rotation angle in degrees.
    ///
    /// Typically animates from 90 (perpendicular/invisible) to 0 (facing forward) for
    /// entrance, and reverses for exit.
    var angle: Double

    /// The rotation axis specified as X and Y components.
    ///
    /// Common values:
    /// - `(x: 0, y: 1)`: Rotates around Y-axis (horizontal flip)
    /// - `(x: 1, y: 0)`: Rotates around X-axis (vertical flip)
    var axis: (x: CGFloat, y: CGFloat)

    /// Applies the 3D rotation transformation to the content.
    ///
    /// Uses a perspective value of 0.3 for a subtle but visible 3D effect.
    /// The rotation is anchored at the center of the view.
    ///
    /// - Parameter content: The view to rotate.
    /// - Returns: The view with 3D rotation applied.
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
