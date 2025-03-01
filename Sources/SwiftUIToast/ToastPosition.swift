import SwiftUI

/// Defines the position of a toast on the screen
///
/// Toasts can be displayed either at the top or bottom of the screen.
public enum ToastPosition {
    /// Display the toast at the top of the screen
    case top

    /// Display the toast at the bottom of the screen
    case bottom

    /// The alignment to use for positioning the toast
    var alignment: Alignment {
        switch self {
        case .top:
            .top
        case .bottom:
            .bottom
        }
    }
}
