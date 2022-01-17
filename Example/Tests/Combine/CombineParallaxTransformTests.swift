import Parallaxer
import RxBlocking
import Combine
import XCTest

extension XCTestCase {
    func waitForSignal<PublisherType: Publisher>(
        _ publisher: PublisherType,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PublisherType.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<PublisherType.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher
            .print()
            .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
}

final class CombineParallaxTransformTests: XCTestCase {

    func testNoTransform() throws {
        let input: [Double] = [
            0, 2, 4, 6, 8, 10
        ]
        
        let parallax = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: Double(0), to: 10))
            .parallaxValue()

        // The output should be identical to the input.
        let expectedOutput = input
        
        XCTAssertEqual(try waitForSignal(parallax.collect()), expectedOutput)
    }

    func testUnclampedPosition() throws {
        let input: [Double] = [
            5, 3, -1
        ]

        let parallax = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            125, // 25 higher than hi bound.
            75,
            -25  // 25 lower than lo bound.
        ]

        XCTAssertEqual(try waitForSignal(parallax.collect()), expectedOutput)
    }

    func testClampedPosition() {
        let input: [Double] = [
            5, 3, -1
        ]

        let parallax = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxMorph(with: Just(.clampToUnitInterval).eraseToAnyPublisher())
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            100, 75, 0
        ]

        XCTAssertEqual(try waitForSignal(parallax.collect()), expectedOutput)
    }

    func testUnclampedOverSubinterval() {
        let input: [Double] = [
            1, 2, 3, 4, 5
        ]

        let parallax = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxFocus(on: .interval(from: 2, to: 4))
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            -50, 0, 50, 100, 150
        ]

        XCTAssertEqual(try waitForSignal(parallax.collect()), expectedOutput)
    }

    func testClampedOverSubinterval() {
        let input: [Double] = [
            1, 2, 3, 4, 5
        ]

        let parallax = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: 0, to: 4))
            .parallaxFocus(on: .interval(from: 2, to: 4))
            .parallaxMorph(with: Just(.clampToUnitInterval).eraseToAnyPublisher())
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            0, 0, 50, 100, 100
        ]

        XCTAssertEqual(try waitForSignal(parallax.collect()), expectedOutput)
    }

    func testDifferentlyTypedTransforms() {
        let input: [CGPoint] = [
            CGPoint(x: 2, y: 2),
            CGPoint(x: 3, y: 3),
            CGPoint(x: 4, y: 4)
        ]

        let pointTransform = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: CGPoint(x: 2, y: 2), to: CGPoint(x: 4, y: 4)))

        let doubleTransform = pointTransform
            .parallaxRelate(to: .interval(from: 0, to: 100))

        let parallax = doubleTransform
            .parallaxValue()
            .map(round)

        let expectedOutput: [Double] = [
            0, 50, 100
        ]

        XCTAssertEqual(try waitForSignal(parallax.collect()), expectedOutput)
    }
}

extension CombineParallaxTransformTests {

    // MARK: Error cases

    func testZeroLengthIntervalError() {
        let input: [Double] = [
            0, 2, 4, 6, 8, 10
        ]

        let parallax = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: 1, to: 1))
            .parallaxValue()

        XCTAssertThrowsError(try waitForSignal(parallax.collect()))
    }
}

extension CombineParallaxTransformTests {

    // MARK: Source examples

    func testRelateExample() {
        let receiver = Just(Double(3)).eraseToAnyPublisher()
            .parallax(over: .interval(from: 0, to: 3))

        let result = receiver
            .parallaxRelate(to: .interval(from: 0, to: 6))
            .parallaxValue()

        XCTAssertEqual(try waitForSignal(result.collect()).first, 6)
    }

    func testMorphExample() {
        let receiver = Just(Double(4)).eraseToAnyPublisher()
            .parallax(over: .interval(from: 0, to: 3))

        let result = receiver
            .parallaxMorph(with: Just(.clampToUnitInterval).eraseToAnyPublisher())
            .parallaxValue()

        XCTAssertEqual(try waitForSignal(result.collect()).first, 3)
    }

    func testFocusExample() {
        let receiver = Just(Double(1)).eraseToAnyPublisher()
            .parallax(over: .interval(from: 0, to: 4))

        let result = receiver
            .parallaxFocus(on: .interval(from: 2, to: 4))
            .parallaxValue()

        XCTAssertEqual(try waitForSignal(result.collect()).first, 1)
    }
}

extension CombineParallaxTransformTests {

    // MARK: Readme examples

    func testPercentageReadmeExample() {
        let input: [Double] = [
            0, 1, 2, 3, 4
        ]

        let root = input.publisher
            .delay(for: .milliseconds(1), tolerance: .milliseconds(100), scheduler: RunLoop.main)
            .parallax(over: .interval(from: 0, to: 4))

        let percentage = root
            .parallaxRelate(to: .interval(from: 0, to: 100))
            .parallaxValue()

        let expectedOutput: [Double] = [
            0, 25, 50, 75, 100
        ]

        XCTAssertEqual(try waitForSignal(percentage.collect()), expectedOutput)
    }
}
