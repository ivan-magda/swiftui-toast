import SwiftUI

/// View extension providing toast notification capabilities.
///
/// These modifiers are the primary API for displaying toasts in your app. Apply them
/// to any view in your hierarchy where you want toasts to appear.
///
/// There are two variants:
/// - ``toast(isPresented:message:type:configuration:)`` for standard styled toasts
/// - ``toast(isPresented:configuration:content:)`` for fully custom toast content
///
/// Both require a ``ToastManager`` in the environment. Set this up at your app's root:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let toastManager = ToastManager()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(toastManager)
///         }
///     }
/// }
/// ```
public extension View {
    /// Displays a toast with standard styling and an icon based on the toast type.
    ///
    /// This is the simplest way to show a toast. The toast automatically includes
    /// an icon and color scheme based on the ``ToastType``.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showSuccess = false
    ///     @State private var showError = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Save") {
    ///                 // ... save logic
    ///                 showSuccess = true
    ///             }
    ///             .toast(isPresented: $showSuccess, message: "Saved!", type: .success)
    ///
    ///             Button("Delete") {
    ///                 // ... delete logic that might fail
    ///                 showError = true
    ///             }
    ///             .toast(
    ///                 isPresented: $showError,
    ///                 message: "Could not delete item",
    ///                 type: .error,
    ///                 configuration: .top
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the toast is visible. Set to
    ///     `true` to show the toast; it automatically resets to `false` when dismissed.
    ///   - message: The text message to display. Supports up to 3 lines with truncation.
    ///   - type: The semantic type of the toast, which determines the icon and color.
    ///     Defaults to ``ToastType/info``.
    ///   - configuration: Customization options for timing, position, and animation.
    ///     Defaults to ``ToastConfiguration/standard``.
    /// - Returns: A view that can display the toast notification.
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

    /// Displays a toast with completely custom content.
    ///
    /// Use this variant when you need full control over the toast's appearance. Your
    /// custom view receives all configured animations and behaviors automatically.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showLevelUp = false
    ///
    ///     var body: some View {
    ///         GameView()
    ///             .toast(isPresented: $showLevelUp, configuration: .bouncy(position: .top)) {
    ///                 HStack(spacing: 12) {
    ///                     Image(systemName: "star.fill")
    ///                         .font(.title)
    ///                         .foregroundStyle(.yellow)
    ///
    ///                     VStack(alignment: .leading) {
    ///                         Text("Level Up!")
    ///                             .font(.headline)
    ///                         Text("You reached level 10")
    ///                             .font(.subheadline)
    ///                             .foregroundStyle(.secondary)
    ///                     }
    ///                 }
    ///                 .padding()
    ///                 .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the toast is visible. Set to
    ///     `true` to show the toast; it automatically resets to `false` when dismissed.
    ///   - configuration: Customization options for timing, position, and animation.
    ///     Defaults to ``ToastConfiguration/standard``.
    ///   - content: A view builder that creates the toast's content. The view should
    ///     include its own background, padding, and styling.
    /// - Returns: A view that can display the custom toast notification.
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
