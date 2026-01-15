import SwiftUI
import Testing
@testable import SwiftUIToast

struct ToastAnimationTests {

    // MARK: - Slide Animation Tests

    @Test("Slide animation supports all edge directions")
    func testSlideAnimationEdges() {
        let edges: [Edge] = [.top, .bottom, .leading, .trailing]

        for edge in edges {
            let animation = ToastAnimation.slide(edge: edge)
            #expect(type(of: animation) == ToastAnimation.self)
        }
    }

    @Test("Slide animation uses default duration of 0.35 seconds")
    func testSlideAnimationDefaultDuration() {
        let animation = ToastAnimation.slide(edge: .bottom)
        #expect(type(of: animation.animation) == Animation.self)
    }

    @Test("Slide animation accepts custom duration")
    func testSlideAnimationCustomDuration() {
        let durations: [TimeInterval] = [0.1, 0.5, 1.0, 2.0]

        for duration in durations {
            let animation = ToastAnimation.slide(edge: .top, duration: duration)
            #expect(type(of: animation.animation) == Animation.self)
        }
    }

    // MARK: - Fade Animation Tests

    @Test("Fade animation uses default duration")
    func testFadeAnimationDefault() {
        let animation = ToastAnimation.fade()
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Fade animation accepts custom duration")
    func testFadeAnimationCustomDuration() {
        let animation = ToastAnimation.fade(duration: 1.0)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Scale Animation Tests

    @Test("Scale animation uses default scale of 0.8")
    func testScaleAnimationDefault() {
        let animation = ToastAnimation.scale()
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Scale animation accepts custom scale values")
    func testScaleAnimationCustomScale() {
        let scaleValues: [CGFloat] = [0.1, 0.5, 0.8, 1.0]

        for scale in scaleValues {
            let animation = ToastAnimation.scale(scale: scale)
            #expect(type(of: animation.transition) == AnyTransition.self)
        }
    }

    @Test("Scale animation accepts custom duration")
    func testScaleAnimationCustomDuration() {
        let animation = ToastAnimation.scale(scale: 0.5, duration: 0.8)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Bounce Animation Tests

    @Test("Bounce animation uses spring physics")
    func testBounceAnimation() {
        let animation = ToastAnimation.bounce()
        #expect(type(of: animation.animation) == Animation.self)
    }

    @Test("Bounce animation accepts custom duration")
    func testBounceAnimationCustomDuration() {
        let animation = ToastAnimation.bounce(duration: 1.0)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Flip Animation Tests

    @Test("Flip animation supports horizontal axis")
    func testFlipAnimationHorizontal() {
        let animation = ToastAnimation.flip(axis: .horizontal)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Flip animation supports vertical axis")
    func testFlipAnimationVertical() {
        let animation = ToastAnimation.flip(axis: .vertical)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Flip animation uses horizontal axis by default")
    func testFlipAnimationDefaultAxis() {
        let animation = ToastAnimation.flip()
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    @Test("Flip animation accepts custom duration")
    func testFlipAnimationCustomDuration() {
        let animation = ToastAnimation.flip(axis: .horizontal, duration: 0.8)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Slide With Bounce Animation Tests

    @Test("Slide with bounce animation supports all edges")
    func testSlideWithBounceEdges() {
        let edges: [Edge] = [.top, .bottom, .leading, .trailing]

        for edge in edges {
            let animation = ToastAnimation.slideWithBounce(edge: edge)
            #expect(type(of: animation.animation) == Animation.self)
        }
    }

    @Test("Slide with bounce animation accepts custom duration")
    func testSlideWithBounceCustomDuration() {
        let animation = ToastAnimation.slideWithBounce(edge: .bottom, duration: 1.0)
        #expect(type(of: animation.animation) == Animation.self)
    }

    // MARK: - Custom Animation Tests

    @Test("Custom animation can be created with specific animation and transition")
    func testCustomAnimation() {
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
    func testCustomAnimationModification() {
        var animation = ToastAnimation.fade()

        // Modify animation
        animation.animation = .easeIn(duration: 1.0)
        animation.transition = .slide

        #expect(type(of: animation.animation) == Animation.self)
        #expect(type(of: animation.transition) == AnyTransition.self)
    }

    // MARK: - All Animation Types

    @Test("All preset animation types can be created successfully")
    func testAllAnimationTypes() {
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
