import SwiftUI

/// Configuration options for toast appearance and behavior
///
/// `ToastConfiguration` allows you to customize how toasts are displayed,
/// including their position, duration, animation, and interaction behavior.
public struct ToastConfiguration {
    /// Duration in seconds the toast will be displayed
    public var duration: TimeInterval = 3.0

    /// Position of the toast on the screen
    public var position: ToastPosition

    /// Whether tapping the toast dismisses it
    public var tapToDismiss: Bool = true

    /// Delay before dismissal animation starts
    public var dismissDelay: TimeInterval = 0.2

    /// Animation configuration for the toast
    public var animation: ToastAnimation

    /// Creates a new toast configuration with the specified parameters
    /// - Parameters:
    ///   - duration: Duration in seconds the toast will be displayed
    ///   - position: Position of the toast on the screen
    ///   - tapToDismiss: Whether tapping the toast dismisses it
    ///   - dismissDelay: Delay before dismissal animation starts
    ///   - animation: Animation configuration for the toast
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

    /// Standard configuration with default animations based on position
    public static var standard: ToastConfiguration {
        ToastConfiguration(
            position: .bottom,
            animation: .slide(edge: .bottom)
        )
    }

    /// Creates a configuration with a specific animation
    /// - Parameter animation: The animation to use
    /// - Returns: A configured ToastConfiguration
    public static func with(animation: ToastAnimation) -> ToastConfiguration {
        var config = standard
        config.animation = animation
        return config
    }

    /// Top position with appropriate animation
    public static var top: ToastConfiguration {
        var config = standard
        config.position = .top
        config.animation = .slide(edge: .top)
        return config
    }

    /// Bottom position with appropriate animation
    public static var bottom: ToastConfiguration {
        var config = standard
        config.position = .bottom
        config.animation = .slide(edge: .bottom)
        return config
    }

    /// Configuration with a bouncy entrance
    /// - Parameter position: The position of the toast (default: .bottom)
    /// - Returns: A configured ToastConfiguration with bounce animation
    public static func bouncy(position: ToastPosition = .bottom) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            animation: .bounce()
        )
    }

    /// Configuration with a fade animation
    /// - Parameter position: The position of the toast (default: .bottom)
    /// - Returns: A configured ToastConfiguration with fade animation
    public static func fade(position: ToastPosition = .bottom) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            animation: .fade()
        )
    }

    /// Configuration with a flip animation
    /// - Parameter position: The position of the toast (default: .bottom)
    /// - Returns: A configured ToastConfiguration with flip animation
    public static func flip(position: ToastPosition = .bottom) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            animation: .flip()
        )
    }
}
