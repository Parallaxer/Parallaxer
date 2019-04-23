import Parallaxer
import XCTest

final class ParallaxerTests: XCTestCase {
    
    func testSeedWithValue() {
        var number: Double?
        let effect = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 10),
            change:     { number = $0 as Double }
        )
        
        effect.seed(withValue: 3)
        XCTAssertEqual(number, 3)
    }
    
    func testSeedWithValueWithMutatedChangeClosure() {
        var number: Double?
        var effect = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 10))

        effect.seed(withValue: 3)
        XCTAssertNil(number)
        
        effect.change = { number = $0 }
        effect.seed(withValue: 3)
        XCTAssertEqual(number, 3)
    }
    
    func testUnclampedEffect() {
        var percentage: Double?
        let makePercentage = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 100),
            change:     { percentage = $0 as Double }
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
        let makePercentageClamped = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 100),
            isClamped:  true,
            change:     { percentage = $0 as Double }
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
        let makePercentage = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 100),
            change:     { percentage = $0 as Double }
        )
        
        var controller = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        controller.addEffect(makePercentage, toSubinterval: ParallaxInterval(from: 0.5, to: 1))

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
        var percentage: Double?
        let makePercentage = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 100),
            isClamped:  true,
            change:     { percentage = $0 as Double }
        )
        
        var controller = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        controller.addEffect(makePercentage, toSubinterval: ParallaxInterval(from: 0.5, to: 1))
        
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
        //              -> makePercentage (ParallaxEffect<Double>)
        //              -> changePoint (ParallaxEffect<CGPoint>)

        var percentage: Double?
        let makePercentage = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 100),
            change:     { percentage = $0 as Double }
        )
        
        var point: CGPoint?
        let changePoint = ParallaxEffect(
            interval:   ParallaxInterval(from: CGPoint(x: 4, y: 0), to: CGPoint(x: 10, y: 0)),
            change:     { point = $0 }
        )
        
        var controller = ParallaxEffect(
            interval:   ParallaxInterval(from: CGPoint(x: 2, y: 2), to: CGPoint(x: 4, y: 4))
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
        let calculatePercentage = ParallaxEffect(
            interval:   ParallaxInterval(from: 0, to: 100),
            change:     { percentage = $0 as Double }
        )
        
        var root = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
        root.addEffect(calculatePercentage)

        root.seed(withValue: 0)
        XCTAssertEqual(percentage, 0)

        root.seed(withValue: 1)
        XCTAssertEqual(percentage, 25)

        root.seed(withValue: 2)
        XCTAssertEqual(percentage, 50)

        root.seed(withValue: 3)
        XCTAssertEqual(percentage, 75)

        root.seed(withValue: 4)
        XCTAssertEqual(percentage, 100)
    }
}
