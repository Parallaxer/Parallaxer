/// Types which conform to `Parallaxable` may represent values in a parallax progression.
public protocol Parallaxable: Hashable {
    
    /// Convert the given `value` on the specified interval to a position on the unit interval.
    ///
    /// - Parameters:
    ///   - value:  A value over the specified interval, [`from`, `to`].
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    /// - Returns: A position over the unit interval, [0, 1].
    static func position(forValue value: Self, from: Self, to: Self) -> Double
    
    /// Convert the given `position` on the unit interval to a value on the specified interval.
    ///
    /// - Parameters:
    ///   - position:   A position on the unit interval, [0, 1].
    ///   - from:       The start of the interval.
    ///   - to:         The end of the interval.
    /// - Returns: A value over the specified interval, [`from`, `to`].
    static func value(atPosition position: Double, from: Self, to: Self) -> Self
}
