@testable import Parallaxer
import XCTest

final class ParallaxCurveTests: XCTestCase {

    func testLinearTransform() {
        let linear = ParallaxCurve.linear
        XCTAssertEqual(linear.transform(progress: -1), -1)
        XCTAssertEqual(linear.transform(progress: -0.75), -0.75)
        XCTAssertEqual(linear.transform(progress: -0.5), -0.5)
        XCTAssertEqual(linear.transform(progress: -0.25), -0.25)
        XCTAssertEqual(linear.transform(progress: 0), 0)
        XCTAssertEqual(linear.transform(progress: 0.25), 0.25)
        XCTAssertEqual(linear.transform(progress: 0.5), 0.5)
        XCTAssertEqual(linear.transform(progress: 0.75), 0.75)
        XCTAssertEqual(linear.transform(progress: 1), 1)
    }
    
    func testEaseInOutTransform() {
        let ease = ParallaxCurve.easeInOut
        XCTAssertEqual(ease.transform(progress: -1), 1)
        XCTAssertEqual(ease.transform(progress: -0.5), 0.5, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(ease.transform(progress: 0), 0)
        XCTAssertEqual(ease.transform(progress: 0.5), 0.5, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(ease.transform(progress: 1), 1)
    }

    func testClampToUnitIntervalTransform() {
        let clamp = ParallaxCurve.clampToUnitInterval
        XCTAssertEqual(clamp.transform(progress: -1), 0)
        XCTAssertEqual(clamp.transform(progress: -0.5), 0, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: -0.25), 0, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: 0), 0)
        XCTAssertEqual(clamp.transform(progress: 0.25), 0.25, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: 0.5), 0.5, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: 0.75), 0.75, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: 1), 1)
        XCTAssertEqual(clamp.transform(progress: 1.25), 1, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: 1.5), 1, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(progress: 2), 1)
    }
    
    func testSingleOscillationTransform() {
        let singleOscillation = ParallaxCurve.oscillate(numberOfTimes: 1)
        XCTAssertEqual(singleOscillation.transform(progress: -1), 0)
        XCTAssertEqual(singleOscillation.transform(progress: -0.5), 1.0)
        XCTAssertEqual(singleOscillation.transform(progress: 0), 0)
        XCTAssertEqual(singleOscillation.transform(progress: 0.5), 1.0)
        XCTAssertEqual(singleOscillation.transform(progress: 1), 0)
    }
    
    func testDoubleOscillationTransform() {
        let doubleOscillation = ParallaxCurve.oscillate(numberOfTimes: 2)
        XCTAssertEqual(doubleOscillation.transform(progress: -1), 0)
        XCTAssertEqual(doubleOscillation.transform(progress: -0.75), 1.0)
        XCTAssertEqual(doubleOscillation.transform(progress: -0.5), 0.0)
        XCTAssertEqual(doubleOscillation.transform(progress: -0.25), 1.0)
        XCTAssertEqual(doubleOscillation.transform(progress: 0), 0)
        XCTAssertEqual(doubleOscillation.transform(progress: 0.25), 1.0)
        XCTAssertEqual(doubleOscillation.transform(progress: 0.5), 0.0)
        XCTAssertEqual(doubleOscillation.transform(progress: 0.75), 1.0)
        XCTAssertEqual(doubleOscillation.transform(progress: 1), 0)
    }
    
    func testCustomTransform() {
        let customLinear = ParallaxCurve.custom { progress in
            return progress
        }

        XCTAssertEqual(customLinear.transform(progress: -1), -1)
        XCTAssertEqual(customLinear.transform(progress: -0.75), -0.75)
        XCTAssertEqual(customLinear.transform(progress: -0.5), -0.5)
        XCTAssertEqual(customLinear.transform(progress: -0.25), -0.25)
        XCTAssertEqual(customLinear.transform(progress: 0), 0)
        XCTAssertEqual(customLinear.transform(progress: 0.25), 0.25)
        XCTAssertEqual(customLinear.transform(progress: 0.5), 0.5)
        XCTAssertEqual(customLinear.transform(progress: 0.75), 0.75)
        XCTAssertEqual(customLinear.transform(progress: 1), 1)
    }
}
