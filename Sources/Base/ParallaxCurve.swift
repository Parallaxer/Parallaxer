import Foundation

/// Specifies how a position is transformed. A position is specified on the unit interval, [0, 1], and may
/// exist outside of that boundary.
///
/// - linear:               Position remains the same.
/// - easeInOut:            Position is slow at the beginning and end of the interval.
/// - clampToUnitInterval:  Position is clamped to the unit interval, [0, 1].
/// - oscillate:            Position oscillates over the interval, up to `numberOfTimes`.
/// - custom:               The position transformation may be customized with a closure.
public enum ParallaxCurve {

    case linear
    case easeInOut
    case clampToUnitInterval
    case oscillate(numberOfTimes: Double)
    case custom((Double) -> Double)
    
    func transform(position: Double) -> Double {
        switch self {

        case .linear:
            return position

        case .easeInOut:
            return 0.5 * (1 - cos(position * .pi))

        case .clampToUnitInterval:
            return min(1, max(0, position))

        case .oscillate(let numberOfTimes):
            return 0.5 * (1 - cos(position * 2 * numberOfTimes * .pi))
            
        case .custom(let customTransform):
            return customTransform(position)
        }
    }
}
