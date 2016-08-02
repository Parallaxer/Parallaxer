@testable import Parallaxer
import XCTest

class ParallaxableTests: XCTestCase {
    
    func testCGFloatType() {
        let from: CGFloat = 8
        let to: CGFloat = 16
        
        XCTAssertEqual(CGFloat.progress(forValue: 4, from: from, to: to), -0.5)
        XCTAssertEqual(CGFloat.progress(forValue: 8, from: from, to: to), 0)
        XCTAssertEqual(CGFloat.progress(forValue: 12, from: from, to: to), 0.5)
        XCTAssertEqual(CGFloat.progress(forValue: 16, from: from, to: to), 1)
        XCTAssertEqual(CGFloat.progress(forValue: 20, from: from, to: to), 1.5)
        
        XCTAssertEqual(CGFloat.value(forProgress: -0.5, from: from, to: to), 4)
        XCTAssertEqual(CGFloat.value(forProgress: 0, from: from, to: to), 8)
        XCTAssertEqual(CGFloat.value(forProgress: 0.5, from: from, to: to), 12)
        XCTAssertEqual(CGFloat.value(forProgress: 1, from: from, to: to), 16)
        XCTAssertEqual(CGFloat.value(forProgress: 1.5, from: from, to: to), 20)
    }
    
    func testCGPointType() {
        let from = CGPoint(x: 8, y: 16)
        let to = CGPoint(x: 16, y: 32)
        
        XCTAssertEqual(CGPoint.progress(forValue: CGPoint(x: 4, y: 8), from: from, to: to), -0.5)
        XCTAssertEqual(CGPoint.progress(forValue: CGPoint(x: 8, y: 16), from: from, to: to), 0)
        XCTAssertEqual(CGPoint.progress(forValue: CGPoint(x: 12, y: 24), from: from, to: to), 0.5)
        XCTAssertEqual(CGPoint.progress(forValue: CGPoint(x: 16, y: 32), from: from, to: to), 1)
        XCTAssertEqual(CGPoint.progress(forValue: CGPoint(x: 20, y: 40), from: from, to: to), 1.5)
        
        XCTAssertEqual(CGPoint.value(forProgress: -0.5, from: from, to: to), CGPoint(x: 4, y: 8))
        XCTAssertEqual(CGPoint.value(forProgress: 0, from: from, to: to), CGPoint(x: 8, y: 16))
        XCTAssertEqual(CGPoint.value(forProgress: 0.5, from: from, to: to), CGPoint(x: 12, y: 24))
        XCTAssertEqual(CGPoint.value(forProgress: 1, from: from, to: to), CGPoint(x: 16, y: 32))
        XCTAssertEqual(CGPoint.value(forProgress: 1.5, from: from, to: to), CGPoint(x: 20, y: 40))
    }
    
    func testDoubleType() {
        let from: Double = 8
        let to: Double = 16
        
        XCTAssertEqual(Double.progress(forValue: 4, from: from, to: to), -0.5)
        XCTAssertEqual(Double.progress(forValue: 8, from: from, to: to), 0)
        XCTAssertEqual(Double.progress(forValue: 12, from: from, to: to), 0.5)
        XCTAssertEqual(Double.progress(forValue: 16, from: from, to: to), 1)
        XCTAssertEqual(Double.progress(forValue: 20, from: from, to: to), 1.5)
        
        XCTAssertEqual(Double.value(forProgress: -0.5, from: from, to: to), 4)
        XCTAssertEqual(Double.value(forProgress: 0, from: from, to: to), 8)
        XCTAssertEqual(Double.value(forProgress: 0.5, from: from, to: to), 12)
        XCTAssertEqual(Double.value(forProgress: 1, from: from, to: to), 16)
        XCTAssertEqual(Double.value(forProgress: 1.5, from: from, to: to), 20)
    }
    
    func testFloatType() {
        let from: Float = 8
        let to: Float = 16
        
        XCTAssertEqual(Float.progress(forValue: 4, from: from, to: to), -0.5)
        XCTAssertEqual(Float.progress(forValue: 8, from: from, to: to), 0)
        XCTAssertEqual(Float.progress(forValue: 12, from: from, to: to), 0.5)
        XCTAssertEqual(Float.progress(forValue: 16, from: from, to: to), 1)
        XCTAssertEqual(Float.progress(forValue: 20, from: from, to: to), 1.5)
        
        XCTAssertEqual(Float.value(forProgress: -0.5, from: from, to: to), 4)
        XCTAssertEqual(Float.value(forProgress: 0, from: from, to: to), 8)
        XCTAssertEqual(Float.value(forProgress: 0.5, from: from, to: to), 12)
        XCTAssertEqual(Float.value(forProgress: 1, from: from, to: to), 16)
        XCTAssertEqual(Float.value(forProgress: 1.5, from: from, to: to), 20)
    }
}
