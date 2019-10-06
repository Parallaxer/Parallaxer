import Parallaxer
import XCTest

final class ParallaxableTests: XCTestCase {
    
    func testCGFloatType() {
        let from: CGFloat = 8
        let to: CGFloat = 16
        
        XCTAssertEqual(CGFloat.unitPosition(forValue: 4, from: from, to: to), -0.5)
        XCTAssertEqual(CGFloat.unitPosition(forValue: 8, from: from, to: to), 0)
        XCTAssertEqual(CGFloat.unitPosition(forValue: 12, from: from, to: to), 0.5)
        XCTAssertEqual(CGFloat.unitPosition(forValue: 16, from: from, to: to), 1)
        XCTAssertEqual(CGFloat.unitPosition(forValue: 20, from: from, to: to), 1.5)
        
        XCTAssertEqual(CGFloat.value(atUnitPosition: -0.5, from: from, to: to), 4)
        XCTAssertEqual(CGFloat.value(atUnitPosition: 0, from: from, to: to), 8)
        XCTAssertEqual(CGFloat.value(atUnitPosition: 0.5, from: from, to: to), 12)
        XCTAssertEqual(CGFloat.value(atUnitPosition: 1, from: from, to: to), 16)
        XCTAssertEqual(CGFloat.value(atUnitPosition: 1.5, from: from, to: to), 20)

        XCTAssertNil(ParallaxInterval(from: from, to: from))
        XCTAssertNil(ParallaxInterval(from: to, to: to))
    }
    
    func testCGPointType() {
        let from = CGPoint(x: 8, y: 16)
        let to = CGPoint(x: 16, y: 32)
        
        XCTAssertEqual(CGPoint.unitPosition(forValue: CGPoint(x: 4, y: 8), from: from, to: to), -0.5)
        XCTAssertEqual(CGPoint.unitPosition(forValue: CGPoint(x: 8, y: 16), from: from, to: to), 0)
        XCTAssertEqual(CGPoint.unitPosition(forValue: CGPoint(x: 12, y: 24), from: from, to: to), 0.5)
        XCTAssertEqual(CGPoint.unitPosition(forValue: CGPoint(x: 16, y: 32), from: from, to: to), 1)
        XCTAssertEqual(CGPoint.unitPosition(forValue: CGPoint(x: 20, y: 40), from: from, to: to), 1.5)
        
        XCTAssertEqual(CGPoint.value(atUnitPosition: -0.5, from: from, to: to), CGPoint(x: 4, y: 8))
        XCTAssertEqual(CGPoint.value(atUnitPosition: 0, from: from, to: to), CGPoint(x: 8, y: 16))
        XCTAssertEqual(CGPoint.value(atUnitPosition: 0.5, from: from, to: to), CGPoint(x: 12, y: 24))
        XCTAssertEqual(CGPoint.value(atUnitPosition: 1, from: from, to: to), CGPoint(x: 16, y: 32))
        XCTAssertEqual(CGPoint.value(atUnitPosition: 1.5, from: from, to: to), CGPoint(x: 20, y: 40))

        XCTAssertNil(ParallaxInterval(from: from, to: from))
        XCTAssertNil(ParallaxInterval(from: to, to: to))
    }
    
    func testDoubleType() {
        let from: Double = 8
        let to: Double = 16
        
        XCTAssertEqual(Double.unitPosition(forValue: 4, from: from, to: to), -0.5)
        XCTAssertEqual(Double.unitPosition(forValue: 8, from: from, to: to), 0)
        XCTAssertEqual(Double.unitPosition(forValue: 12, from: from, to: to), 0.5)
        XCTAssertEqual(Double.unitPosition(forValue: 16, from: from, to: to), 1)
        XCTAssertEqual(Double.unitPosition(forValue: 20, from: from, to: to), 1.5)
        
        XCTAssertEqual(Double.value(atUnitPosition: -0.5, from: from, to: to), 4)
        XCTAssertEqual(Double.value(atUnitPosition: 0, from: from, to: to), 8)
        XCTAssertEqual(Double.value(atUnitPosition: 0.5, from: from, to: to), 12)
        XCTAssertEqual(Double.value(atUnitPosition: 1, from: from, to: to), 16)
        XCTAssertEqual(Double.value(atUnitPosition: 1.5, from: from, to: to), 20)

        XCTAssertNil(ParallaxInterval(from: from, to: from))
        XCTAssertNil(ParallaxInterval(from: to, to: to))
    }
    
    func testFloatType() {
        let from: Float = 8
        let to: Float = 16
        
        XCTAssertEqual(Float.unitPosition(forValue: 4, from: from, to: to), -0.5)
        XCTAssertEqual(Float.unitPosition(forValue: 8, from: from, to: to), 0)
        XCTAssertEqual(Float.unitPosition(forValue: 12, from: from, to: to), 0.5)
        XCTAssertEqual(Float.unitPosition(forValue: 16, from: from, to: to), 1)
        XCTAssertEqual(Float.unitPosition(forValue: 20, from: from, to: to), 1.5)
        
        XCTAssertEqual(Float.value(atUnitPosition: -0.5, from: from, to: to), 4)
        XCTAssertEqual(Float.value(atUnitPosition: 0, from: from, to: to), 8)
        XCTAssertEqual(Float.value(atUnitPosition: 0.5, from: from, to: to), 12)
        XCTAssertEqual(Float.value(atUnitPosition: 1, from: from, to: to), 16)
        XCTAssertEqual(Float.value(atUnitPosition: 1.5, from: from, to: to), 20)

        XCTAssertNil(ParallaxInterval(from: from, to: from))
        XCTAssertNil(ParallaxInterval(from: to, to: to))
    }
}
