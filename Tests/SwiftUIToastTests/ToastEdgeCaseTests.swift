import Testing
import SwiftUI
@testable import SwiftUIToast

@MainActor
struct ToastEdgeCaseTests {

    // MARK: - Message Edge Cases

    @Test("Empty toast message creates valid view")
    func testEmptyToastMessage() {
        let view = ToastView(message: "", type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Single character message creates valid view")
    func testSingleCharacterMessage() {
        let view = ToastView(message: "!", type: .success)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Very long message is handled properly")
    func testVeryLongToastMessage() {
        let longMessage = String(repeating: "This is a very long toast message. ", count: 100)
        let view = ToastView(message: longMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Message with special characters is handled")
    func testSpecialCharactersMessage() {
        let specialMessage = "🎉 Success! <script>alert('xss')</script> & \"quotes\" 'apostrophes'"
        let view = ToastView(message: specialMessage, type: .success)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Message with newlines is handled")
    func testNewlinesMessage() {
        let multilineMessage = "Line 1\nLine 2\nLine 3\nLine 4"
        let view = ToastView(message: multilineMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Message with only whitespace is handled")
    func testWhitespaceOnlyMessage() {
        let whitespaceMessage = "   \t\n   "
        let view = ToastView(message: whitespaceMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Unicode message is handled")
    func testUnicodeMessage() {
        let unicodeMessage = "日本語テスト العربية עברית 中文测试"
        let view = ToastView(message: unicodeMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    // MARK: - Toast Manager Queue Edge Cases

    @Test("Dequeuing wrong toast has no effect on current toast")
    func testDequeueWrongToast() {
        let toastManager = ToastManager()

        toastManager.enqueue(id: "correct-toast")
        toastManager.dequeue(id: "wrong-toast")

        #expect(toastManager.currentToastID == "correct-toast")

        toastManager.dequeue(id: "correct-toast")
    }

    @Test("Rapid toggle doesn't cause state inconsistency")
    func testRapidToggle() {
        let toastManager = ToastManager()
        let toastID = "rapid-toggle"

        for _ in 0..<10 {
            toastManager.enqueue(id: toastID)
            toastManager.dequeue(id: toastID)
        }

        #expect(toastManager.currentToastID == nil)
    }

    @Test("Queue respects maximum size limit")
    func testQueueMaxSizeLimit() {
        let maxSize = 3
        let toastManager = ToastManager(maxQueueSize: maxSize)

        // Show first toast
        toastManager.enqueue(id: "toast-1")
        #expect(toastManager.currentToastID == "toast-1")

        // Fill the queue
        for i in 2...(maxSize + 1) {
            toastManager.enqueue(id: "toast-\(i)")
        }

        // Try to add one more - should be ignored
        toastManager.enqueue(id: "toast-overflow")

        // Dequeue all and verify only maxSize toasts were queued
        var dequeuedCount = 0
        while toastManager.currentToastID != nil {
            toastManager.dequeue(id: toastManager.currentToastID!)
            dequeuedCount += 1
        }

        #expect(dequeuedCount == maxSize + 1) // 1 current + maxSize queued
    }

    @Test("Duplicate toast IDs are not queued")
    func testDuplicateToastPrevention() {
        let toastManager = ToastManager()

        toastManager.enqueue(id: "duplicate-toast")
        toastManager.enqueue(id: "duplicate-toast")
        toastManager.enqueue(id: "duplicate-toast")

        #expect(toastManager.currentToastID == "duplicate-toast")

        toastManager.dequeue(id: "duplicate-toast")

        #expect(toastManager.currentToastID == nil)
    }

    @Test("Dequeuing from empty manager has no effect")
    func testDequeueFromEmptyManager() {
        let toastManager = ToastManager()

        #expect(toastManager.currentToastID == nil)

        toastManager.dequeue(id: "nonexistent-toast")

        #expect(toastManager.currentToastID == nil)
    }

    @Test("Empty toast ID string is handled")
    func testEmptyToastID() {
        let toastManager = ToastManager()

        toastManager.enqueue(id: "")
        #expect(toastManager.currentToastID == "")

        toastManager.dequeue(id: "")
        #expect(toastManager.currentToastID == nil)
    }

    @Test("Queue processes toasts in FIFO order")
    func testFIFOOrder() {
        let toastManager = ToastManager()

        toastManager.enqueue(id: "first")
        toastManager.enqueue(id: "second")
        toastManager.enqueue(id: "third")

        #expect(toastManager.currentToastID == "first")

        toastManager.dequeue(id: "first")
        #expect(toastManager.currentToastID == "second")

        toastManager.dequeue(id: "second")
        #expect(toastManager.currentToastID == "third")

        toastManager.dequeue(id: "third")
        #expect(toastManager.currentToastID == nil)
    }

    @Test("Removing queued toast before it displays")
    func testRemoveQueuedToast() {
        let toastManager = ToastManager()

        toastManager.enqueue(id: "current")
        toastManager.enqueue(id: "queued-to-remove")
        toastManager.enqueue(id: "next")

        // Remove the middle toast from queue
        toastManager.dequeue(id: "queued-to-remove")

        #expect(toastManager.currentToastID == "current")

        toastManager.dequeue(id: "current")
        #expect(toastManager.currentToastID == "next")

        toastManager.dequeue(id: "next")
        #expect(toastManager.currentToastID == nil)
    }

    // MARK: - Configuration Edge Cases

    @Test("Zero duration configuration is valid")
    func testZeroDurationConfiguration() {
        let config = ToastConfiguration(
            duration: 0,
            position: .bottom,
            animation: .fade()
        )

        #expect(config.duration == 0)
    }

    @Test("Very long duration configuration is valid")
    func testVeryLongDurationConfiguration() {
        let config = ToastConfiguration(
            duration: 3600, // 1 hour
            position: .top,
            animation: .slide(edge: .top)
        )

        #expect(config.duration == 3600)
    }

    @Test("Negative dismiss delay doesn't crash")
    func testNegativeDismissDelay() {
        let config = ToastConfiguration(
            duration: 3.0,
            position: .bottom,
            tapToDismiss: true,
            dismissDelay: -1.0,
            animation: .fade()
        )

        #expect(config.dismissDelay == -1.0)
    }

    @Test("Zero dismiss delay is valid")
    func testZeroDismissDelay() {
        let config = ToastConfiguration(
            duration: 3.0,
            position: .bottom,
            tapToDismiss: true,
            dismissDelay: 0,
            animation: .fade()
        )

        #expect(config.dismissDelay == 0)
    }

    // MARK: - Async Behavior Tests

    @Test("Dismissing during animation maintains proper state")
    func testDismissDuringAnimation() async throws {
        let toastManager = ToastManager()
        let toastID = "animation-toast"

        var stateChanges: [String?] = []
        let expectation = AsyncExpectation()

        func observe() {
            withObservationTracking {
                _ = toastManager.currentToastID
            } onChange: {
                Task { @MainActor in
                    stateChanges.append(toastManager.currentToastID)

                    if stateChanges.count >= 2 {
                        expectation.fulfill()
                    }

                    observe()
                }
            }
        }
        observe()

        toastManager.enqueue(id: toastID)
        try await Task.sleep(for: .milliseconds(1))
        toastManager.dequeue(id: toastID)

        await expectation.wait(timeout: .milliseconds(500))

        #expect(stateChanges.count == 2)
        #expect(stateChanges[0] == toastID)
        #expect(stateChanges[1] == nil)
    }

    @Test("Multiple toasts enqueued rapidly are processed correctly")
    func testRapidEnqueue() async throws {
        let toastManager = ToastManager()

        // Rapidly enqueue multiple toasts
        for i in 1...5 {
            toastManager.enqueue(id: "rapid-\(i)")
        }

        #expect(toastManager.currentToastID == "rapid-1")

        // Dequeue all and verify order
        var order: [String] = []
        while let current = toastManager.currentToastID {
            order.append(current)
            toastManager.dequeue(id: current)
        }

        #expect(order == ["rapid-1", "rapid-2", "rapid-3", "rapid-4", "rapid-5"])
    }

    // MARK: - Toast Type Edge Cases

    @Test("All toast types create valid views")
    func testAllToastTypes() {
        let types: [ToastType] = [.success, .error, .info]

        for toastType in types {
            let view = ToastView(message: "Test", type: toastType)
            #expect(type(of: view) == ToastView.self)
        }
    }

    @Test("Toast type icon properties are accessible")
    func testToastTypeIcons() {
        #expect(ToastType.success.icon == "checkmark.circle.fill")
        #expect(ToastType.error.icon == "exclamationmark.circle.fill")
        #expect(ToastType.info.icon == "info.circle.fill")
    }

    @Test("Toast type colors are accessible")
    func testToastTypeColors() {
        #expect(ToastType.success.iconColor == .green)
        #expect(ToastType.error.iconColor == .red)
        #expect(ToastType.info.iconColor == .accentColor)
    }
}
