import Testing
@testable import SwiftUIToast

struct ToastConfigurationTests {
    @Test("Standard configuration has expected values")
    func testStandardConfiguration() {
        let config = ToastConfiguration.standard

        #expect(config.position == .bottom)
        #expect(config.duration == 3.0)
        #expect(config.tapToDismiss == true)
    }

    @Test("Positional configurations have correct positions")
    func testPositionalConfigurations() {
        let topConfig = ToastConfiguration.top
        #expect(topConfig.position == .top)

        let bottomConfig = ToastConfiguration.bottom
        #expect(bottomConfig.position == .bottom)
    }

    @Test("Animation configurations are valid")
    func testAnimationConfigurations() {
        // Test that each animation type creates a valid configuration
        let animations = [
            ToastConfiguration.bouncy(position: .bottom),
            ToastConfiguration.fade(position: .top),
            ToastConfiguration.flip(position: .bottom)
        ]

        for config in animations {
            // Verify each one has a valid animation
            #expect(config.animation.animation != nil)
            #expect(config.animation.transition != nil)
        }
    }

    @Test("Custom configuration preserves all properties")
    func testCustomConfiguration() {
        let customConfig = ToastConfiguration(
            duration: 5.0,
            position: .top,
            tapToDismiss: false,
            dismissDelay: 0.5,
            animation: .bounce()
        )

        #expect(customConfig.duration == 5.0)
        #expect(customConfig.position == .top)
        #expect(customConfig.tapToDismiss == false)
        #expect(customConfig.dismissDelay == 0.5)
    }
}
