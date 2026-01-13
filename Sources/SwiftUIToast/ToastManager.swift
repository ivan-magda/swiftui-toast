import SwiftUI
import Observation

/// Manages the queue of toast notifications to display one at a time.
///
/// `ToastManager` provides centralized management for toast notifications in your app.
/// It maintains an internal queue to ensure toasts are displayed sequentially rather
/// than overlapping, creating a polished user experience.
///
/// The manager handles:
/// - **Queue management**: Toasts are displayed in first-in, first-out order
/// - **Deduplication**: Prevents the same toast from being queued multiple times
/// - **Memory protection**: Limits queue size to prevent unbounded growth
/// - **Lifecycle coordination**: Works with ``ToastModifier`` to manage visibility
///
/// Create a single instance at your app's root and share it via the environment:
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
///
/// Then use the `.toast()` modifier anywhere in your view hierarchy:
///
/// ```swift
/// struct ContentView: View {
///     @State private var showSuccess = false
///
///     var body: some View {
///         Button("Complete Task") {
///             // ... perform task
///             showSuccess = true
///         }
///         .toast(isPresented: $showSuccess, message: "Task completed!", type: .success)
///     }
/// }
/// ```
///
/// - Note: `ToastManager` is marked with `@MainActor` and `@Observable`, making it
///   safe for use in SwiftUI views and automatically triggering view updates.
@MainActor
@Observable
public final class ToastManager {
    /// Maximum number of toasts that can be queued.
    ///
    /// When the queue reaches this limit, new toast requests are silently ignored.
    /// This prevents memory issues in scenarios where toasts are triggered rapidly.
    private let maxQueueSize: Int

    /// The identifier of the currently displayed toast, if any.
    ///
    /// This property is observed by ``ToastModifier`` instances to determine
    /// whether their associated toast should be visible.
    private(set) var currentToastID: String?

    /// Queue of toast IDs waiting to be displayed.
    ///
    /// Toasts are added to the end and removed from the front (FIFO order).
    private var toastQueue: [String] = []

    /// Creates a new toast manager with the specified queue size limit.
    ///
    /// ```swift
    /// // Default queue size of 10
    /// let manager = ToastManager()
    ///
    /// // Custom queue size for high-frequency scenarios
    /// let largerManager = ToastManager(maxQueueSize: 25)
    /// ```
    ///
    /// - Parameter maxQueueSize: The maximum number of toasts that can wait in the queue.
    ///   Once this limit is reached, additional toast requests are ignored until space
    ///   becomes available. Defaults to 10.
    public init(maxQueueSize: Int = 10) {
        self.maxQueueSize = maxQueueSize
    }

    /// Adds a toast to the display queue.
    ///
    /// The toast will be shown immediately if no other toast is currently displayed,
    /// otherwise it will wait in the queue until its turn.
    ///
    /// The request is silently ignored if:
    /// - The queue has reached its maximum size
    /// - The ID matches the currently displayed toast
    /// - The queue already contains this ID
    ///
    /// - Parameter id: A unique identifier for the toast. Each toast modifier generates
    ///   its own UUID, ensuring uniqueness within the view hierarchy.
    func enqueue(id: String) {
        guard toastQueue.count < maxQueueSize
              && currentToastID != id
              && !toastQueue.contains(id) else {
            return
        }

        toastQueue.append(id)

        if currentToastID == nil {
            showNextToast()
        }
    }

    /// Removes a toast from the queue or dismisses it if currently displayed.
    ///
    /// If the specified ID matches the currently visible toast, it will be dismissed
    /// and the next queued toast (if any) will be shown. If the ID is found in the
    /// queue, it will be removed without affecting the current display.
    ///
    /// - Parameter id: The unique identifier of the toast to remove.
    func dequeue(id: String) {
        if currentToastID == id {
            completeCurrentToast()
        } else if let index = toastQueue.firstIndex(of: id) {
            toastQueue.remove(at: index)
        }
    }

    /// Completes the current toast and advances to the next in queue.
    private func completeCurrentToast() {
        currentToastID = nil
        showNextToast()
    }

    /// Displays the next toast from the queue if available.
    private func showNextToast() {
        guard currentToastID == nil,
              !toastQueue.isEmpty else {
            return
        }

        currentToastID = toastQueue.removeFirst()
    }
}
