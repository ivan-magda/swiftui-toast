import SwiftUI

/// The default visual presentation for toast notifications.
///
/// `ToastView` renders a horizontally-stacked icon and message with platform-appropriate
/// styling. It's used automatically when you call the message-based toast modifier:
///
/// ```swift
/// .toast(isPresented: $show, message: "Saved!", type: .success)
/// ```
///
/// The view adapts its appearance based on the ``ToastType``:
/// - Icon and color are determined by the type
/// - Background uses platform-specific system colors
/// - Text supports up to 3 lines with truncation
/// - Minimum touch target height of 44 points for accessibility
///
/// For custom toast appearances, use the content-based toast modifier instead
/// and provide your own view.
struct ToastView: View {
    /// The text message displayed in the toast.
    ///
    /// Long messages are automatically truncated after 3 lines with a trailing ellipsis.
    let message: String

    /// The semantic type determining the icon and color scheme.
    let type: ToastType

    var body: some View {
        HStack(
            alignment: .center,
            spacing: LayoutInsets.smallInset
        ) {
            Image(systemName: type.icon)
                .foregroundColor(type.iconColor)

            Text(message)
                .lineLimit(3)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.body)
        .padding(.vertical, LayoutInsets.smallInset)
        .padding(.horizontal, LayoutInsets.defaultInset)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(String(describing: type).capitalized): \(message)")
    }

    /// Platform-appropriate background color for the toast.
    ///
    /// Returns:
    /// - iOS/tvOS: `UIColor.tertiarySystemBackground` for subtle elevation
    /// - macOS: `NSColor.windowBackgroundColor` for native appearance
    /// - Other platforms: Light secondary color fallback
    private var backgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.tertiarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.secondary.opacity(0.1)
        #endif
    }
}
