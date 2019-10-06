import Parallaxer
import RxBlocking
import RxSwift
import XCTest

final class ParallaxTransformTests: XCTestCase {

    // MARK: Source examples

    func testScaleExample() {
        let receiver = ParallaxTransform(
            interval: ParallaxInterval(from: 0, to: 3)!,
            parallaxValue: 3)

        let result = receiver
            .scale(to: ParallaxInterval<CGFloat>(from: 0, to: 6)!)
            .parallaxValue()

        XCTAssertEqual(result, 6)
    }

    func testRepositionExample() {
        let receiver = ParallaxTransform(
            interval: ParallaxInterval(from: 0, to: 3)!,
            parallaxValue: 4)

        let result = receiver
            .reposition(with: .clampToUnitInterval)
            .parallaxValue()

        XCTAssertEqual(result, 3)
    }

    func testFocusExample() {
        let receiver = ParallaxTransform(
            interval: ParallaxInterval(from: 0, to: 4)!,
            parallaxValue: 1)

        let result = receiver
            .focus(subinterval: ParallaxInterval(from: 2, to: 4)!)
            .parallaxValue()

        XCTAssertEqual(result, 1)
    }
}
