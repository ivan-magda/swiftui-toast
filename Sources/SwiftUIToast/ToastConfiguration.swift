import SwiftUI

/// Configuration options for toast appearance and behavior.
///
/// `ToastConfiguration` provides a flexible way to customize how toasts are displayed
/// in your app. You can control timing, positioning, animations, and user interaction.
///
/// Use the built-in presets for common configurations:
///
/// ```swift
/// // Standard bottom toast with slide animation
/// .toast(isPresented: $show, message: "Saved", configuration: .standard)
///
/// // Top toast for notifications
/// .toast(isPresented: $show, message: "New message", configuration: .top)
///
/// // Bouncy animation for celebratory moments
/// .toast(isPresented: $show, message: "Achievement unlocked!", configuration: .bouncy())
/// ```
///
/// Or create a custom configuration for fine-grained control:
///
/// ```swift
/// let customConfig = ToastConfiguration(
///     duration: 5.0,
///     position: .top,
///     tapToDismiss: true,
///     dismissDelay: 0.3,
///     animation: .slideWithBounce(edge: .top)
/// )
/// ```
public struct ToastConfiguration {
    /// Duration in seconds the toast remains visible before auto-dismissing.
    ///
    /// The timer starts when the toast becomes visible. If the user taps to dismiss
    /// (when ``tapToDismiss`` is enabled), the toast dismisses immediately regardless
    /// of remaining duration.
    ///
    /// - Note: Default value is 3.0 seconds.
    public var duration: TimeInterval = 3.0

    /// Screen position where the toast appears.
    ///
    /// The position affects both visual placement and the default slide direction
    /// when using position-aware animations like ``ToastAnimation/slide(edge:duration:)``.
    public var position: ToastPosition

    /// Controls whether tapping the toast dismisses it.
    ///
    /// When `true`, users can tap anywhere on the toast to dismiss it immediately.
    /// The ``dismissDelay`` is applied before the dismissal animation begins.
    ///
    /// - Note: Default value is `true`.
    public var tapToDismiss: Bool = true

    /// Delay in seconds before the dismissal animation starts after a tap.
    ///
    /// This brief pause provides visual feedback that the tap was recognized before
    /// the toast animates away. Only applies when ``tapToDismiss`` is enabled.
    ///
    /// - Note: Default value is 0.2 seconds.
    public var dismissDelay: TimeInterval = 0.2

    /// Animation style for toast entrance and exit.
    ///
    /// The animation controls how the toast appears and disappears. See ``ToastAnimation``
    /// for available animation types including slide, fade, bounce, scale, and flip.
    public var animation: ToastAnimation

    /// Creates a new toast configuration with the specified parameters.
    ///
    /// ```swift
    /// // Custom configuration with all parameters
    /// let config = ToastConfiguration(
    ///     duration: 4.0,
    ///     position: .top,
    ///     tapToDismiss: true,
    ///     dismissDelay: 0.1,
    ///     animation: .bounce()
    /// )
    ///
    /// // Minimal configuration (other values use defaults)
    /// let simpleConfig = ToastConfiguration(
    ///     position: .bottom,
    ///     animation: .fade()
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - duration: How long the toast remains visible in seconds. Defaults to 3.0.
    ///   - position: Where the toast appears on screen (top or bottom).
    ///   - tapToDismiss: Whether users can tap to dismiss. Defaults to `true`.
    ///   - dismissDelay: Delay before tap-triggered dismissal animation. Defaults to 0.2.
    ///   - animation: The animation style for showing and hiding the toast.
    public init(
        duration: TimeInterval = 3.0,
        position: ToastPosition,
        tapToDismiss: Bool = true,
        dismissDelay: TimeInterval = 0.2,
        animation: ToastAnimation
    ) {
        self.duration = duration
        self.position = position
        self.tapToDismiss = tapToDismiss
        self.dismissDelay = dismissDelay
        self.animation = animation
    }

    // MARK: - Preset Configurations

    /// Standard configuration with bottom position and slide animation.
    ///
    /// This is the recommended default for most use cases. The toast slides up from
    /// the bottom of the screen with a smooth easing animation.
    ///
    /// ```swift
    /// .toast(isPresented: $showToast, message: "Changes saved", configuration: .standard)
    /// ```
    public static var standard: ToastConfiguration {
        ToastConfiguration(
            position: .bottom,
            animation: .slide(edge: .bottom)
        )
    }

    /// Creates a configuration with a custom animation while keeping other defaults.
    ///
    /// Use this when you want a specific animation style but don't need to customize
    /// duration, position, or other parameters.
    ///
    /// ```swift
    /// .toast(isPresented: $show, message: "Hello", configuration: .with(animation: .scale()))
    /// ```
    ///
    /// - Parameter animation: The animation style to use.
    /// - Returns: A configuration with the specified animation and default values for other properties.
    public static func with(animation: ToastAnimation) -> ToastConfiguration {
        var config = standard
        config.animation = animation
        return config
    }

    /// Configuration for top-positioned toasts.
    ///
    /// Ideal for notification-style toasts that shouldn't interfere with bottom
    /// navigation or action buttons. The toast slides down from the top edge.
    ///
    /// ```swift
    /// .toast(isPresented: $showNotification, message: "New message received", configuration: .top)
    /// ```
    public static var top: ToastConfiguration {
        var config = standard
        config.position = .top
        config.animation = .slide(edge: .top)
        return config
    }

    /// Configuration for bottom-positioned toasts.
    ///
    /// The default position for most toast notifications. The toast slides up from
    /// the bottom edge. Equivalent to ``standard``.
    ///
    /// ```swift
    /// .toast(isPresented: $showToast, message: "Item added to cart", configuration: .bottom)
    /// ```
    public static var bottom: ToastConfiguration {
        var config = standard
        config.position = .bottom
        config.animation = .slide(edge: .bottom)
        return config
    }

    /// Configuration with a playful bounce animation.
    ///
    /// Great for celebratory or attention-grabbing toasts. The toast scales in with
    /// spring physics for a lively entrance.
    ///
    /// ```swift
    /// // Bottom bounce (default)
    /// .toast(isPresented: $showAchievement, message: "Level up!", configuration: .bouncy())
    ///
    /// // Top bounce
    /// .toast(isPresented: $showReward, message: "Bonus earned!", configuration: .bouncy(position: .top))
    /// ```
    ///
    /// - Parameter position: The screen position for the toast. Defaults to `.bottom`.
    /// - Returns: A configuration with bounce animation at the specified position.
    public static func bouncy(position: ToastPosition = .bottom) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            animation: .bounce()
        )
    }

    /// Configuration with a subtle fade animation.
    ///
    /// A gentle, non-distracting animation suitable for low-priority notifications
    /// or contexts where bouncy animations feel out of place.
    ///
    /// ```swift
    /// .toast(isPresented: $showInfo, message: "Auto-saved", configuration: .fade())
    /// ```
    ///
    /// - Parameter position: The screen position for the toast. Defaults to `.bottom`.
    /// - Returns: A configuration with fade animation at the specified position.
    public static func fade(position: ToastPosition = .bottom) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            animation: .fade()
        )
    }

    /// Configuration with a 3D flip animation.
    ///
    /// An eye-catching animation that rotates the toast into view. Use sparingly
    /// for special moments or to draw attention to important notifications.
    ///
    /// ```swift
    /// .toast(isPresented: $showSpecial, message: "Surprise!", configuration: .flip())
    /// ```
    ///
    /// - Parameter position: The screen position for the toast. Defaults to `.bottom`.
    /// - Returns: A configuration with flip animation at the specified position.
    public static func flip(position: ToastPosition = .bottom) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            animation: .flip()
        )
    }
}
