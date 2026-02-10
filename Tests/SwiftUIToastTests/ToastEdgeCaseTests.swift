import Testing
import SwiftUI
@testable import SwiftUIToast

@MainActor
struct ToastEdgeCaseTests {

    // MARK: - Message Edge Cases

    @Test("Empty toast message creates valid view")
    func emptyToastMessage() {
        let view = ToastView(message: "", type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Single character message creates valid view")
    func singleCharacterMessage() {
        let view = ToastView(message: "!", type: .success)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Very long message is handled properly")
    func veryLongToastMessage() {
        let longMessage = String(repeating: "This is a very long toast message. ", count: 100)
        let view = ToastView(message: longMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Message with special characters is handled")
    func specialCharactersMessage() {
        let specialMessage = "🎉 Success! <script>alert('xss')</script> & \"quotes\" 'apostrophes'"
        let view = ToastView(message: specialMessage, type: .success)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Message with newlines is handled")
    func newlinesMessage() {
        let multilineMessage = "Line 1\nLine 2\nLine 3\nLine 4"
        let view = ToastView(message: multilineMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Message with only whitespace is handled")
    func whitespaceOnlyMessage() {
        let whitespaceMessage = "   \t\n   "
        let view = ToastView(message: whitespaceMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    @Test("Unicode message is handled")
    func unicodeMessage() {
        let unicodeMessage = "日本語テスト العربية עברית 中文测试"
        let view = ToastView(message: unicodeMessage, type: .info)
        #expect(type(of: view) == ToastView.self)
    }

    // MARK: - Toast Manager Queue Edge Cases

    @Test("Empty toast ID string is handled")
    func emptyToastID() {
        let toastManager = ToastManager()

        toastManager.enqueue(id: "")
        #expect(toastManager.currentToastID?.isEmpty == true)

        toastManager.dequeue(id: "")
        #expect(toastManager.currentToastID == nil)
    }

    // MARK: - Configuration Edge Cases

    @Test("Zero duration configuration is valid")
    func zeroDurationConfiguration() {
        let config = ToastConfiguration(
            duration: 0,
            position: .bottom,
            animation: .fade()
        )

        #expect(config.duration == 0)
    }

    @Test("Very long duration configuration is valid")
    func veryLongDurationConfiguration() {
        let config = ToastConfiguration(
            duration: 3600, // 1 hour
            position: .top,
            animation: .slide(edge: .top)
        )

        #expect(config.duration == 3600)
    }

    @Test("Negative dismiss delay doesn't crash")
    func negativeDismissDelay() {
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
    func zeroDismissDelay() {
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
    func dismissDuringAnimation() async throws {
        let toastManager = ToastManager()
        let toastID = "animation-toast"

        var stateChanges: [String?] = []

        try await confirmation { confirm in
            let observer = ToastObserver(
                toastManager: toastManager,
                onChangeCount: 2
            ) { currentID in
                stateChanges.append(currentID)
            } onComplete: {
                confirm()
            }
            observer.startObserving()

            toastManager.enqueue(id: toastID)
            try await Task.sleep(for: .milliseconds(1))
            toastManager.dequeue(id: toastID)

            try await Task.sleep(for: .milliseconds(500))
        }

        #expect(stateChanges.count == 2)
        #expect(stateChanges[0] == toastID)
        #expect(stateChanges[1] == nil)
    }

    @Test("Multiple toasts enqueued rapidly are processed correctly")
    func rapidEnqueue() async throws {
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
    func allToastTypes() {
        let types: [ToastType] = [.success, .error, .info]

        for toastType in types {
            let view = ToastView(message: "Test", type: toastType)
            #expect(type(of: view) == ToastView.self)
        }
    }

    @Test("Toast type icon properties are accessible")
    func toastTypeIcons() {
        #expect(ToastType.success.icon == "checkmark.circle.fill")
        #expect(ToastType.error.icon == "exclamationmark.circle.fill")
        #expect(ToastType.info.icon == "info.circle.fill")
    }

    @Test("Toast type colors are accessible")
    func toastTypeColors() {
        #expect(ToastType.success.iconColor == .green)
        #expect(ToastType.error.iconColor == .red)
        #expect(ToastType.info.iconColor == .accentColor)
    }
}
