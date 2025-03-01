import SwiftUI

/// Defines the type and appearance of a toast
///
/// Built-in toast types include success, error, and informational toasts,
/// each with appropriate styling.
public enum ToastType {
    /// A success message toast with a checkmark icon
    case success

    /// An error message toast with an exclamation icon
    case error

    /// An informational toast with an info icon
    case info

    /// The SF Symbol icon name to use for this toast type
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

    /// The color to use for the icon
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
