@testable import Parallaxer
import XCTest

final class PositionCurveTests: XCTestCase {
    
    func testEaseInOutTransform() {
        let ease = PositionCurve.easeInOut
        XCTAssertEqual(ease.transform(position: -1), 1)
        XCTAssertEqual(ease.transform(position: -0.5), 0.5, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(ease.transform(position: 0), 0)
        XCTAssertEqual(ease.transform(position: 0.5), 0.5, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(ease.transform(position: 1), 1)
    }

    func testClampToUnitIntervalTransform() {
        let clamp = PositionCurve.clampToUnitInterval
        XCTAssertEqual(clamp.transform(position: -1), 0)
        XCTAssertEqual(clamp.transform(position: -0.5), 0, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: -0.25), 0, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: 0), 0)
        XCTAssertEqual(clamp.transform(position: 0.25), 0.25, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: 0.5), 0.5, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: 0.75), 0.75, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: 1), 1)
        XCTAssertEqual(clamp.transform(position: 1.25), 1, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: 1.5), 1, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(clamp.transform(position: 2), 1)
    }
    
    func testSingleOscillationTransform() {
        let singleOscillation = PositionCurve.oscillate(numberOfTimes: 1)
        XCTAssertEqual(singleOscillation.transform(position: -1), 0)
        XCTAssertEqual(singleOscillation.transform(position: -0.5), 1.0)
        XCTAssertEqual(singleOscillation.transform(position: 0), 0)
        XCTAssertEqual(singleOscillation.transform(position: 0.5), 1.0)
        XCTAssertEqual(singleOscillation.transform(position: 1), 0)
    }
    
    func testDoubleOscillationTransform() {
        let doubleOscillation = PositionCurve.oscillate(numberOfTimes: 2)
        XCTAssertEqual(doubleOscillation.transform(position: -1), 0)
        XCTAssertEqual(doubleOscillation.transform(position: -0.75), 1.0)
        XCTAssertEqual(doubleOscillation.transform(position: -0.5), 0.0)
        XCTAssertEqual(doubleOscillation.transform(position: -0.25), 1.0)
        XCTAssertEqual(doubleOscillation.transform(position: 0), 0)
        XCTAssertEqual(doubleOscillation.transform(position: 0.25), 1.0)
        XCTAssertEqual(doubleOscillation.transform(position: 0.5), 0.0)
        XCTAssertEqual(doubleOscillation.transform(position: 0.75), 1.0)
        XCTAssertEqual(doubleOscillation.transform(position: 1), 0)
    }
    
    func testCustomTransform() {
        let customLinear = PositionCurve.custom { position in
            return position
        }

        XCTAssertEqual(customLinear.transform(position: -1), -1)
        XCTAssertEqual(customLinear.transform(position: -0.75), -0.75)
        XCTAssertEqual(customLinear.transform(position: -0.5), -0.5)
        XCTAssertEqual(customLinear.transform(position: -0.25), -0.25)
        XCTAssertEqual(customLinear.transform(position: 0), 0)
        XCTAssertEqual(customLinear.transform(position: 0.25), 0.25)
        XCTAssertEqual(customLinear.transform(position: 0.5), 0.5)
        XCTAssertEqual(customLinear.transform(position: 0.75), 0.75)
        XCTAssertEqual(customLinear.transform(position: 1), 1)
    }
}
