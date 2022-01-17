import Combine

extension Publisher  {
    public func parallaxValue<ValueType>()
    -> AnyPublisher<ValueType, Failure>
    where Output == ParallaxTransform<ValueType>, Failure == ParallaxError
    {
        return self
            .map { transform in
                return transform.parallaxValue()
            }
            .eraseToAnyPublisher()
    }
    
    public func parallaxRelate<ValueType, ResultValueType>(
        to newInterval: AnyPublisher<ParallaxInterval<ResultValueType>, Failure>)
    -> AnyPublisher<ParallaxTransform<ResultValueType>, Failure>
    where Output == ParallaxTransform<ValueType>, Failure == ParallaxError
    {
        return self
            .combineLatest(newInterval)
            .map { transform, newInterval in
                return transform.relate(to: newInterval)
            }
            .eraseToAnyPublisher()
    }
    
    public func parallaxMorph<ValueType>(
        with curve: AnyPublisher<PositionCurve, Never>)
    -> AnyPublisher<Output, Failure>
    where Output == ParallaxTransform<ValueType>, Failure == ParallaxError
    {
        let curve = curve.setFailureType(to: ParallaxError.self)
        return self
            .combineLatest(curve)
            .map { transform, curve in
                return transform.morph(with: curve)
            }
            .eraseToAnyPublisher()
    }
    
    public func parallaxFocus<ValueType>(
        on subinterval: AnyPublisher<ParallaxInterval<ValueType>, Failure>)
    -> AnyPublisher<Output, Failure>
    where Output == ParallaxTransform<ValueType>, Failure == ParallaxError
    {
        return self
            .combineLatest(subinterval)
            .map { transform, subinterval in
                return transform.focus(on: subinterval)
            }
            .eraseToAnyPublisher()
    }
}
