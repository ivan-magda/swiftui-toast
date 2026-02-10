import Foundation
import SwiftUI
import Testing
@testable import SwiftUIToast

/// Helper class for observing ToastManager changes in Swift 6 compatible way
@MainActor
final class ToastObserver {
    private let toastManager: ToastManager
    private let onChange: @MainActor (String?) -> Void
    private let onComplete: @MainActor () -> Void
    private let targetChangeCount: Int
    private var changeCount = 0

    init(
        toastManager: ToastManager,
        onChangeCount: Int,
        onChange: @escaping @MainActor (String?) -> Void,
        onComplete: @escaping @MainActor () -> Void
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
                    self.onComplete()
                    return
                }

                self.observe()
            }
        }
    }
}
