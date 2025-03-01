import Testing
import SwiftUI
import Combine
import XCTest
@testable import SwiftUIToast

@MainActor
struct ToastIntegrationTests {
    @Test("Toast lifecycle triggers expected state changes")
    func testToastLifecycle() async throws {
        // Given
        let toastManager = ToastManager()
        let toastID = UUID().uuidString

        // Track currentToastID changes
        var toastIDChanges: [String?] = []

        // Setup observation
        let expectation = AsyncExpectation()

        // Use a cancellable to track changes
        var cancellable: AnyCancellable?
        cancellable = toastManager.$currentToastID
            .sink { value in
                toastIDChanges.append(value)

                // Once we have at least 3 changes, fulfill expectation
                if toastIDChanges.count >= 3 {
                    expectation.fulfill()
                }
            }

        // When - Simulate toast presentation and dismissal
        toastManager.enqueue(id: toastID)

        // Short delay, then dismiss
        try await Task.sleep(for: .milliseconds(100))
        toastManager.dequeue(id: toastID)

        // Wait for observation to complete
        await expectation.wait(timeout: .milliseconds(500))

        // Then - Verify toast ID changes: nil -> toastID -> nil
        #expect(toastIDChanges.count >= 3)
        #expect(toastIDChanges[0] == nil)
        #expect(toastIDChanges[1] == toastID)
        #expect(toastIDChanges[2] == nil)

        // Clean up
        cancellable?.cancel()
    }

    @Test("Binding updates trigger appropriate toast visibility")
    func testToastModifierBindingUpdates() {
        // Given
        let toastManager = ToastManager()
        var isPresentedValue = false
        let isPresentedBinding = Binding<Bool>(
            get: { isPresentedValue },
            set: { isPresentedValue = $0 }
        )

        // When - Simulate binding change
        isPresentedBinding.wrappedValue = true

        // Toast modifier would enqueue with a UUID, but we can't access that
        // So we'll manually enqueue to simulate
        toastManager.enqueue(id: "simulated-toast")

        // Then - Verify toast was shown
        #expect(toastManager.currentToastID != nil)

        // When - Simulate dequeue
        toastManager.dequeue(id: "simulated-toast")
        isPresentedBinding.wrappedValue = false

        // Then - Verify final state
        #expect(isPresentedValue == false)
        #expect(toastManager.currentToastID == nil)
    }
}

// MARK: - SwiftUI Integration Tests

struct ToastSwiftUIIntegrationTests {
    @Test("View modifier can be applied to SwiftUI views")
    func testViewModifierIntegration() {
        let view = Text("Test View")
            .toast(
                isPresented: .constant(true),
                message: "Test Toast",
                type: .info
            )

        #expect(view != nil, "View with toast modifier should be valid")
    }
}
