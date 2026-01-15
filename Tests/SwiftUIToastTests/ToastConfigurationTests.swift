import Testing
@testable import SwiftUIToast

struct ToastConfigurationTests {

    // MARK: - Standard Configuration Tests

    @Test("Standard configuration has expected default values")
    func testStandardConfiguration() {
        let config = ToastConfiguration.standard

        #expect(config.position == .bottom)
        #expect(config.duration == 3.0)
        #expect(config.tapToDismiss == true)
        #expect(config.dismissDelay == 0.2)
    }

    @Test("Standard configuration uses slide animation")
    func testStandardConfigurationAnimation() {
        let config = ToastConfiguration.standard
        #expect(type(of: config.animation) == ToastAnimation.self)
    }

    // MARK: - Positional Configuration Tests

    @Test("Top configuration has correct position and animation")
    func testTopConfiguration() {
        let config = ToastConfiguration.top

        #expect(config.position == .top)
        #expect(config.duration == 3.0)
        #expect(config.tapToDismiss == true)
    }

    @Test("Bottom configuration has correct position and animation")
    func testBottomConfiguration() {
        let config = ToastConfiguration.bottom

        #expect(config.position == .bottom)
        #expect(config.duration == 3.0)
        #expect(config.tapToDismiss == true)
    }

    @Test("Top and bottom configurations have different positions")
    func testPositionalDifference() {
        let topConfig = ToastConfiguration.top
        let bottomConfig = ToastConfiguration.bottom

        #expect(topConfig.position != bottomConfig.position)
    }

    // MARK: - Animation Preset Tests

    @Test("Bouncy configuration uses bounce animation")
    func testBouncyConfiguration() {
        let config = ToastConfiguration.bouncy()

        #expect(config.position == .bottom)
        #expect(type(of: config.animation) == ToastAnimation.self)
    }

    @Test("Bouncy configuration accepts custom position")
    func testBouncyConfigurationWithPosition() {
        let topBouncy = ToastConfiguration.bouncy(position: .top)
        let bottomBouncy = ToastConfiguration.bouncy(position: .bottom)

        #expect(topBouncy.position == .top)
        #expect(bottomBouncy.position == .bottom)
    }

    @Test("Fade configuration uses fade animation")
    func testFadeConfiguration() {
        let config = ToastConfiguration.fade()

        #expect(config.position == .bottom)
        #expect(type(of: config.animation) == ToastAnimation.self)
    }

    @Test("Fade configuration accepts custom position")
    func testFadeConfigurationWithPosition() {
        let topFade = ToastConfiguration.fade(position: .top)
        let bottomFade = ToastConfiguration.fade(position: .bottom)

        #expect(topFade.position == .top)
        #expect(bottomFade.position == .bottom)
    }

    @Test("Flip configuration uses flip animation")
    func testFlipConfiguration() {
        let config = ToastConfiguration.flip()

        #expect(config.position == .bottom)
        #expect(type(of: config.animation) == ToastAnimation.self)
    }

    @Test("Flip configuration accepts custom position")
    func testFlipConfigurationWithPosition() {
        let topFlip = ToastConfiguration.flip(position: .top)
        let bottomFlip = ToastConfiguration.flip(position: .bottom)

        #expect(topFlip.position == .top)
        #expect(bottomFlip.position == .bottom)
    }

    // MARK: - With Animation Helper Tests

    @Test("With animation helper creates configuration with custom animation")
    func testWithAnimationHelper() {
        let config = ToastConfiguration.with(animation: .scale())

        #expect(config.position == .bottom) // Inherits from standard
        #expect(type(of: config.animation) == ToastAnimation.self)
    }

    @Test("With animation helper preserves other standard defaults")
    func testWithAnimationPreservesDefaults() {
        let config = ToastConfiguration.with(animation: .bounce())

        #expect(config.duration == 3.0)
        #expect(config.tapToDismiss == true)
        #expect(config.dismissDelay == 0.2)
    }

    // MARK: - Custom Configuration Tests

    @Test("Custom configuration preserves all properties")
    func testCustomConfiguration() {
        let config = ToastConfiguration(
            duration: 5.0,
            position: .top,
            tapToDismiss: false,
            dismissDelay: 0.5,
            animation: .bounce()
        )

        #expect(config.duration == 5.0)
        #expect(config.position == .top)
        #expect(config.tapToDismiss == false)
        #expect(config.dismissDelay == 0.5)
    }

    @Test("Custom configuration with minimum values")
    func testCustomConfigurationMinimumValues() {
        let config = ToastConfiguration(
            duration: 0,
            position: .bottom,
            tapToDismiss: false,
            dismissDelay: 0,
            animation: .fade()
        )

        #expect(config.duration == 0)
        #expect(config.dismissDelay == 0)
        #expect(config.tapToDismiss == false)
    }

    @Test("Custom configuration with large values")
    func testCustomConfigurationLargeValues() {
        let config = ToastConfiguration(
            duration: 3600,
            position: .top,
            tapToDismiss: true,
            dismissDelay: 10.0,
            animation: .scale()
        )

        #expect(config.duration == 3600)
        #expect(config.dismissDelay == 10.0)
    }

    // MARK: - Configuration Mutability Tests

    @Test("Configuration properties can be modified")
    func testConfigurationMutability() {
        var config = ToastConfiguration.standard

        config.duration = 10.0
        config.position = .top
        config.tapToDismiss = false
        config.dismissDelay = 1.0
        config.animation = .bounce()

        #expect(config.duration == 10.0)
        #expect(config.position == .top)
        #expect(config.tapToDismiss == false)
        #expect(config.dismissDelay == 1.0)
    }

    @Test("Modifying one configuration doesn't affect another")
    func testConfigurationIndependence() {
        var config1 = ToastConfiguration.standard
        let config2 = ToastConfiguration.standard

        config1.duration = 99.0

        #expect(config1.duration == 99.0)
        #expect(config2.duration == 3.0)
    }

    // MARK: - All Animation Types Tests

    @Test("All preset configurations create valid configurations")
    func testAllPresetConfigurations() {
        let configs: [ToastConfiguration] = [
            .standard,
            .top,
            .bottom,
            .bouncy(),
            .bouncy(position: .top),
            .fade(),
            .fade(position: .top),
            .flip(),
            .flip(position: .top),
            .with(animation: .slide(edge: .bottom)),
            .with(animation: .scale()),
            .with(animation: .slideWithBounce(edge: .top))
        ]

        #expect(configs.count == 12)

        for config in configs {
            #expect(type(of: config) == ToastConfiguration.self)
            #expect(config.duration > 0 || config.duration == 0)
        }
    }

    // MARK: - Default Parameter Tests

    @Test("Init uses default duration of 3.0")
    func testDefaultDuration() {
        let config = ToastConfiguration(
            position: .bottom,
            animation: .fade()
        )

        #expect(config.duration == 3.0)
    }
    
    @Test("Init uses default tapToDismiss of true")
    func testDefaultTapToDismiss() {
        let config = ToastConfiguration(
            position: .bottom,
            animation: .fade()
        )

        #expect(config.tapToDismiss == true)
    }

    @Test("Init uses default dismissDelay of 0.2")
    func testDefaultDismissDelay() {
        let config = ToastConfiguration(
            position: .bottom,
            animation: .fade()
        )

        #expect(config.dismissDelay == 0.2)
    }
}
