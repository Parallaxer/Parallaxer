@testable import Parallaxer
import XCTest

final class ParallaxIntervalTests: XCTestCase {

    func testValue() {
        let interval = ParallaxInterval(from: 0, to: 10)!
        XCTAssertEqual(interval.value(atPosition: 0.5), 5)
        XCTAssertEqual(interval.value(atPosition: 0), 0)
        XCTAssertEqual(interval.value(atPosition: 1), 10)
    }
    
    func testPosition() {
        let interval = ParallaxInterval(from: 0, to: 10)!
        XCTAssertEqual(interval.position(forValue: 5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 0)
        XCTAssertEqual(interval.position(forValue: 10), 1)
    }
    
    func testValueOnBackwardInterval() {
        let interval = ParallaxInterval(from: 10, to: 0)!
        XCTAssertEqual(interval.value(atPosition: 0.5), 5)
        XCTAssertEqual(interval.value(atPosition: 0), 10)
        XCTAssertEqual(interval.value(atPosition: 1), 0)
    }
    
    func testPositionOnBackwardInterval() {
        let interval = ParallaxInterval(from: 10, to: 0)!
        XCTAssertEqual(interval.position(forValue: 5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 1)
        XCTAssertEqual(interval.position(forValue: 10), 0)
    }
    
    func testValueOnNegativeInterval() {
        let interval = ParallaxInterval(from: -10, to: 0)!
        XCTAssertEqual(interval.value(atPosition: 0.5), -5)
        XCTAssertEqual(interval.value(atPosition: 0), -10)
        XCTAssertEqual(interval.value(atPosition: 1), 0)
    }
    
    func testPositionOnNegativeInterval() {
        let interval = ParallaxInterval(from: -10, to: 0)!
        XCTAssertEqual(interval.position(forValue: -5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 1)
        XCTAssertEqual(interval.position(forValue: -10), 0)
    }
    
    func testValueOnBackwardNegativeInterval() {
        let interval = ParallaxInterval(from: 0, to: -10)!
        XCTAssertEqual(interval.value(atPosition: 0.5), -5)
        XCTAssertEqual(interval.value(atPosition: 0), 0)
        XCTAssertEqual(interval.value(atPosition: 1), -10)
    }
    
    func testPositionOnBackwardNegativeInterval() {
        let interval = ParallaxInterval(from: 0, to: -10)!
        XCTAssertEqual(interval.position(forValue: -5), 0.5)
        XCTAssertEqual(interval.position(forValue: 0), 0)
        XCTAssertEqual(interval.position(forValue: -10), 1)
    }
    
    func testValueOffInterval() {
        let interval = ParallaxInterval(from: -5, to: 5)!
        XCTAssertEqual(interval.value(atPosition: -0.1), -6)
        XCTAssertEqual(interval.value(atPosition: 0), -5)
        XCTAssertEqual(interval.value(atPosition: 1), 5)
        XCTAssertEqual(interval.value(atPosition: 1.1), 6)
    }
    
    func testPositionOffInterval() {
        let interval = ParallaxInterval(from: -5, to: 5)!
        XCTAssertEqual(interval.position(forValue: -6), -0.1)
        XCTAssertEqual(interval.position(forValue: -5), 0)
        XCTAssertEqual(interval.position(forValue: 5), 1)
        XCTAssertEqual(interval.position(forValue: 6), 1.1)
    }

    func testNilInterval() {
        let value: Double = 12
        XCTAssertNil(ParallaxInterval(from: value, to: value))
    }
}
