import Parallaxer
import XCTest
import RxTest

final class RxParallaxerTests: XCTestCase {

    func testNoTransform() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [Double] = [
            0,
            2,
            4,
            6,
            8,
            10
        ]

        let parallax = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 10))
            .toParallaxValue()

        // Record events emitted by parallax.
        let results = scheduler.record(parallax)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput = TestScheduler.chronologicalEvents(from: input)

        XCTAssertEqual(results.events, expectedOutput)
    }

    func testUnclampedProgress() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [Double] = [
            5,
            3,
            -1
        ]

        let parallax = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 4))
            .parallaxScale(to: ParallaxInterval<Double>(from: 0, to: 100))
            .toParallaxValue()

        // Record events emitted by parallax.
        let results = scheduler.record(parallax)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput: [Double] = [
            125, // 25 higher than hi bound.
            75,
            -25  // 25 lower than lo bound.
        ]

        XCTAssertEqual(results.events, TestScheduler.chronologicalEvents(from: expectedOutput))
    }

    func testClampedProgress() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [Double] = [
            5,
            3,
            -1
        ]

        let parallax = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 4))
            .parallaxCurve(.clampToUnitInterval)
            .parallaxScale(to: ParallaxInterval<Double>(from: 0, to: 100))
            .toParallaxValue()

        // Record events emitted by parallax.
        let results = scheduler.record(parallax)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput: [Double] = [
            100,
            75,
            0
        ]

        XCTAssertEqual(results.events, TestScheduler.chronologicalEvents(from: expectedOutput))
    }

    func testUnclampedOverSubinterval() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [Double] = [
            1,
            2,
            3,
            4,
            5
        ]

        let parallax = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 4))
            .parallaxSelect(subinterval: ParallaxInterval(from: 2, to: 4))
            .parallaxScale(to: ParallaxInterval<Double>(from: 0, to: 100))
            .toParallaxValue()

        // Record events emitted by parallax.
        let results = scheduler.record(parallax)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput: [Double] = [
            -50,
            0,
            50,
            100,
            150
        ]

        XCTAssertEqual(results.events, TestScheduler.chronologicalEvents(from: expectedOutput))
    }

    func testClampedOverSubinterval() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [Double] = [
            1,
            2,
            3,
            4,
            5
        ]

        let parallax = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 4))
            .parallaxSelect(subinterval: ParallaxInterval(from: 2, to: 4))
            .parallaxCurve(.clampToUnitInterval)
            .parallaxScale(to: ParallaxInterval<Double>(from: 0, to: 100))
            .toParallaxValue()

        // Record events emitted by parallax.
        let results = scheduler.record(parallax)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput: [Double] = [
            0,
            0,
            50,
            100,
            100
        ]

        XCTAssertEqual(results.events, TestScheduler.chronologicalEvents(from: expectedOutput))
    }

    func testDifferentlyTypedTransforms() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [CGPoint] = [
            CGPoint(x: 2, y: 2),
            CGPoint(x: 3, y: 3),
            CGPoint(x: 4, y: 4)
        ]

        let parallax = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: CGPoint(x: 2, y: 2), to: CGPoint(x: 4, y: 4)))
            .parallaxScale(to: ParallaxInterval<Double>(from: 0, to: 100))
            .toParallaxValue()
            .map(round)

        // Record events emitted by parallax.
        let results = scheduler.record(parallax)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput: [Double] = [
            0,
            50,
            100
        ]

        XCTAssertEqual(results.events, TestScheduler.chronologicalEvents(from: expectedOutput))
    }

    func testReadmePercentage() {
        let scheduler = TestScheduler(initialClock: 0)

        let input: [Double] = [
            0,
            1,
            2,
            3,
            4
        ]

        let root = scheduler.createHotObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 4))

        let percentage = root
            .parallaxScale(to: ParallaxInterval<Double>(from: 0, to: 100))
            .toParallaxValue()

        // Record events emitted by percentage.
        let results = scheduler.record(percentage)
        scheduler.start()

        // The output should be identical to the input.
        let expectedOutput: [Double] = [
            0,
            25,
            50,
            75,
            100
        ]

        XCTAssertEqual(results.events, TestScheduler.chronologicalEvents(from: expectedOutput))
    }
}
