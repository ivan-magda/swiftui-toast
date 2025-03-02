import SwiftUI

/// View modifier that adds toast presentation logic to any view
///
/// This modifier handles the presentation, animation, and dismissal of toasts,
/// coordinating with the `ToastManager` to ensure proper queuing and lifecycle management.
struct ToastModifier<ToastContent: View>: ViewModifier {
    /// The toast manager responsible for queue management
    @Environment(ToastManager.self) private var toastManager

    /// Unique identifier for this toast instance
    @State private var toastID = UUID().uuidString

    /// Whether this toast is currently visible
    @State private var isVisible = false

    /// Binding to control toast presentation
    @Binding var isPresented: Bool

    /// Configuration options for the toast
    let configuration: ToastConfiguration

    /// The content view to display within the toast
    let toastContent: ToastContent

    /// Task for handling automatic dismissal
    @State private var autoDismissTask: Task<Void, Error>?

    /// Applies the toast presentation logic to the content
    /// - Parameter content: The view to which the toast will be attached
    /// - Returns: The modified view with toast presentation capability
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

    /// Dismisses the toast with an optional delay
    /// - Parameter delay: Whether to include the configured dismissal delay
    @MainActor
    private func dismiss(withDelay delay: Bool) async throws {
        if delay {
            try await Task.sleep(for: .seconds(configuration.dismissDelay))
        }
        isPresented = false
    }
}
