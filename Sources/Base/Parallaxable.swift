/// Types which conform to `Parallaxable` may represent values in a parallax progression.
public protocol Parallaxable: Hashable {
    
    /// Convert the given `value` to a unit position on the interval [`from`, `to`].
    ///
    /// - Parameters:
    ///   - value:  A value on the specified interval, [`from`, `to`].
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    /// - Returns: A position on the unit interval, [0, 1].
    static func unitPosition(forValue value: Self, from: Self, to: Self) -> Double
    
    /// Convert the given `unitPosition` to a value on the interval [`from`, `to`].
    ///
    /// - Parameters:
    ///   - unitPosition:   A position on the unit interval, [0, 1].
    ///   - from:           The start of the interval.
    ///   - to:             The end of the interval.
    /// - Returns: A value on the specified interval, [`from`, `to`].
    static func value(atUnitPosition unitPosition: Double, from: Self, to: Self) -> Self
}
