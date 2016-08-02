import Parallaxer
import XCTest

class ParallaxerTests: XCTestCase {

    func testSeedWithValue() {
        var value: CGFloat?
        let effect = ParallaxEffect<CGFloat>(
            interval: ParallaxInterval(from: 0, to: 10),
            onChange: { value = $0 }
        )
        
        effect.seed(withValue: 3)
        XCTAssertEqual(value, 3)
    }
    
    func testSeedWithValueWithMutatedChangeClosure() {
        var value: CGFloat?
        var effect = ParallaxEffect<CGFloat>(interval: ParallaxInterval(from: 0, to: 10))
        
        effect.seed(withValue: 3)
        XCTAssertNil(value)
        
        effect.onChange = { value = $0 }
        effect.seed(withValue: 3)
        XCTAssertEqual(value, 3)
    }
    
    func testUnclampedEffect() {
        var percentage: Double?
        let makePercentage = ParallaxEffect<Double>(
            interval: ParallaxInterval(from: 0.0, to: 100.0),
            onChange: { percentage = $0 }
        )
        
        var controller = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        controller.addEffect(makePercentage)

        controller.seed(withValue: 5)
        XCTAssertEqual(percentage, 125)
        
        controller.seed(withValue: 3)
        XCTAssertEqual(percentage, 75)
        
        controller.seed(withValue: -1)
        XCTAssertEqual(percentage, -25)
    }
    
    func testClampedEffect() {
        var percentage: Double?
        let makePercentageClamped = ParallaxEffect<Double>(
            interval: ParallaxInterval(from: 0, to: 100),
            isClamped: true,
            onChange: { percentage = $0 }
        )
        
        var controller = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        controller.addEffect(makePercentageClamped)
        
        controller.seed(withValue: 5)
        XCTAssertEqual(percentage, 100)
        
        controller.seed(withValue: 3)
        XCTAssertEqual(percentage, 75)
        
        controller.seed(withValue: -1)
        XCTAssertEqual(percentage, 0)
    }
    
    func testUnclampedEffectOverSubinterval() {
        var percentage: Double?
        let makePercentage = ParallaxEffect<Double>(
            interval: ParallaxInterval(from: 0, to: 100),
            onChange: { percentage = $0 }
        )
        
        var controller = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        controller.addEffect(makePercentage, subinterval: ParallaxInterval(from: 0.5, to: 1))
        
        controller.seed(withValue: 1)
        XCTAssertEqual(percentage, -50)
        
        controller.seed(withValue: 2)
        XCTAssertEqual(percentage, 0)
        
        controller.seed(withValue: 3)
        XCTAssertEqual(percentage, 50)
        
        controller.seed(withValue: 4)
        XCTAssertEqual(percentage, 100)
        
        controller.seed(withValue: 5)
        XCTAssertEqual(percentage, 150)
    }
    
    func testClampedEffectOverSubinterval() {
        var percentage: CGFloat?
        let makePercentage = ParallaxEffect<CGFloat>(
            interval: ParallaxInterval(from: 0, to: 100),
            isClamped: true,
            onChange: { percentage = $0 }
        )
        
        var controller = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        controller.addEffect(makePercentage, subinterval: ParallaxInterval(from: 0.5, to: 1))
        
        controller.seed(withValue: 1)
        XCTAssertEqual(percentage, 0)
        
        controller.seed(withValue: 2)
        XCTAssertEqual(percentage, 0)
        
        controller.seed(withValue: 3)
        XCTAssertEqual(percentage, 50)
        
        controller.seed(withValue: 4)
        XCTAssertEqual(percentage, 100)
        
        controller.seed(withValue: 5)
        XCTAssertEqual(percentage, 100)
    }
    
    func testDifferentlyTypedNestedEffects() {
        // Set up the following parallax tree:
        //      > controller (ParallaxEffect<CGPoint>)
        //              -> makePercentage (ParallaxEffect<CGFloat>)
        //              -> changePoint (ParallaxEffect<CGPoint>)

        var percentage: CGFloat?
        let makePercentage = ParallaxEffect<CGFloat>(
            interval: ParallaxInterval(from: 0, to: 100),
            onChange: { percentage = $0 }
        )
        
        var point: CGPoint?
        let changePoint = ParallaxEffect(
            interval: ParallaxInterval(from: CGPoint(x: 4, y: 0), to: CGPoint(x: 10, y: 0)),
            onChange: { point = $0 }
        )
        
        var controller = ParallaxEffect(
            interval: ParallaxInterval(from: CGPoint(x: 2, y: 2), to: CGPoint(x: 4, y: 4))
        )
        
        controller.addEffect(makePercentage)
        controller.addEffect(changePoint)

        controller.seed(withValue: CGPoint(x: 2, y: 2))
        XCTAssertEqual(round(percentage!), 0)
        XCTAssertEqual(point, CGPoint(x: 4, y: 0))
        
        controller.seed(withValue: CGPoint(x: 3, y: 3))
        XCTAssertEqual(round(percentage!), 50)
        XCTAssertEqual(point, CGPoint(x: 7, y: 0))
        
        controller.seed(withValue: CGPoint(x: 4, y: 4))
        XCTAssertEqual(round(percentage!), 100)
        XCTAssertEqual(point, CGPoint(x: 10, y: 0))
    }
    
    func testReadmePercentageExample() {
        var percentage: Double?
        
        // Define an effect that expresses a value as a percentage of its parent interval.
        let calculatePercentage = ParallaxEffect<Double>(
            interval: ParallaxInterval(from: 0, to: 100),
            onChange: { percentage = $0 }
        )
        
        var root = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        root.addEffect(calculatePercentage)
        
        root.seed(withValue: 2)
        XCTAssertEqual(percentage, 50)
    }
}
