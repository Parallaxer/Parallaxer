import Foundation

/// Specifies how progress is transformed. Progress is specified along the unit interval, [0, 1]. Unclamped
/// progress may be below or exceed the interval boundaries.
///
/// - linear:               Progress matches that of its parent.
/// - easeInOut:            Progress is slow at the beginning and end of the interval.
/// - clampToUnitInterval:  Progress is clamped to the unit interval, [0, 1].
/// - oscillate:            Progress oscillates over the interval, up to `numberOfTimes`.
/// - custom -> Double:     The progress transformation may be customized with a closure.
public enum ParallaxCurve {

    case linear
    case easeInOut
    case clampToUnitInterval
    case oscillate(numberOfTimes: Double)
    case custom((Double) -> Double)
    
    func transform(progress: Double) -> Double {
        switch self {

        case .linear:
            return progress

        case .easeInOut:
            return 0.5 * (1 - cos(progress * .pi))

        case .clampToUnitInterval:
            return min(1, max(0, progress))

        case .oscillate(let numberOfTimes):
            return 0.5 * (1 - cos(progress * 2 * numberOfTimes * .pi))
            
        case .custom(let customTransform):
            return customTransform(progress)
        }
    }
}
