import SwiftUI

/// Defines the vertical position of a toast on the screen.
///
/// Choose a position based on your app's UI and the toast's purpose:
///
/// - **Bottom**: The default and most common position. Works well for confirmations
///   and feedback about completed actions. Stays clear of navigation bars.
///
/// - **Top**: Better for notifications and alerts that need immediate attention.
///   Useful when bottom content (like a tab bar) shouldn't be obscured.
///
/// ```swift
/// // Bottom toast (default)
/// .toast(isPresented: $show, message: "Saved", configuration: .bottom)
///
/// // Top toast for notifications
/// .toast(isPresented: $show, message: "New message", configuration: .top)
///
/// // Custom configuration with specific position
/// let config = ToastConfiguration(
///     position: .top,
///     animation: .slide(edge: .top)
/// )
/// ```
///
/// - Tip: Match the animation edge to the position for natural motion. For example,
///   use `.slide(edge: .top)` with `.top` position.
public enum ToastPosition {
    /// Positions the toast at the top of the screen.
    ///
    /// The toast appears below the safe area inset with appropriate padding.
    /// Best for notification-style toasts or when bottom content should remain visible.
    case top

    /// Positions the toast at the bottom of the screen.
    ///
    /// The toast appears above the safe area inset with appropriate padding.
    /// This is the most common position for confirmation and feedback toasts.
    case bottom

    /// The SwiftUI alignment value corresponding to this position.
    ///
    /// Used internally by ``ToastModifier`` to position the toast overlay.
    /// Returns `.top` or `.bottom` alignment for the overlay container.
    var alignment: Alignment {
        switch self {
        case .top:
            .top
        case .bottom:
            .bottom
        }
    }
}
