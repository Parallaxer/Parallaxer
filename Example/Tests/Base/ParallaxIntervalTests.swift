@testable import Parallaxer
import XCTest

final class ParallaxIntervalTests: XCTestCase {

    func testValue() {
        let interval = try! ParallaxInterval(from: 0, to: 10)
        XCTAssertEqual(interval.value(atPosition: 0.5), 5)
        XCTAssertEqual(interval.value(atPosition: 0), 0)
        XCTAssertEqual(interval.value(atPosition: 1), 10)
    }
    
    func testPosition() {
        let interval = try! ParallaxInterval(from: 0, to: 10)
        XCTAssertEqual(interval.position(forValue: 5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 0)
        XCTAssertEqual(interval.position(forValue: 10), 1)
    }
    
    func testValueOnBackwardInterval() {
        let interval = try! ParallaxInterval(from: 10, to: 0)
        XCTAssertEqual(interval.value(atPosition: 0.5), 5)
        XCTAssertEqual(interval.value(atPosition: 0), 10)
        XCTAssertEqual(interval.value(atPosition: 1), 0)
    }
    
    func testPositionOnBackwardInterval() {
        let interval = try! ParallaxInterval(from: 10, to: 0)
        XCTAssertEqual(interval.position(forValue: 5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 1)
        XCTAssertEqual(interval.position(forValue: 10), 0)
    }
    
    func testValueOnNegativeInterval() {
        let interval = try! ParallaxInterval(from: -10, to: 0)
        XCTAssertEqual(interval.value(atPosition: 0.5), -5)
        XCTAssertEqual(interval.value(atPosition: 0), -10)
        XCTAssertEqual(interval.value(atPosition: 1), 0)
    }
    
    func testPositionOnNegativeInterval() {
        let interval = try! ParallaxInterval(from: -10, to: 0)
        XCTAssertEqual(interval.position(forValue: -5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 1)
        XCTAssertEqual(interval.position(forValue: -10), 0)
    }
    
    func testValueOnBackwardNegativeInterval() {
        let interval = try! ParallaxInterval(from: 0, to: -10)
        XCTAssertEqual(interval.value(atPosition: 0.5), -5)
        XCTAssertEqual(interval.value(atPosition: 0), 0)
        XCTAssertEqual(interval.value(atPosition: 1), -10)
    }
    
    func testPositionOnBackwardNegativeInterval() {
        let interval = try! ParallaxInterval(from: 0, to: -10)
        XCTAssertEqual(interval.position(forValue: -5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 0)
        XCTAssertEqual(interval.position(forValue: -10), 1)
    }
    
    func testValueOffInterval() {
        let interval = try! ParallaxInterval(from: -5, to: 5)
        XCTAssertEqual(interval.value(atPosition: -0.1), -6)
        XCTAssertEqual(interval.value(atPosition: 0), -5)
        XCTAssertEqual(interval.value(atPosition: 1), 5)
        XCTAssertEqual(interval.value(atPosition: 1.1), 6)
    }
    
    func testPositionOffInterval() {
        let interval = try! ParallaxInterval(from: -5, to: 5)
        XCTAssertEqual(interval.position(forValue: -6), -0.1)
        XCTAssertEqual(interval.position(forValue: -5), 0)
        XCTAssertEqual(interval.position(forValue: 5), 1)
        XCTAssertEqual(interval.position(forValue: 6), 1.1)
    }

    func testZeroLengthIntervalError() {
        let value: Double = 12
        XCTAssertThrowsError(try ParallaxInterval(from: value, to: value))
    }
}
