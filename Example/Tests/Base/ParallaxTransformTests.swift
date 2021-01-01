import Parallaxer
import RxBlocking
import RxSwift
import XCTest

final class ParallaxTransformTests: XCTestCase {

    // MARK: Source examples

    func testRelateExample() {
        let receiver = ParallaxTransform(
            interval: try! ParallaxInterval(from: 0, to: 3),
            parallaxValue: 3)

        let result = receiver
            .relate(to: try! ParallaxInterval<CGFloat>(from: 0, to: 6))
            .parallaxValue()

        XCTAssertEqual(result, 6)
    }

    func testMorphExample() {
        let receiver = ParallaxTransform(
            interval: try! ParallaxInterval(from: 0, to: 3),
            parallaxValue: 4)

        let result = receiver
            .morph(with: .clampToUnitInterval)
            .parallaxValue()

        XCTAssertEqual(result, 3)
    }

    func testFocusExample() {
        let receiver = ParallaxTransform(
            interval: try! ParallaxInterval(from: 0, to: 4),
            parallaxValue: 1)

        let result = receiver
            .focus(on: try! ParallaxInterval(from: 2, to: 4))
            .parallaxValue()

        XCTAssertEqual(result, 1)
    }
}
