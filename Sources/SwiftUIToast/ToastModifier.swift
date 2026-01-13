import SwiftUI

/// View modifier that orchestrates toast presentation, animation, and lifecycle.
///
/// `ToastModifier` is the internal engine powering the `.toast()` view modifiers.
/// It coordinates between the view hierarchy and ``ToastManager`` to:
///
/// - Register toasts in the display queue when `isPresented` becomes `true`
/// - Show the toast with configured animations when it becomes the current toast
/// - Handle tap-to-dismiss with configurable delay
/// - Automatically dismiss after the configured duration
/// - Clean up and advance the queue when dismissed
///
/// You typically don't use this modifier directly. Instead, use the View extensions:
///
/// ```swift
/// // Standard toast
/// .toast(isPresented: $show, message: "Done!", type: .success)
///
/// // Custom content toast
/// .toast(isPresented: $show) {
///     MyCustomToastView()
/// }
/// ```
struct ToastModifier<ToastContent: View>: ViewModifier {
    /// The shared toast manager from the environment.
    ///
    /// Coordinates queuing and ensures only one toast displays at a time.
    @Environment(ToastManager.self) private var toastManager

    /// Unique identifier for this toast modifier instance.
    ///
    /// Generated once per modifier instance and used to track this toast
    /// in the manager's queue.
    @State private var toastID = UUID().uuidString

    /// Whether this specific toast is currently the visible one.
    ///
    /// Becomes `true` when ``ToastManager/currentToastID`` matches this toast's ID.
    @State private var isVisible = false

    /// External binding controlling whether this toast should be shown.
    ///
    /// Setting to `true` enqueues the toast; setting to `false` (or automatic
    /// dismissal) dequeues it. The binding is reset to `false` when the toast
    /// is dismissed for any reason.
    @Binding var isPresented: Bool

    /// Appearance and behavior settings for this toast.
    let configuration: ToastConfiguration

    /// The view content to display as the toast.
    let toastContent: ToastContent

    /// Handle for the auto-dismiss timer task.
    ///
    /// Cancelled when the toast is dismissed early (tap or binding change).
    @State private var autoDismissTask: Task<Void, Error>?

    /// Applies toast presentation logic to the modified view.
    ///
    /// The implementation:
    /// 1. Observes `isPresented` changes to enqueue/dequeue the toast
    /// 2. Observes the manager's `currentToastID` to show/hide this toast
    /// 3. Overlays the toast content when visible
    /// 4. Manages the auto-dismiss timer
    /// 5. Handles tap-to-dismiss when enabled
    ///
    /// - Parameter content: The view being modified.
    /// - Returns: The view with toast overlay capability.
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { oldValue, newValue in
                if !oldValue && newValue {
                    toastManager.enqueue(id: toastID)
                } else if oldValue && !newValue {
                    toastManager.dequeue(id: toastID)
                }
            }
            .onChange(of: toastManager.currentToastID) { _, newValue in
                isVisible = newValue == toastID
            }
            .overlay(alignment: configuration.position.alignment) {
                if isVisible {
                    toastContent
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if configuration.tapToDismiss {
                                autoDismissTask?.cancel()
                                autoDismissTask = nil

                                Task { @MainActor in
                                    try? await dismiss(withDelay: true)
                                }
                            }
                        }
                        .transition(configuration.animation.transition)
                        .padding(.horizontal)
                        .padding(.bottom, configuration.position == .bottom ? LayoutInsets.defaultInset : 0)
                        .padding(.top, configuration.position == .top ? LayoutInsets.defaultInset : 0)
                        .onAppear {
                            autoDismissTask = Task { @MainActor in
                                try await Task.sleep(for: .seconds(configuration.duration))
                                try await dismiss(withDelay: false)
                            }
                        }
                        .onDisappear {
                            if isPresented {
                                isPresented = false
                                toastManager.dequeue(id: toastID)
                            }

                            autoDismissTask?.cancel()
                            autoDismissTask = nil
                        }
                }
            }
            .animation(configuration.animation.animation, value: isVisible)
    }

    /// Dismisses the toast by resetting the `isPresented` binding.
    ///
    /// When `withDelay` is `true`, waits for the configured ``ToastConfiguration/dismissDelay``
    /// before dismissing. This provides visual feedback for tap-to-dismiss actions.
    ///
    /// - Parameter withDelay: If `true`, applies the dismiss delay before hiding.
    ///   Typically `true` for user-initiated dismissal and `false` for auto-dismiss.
    /// - Throws: `CancellationError` if the task is cancelled during the delay.
    @MainActor
    private func dismiss(withDelay delay: Bool) async throws {
        if delay {
            try await Task.sleep(for: .seconds(configuration.dismissDelay))
        }
        isPresented = false
    }
}
