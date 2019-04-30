import Parallaxer
import XCTest
import RxTest
import RxSwift

final class RxParallaxerDocumentationTests: XCTestCase {

    func testParallaxCurveExample1() {
        let input: [Double]     = [-2, -1, 0, 1, 2, 3, 4, 5]
        let output: [Double]    = [ 0,  0, 0, 1, 2, 3, 3, 3]

        let scheduler = TestScheduler(initialClock: 0)
        let progression = scheduler.createColdObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval(from: 0, to: 3))
            .parallaxCurve(.clampToUnitInterval)
            .toParallaxValue()

        scheduler.assert(output: output, from: progression)
    }

    func testParallaxMapExample() {
        let input: [Double]     = [-1, 0, 1, 2, 3, 4]
        let output: [CGFloat]   = [-2, 0, 2, 4, 6, 8]

        let scheduler = TestScheduler(initialClock: 0)
        let progression = scheduler.createColdObservable(withChronologicalValues: input)
            .toParallaxTransform(over: ParallaxInterval<Double>(from: 0, to: 3))
            .parallaxMap(toInterval: ParallaxInterval<CGFloat>(from: 0, to: 6))
            .toParallaxValue()

        scheduler.assert(output: output, from: progression)
    }
}
