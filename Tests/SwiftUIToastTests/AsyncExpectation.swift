import Foundation
import SwiftUI
import Testing
@testable import SwiftUIToast

/// Custom expectation for async testing with Swift Testing
actor AsyncExpectation {
    private var isFulfilled = false

    /// Marks the expectation as fulfilled
    func fulfill() {
        isFulfilled = true
    }

    /// Waits for the expectation to be fulfilled with a timeout
    /// - Parameter timeout: How long to wait before timing out
    func wait(timeout: Duration) async {
        let deadline = Date().addingTimeInterval(timeout.timeInterval)

        while true {
            if isFulfilled || Date() >= deadline {
                return
            }

            // Yield to allow other tasks to run
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}

/// Extension to convert Duration to TimeInterval
extension Duration {
    var timeInterval: TimeInterval {
        let components = self.components
        return TimeInterval(components.seconds) + TimeInterval(components.attoseconds) / 1e18
    }
}

/// Helper class for observing ToastManager changes in Swift 6 compatible way
@MainActor
final class ToastObserver {
    private let toastManager: ToastManager
    private let onChange: @MainActor (String?) -> Void
    private let onComplete: @MainActor () async -> Void
    private let targetChangeCount: Int
    private var changeCount = 0

    init(
        toastManager: ToastManager,
        onChangeCount: Int,
        onChange: @escaping @MainActor (String?) -> Void,
        onComplete: @escaping @MainActor () async -> Void
    ) {
        self.toastManager = toastManager
        self.targetChangeCount = onChangeCount
        self.onChange = onChange
        self.onComplete = onComplete
    }

    func startObserving() {
        observe()
    }

    private func observe() {
        withObservationTracking {
            _ = toastManager.currentToastID
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                self.changeCount += 1
                self.onChange(self.toastManager.currentToastID)

                if self.changeCount >= self.targetChangeCount {
                    await self.onComplete()
                    return
                }

                self.observe()
            }
        }
    }
}
