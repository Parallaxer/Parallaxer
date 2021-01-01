import Parallaxer
import RxBlocking
import RxSwift
import XCTest

final class RxParallaxTransformTests: XCTestCase {

    func testNoTransform() {
        let input: [Double] = [
            0, 2, 4, 6, 8, 10
        ]

        let parallax = Observable.from(input)
            .parallax(over: .interval(from: 0, to: 10))
            .parallaxValue()

        // The output should be identical to the input.
        let expectedOutput = input

        XCTAssertEqual(try parallax.toBlocking().toArray(), expectedOutput)
    }

    func testUnclampedPosition() {
        let input: [Double] = [
            5, 3, -1
        ]

        let parallax = Observable.from(input)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            125, // 25 higher than hi bound.
            75,
            -25  // 25 lower than lo bound.
        ]

        XCTAssertEqual(try parallax.toBlocking().toArray(), expectedOutput)
    }

    func testClampedPosition() {
        let input: [Double] = [
            5, 3, -1
        ]

        let parallax = Observable.from(input)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxMorph(with: .just(.clampToUnitInterval))
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            100, 75, 0
        ]

        XCTAssertEqual(try parallax.toBlocking().toArray(), expectedOutput)
    }

    func testUnclampedOverSubinterval() {
        let input: [Double] = [
            1, 2, 3, 4, 5
        ]

        let parallax = Observable.from(input)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxFocus(subinterval: .interval(from: 2, to: 4))
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            -50, 0, 50, 100, 150
        ]

        XCTAssertEqual(try parallax.toBlocking().toArray(), expectedOutput)
    }

    func testClampedOverSubinterval() {
        let input: [Double] = [
            1, 2, 3, 4, 5
        ]

        let parallax = Observable.from(input)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxFocus(subinterval: .interval(from: 2, to: 4))
            .parallaxMorph(with: .just(.clampToUnitInterval))
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            0, 0, 50, 100, 100
        ]

        XCTAssertEqual(try parallax.toBlocking().toArray(), expectedOutput)
    }

    func testDifferentlyTypedTransforms() {
        let input: [CGPoint] = [
            CGPoint(x: 2, y: 2),
            CGPoint(x: 3, y: 3),
            CGPoint(x: 4, y: 4)
        ]

        let pointTransform = Observable.from(input)
            .parallax(over: .interval(from: CGPoint(x: 2, y: 2), to: CGPoint(x: 4, y: 4)))

        let doubleTransform = pointTransform
            .parallaxRelate(to: .interval(from: 0, to: 100))

        let parallax = doubleTransform
            .parallaxValue()
            .map(round)

        let expectedOutput: [Double] = [
            0, 50, 100
        ]

        XCTAssertEqual(try parallax.toBlocking().toArray(), expectedOutput)
    }
}

extension RxParallaxTransformTests {
    
    // MARK: Error cases
    
    func testZeroLengthIntervalError() {
        let input: [Double] = [
            0, 2, 4, 6, 8, 10
        ]

        let parallax = Observable.from(input)
            .parallax(over: .interval(from: 1, to: 1))
            .parallaxValue()

        XCTAssertThrowsError(try parallax.toBlocking().toArray())
    }
}

extension RxParallaxTransformTests {

    // MARK: Source examples

    func testRelateExample() {
        let receiver = Observable<Double>.just(3)
            .parallax(over: .interval(from: 0, to: 3))

        let result = receiver
            .parallaxRelate(to: ParallaxInterval<CGFloat>.rx.interval(from: 0, to: 6))
            .parallaxValue()

        XCTAssertEqual(try result.toBlocking().first(), 6)
    }

    func testMorphExample() {
        let receiver = Observable<Double>.just(4)
            .parallax(over: .interval(from: 0, to: 3))

        let result = receiver
            .parallaxMorph(with: .just(.clampToUnitInterval))
            .parallaxValue()

        XCTAssertEqual(try result.toBlocking().first(), 3)
    }

    func testFocusExample() {
        let receiver = Observable<Double>.just(1)
            .parallax(over: .interval(from: 0, to: 4))

        let result = receiver
            .parallaxFocus(subinterval: .interval(from: 2, to: 4))
            .parallaxValue()

        XCTAssertEqual(try result.toBlocking().first(), 1)
    }
}

extension RxParallaxTransformTests {
    
    // MARK: Readme examples

    func testPercentageReadmeExample() {
        let input: [Double] = [
            0, 1, 2, 3, 4
        ]

        let root = Observable.from(input)
            .parallax(over: .interval(from: 0, to: 4))

        let percentage = root
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            0, 25, 50, 75, 100
        ]

        XCTAssertEqual(try percentage.toBlocking().toArray(), expectedOutput)
    }
}
