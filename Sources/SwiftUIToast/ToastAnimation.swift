import SwiftUI

/// Defines the animation behavior for a toast
///
/// `ToastAnimation` combines a SwiftUI animation curve with a transition
/// to create cohesive entrance and exit animations for toasts.
public struct ToastAnimation {
    /// The animation curve to use
    public var animation: Animation

    /// The transition to apply
    public var transition: AnyTransition

    // MARK: - Preset Animations

    /// Standard slide-in/out animation from the edges
    /// - Parameters:
    ///   - edge: The edge from which the toast slides in/out
    ///   - duration: Duration of the animation in seconds
    /// - Returns: A configured toast animation
    public static func slide(
        edge: Edge,
        duration: TimeInterval = 0.35
    ) -> ToastAnimation {
        ToastAnimation(
            animation: .easeInOut(duration: duration),
            transition: AnyTransition.move(edge: edge).combined(with: .opacity)
        )
    }

    /// Fade in/out animation
    /// - Parameter duration: Duration of the animation in seconds
    /// - Returns: A configured toast animation
    public static func fade(duration: TimeInterval = 0.35) -> ToastAnimation {
        ToastAnimation(
            animation: .easeInOut(duration: duration),
            transition: .opacity
        )
    }

    /// Scale animation that grows/shrinks the toast
    /// - Parameters:
    ///   - scale: The scale factor to animate from/to
    ///   - duration: Duration of the animation in seconds
    /// - Returns: A configured toast animation
    public static func scale(
        scale: CGFloat = 0.8,
        duration: TimeInterval = 0.35
    ) -> ToastAnimation {
        ToastAnimation(
            animation: .spring(duration: duration),
            transition: .asymmetric(
                insertion: AnyTransition.scale(scale: scale).combined(with: .opacity),
                removal: AnyTransition.scale(scale: scale).combined(with: .opacity)
            )
        )
    }

    /// Bouncy animation with spring physics
    /// - Parameter duration: Duration of the animation in seconds
    /// - Returns: A configured toast animation
    public static func bounce(duration: TimeInterval = 0.5) -> ToastAnimation {
        ToastAnimation(
            animation: .interpolatingSpring(
                mass: 1.0,
                stiffness: 100.0,
                damping: 10,
                initialVelocity: 0
            ),
            transition: AnyTransition.scale.combined(with: .opacity)
        )
    }

    /// Flip animation that rotates the toast in 3D
    /// - Parameters:
    ///   - axis: The axis to rotate around (horizontal or vertical)
    ///   - duration: Duration of the animation in seconds
    /// - Returns: A configured toast animation
    public static func flip(axis: Axis = .horizontal, duration: TimeInterval = 0.5) -> ToastAnimation {
        let perspectiveTransform = axis == .horizontal ?
        AnyTransition.modifier(
            active: FlipEffect(angle: 90, axis: (x: 0, y: 1)),
            identity: FlipEffect(angle: 0, axis: (x: 0, y: 1))
        ) :
        AnyTransition.modifier(
            active: FlipEffect(angle: 90, axis: (x: 1, y: 0)),
            identity: FlipEffect(angle: 0, axis: (x: 1, y: 0))
        )

        return ToastAnimation(
            animation: .easeInOut(duration: duration),
            transition: perspectiveTransform.combined(with: .opacity)
        )
    }

    /// Slide with bounce animation
    /// - Parameters:
    ///   - edge: The edge from which the toast slides in/out
    ///   - duration: Duration of the animation in seconds
    /// - Returns: A configured toast animation
    public static func slideWithBounce(
        edge: Edge,
        duration: TimeInterval = 0.5
    ) -> ToastAnimation {
        ToastAnimation(
            animation: .interpolatingSpring(
                mass: 1.0,
                stiffness: 100.0,
                damping: 12,
                initialVelocity: 0
            ),
            transition: AnyTransition.move(edge: edge).combined(with: .opacity)
        )
    }
}
