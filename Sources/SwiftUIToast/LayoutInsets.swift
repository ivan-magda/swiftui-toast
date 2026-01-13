import Foundation

/// Standard spacing values used throughout the toast UI.
///
/// `LayoutInsets` provides consistent spacing constants to ensure visual harmony
/// across all toast components. These values follow common iOS spacing conventions:
///
/// - ``smallInset`` (8pt): Used for tight spacing, such as between icon and text
/// - ``defaultInset`` (16pt): Used for standard padding and margins
///
/// - Note: This is an internal implementation detail used by ``ToastView`` and
///   ``ToastModifier`` for consistent layout.
enum LayoutInsets {
    /// Compact spacing for tight layouts (8 points).
    ///
    /// Used for spacing between elements within the toast, such as the gap
    /// between the icon and message text in ``ToastView``.
    static let smallInset: CGFloat = 8

    /// Standard spacing for padding and margins (16 points).
    ///
    /// Used for horizontal padding within toasts and the inset from screen
    /// edges. This matches the standard iOS content margin.
    static let defaultInset: CGFloat = 16
}
