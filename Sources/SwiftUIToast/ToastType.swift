import SwiftUI

/// Defines the semantic type and visual style of a toast notification.
///
/// `ToastType` provides three built-in toast categories, each with an appropriate
/// SF Symbol icon and color. The type conveys the nature of the notification to users
/// at a glance and ensures consistent visual language across your app.
///
/// ```swift
/// // Success toast - green checkmark
/// .toast(isPresented: $showSuccess, message: "File saved!", type: .success)
///
/// // Error toast - red exclamation
/// .toast(isPresented: $showError, message: "Upload failed", type: .error)
///
/// // Info toast - accent-colored info icon
/// .toast(isPresented: $showInfo, message: "Tip: Swipe to dismiss", type: .info)
/// ```
///
/// For fully custom toast appearances, use the content-based toast modifier instead:
///
/// ```swift
/// .toast(isPresented: $show, configuration: .standard) {
///     MyCustomToastView()
/// }
/// ```
public enum ToastType {
    /// A success notification indicating a completed or positive action.
    ///
    /// Displays a green checkmark icon. Use for confirmations like "Saved",
    /// "Sent", "Completed", or other successful outcomes.
    case success

    /// An error notification indicating a failure or problem.
    ///
    /// Displays a red exclamation icon. Use for failures like "Upload failed",
    /// "Connection lost", or validation errors.
    case error

    /// An informational notification for neutral messages.
    ///
    /// Displays an info icon in the app's accent color. Use for tips, updates,
    /// or other messages that aren't explicitly positive or negative.
    case info

    /// The SF Symbol name for this toast type's icon.
    ///
    /// Returns a filled circle variant for visual prominence:
    /// - `.success`: "checkmark.circle.fill"
    /// - `.error`: "exclamationmark.circle.fill"
    /// - `.info`: "info.circle.fill"
    var icon: String {
        switch self {
        case .success:
            "checkmark.circle.fill"
        case .error:
            "exclamationmark.circle.fill"
        case .info:
            "info.circle.fill"
        }
    }

    /// The color applied to the toast icon.
    ///
    /// Returns semantically appropriate colors:
    /// - `.success`: Green (positive)
    /// - `.error`: Red (negative/warning)
    /// - `.info`: The app's accent color (neutral)
    var iconColor: Color {
        switch self {
        case .success:
            .green
        case .error:
            .red
        case .info:
            .accentColor
        }
    }
}
