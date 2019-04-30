import RxSwift
import RxCocoa

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
    ///   - `parallaxMap(toInterval:)`
    ///   - `parallaxCurve(_ curve:)`
    ///   - `parallaxFocus(subinterval:)`
    ///
    /// After defining a parallax transform, it can be converted back into a value suitable for the user
    /// interface with the following operator:
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

    /// Transform values from the prior transform interval to the given `otherInterval`.
    ///
    /// Note: This operator shall preserve the position of a prior transform. Thus, values at the *beginning*
    /// of the prior transform interval shall map to values at the *beginning* of `otherInterval`, values at
    /// the *center* of the prior transform interval shall map to values at the *center* of `otherInterval`,
    /// etc.
    ///
    /// Note: This operator shall transform the interval of a prior transform.
    ///
    /// Note: `otherInterval`'s value type can differ from that of the prior transform interval.
    ///
    /// ```
    /// Prior transform:
    ///       [0           3]           prior interval: [0, 3]
    ///  -50%  0%  50%  100%   150%     prior progression
    ///                    ^            prior position: 100%
    ///  0     1     2     3     4      prior values
    ///
    /// After Map([0, 4):
    ///       [0                 4]     new interval: [0, 4]
    /// -50%   0%  25% 50% 75% 100%     new progression
    ///                          ^      new position: 100% (unchanged)
    ///  0     1     2     3     4      new values
    /// ```
    ///
    /// Example - Map values from the Double-typed interval, `[0, 3]`, to the CGFloat-typed interval `[0, 6]`:
    ///   ```
    ///   Observable.from([-1, 0, 1, 2, 3, 4])
    ///       .parallaxProgression(over: ParallaxInterval<Double>(from: 0, to: 3))
    ///       .parallaxMap(toInterval: ParallaxInterval<CGFloat>(from: 0, to: 6))
    ///       .parallaxValue()
    ///       // signals: -2, 0, 2, 4, 6, 8
    ///   ```
    /// - Parameter otherInterval: The interval to which values shall map from the prior interval.
    /// - Returns: A parallax transform, with values transformed to `otherInterval`.
    public func parallaxMap<OtherValueType>(toInterval otherInterval: ParallaxInterval<OtherValueType>)
        -> Observable<ParallaxTransform<OtherValueType>>
    {
        return map { value in
            return ParallaxTransform<OtherValueType>(interval: otherInterval, unitPosition: value.unitPosition)
        }
    }

    /// Transform position from a prior transform using the given `curve`.
    ///
    /// Note: This operator shall transform the position of a prior transform.
    ///
    /// Note: This operator shall preserve the interval of a prior transform.
    ///
    /// ```
    /// Prior transform:
    ///       [1           3]           prior interval: [1, 3]
    /// -50%   0%  50%  100%    150%    prior position: 150%
    ///                          ^
    ///  0     1     2     3     4      prior value: 4
    ///
    /// After Curve(.clampToUnitInterval):
    ///       [1           3]           new interval: [1, 3] (unchanged)
    /// -50%  [0%  50%  100%]   150%    new position: 100%
    ///                    ^
    ///  0     1     2     3     4      new value: 3
    /// ```
    ///
    /// Example 1 - Clamp values to the interval, `[0, 3]`:
    ///   ```
    ///   Observable.from([-2, -1, 0, 1, 2, 3, 4, 5])
    ///       .parallaxProgression(over: ParallaxInterval(from: 0, to: 3))
    ///       .parallaxCurve(.clampToUnitInterval)
    ///       .parallaxValue()
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

    /// Transform a position on the given `subinterval`, a subset of the prior transform interval, such that a
    /// value on the prior transform interval maps to the same value on `subinterval`.
    ///
    /// Note: This operator shall transform both the position and interval of a prior transform.
    ///
    /// Note: `subinterval` need not necessarily be a strict subset of the prior interval; indeed some
    /// interesting effects can be created with a superset as well.
    ///
    /// ```
    /// Prior transform:
    /// [0                       4]     prior interval: [0, 4]
    /// [0%   25%   50%   75%   100%]   prior position: 25%
    ///        ^
    ///  0     1     2     3     4      prior value: 1
    ///
    /// After Focus([2, 4]):
    ///             [2           4]     `subinterval`: [2, 4]
    /// -100% -50%   0%   50%   100%    new position: -50%
    ///        ^
    ///  0     1     2     3     4      new value: 1 (unchanged)
    /// ```
    ///
    /// - Parameter subinterval: A subset of the prior transform interval.
    /// - Returns: A parallax transform with each value on the prior interval mapped to the same value on
    ///            the given `subinterval`.
    public func parallaxFocus(subinterval: ParallaxInterval<E.ValueType>)
        -> Observable<ParallaxTransform<E.ValueType>> {
            return map { value in
                let valueOnOldInterval = value.interval.value(atPosition: value.unitPosition)
                let transformedProgress = subinterval.position(forValue: valueOnOldInterval)
                return ParallaxTransform(interval: subinterval, unitPosition: transformedProgress)
            }
    }
}

// MARK: Convert a parallax transform into a value

extension ObservableType where E: ParallaxTransformable {

    /// Convert a prior transform into a value on the prior transform interval; this value is intended for the
    /// user interface.
    ///
    /// - Returns: A value on the prior transform interval, suitable for the user interface.
    public func toParallaxValue() -> Observable<E.ValueType> {
        return map { value in
            return value.valueOverInterval
        }
    }
}
