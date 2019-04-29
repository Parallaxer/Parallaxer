import RxSwift
import RxCocoa

public protocol ParallaxTransformable {

    /// The type of value that is changing.
    associatedtype ValueType: Parallaxable

    /// The interval over which change is expected to occur. Values are relative to this interval.
    var interval: ParallaxInterval<ValueType> { get }

    /// Current position over `interval`, represented as a value along, but not necessarily bounded by, the
    /// unit interval [0, 1].
    var position: Double { get }
}

extension ParallaxTransformable {

    /// A value relative to the position over the interval.
    var valueOverInterval: ValueType {
        return interval.value(atPosition: position)
    }
}

public struct ParallaxProgression<ValueType: Parallaxable>: ParallaxTransformable {

    public let interval: ParallaxInterval<ValueType>
    public let position: Double
}

extension ObservableType where E: Parallaxable {

    /// Transform a parallaxable value into a parallax progression, with position determined by the value
    /// along the given `interval`; this is the first step toward defining a parallax transformation.
    ///
    /// - Parameter interval: An interval over which change is expected to occur.
    /// - Returns: A parallax progression over the given `interval`.
    public func toParallaxProgression(over interval: ParallaxInterval<E>)
        -> Observable<ParallaxProgression<E>>
    {
        return map { value in
            let position = interval.position(forValue: value)
            return ParallaxProgression(interval: interval, position: position)
        }
    }
}

extension ObservableType where E: ParallaxTransformable {

    /// Transform values from the prior progression interval to the given `otherInterval`.
    ///
    /// Note: This operator shall preserve the position of a parallax progression. Thus, values at the
    /// *beginning* of the prior interval shall map to values at the *beginning* of `otherInterval`, values at
    /// the *center* of the prior interval shall map to values at the *center* of `otherInterval`, etc.
    ///
    /// Note: This operator shall transform the interval of a parallax progression.
    ///
    /// Note: `otherInterval`'s value type can differ from that of the prior interval.
    ///
    /// ```
    /// Before Map:
    ///       [0           3]           prior interval: [0, 3]
    ///  -50%  0%  50%  100%   150%     prior progression
    ///                    ^            prior position: 100%
    ///  0     1     2     3     4      prior values
    ///
    /// After Map([0, 4):
    ///       [0                 4]     new interval: [0, 4]
    /// -50%   0% 25% 50% 75% 100%      new progression
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
    /// - Returns: A parallax progression, with values transformed to `otherInterval`.
    public func parallaxMap<OtherValueType>(toInterval otherInterval: ParallaxInterval<OtherValueType>)
        -> Observable<ParallaxProgression<OtherValueType>>
    {
        return map { value in
            return ParallaxProgression<OtherValueType>(interval: otherInterval, position: value.position)
        }
    }

    /// Transform position from a prior progression using the given `curve`.
    ///
    /// Note: This operator shall transform the position of a parallax progression.
    ///
    /// Note: This operator shall preserve the interval of a parallax progression.
    ///
    /// ```
    /// Before Curve:
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
    /// - Returns: A parallax progression, with position transformed by `curve`.
    public func parallaxCurve(_ curve: ParallaxCurve) -> Observable<ParallaxProgression<E.ValueType>> {
        return map { value in
            let transformedPosition = curve.transform(position: value.position)
            return ParallaxProgression(interval: value.interval, position: transformedPosition)
        }
    }

    /// Transform position over the given `subinterval`, a subset of the prior progression interval, such that
    /// a value on the prior interval maps to the same value on `subinterval`.
    ///
    /// Note: This operator shall transform both the position and interval of a parallax progression.
    ///
    /// Note: `subinterval` need not necessarily be a strict subset of the prior interval; indeed some
    /// interesting effects can be created with a superset as well.
    ///
    /// ```
    /// Before Filter:
    /// [0                       4]     prior interval: [0, 4]
    /// [0%   25%   50%   75%   100%]   prior position: 25%
    ///        ^
    ///  0     1     2     3     4      prior value: 1
    ///
    /// After Filter([2, 4]):
    ///             [2           4]     `subinterval`: [2, 4]
    /// -100% -50%   0%   50%   100%    new position: -50%
    ///        ^
    ///  0     1     2     3     4      new value: 1 (unchanged)
    /// ```
    ///
    /// - Parameter subinterval: A subset of the prior progression interval.
    /// - Returns: A parallax progression with each value from the prior interval mapped to the same value on
    ///            the given `subinterval`.
    public func parallaxFocus(subinterval: ParallaxInterval<E.ValueType>)
        -> Observable<ParallaxProgression<E.ValueType>> {
            return map { value in
                let valueOnOldInterval = value.interval.value(atPosition: value.position)
                let transformedProgress = subinterval.position(forValue: valueOnOldInterval)
                return ParallaxProgression(interval: subinterval, position: transformedProgress)
            }
    }

    /// Convert the parallax progression into a value over the prior interval; this value is intended for the
    /// user interface.
    ///
    /// - Returns: A value over the prior interval, suitable for the user interface.
    public func toParallaxValue() -> Observable<E.ValueType> {
        return map { value in
            return value.valueOverInterval
        }
    }
}
