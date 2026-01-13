import SwiftUI

/// Defines the animation behavior for toast entrance and exit.
///
/// `ToastAnimation` pairs a SwiftUI `Animation` curve with an `AnyTransition` to create
/// smooth, cohesive animations when toasts appear and disappear. The library provides
/// several built-in animation styles, and you can create custom animations by combining
/// any animation curve with any transition.
///
/// Built-in animation styles:
/// - ``slide(edge:duration:)``: Slides in from a screen edge
/// - ``fade(duration:)``: Simple opacity fade
/// - ``scale(scale:duration:)``: Grows from a smaller size
/// - ``bounce(duration:)``: Spring physics with overshoot
/// - ``flip(axis:duration:)``: 3D rotation effect
/// - ``slideWithBounce(edge:duration:)``: Slide with spring physics
///
/// ```swift
/// // Using preset animations
/// let slideConfig = ToastConfiguration(position: .bottom, animation: .slide(edge: .bottom))
/// let bounceConfig = ToastConfiguration(position: .top, animation: .bounce())
///
/// // Creating a custom animation
/// let customAnimation = ToastAnimation(
///     animation: .spring(duration: 0.6, bounce: 0.3),
///     transition: .scale.combined(with: .opacity)
/// )
/// ```
public struct ToastAnimation {
    /// The SwiftUI animation curve controlling timing and easing.
    ///
    /// This determines how the animation progresses over time—whether it's linear,
    /// eased, or uses spring physics.
    public var animation: Animation

    /// The visual transition applied when the toast appears and disappears.
    ///
    /// Transitions define the visual transformation (move, scale, opacity, etc.)
    /// that occurs during the animation.
    public var transition: AnyTransition

    // MARK: - Preset Animations

    /// Creates a slide animation from the specified edge.
    ///
    /// The toast moves in from off-screen while fading in, and reverses on exit.
    /// This is the most common animation style, providing clear directional context.
    ///
    /// ```swift
    /// // Slide up from bottom
    /// .toast(isPresented: $show, message: "Saved",
    ///        configuration: .with(animation: .slide(edge: .bottom)))
    ///
    /// // Slide down from top with slower duration
    /// .toast(isPresented: $show, message: "Alert",
    ///        configuration: .with(animation: .slide(edge: .top, duration: 0.5)))
    /// ```
    ///
    /// - Parameters:
    ///   - edge: The screen edge from which the toast enters. Use `.bottom` for bottom
    ///     toasts and `.top` for top toasts to match the position.
    ///   - duration: Animation duration in seconds. Defaults to 0.35 for a snappy feel.
    /// - Returns: A configured `ToastAnimation` with slide and fade transitions.
    public static func slide(
        edge: Edge,
        duration: TimeInterval = 0.35
    ) -> ToastAnimation {
        ToastAnimation(
            animation: .easeInOut(duration: duration),
            transition: AnyTransition.move(edge: edge).combined(with: .opacity)
        )
    }

    /// Creates a simple fade animation.
    ///
    /// The toast fades in from transparent to opaque, and fades out on exit.
    /// This is the most subtle animation, suitable for unobtrusive notifications.
    ///
    /// ```swift
    /// .toast(isPresented: $show, message: "Auto-saved",
    ///        configuration: .with(animation: .fade()))
    ///
    /// // Slower fade for gentler appearance
    /// .toast(isPresented: $show, message: "Tip of the day",
    ///        configuration: .with(animation: .fade(duration: 0.5)))
    /// ```
    ///
    /// - Parameter duration: Animation duration in seconds. Defaults to 0.35.
    /// - Returns: A configured `ToastAnimation` with opacity transition only.
    public static func fade(duration: TimeInterval = 0.35) -> ToastAnimation {
        ToastAnimation(
            animation: .easeInOut(duration: duration),
            transition: .opacity
        )
    }

    /// Creates a scale animation that grows the toast from a smaller size.
    ///
    /// The toast scales up from the specified factor while fading in. This draws
    /// attention to the toast's appearance without being as dramatic as bounce.
    ///
    /// ```swift
    /// // Default 80% scale
    /// .toast(isPresented: $show, message: "New item",
    ///        configuration: .with(animation: .scale()))
    ///
    /// // More dramatic scale from 50%
    /// .toast(isPresented: $show, message: "Unlocked!",
    ///        configuration: .with(animation: .scale(scale: 0.5)))
    /// ```
    ///
    /// - Parameters:
    ///   - scale: The starting scale factor (0.0–1.0). Lower values create more
    ///     dramatic growth. Defaults to 0.8.
    ///   - duration: Animation duration in seconds. Defaults to 0.35.
    /// - Returns: A configured `ToastAnimation` with scale and fade transitions.
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

    /// Creates a playful bounce animation with spring physics.
    ///
    /// The toast scales in with overshoot and oscillation, creating a lively,
    /// attention-grabbing effect. Best for celebratory or high-priority toasts.
    ///
    /// ```swift
    /// .toast(isPresented: $showAchievement, message: "Achievement unlocked!",
    ///        configuration: .bouncy())
    ///
    /// // Or use the animation directly
    /// .toast(isPresented: $show, message: "Bonus!",
    ///        configuration: .with(animation: .bounce()))
    /// ```
    ///
    /// - Parameter duration: Base duration in seconds. The spring physics may extend
    ///   the actual animation time. Defaults to 0.5.
    /// - Returns: A configured `ToastAnimation` with spring-driven scale transition.
    ///
    /// - Note: The spring uses `mass: 1.0`, `stiffness: 100.0`, `damping: 10` for
    ///   a noticeable but controlled bounce effect.
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

    /// Creates a 3D flip animation that rotates the toast into view.
    ///
    /// The toast rotates 90 degrees around the specified axis while fading in,
    /// creating an eye-catching 3D effect. Use sparingly for special occasions.
    ///
    /// ```swift
    /// // Horizontal flip (default) - rotates around Y axis
    /// .toast(isPresented: $show, message: "Surprise!",
    ///        configuration: .flip())
    ///
    /// // Vertical flip - rotates around X axis
    /// .toast(isPresented: $show, message: "Flipped!",
    ///        configuration: .with(animation: .flip(axis: .vertical)))
    /// ```
    ///
    /// - Parameters:
    ///   - axis: The rotation axis. `.horizontal` rotates around the Y axis (like a
    ///     door), `.vertical` rotates around the X axis (like a card flip). Defaults
    ///     to `.horizontal`.
    ///   - duration: Animation duration in seconds. Defaults to 0.5.
    /// - Returns: A configured `ToastAnimation` with 3D rotation and fade transitions.
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

    /// Creates a slide animation with spring physics for a bouncy entrance.
    ///
    /// Combines the directional motion of ``slide(edge:duration:)`` with the spring
    /// physics of ``bounce(duration:)``. The toast slides in from the edge with a
    /// slight overshoot and settle.
    ///
    /// ```swift
    /// // Bouncy slide from bottom
    /// .toast(isPresented: $show, message: "Welcome!",
    ///        configuration: ToastConfiguration(
    ///            position: .bottom,
    ///            animation: .slideWithBounce(edge: .bottom)
    ///        ))
    /// ```
    ///
    /// - Parameters:
    ///   - edge: The screen edge from which the toast enters. Match this to the
    ///     toast position for natural motion.
    ///   - duration: Base duration in seconds. Spring physics may extend the actual
    ///     animation time. Defaults to 0.5.
    /// - Returns: A configured `ToastAnimation` with spring-driven slide transition.
    ///
    /// - Note: Uses slightly higher damping (12) than ``bounce(duration:)`` for a
    ///   more controlled settle when combined with directional motion.
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
