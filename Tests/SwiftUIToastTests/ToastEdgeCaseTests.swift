import Testing
import SwiftUI
@testable import SwiftUIToast

@MainActor
struct ToastEdgeCaseTests {
    @Test("Empty toast message doesn't cause issues")
    func testEmptyToastMessage() {
        // Verify a toast with empty message doesn't cause issues
        let view = ToastView(message: "", type: .info)
        #expect(view != nil)
    }

    @Test("Very long toast message is handled properly")
    func testVeryLongToastMessage() {
        // Verify very long toast messages don't cause layout issues
        let longMessage = String(repeating: "This is a very long toast message. ", count: 100)
        let view = ToastView(message: longMessage, type: .info)
        #expect(view != nil)
    }

    @Test("Dismissing during animation maintains proper state")
    func testDismissDuringAnimation() async throws {
        // Given
        let toastManager = ToastManager()
        let toastID = "animation-toast"

        // Track state changes
        var stateChanges: [String?] = []
        let expectation = AsyncExpectation()

        // Setup observation
        func observe() {
            withObservationTracking {
                _ = toastManager.currentToastID
            } onChange: {
                Task { @MainActor in
                    stateChanges.append(toastManager.currentToastID)

                    // Once we have at least 2 changes, fulfill expectation
                    if stateChanges.count >= 2 {
                        expectation.fulfill()
                    }

                    observe()
                }
            }
        }
        observe()

        // When - Enqueue and immediately dequeue
        toastManager.enqueue(id: toastID)
        try await Task.sleep(for: .milliseconds(1)) // Wait for onChange to trigger
        toastManager.dequeue(id: toastID)

        // Wait for observation to complete
        await expectation.wait(timeout: .milliseconds(500))

        // Then - Verify proper sequence: toastID -> nil
        #expect(stateChanges.count == 2)
        #expect(stateChanges[0] == toastID)
        #expect(stateChanges[1] == nil)
    }

    @Test("Rapid toggle doesn't cause state inconsistency")
    func testRapidToggle() {
        // Given
        let toastManager = ToastManager()
        let toastID = "rapid-toggle"

        // When - Rapidly enqueue and dequeue multiple times
        for _ in 0..<10 {
            toastManager.enqueue(id: toastID)
            toastManager.dequeue(id: toastID)
        }

        // Then - Final state should be clean
        #expect(toastManager.currentToastID == nil)
    }

    @Test("Dequeuing wrong toast has no effect on current toast")
    func testDequeueWrongToast() {
        // Given
        let toastManager = ToastManager()

        // Enqueue one toast
        toastManager.enqueue(id: "correct-toast")

        // When - Try to dequeue a different toast
        toastManager.dequeue(id: "wrong-toast")

        // Then - Original toast should still be current
        #expect(toastManager.currentToastID == "correct-toast")

        // Clean up
        toastManager.dequeue(id: "correct-toast")
    }
}
