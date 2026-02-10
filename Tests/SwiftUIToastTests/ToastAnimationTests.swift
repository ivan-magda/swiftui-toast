import SwiftUI
import Testing
@testable import SwiftUIToast

struct ToastAnimationTests {

    // MARK: - FlipEffect Tests

    @Test("FlipEffect exposes angle as animatableData")
    @MainActor
    func flipEffectAnimatableData() {
        var effect = FlipEffect(angle: 90, axis: (x: 0, y: 1))
        #expect(effect.animatableData == 90)

        effect.animatableData = 45
        #expect(effect.angle == 45)
    }

    // MARK: - Slide Animation Tests

    @Test("Slide animation supports all edge directions")
    func slideAnimationEdges() {
        let edges: [Edge] = [.top, .bottom, .leading, .trailing]

        for edge in edges {
            let animation = ToastAnimation.slide(edge: edge)
            #expect(type(of: animation) == ToastAnimation.self)
        }
    }

    @Test("Slide animation uses default duration of 0.35 seconds")
    func slideAnimationDefaultDuration() {
        let animation = ToastAnimation.slide(edge: .bottom)
        #expect(type(of: animation.animation) == Animation.self)
    }

    @Test("Slide animation accepts custom duration")
    func slideAnimationCustomDuration() {
        let durations: [TimeInterval] = [0.1, 0.5, 1.0, 2.0]

        for duration in durations {
            let animation = ToastAnimation.slide(edge: .top, duration: duration)
            #expect(type(of: animation.animation) == Animation.self)
        }
    }

    // MARK: - Fade Animation Tests

    @Test("Fade animation uses default duration")
    func fadeAnimationDefault() {
        let animation = ToastAnimation.fade()
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Fade animation accepts custom duration")
    func fadeAnimationCustomDuration() {
        let animation = ToastAnimation.fade(duration: 1.0)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Scale Animation Tests

    @Test("Scale animation uses default scale of 0.8")
    func scaleAnimationDefault() {
        let animation = ToastAnimation.scale()
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Scale animation accepts custom scale values")
    func scaleAnimationCustomScale() {
        let scaleValues: [CGFloat] = [0.1, 0.5, 0.8, 1.0]

        for scale in scaleValues {
            let animation = ToastAnimation.scale(scale: scale)
            #expect(type(of: animation.transition) == AnyTransition.self)
        }
    }

    @Test("Scale animation accepts custom duration")
    func scaleAnimationCustomDuration() {
        let animation = ToastAnimation.scale(scale: 0.5, duration: 0.8)
        #expect(type(of: animation.animation) == Animation.self)
    }

    @Test("Scale animation uses symmetric transition")
    func scaleAnimationSymmetricTransition() {
        let animation = ToastAnimation.scale(scale: 0.5)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    // MARK: - Bounce Animation Tests

    @Test("Bounce animation uses spring physics")
    func bounceAnimation() {
        let animation = ToastAnimation.bounce()
        #expect(type(of: animation.animation) == Animation.self)
    }

    @Test("Bounce animation accepts custom duration")
    func bounceAnimationCustomDuration() {
        let animation = ToastAnimation.bounce(duration: 1.0)
        #expect(type(of: animation.animation) == Animation.self)
    }

    @Test("Bounce animation with different durations produces different animations")
    func bounceAnimationDurationDifference() {
        let fast = ToastAnimation.bounce(duration: 0.2)
        let slow = ToastAnimation.bounce(duration: 2.0)
        #expect(type(of: fast.animation) == Animation.self)
        #expect(type(of: slow.animation) == Animation.self)
    }

    // MARK: - Flip Animation Tests

    @Test("Flip animation supports horizontal axis")
    func flipAnimationHorizontal() {
        let animation = ToastAnimation.flip(axis: .horizontal)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Flip animation supports vertical axis")
    func flipAnimationVertical() {
        let animation = ToastAnimation.flip(axis: .vertical)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Flip animation uses horizontal axis by default")
    func flipAnimationDefaultAxis() {
        let animation = ToastAnimation.flip()
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Flip animation accepts custom duration")
    func flipAnimationCustomDuration() {
        let animation = ToastAnimation.flip(axis: .horizontal, duration: 0.8)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Slide With Bounce Animation Tests

    @Test("Slide with bounce animation supports all edges")
    func slideWithBounceEdges() {
        let edges: [Edge] = [.top, .bottom, .leading, .trailing]

        for edge in edges {
            let animation = ToastAnimation.slideWithBounce(edge: edge)
            #expect(type(of: animation.animation) == Animation.self)
        }
    }

    @Test("Slide with bounce animation accepts custom duration")
    func slideWithBounceCustomDuration() {
        let animation = ToastAnimation.slideWithBounce(edge: .bottom, duration: 1.0)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Custom Animation Tests

    @Test("Custom animation can be created with specific animation and transition")
    func customAnimation() {
        let customAnimation = ToastAnimation(
            animation: .spring(duration: 0.5),
            transition: .asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .opacity
            )
        )

        #expect(type(of: customAnimation.animation) == Animation.self)
        #expect(type(of: customAnimation.transition) == AnyTransition.self)
    }

    @Test("Custom animation properties can be modified")
    func customAnimationModification() {
        var animation = ToastAnimation.fade()

        // Modify animation
        animation.animation = .easeIn(duration: 1.0)
        animation.transition = .slide

        #expect(type(of: animation.animation) == Animation.self)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    // MARK: - All Animation Types

    @Test("All preset animation types can be created successfully")
    func allAnimationTypes() {
        let animations: [ToastAnimation] = [
            .slide(edge: .bottom),
            .slide(edge: .top),
            .fade(),
            .scale(),
            .scale(scale: 0.5),
            .bounce(),
            .flip(),
            .flip(axis: .vertical),
            .slideWithBounce(edge: .top),
            .slideWithBounce(edge: .bottom)
        ]

        #expect(animations.count == 10)

        for animation in animations {
            #expect(type(of: animation) == ToastAnimation.self)
        }
    }
}
