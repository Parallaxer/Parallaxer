import RxSwift
import RxCocoa

/// A conforming type may be transformed by the parallax transformation operations.
public protocol ParallaxTransformable {

    /// The type of value that is changing.
    associatedtype ValueType: Parallaxable

    /// The interval over which change is expected to occur. Values are relative to this interval.
    var interval: ParallaxInterval<ValueType> { get }

    /// The current position on `interval`, represented as a value on, but not necessarily bounded by, the
    /// unit interval [0, 1].
    var unitPosition: Double { get }
}

extension ParallaxTransformable {

    /// A value relative to the unit position on the interval.
    var valueOverInterval: ValueType {
        return interval.value(atPosition: unitPosition)
    }
}

/// The result of a parallax transformation, which itself is transformable.
public struct ParallaxTransform<ValueType: Parallaxable>: ParallaxTransformable {

    public let interval: ParallaxInterval<ValueType>
    public let unitPosition: Double
}

// MARK: Create an initial parallax transform

extension ObservableType where E: Parallaxable {

    /// Define a parallax transform, with a position relative to the received value on the given `interval`.
    ///
    /// A parallax transform is the result of one or more parallax transformations, which can be performed
    /// using any of the following operators:
    ///   - `parallaxScale(toInterval:)`
    ///   - `parallaxCurve(_ curve:)`
    ///   - `parallaxFocus(subinterval:)`
    ///
    /// After a parallax transform, or chain of transforms, is defined, it can be converted back into a value
    /// suitable for the user interface with the following operator:
    ///   - `toParallaxValue()`
    ///
    /// - Parameter interval: An interval over which change is expected to occur.
    /// - Returns: A parallax transform over the given `interval`.
    public func toParallaxTransform(over interval: ParallaxInterval<E>) -> Observable<ParallaxTransform<E>> {
        return map { value in
            let position = interval.position(forValue: value)
            return ParallaxTransform(interval: interval, unitPosition: position)
        }
    }
}

// MARK: Apply parallax transformations

extension ObservableType where E: ParallaxTransformable {

    /// Scale a value relative to the difference between the prior transform interval and the given
    /// `otherInterval`.
    ///
    /// The resulting transform has the following characteristics:
    ///   - The interval is now `otherInterval`.
    ///   - The unit position is preserved.
    ///   - The parallax value is scaled relative to the difference between the prior transform interval and
    ///     the given `otherInterval`.
    ///
    /// Note: `otherInterval`'s value type can differ from that of the prior transform interval.
    ///
    /// ```
    /// Prior transform:
    ///         [0           3]           prior interval: [0, 3]
    ///  -.5     0    .5     1   1.5      prior position: 1
    ///    0     1     2    (3)    4      prior values
    ///
    /// After Scale([0, 4):
    ///         [0                 4]     new interval: [0, 4]
    ///  -.5     0  .25  .5   .75  1      new position: 1 (unchanged)
    ///    0     1     2     3    (4)     new values
    /// ```
    ///
    /// Example - Map values from the Double-typed interval, `[0, 3]`, to the CGFloat-typed interval `[0, 6]`:
    ///   ```
    ///   Observable.from([-1, 0, 1, 2, 3, 4])
    ///       .toParallaxTransform(over: ParallaxInterval<Double>(from: 0, to: 3))
    ///       .parallaxScale(toInterval: ParallaxInterval<CGFloat>(from: 0, to: 6))
    ///       .toParallaxValue()
    ///       // signals: -2, 0, 2, 4, 6, 8
    ///   ```
    /// - Parameter otherInterval: The interval to which values shall map from the prior interval.
    /// - Returns: A parallax transform, with values transformed to `otherInterval`.
    public func parallaxScale<OtherValueType>(to otherInterval: ParallaxInterval<OtherValueType>)
        -> Observable<ParallaxTransform<OtherValueType>>
    {
        return map { value in
            return ParallaxTransform<OtherValueType>(
                interval: otherInterval,
                unitPosition: value.unitPosition)
        }
    }

    /// Apply a given `curve` to the prior transform, changing its position in accordance with the curve.
    ///
    /// The resulting transform has the following characteristics:
    ///   - The interval is preserved.
    ///   - The unit position is changed in accordance with the curve function.
    ///   - The parallax value may shift up or down, relative to the prior transform, due to the change in
    ///     unit position.
    ///
    /// ```
    /// Prior transform:
    ///        [1           3]           prior interval: [1, 3]
    /// -.5     0    .5     1   1.5      prior position: 1.5
    ///   0     1     2     3    (4)     prior value: 4
    ///
    /// After Curve(.clampToUnitInterval):
    ///        [1           3]           new interval: [1, 3] (unchanged)
    /// -.5    [0    .5     1]  1.5      new position: 1
    ///   0    [1     2    (3)]   4      new value: 3
    /// ```
    ///
    /// Example 1 - Clamp values to the interval, `[0, 3]`:
    ///   ```
    ///   Observable.from([-2, -1, 0, 1, 2, 3, 4, 5])
    ///       .toParallaxTransform(over: ParallaxInterval(from: 0, to: 3))
    ///       .parallaxCurve(.clampToUnitInterval)
    ///       .toParallaxValue()
    ///       // signals: 0, 0, 0, 1, 2, 3, 3, 3
    ///   ```
    /// - Parameter curve: The curve with which to transform position.
    /// - Returns: A parallax transform, with position transformed by `curve`.
    public func parallaxCurve(_ curve: ParallaxCurve) -> Observable<ParallaxTransform<E.ValueType>> {
        return map { value in
            let transformedPosition = curve.transform(position: value.unitPosition)
            return ParallaxTransform(interval: value.interval, unitPosition: transformedPosition)
        }
    }

    /// Select a subset of the prior transform interval, specified by `subinterval`, over which future
    /// transformations shall occur.
    ///
    /// The resulting transform has the following characteristics:
    ///   - The interval is changed to `subinterval`.
    ///   - The unit position is changed such that the parallax value is preserved.
    ///   - The parallax value is preserved.
    ///
    /// Note: `subinterval` need not necessarily be a strict subset of the prior interval.
    ///
    /// ```
    /// Prior transform:
    ///   [0                       4]   prior interval: [0, 4]
    ///   [0    .25   .5    .75    1]   prior position: .25
    ///    0    (1)    2     3     4    prior value: 1
    ///
    /// After Select([2, 4]):
    ///               [2           4]   `subinterval`: [2, 4]
    ///   -1   -.5     0    .5     1    new position: -.5
    ///    0    (1)    2     3     4    new value: 1 (unchanged)
    /// ```
    /// - Parameter subinterval: A subset of the prior transform interval.
    /// - Returns: A parallax transform with each value on the prior interval mapped to the same value on
    ///            the given `subinterval`.
    public func parallaxSelect(subinterval: ParallaxInterval<E.ValueType>)
        -> Observable<ParallaxTransform<E.ValueType>> {
            return map { value in
                let valueOnOldInterval = value.interval.value(atPosition: value.unitPosition)
                let transformedPosition = subinterval.position(forValue: valueOnOldInterval)
                return ParallaxTransform(interval: subinterval, unitPosition: transformedPosition)
            }
    }
}

// MARK: Convert a parallax transform into a value

extension ObservableType where E: ParallaxTransformable {

    /// Determine the value of a prior parallax transformation; this value is intended for the user interface.
    ///
    /// - Returns: A value on the prior transform interval, suitable for the user interface.
    public func toParallaxValue() -> Observable<E.ValueType> {
        return map { value in
            return value.valueOverInterval
        }
    }
}
