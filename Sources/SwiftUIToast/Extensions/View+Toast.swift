import SwiftUI

/// Extensions that add toast functionality to any SwiftUI View
public extension View {
    /// Displays a toast with a predefined style
    ///
    /// This modifier attaches a toast with standard styling to the view.
    ///
    /// ```swift
    /// Button("Show Toast") {
    ///     showToast = true
    /// }
    /// .toast(
    ///     isPresented: $showToast,
    ///     message: "Operation completed successfully!",
    ///     type: .success
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls whether the toast is presented
    ///   - message: Text to display in the toast
    ///   - type: Toast type (info, success, error)
    ///   - configuration: Toast configuration options
    /// - Returns: A view with the toast modifier applied
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        type: ToastType = .info,
        configuration: ToastConfiguration = .standard
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                configuration: configuration,
                toastContent: ToastView(message: message, type: type)
            )
        )
    }

    /// Displays a toast with custom content
    ///
    /// This modifier attaches a toast with custom content to the view.
    ///
    /// ```swift
    /// Button("Show Custom Toast") {
    ///     showToast = true
    /// }
    /// .toast(isPresented: $showToast, configuration: .top) {
    ///     HStack {
    ///         Image(systemName: "star.fill")
    ///             .foregroundColor(.yellow)
    ///         Text("Custom Toast!")
    ///             .bold()
    ///     }
    ///     .padding()
    ///     .background(Color.black.opacity(0.8))
    ///     .cornerRadius(10)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls whether the toast is presented
    ///   - configuration: Toast configuration options
    ///   - content: Custom view builder for toast content
    /// - Returns: A view with the toast modifier applied
    func toast<ToastContent: View>(
        isPresented: Binding<Bool>,
        configuration: ToastConfiguration = .standard,
        @ViewBuilder content: () -> ToastContent
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                configuration: configuration,
                toastContent: content()
            )
        )
    }
}
