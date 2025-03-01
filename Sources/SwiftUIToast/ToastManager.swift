import SwiftUI

/// Manages the queue of toast notifications to display one at a time
///
/// `ToastManager` is responsible for:
/// - Maintaining a queue of toast notifications
/// - Displaying toasts in the order they were added
/// - Limiting the number of queued toasts to prevent memory issues
/// - Managing the lifecycle of each toast
///
/// You should typically create a single `ToastManager` instance and share it
/// throughout your application as an environment object.
///
/// ```swift
/// @main
/// struct MyApp: App {
///     @StateObject private var toastManager = ToastManager()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environmentObject(toastManager)
///         }
///     }
/// }
/// ```
@MainActor
public class ToastManager: ObservableObject {
    /// Maximum number of toasts that can be queued
    private let maxQueueSize: Int

    /// The currently displayed toast ID
    @Published private(set) var currentToastID: String?

    /// Queue of toast IDs waiting to be displayed
    private var toastQueue: [String] = []

    /// Creates a new toast manager
    /// - Parameter maxQueueSize: Maximum number of toasts to queue (default: 10)
    public init(maxQueueSize: Int = 10) {
        self.maxQueueSize = maxQueueSize
    }

    /// Adds a toast to the queue
    /// - Parameter id: Unique identifier for the toast
    ///
    /// If the queue is full or already contains the given ID, the toast will not be added.
    /// If no toast is currently displayed, the added toast will be shown immediately.
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

    /// Removes a toast from the queue or current display
    /// - Parameter id: Unique identifier for the toast
    ///
    /// If the given ID matches the currently displayed toast, it will be dismissed
    /// and the next toast in the queue will be shown.
    func dequeue(id: String) {
        if currentToastID == id {
            completeCurrentToast()
        } else if let index = toastQueue.firstIndex(of: id) {
            toastQueue.remove(at: index)
        }
    }

    /// Completes the current toast and shows the next one
    private func completeCurrentToast() {
        currentToastID = nil
        showNextToast()
    }

    /// Shows the next toast in the queue
    private func showNextToast() {
        guard currentToastID == nil,
              !toastQueue.isEmpty else {
            return
        }

        currentToastID = toastQueue.removeFirst()
    }
}
