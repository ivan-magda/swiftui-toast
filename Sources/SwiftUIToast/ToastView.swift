import SwiftUI

/// A standard toast notification view
///
/// `ToastView` provides a standard appearance for toast messages with an icon,
/// message text, and appropriate styling based on the toast type.
struct ToastView: View {
    /// The message to display in the toast
    let message: String

    /// The type of toast (determines styling)
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
