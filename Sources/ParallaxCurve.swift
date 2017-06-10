import Foundation

/// Specifies how a `ParallaxEffect` transforms progress inherited from its parent.
///
/// - linear:           Progress matches that of its parent.
/// - easeInOut:        Progress is slow at the beginning and end of the interval.
/// - oscillate:        Progress oscillates over the interval, up to `numberOfTimes`.
/// - custom->Double:   The progress transformation may be customized with a closure.
public enum ParallaxCurve {
    
    case linear
    case easeInOut
    case oscillate(numberOfTimes: Double)
    case custom((Double) -> Double)
    
    func transform(progress: Double) -> Double {
        switch self {
            case .linear:
                return progress
            
            case .easeInOut:
                return 0.5 * (1 - cos(progress * .pi))
            
            case .oscillate(let numberOfTimes):
                return 0.5 * (1 - cos(progress * 2 * numberOfTimes * .pi))
            
            case .custom(let customTransform):
                return customTransform(progress)
        }
    }
}
