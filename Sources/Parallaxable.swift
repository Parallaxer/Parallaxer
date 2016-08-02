/**
 Types which conform to `Parallaxable` may represent values in a parallax tree.
 */
public protocol Parallaxable: Hashable {
    
    /**
     Convert a value over the specified interval to progress over the unit interval.
     
     - parameter value: A value over the specified interval, [`from`, `to`].
     - parameter from:  The start of the interval.
     - parameter to:    The end of the interval.
     
     - returns: Progress over the unit interval, [0, 1].
     */
    static func progress(forValue value: Self, from: Self, to: Self) -> Double

    /**
     Convert progress over the unit interval to a value over the specified interval.
     
     - parameter progress:  Progress over the unit interval, [0, 1].
     - parameter from:      The start of the interval.
     - parameter to:        The end of the interval.
     
     - returns: Value over the specified interval, [`from`, `to`].
     */
    static func value(forProgress progress: Double, from: Self, to: Self) -> Self
}
