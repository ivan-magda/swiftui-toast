import Testing
@testable import SwiftUIToast

struct ToastAnimationTests {
    @Test("Slide animation can be created with default and custom parameters")
    func testSlideAnimation() {
        let animation = ToastAnimation.slide(edge: .bottom)
        #expect(animation != nil)

        // Test with custom duration
        let customAnimation = ToastAnimation.slide(edge: .top, duration: 2.0)
        #expect(customAnimation != nil)
    }

    @Test("All animation types can be created")
    func testAllAnimationTypes() {
        let animations: [ToastAnimation] = [
            .slide(edge: .bottom),
            .fade(),
            .scale(),
            .bounce(),
            .flip(),
            .slideWithBounce(edge: .top)
        ]

        // Verify all animations are created properly
        for animation in animations {
            #expect(animation.animation != nil)
            #expect(animation.transition != nil)
        }
    }

    @Test("Custom animations can be created with specific properties")
    func testCustomAnimation() {
        let customAnimation = ToastAnimation(
            animation: .spring(duration: 0.5),
            transition: .asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .opacity
            )
        )

        #expect(customAnimation != nil)
        #expect(customAnimation.animation != nil)
        #expect(customAnimation.transition != nil)
    }
}
