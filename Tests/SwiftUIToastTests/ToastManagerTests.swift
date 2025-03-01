import Testing
@testable import SwiftUIToast

@MainActor
struct ToastManagerTests {
    // Helper function to create a fresh ToastManager for each test
    func createToastManager(maxQueueSize: Int = 10) -> ToastManager {
        ToastManager(maxQueueSize: maxQueueSize)
    }

    @Test("Initial state has nil currentToastID")
    func testInitialState() {
        let toastManager = createToastManager()
        #expect(toastManager.currentToastID == nil)
    }

    @Test("Basic enqueue and dequeue works correctly")
    func testSingleEnqueueDequeue() {
        // Given
        let toastManager = createToastManager()
        let toastID = "test-toast"

        // When
        toastManager.enqueue(id: toastID)

        // Then
        #expect(toastManager.currentToastID == toastID, "Enqueued toast should become current")

        // When
        toastManager.dequeue(id: toastID)

        // Then
        #expect(toastManager.currentToastID == nil, "Current toast should be nil after dequeue")
    }

    @Test("Dequeuing a non-existent toast has no effect")
    func testDequeueNonExistentToast() {
        // Given
        let toastManager = createToastManager()

        // When - Dequeue a toast that doesn't exist
        toastManager.dequeue(id: "non-existent")

        // Then - Should have no effect
        #expect(toastManager.currentToastID == nil)
    }

    @Test("Toasts are shown in queue order")
    func testQueueOrder() {
        // Given
        let toastManager = createToastManager()
        let toastIDs = ["toast-1", "toast-2", "toast-3"]

        // When - Enqueue multiple toasts
        for id in toastIDs {
            toastManager.enqueue(id: id)
        }

        // Then - First toast should be current
        #expect(toastManager.currentToastID == toastIDs[0], "First toast should be current")

        // When - Dequeue the first toast
        toastManager.dequeue(id: toastIDs[0])

        // Then - Second toast should become current
        #expect(toastManager.currentToastID == toastIDs[1], "Second toast should become current")

        // When - Dequeue the second toast
        toastManager.dequeue(id: toastIDs[1])

        // Then - Third toast should become current
        #expect(toastManager.currentToastID == toastIDs[2], "Third toast should become current")

        // When - Dequeue the third toast
        toastManager.dequeue(id: toastIDs[2])

        // Then - Should be nil
        #expect(toastManager.currentToastID == nil, "No toasts should remain")
    }

    @Test("Queue respects maximum size")
    func testQueueLimit() {
        // Given - A toast manager with max queue size of 3
        let maxSize = 3
        let limitedManager = createToastManager(maxQueueSize: maxSize)

        // When - Try to enqueue 5 toasts
        for i in 1...5 {
            limitedManager.enqueue(id: "toast-\(i)")
        }

        // Then - First toast should be current
        #expect(limitedManager.currentToastID == "toast-1", "First toast should be current")

        // Dequeue all and count
        var count = 0
        while limitedManager.currentToastID != nil {
            if let current = limitedManager.currentToastID {
                limitedManager.dequeue(id: current)
                count += 1
            }
        }

        // Should only have processed 4 toasts (1 current + 3 queued)
        #expect(count == 4, "Should only process up to max queue size + 1")
    }

    @Test("Duplicate enqueue requests are ignored")
    func testDuplicateEnqueue() {
        // Given
        let toastManager = createToastManager()
        let toastID = "duplicate-toast"

        // When - Enqueue the same toast twice
        toastManager.enqueue(id: toastID)
        toastManager.enqueue(id: toastID) // This should be ignored

        // Then - Should be the current toast
        #expect(toastManager.currentToastID == toastID)

        // When - Dequeue it
        toastManager.dequeue(id: toastID)

        // Then - Should be nil (no duplicates)
        #expect(toastManager.currentToastID == nil, "No duplicates should be in the queue")
    }

    @Test("Can dequeue a toast from the middle of the queue")
    func testDequeueFromMiddleOfQueue() {
        // Given - Three queued toasts
        let toastManager = createToastManager()
        let toastIDs = ["toast-1", "toast-2", "toast-3"]
        for id in toastIDs {
            toastManager.enqueue(id: id)
        }

        // When - Dequeue the middle toast while it's still in queue
        toastManager.dequeue(id: "toast-2")

        // Then - First toast should be current
        #expect(toastManager.currentToastID == "toast-1")

        // When - Dequeue the first toast
        toastManager.dequeue(id: "toast-1")

        // Then - Third toast should now be current (second was removed)
        #expect(toastManager.currentToastID == "toast-3")
    }

    @Test("Concurrent enqueue operations maintain correct state")
    @MainActor
    func testConcurrentEnqueueOperations() async throws {
        // Given
        let toastManager = createToastManager()
        let operations = 10

        // When - Perform concurrent operations using task group
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<operations {
                group.addTask {
                    await MainActor.run {
                        toastManager.enqueue(id: "concurrent-\(i)")
                    }
                }
            }

            // Wait for all tasks to complete
            await group.waitForAll()
        }

        // Then - Verify state is valid
        #expect(toastManager.currentToastID != nil, "A toast should be showing")

        // Clean up
        while let currentID = toastManager.currentToastID {
            toastManager.dequeue(id: currentID)
        }

        // Final state check
        #expect(toastManager.currentToastID == nil, "Final state should be clean")
    }

    @Test("Rapid enqueue/dequeue operations maintain consistent state")
    @MainActor
    func testRapidEnqueueDequeue() async throws {
        // Given
        let toastManager = createToastManager()
        let operations = 100

        // When - Perform rapid alternating operations
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<operations {
                group.addTask {
                    Task { @MainActor in
                        let id = "rapid-\(i)"
                        toastManager.enqueue(id: id)
                        // Small delay to simulate real usage pattern
                        try? await Task.sleep(for: .microseconds(100)) // 0.1ms
                        toastManager.dequeue(id: id)
                    }
                }
            }

            // Wait for all tasks to complete
            await group.waitForAll()
        }

        // Then - Allow time for all operations to complete
        try? await Task.sleep(for: .milliseconds(500))

        // Verify final state is clean
        #expect(toastManager.currentToastID == nil, "Manager should return to clean state")
    }

    @Test("Interleaved operations maintain consistent state")
    @MainActor
    func testInterleavedOperations() async throws {
        // Given
        let toastManager = createToastManager()

        // Queue up several toasts
        for i in 1...5 {
            toastManager.enqueue(id: "toast-\(i)")
        }

        // When - Perform interleaved operations
        // Dequeue the current toast
        if let currentID = toastManager.currentToastID {
            toastManager.dequeue(id: currentID)
        }

        // Enqueue a new toast
        toastManager.enqueue(id: "interleaved-1")

        // Dequeue the new current toast
        if let currentID = toastManager.currentToastID {
            toastManager.dequeue(id: currentID)
        }

        // Enqueue another toast
        toastManager.enqueue(id: "interleaved-2")

        // Then - Verify we still have a valid state
        #expect(toastManager.currentToastID != nil)

        // Clean up
        while let currentID = toastManager.currentToastID {
            toastManager.dequeue(id: currentID)
        }

        // Final state check
        #expect(toastManager.currentToastID == nil)
    }
}
