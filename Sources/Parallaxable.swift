/**
 Types which conform to `Parallaxable` may represent values in a parallax tree.
 */
public protocol Parallaxable: Hashable {
    
    /**
     Convert `value`, specified over [`from`, `to`], to progress over the unit interval [0, 1].
     */
    static func progress(forValue value: Self, from: Self, to: Self) -> Double

    /**
     Convert `progress`, specified over the unit interval [0, 1], to a value over the interval [`from`, `to`].
     */
    static func value(forProgress progress: Double, from: Self, to: Self) -> Self
}
