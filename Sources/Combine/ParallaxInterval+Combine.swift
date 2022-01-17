import Combine

extension Publisher {
    public static func interval<ValueType>(
        from: AnyPublisher<ValueType, Never>,
        to: AnyPublisher<ValueType, Never>)
    -> AnyPublisher<ParallaxInterval<ValueType>, ParallaxError>
    where Output == ParallaxInterval<ValueType>, Failure == ParallaxError
    {
        return from
            .combineLatest(to)
            .tryMap { from, to in
                return try ParallaxInterval<ValueType>(from: from, to: to)
            }
            .mapError { $0 as! ParallaxError }
            .eraseToAnyPublisher()
    }
    
    public static func interval<ValueType>(
        from: ValueType,
        to: ValueType)
    -> AnyPublisher<ParallaxInterval<ValueType>, ParallaxError>
    where Output == ParallaxInterval<ValueType>, Failure == ParallaxError
    {
        let from = Just(from).eraseToAnyPublisher()
        let to = Just(to).eraseToAnyPublisher()
        return interval(from: from, to: to)
    }
}
