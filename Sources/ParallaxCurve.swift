import Foundation

private let kPi: Double = 3.14159265359

/**
 Specifies how a `ParallaxEffect` transforms progress inheritted from its parent.
 
 - linear:      No change.
 - easeInOut:   Progress is slow at the beginning and end of the interval.
 - oscillate:   Progress oscillates over the interval, up to `numberOfTimes`.
 - custom:      The progress transformation may be customized with a closure.
 */
public enum ParallaxCurve {
    
    case linear
    case easeInOut
    case oscillate(numberOfTimes: Double)
    case custom((progress: Double) -> Double)
    
    func transform(progress: Double) -> Double {
        switch self {
            case .linear:
                return progress
            case .easeInOut:
                return 0.5 * (1 - cos(progress * kPi))
            case .oscillate(let numberOfTimes):
                return 0.5 * (1 - cos(progress * 2 * numberOfTimes * kPi))
            case .custom(let transform):
                return transform(progress: progress)
        }
    }
}
