import Foundation
import Testing

/// Custom expectation for async testing with Swift Testing
final class AsyncExpectation {
    private var isFulfilled = false
    private let lock = NSLock()

    /// Marks the expectation as fulfilled
    func fulfill() {
        lock.lock()
        isFulfilled = true
        lock.unlock()
    }

    /// Waits for the expectation to be fulfilled with a timeout
    /// - Parameter timeout: How long to wait before timing out
    func wait(timeout: Duration) async {
        let deadline = Date().addingTimeInterval(timeout.timeInterval)

        while true {
            lock.lock()
            let fulfilled = isFulfilled
            lock.unlock()

            if fulfilled || Date() >= deadline {
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
