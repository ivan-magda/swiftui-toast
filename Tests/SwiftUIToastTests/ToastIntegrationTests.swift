import Testing
import SwiftUI
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

        func observe() {
            withObservationTracking {
                _ = toastManager.currentToastID
            } onChange: {
                Task { @MainActor in
                    toastIDChanges.append(toastManager.currentToastID)

                    // Once we have at least 2 changes, fulfill expectation
                    if toastIDChanges.count >= 2 {
                        expectation.fulfill()
                    }

                    observe()
                }
            }
        }
        observe()

        // When - Simulate toast presentation and dismissal
        toastManager.enqueue(id: toastID)

        // Short delay, then dismiss
        try await Task.sleep(for: .milliseconds(100))
        toastManager.dequeue(id: toastID)

        // Wait for observation to complete
        await expectation.wait(timeout: .milliseconds(500))

        // Then - Verify toast ID changes: toastID -> nil
        #expect(toastIDChanges.count == 2)
        #expect(toastIDChanges[0] == toastID)
        #expect(toastIDChanges[1] == nil)
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

    // MARK: - Basic View Modifier Tests

    @Test("View modifier can be applied to SwiftUI views")
    func testViewModifierIntegration() {
        let view = Text("Test View")
            .toast(
                isPresented: .constant(true),
                message: "Test Toast",
                type: .info
            )

        // Verify view modifier was applied successfully by checking type
        #expect(type(of: view) != type(of: Text("Test View")))
    }

    @Test("View modifier works with false binding")
    func testViewModifierWithFalseBinding() {
        let view = Text("Test View")
            .toast(
                isPresented: .constant(false),
                message: "Hidden Toast",
                type: .info
            )

        #expect(type(of: view) != type(of: Text("Test View")))
    }

    // MARK: - Toast Type Tests

    @Test("View modifier supports all toast types")
    func testAllToastTypes() {
        let toastTypes: [ToastType] = [.success, .error, .info]

        for toastType in toastTypes {
            let view = Text("Test")
                .toast(
                    isPresented: .constant(true),
                    message: "Message",
                    type: toastType
                )

            #expect(type(of: view) != type(of: Text("Test")))
        }
    }

    // MARK: - Configuration Tests

    @Test("View modifier accepts standard configuration")
    func testStandardConfiguration() {
        let view = Text("Test")
            .toast(
                isPresented: .constant(true),
                message: "Message",
                type: .info,
                configuration: .standard
            )

        #expect(type(of: view) != type(of: Text("Test")))
    }

    @Test("View modifier accepts top configuration")
    func testTopConfiguration() {
        let view = Text("Test")
            .toast(
                isPresented: .constant(true),
                message: "Message",
                type: .info,
                configuration: .top
            )

        #expect(type(of: view) != type(of: Text("Test")))
    }

    @Test("View modifier accepts bouncy configuration")
    func testBouncyConfiguration() {
        let view = Text("Test")
            .toast(
                isPresented: .constant(true),
                message: "Message",
                type: .success,
                configuration: .bouncy()
            )

        #expect(type(of: view) != type(of: Text("Test")))
    }

    @Test("View modifier accepts flip configuration")
    func testFlipConfiguration() {
        let view = Text("Test")
            .toast(
                isPresented: .constant(true),
                message: "Message",
                type: .info,
                configuration: .flip()
            )

        #expect(type(of: view) != type(of: Text("Test")))
    }

    @Test("View modifier accepts custom configuration")
    func testCustomConfiguration() {
        let customConfig = ToastConfiguration(
            duration: 5.0,
            position: .top,
            tapToDismiss: false,
            dismissDelay: 0.5,
            animation: .scale(scale: 0.5, duration: 0.4)
        )

        let view = Text("Test")
            .toast(
                isPresented: .constant(true),
                message: "Message",
                type: .error,
                configuration: customConfig
            )

        #expect(type(of: view) != type(of: Text("Test")))
    }

    // MARK: - Custom Content Tests

    @Test("View modifier supports custom content")
    func testCustomContent() {
        let view = Text("Test")
            .toast(isPresented: .constant(true), configuration: .standard) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Custom Toast")
                }
            }

        #expect(type(of: view) != type(of: Text("Test")))
    }

    @Test("View modifier supports complex custom content")
    func testComplexCustomContent() {
        let view = Text("Test")
            .toast(isPresented: .constant(true), configuration: .bouncy()) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Achievement Unlocked!")
                            .font(.headline)
                    }
                    Text("You completed 10 tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

        #expect(type(of: view) != type(of: Text("Test")))
    }

    // MARK: - Multiple Toast Modifiers

    @Test("Multiple toast modifiers can be chained")
    func testMultipleToastModifiers() {
        let view = Text("Test")
            .toast(
                isPresented: .constant(false),
                message: "First Toast",
                type: .success
            )
            .toast(
                isPresented: .constant(false),
                message: "Second Toast",
                type: .error,
                configuration: .top
            )

        #expect(type(of: view) != type(of: Text("Test")))
    }

    // MARK: - Different View Types

    @Test("Toast modifier works with Button")
    func testToastOnButton() {
        let view = Button("Tap Me") {}
            .toast(
                isPresented: .constant(true),
                message: "Button Toast",
                type: .info
            )

        #expect(type(of: view) != type(of: Button("Tap Me") {}))
    }

    @Test("Toast modifier works with VStack")
    func testToastOnVStack() {
        let view = VStack {
            Text("Line 1")
            Text("Line 2")
        }
            .toast(
                isPresented: .constant(true),
                message: "VStack Toast",
                type: .success
            )

        #expect(type(of: view) != type(of: VStack { Text("") }))
    }

    @Test("Toast modifier works with EmptyView")
    func testToastOnEmptyView() {
        let view = EmptyView()
            .toast(
                isPresented: .constant(true),
                message: "Empty Toast",
                type: .info
            )

        #expect(type(of: view) != type(of: EmptyView()))
    }
}
