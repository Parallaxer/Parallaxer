import Foundation

/// Specifies how a position changes. A position is specified on the unit interval,
/// [0, 1], but it may be less than 0 or greater than 1.
public enum PositionCurve {

    /// Position changes slowly at the beginning and at the end of the interval.
    case easeInOut

    /// Position is clamped to the unit interval, [0, 1].
    case clampToUnitInterval

    /// Position oscillates over the interval, up to `numberOfTimes`.
    case oscillate(numberOfTimes: Double)

    /// The position may be customized with a closure.
    case custom((Double) -> Double)
    
    func transform(position: Double) -> Double {
        switch self {

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
