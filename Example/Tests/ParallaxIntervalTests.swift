@testable import Parallaxer
import XCTest

final class ParallaxIntervalTests: XCTestCase {

    func testValue() {
        let interval = ParallaxInterval(from: 0, to: 10)
        XCTAssertEqual(interval.value(forProgress: 0.5), 5)
        XCTAssertEqual(interval.value(forProgress: 0), 0)
        XCTAssertEqual(interval.value(forProgress: 1), 10)
    }
    
    func testProgress() {
        let interval = ParallaxInterval(from: 0, to: 10)
        XCTAssertEqual(interval.progress(forValue: 5), 0.5)
        XCTAssertEqual(interval.progress(forValue: 0), 0)
        XCTAssertEqual(interval.progress(forValue: 10), 1)
    }
    
    func testValueOnBackwardInterval() {
        let interval = ParallaxInterval(from: 10, to: 0)
        XCTAssertEqual(interval.value(forProgress: 0.5), 5)
        XCTAssertEqual(interval.value(forProgress: 0), 10)
        XCTAssertEqual(interval.value(forProgress: 1), 0)
    }
    
    func testProgressOnBackwardInterval() {
        let interval = ParallaxInterval(from: 10, to: 0)
        XCTAssertEqual(interval.progress(forValue: 5), 0.5)
        XCTAssertEqual(interval.progress(forValue: 0), 1)
        XCTAssertEqual(interval.progress(forValue: 10), 0)
    }
    
    func testValueOnNegativeInterval() {
        let interval = ParallaxInterval(from: -10, to: 0)
        XCTAssertEqual(interval.value(forProgress: 0.5), -5)
        XCTAssertEqual(interval.value(forProgress: 0), -10)
        XCTAssertEqual(interval.value(forProgress: 1), 0)
    }
    
    func testProgressOnNegativeInterval() {
        let interval = ParallaxInterval(from: -10, to: 0)
        XCTAssertEqual(interval.progress(forValue: -5), 0.5)
        XCTAssertEqual(interval.progress(forValue: 0), 1)
        XCTAssertEqual(interval.progress(forValue: -10), 0)
    }
    
    func testValueOnBackwardNegativeInterval() {
        let interval = ParallaxInterval(from: 0, to: -10)
        XCTAssertEqual(interval.value(forProgress: 0.5), -5)
        XCTAssertEqual(interval.value(forProgress: 0), 0)
        XCTAssertEqual(interval.value(forProgress: 1), -10)
    }
    
    func testProgressOnBackwardNegativeInterval() {
        let interval = ParallaxInterval(from: 0, to: -10)
        XCTAssertEqual(interval.progress(forValue: -5), 0.5)
        XCTAssertEqual(interval.progress(forValue: 0), 0)
        XCTAssertEqual(interval.progress(forValue: -10), 1)
    }
    
    func testValueOffInterval() {
        let interval = ParallaxInterval(from: -5, to: 5)
        XCTAssertEqual(interval.value(forProgress: -0.1), -6)
        XCTAssertEqual(interval.value(forProgress: 0), -5)
        XCTAssertEqual(interval.value(forProgress: 1), 5)
        XCTAssertEqual(interval.value(forProgress: 1.1), 6)
    }
    
    func testProgressOffInterval() {
        let interval = ParallaxInterval(from: -5, to: 5)
        XCTAssertEqual(interval.progress(forValue: -6), -0.1)
        XCTAssertEqual(interval.progress(forValue: -5), 0)
        XCTAssertEqual(interval.progress(forValue: 5), 1)
        XCTAssertEqual(interval.progress(forValue: 6), 1.1)
    }
}
