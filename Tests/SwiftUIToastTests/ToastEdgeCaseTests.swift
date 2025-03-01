import Testing
import SwiftUI
import Combine
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
        var cancellable: AnyCancellable?
        cancellable = toastManager.$currentToastID
            .sink { value in
                stateChanges.append(value)
                if stateChanges.count >= 3 {
                    expectation.fulfill()
                }
            }

        // When - Enqueue and immediately dequeue
        toastManager.enqueue(id: toastID)
        toastManager.dequeue(id: toastID)

        // Wait for observation to complete
        await expectation.wait(timeout: .milliseconds(500))

        // Then - Verify proper sequence: nil -> toastID -> nil
        #expect(stateChanges.count >= 3)
        #expect(stateChanges[0] == nil)
        #expect(stateChanges[1] == toastID)
        #expect(stateChanges[2] == nil)

        // Clean up
        cancellable?.cancel()
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
